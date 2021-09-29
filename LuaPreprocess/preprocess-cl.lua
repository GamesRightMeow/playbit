#!/bin/sh
_=[[
exec lua "$0" "$@"
]]
--[[============================================================
--=
--=  LuaPreprocess command line program
--=  by Marcus 'ReFreezed' Thunström
--=
--=  Requires preprocess.lua to be in the same folder!
--=
--=  License: MIT (see the bottom of this file)
--=  Website: http://luapreprocess.refreezed.com/
--=
--=  Tested with Lua 5.1, 5.2, 5.3 and 5.4.
--=
--==============================================================

	Script usage:
		lua preprocess-cl.lua               [options] [--] filepath1 [filepath2 ...]
		OR
		lua preprocess-cl.lua --outputpaths [options] [--] inputpath1 outputpath1 [inputpath2 outputpath2 ...]

	Examples:
		lua preprocess-cl.lua --saveinfo=logs/info.lua --silent src/main.lua2p src/network.lua2p
		lua preprocess-cl.lua --debug src/main.lua2p src/network.lua2p
		lua preprocess-cl.lua --outputpaths --linenumbers src/main.lua2p output/main.lua src/network.lua2p output/network.lua

	Options:
		--backtickstrings
			Enable the backtick (`) to be used as string literal delimiters.
			Backtick strings don't interpret any escape sequences and can't
			contain other backticks.

		--data|-d="Any data."
			A string with any data. If this option is present then the value
			will be available through the global 'dataFromCommandLine' in the
			processed files (and any message handler). Otherwise,
			'dataFromCommandLine' is nil.

		--faststrings
			Force fast serialization of string values. (Non-ASCII characters
			will look ugly.)

		--handler|-h=pathToMessageHandler
			Path to a Lua file that's expected to return a function or a
			table of functions. If it returns a function then it will be
			called with various messages as it's first argument. If it's
			a table, the keys should be the message names and the values
			should be functions to handle the respective message.
			(See 'Handler messages' and tests/testHandler.lua)
			The file shares the same environment as the processed files.

		--jitsyntax
			Allow LuaJIT-specific syntax, specifically literals for 64-bit
			integers and complex numbers.
			(https://luajit.org/ext_ffi_api.html#literals)

		--linenumbers
			Add comments with line numbers to the output.

		--meta
			Output the metaprogram to a temporary file (*.meta.lua). Useful if
			an error happens when the metaprogram runs. This file is removed
			if there's no error and --debug isn't enabled.

		--nogc
			Stop the garbage collector. This may speed up the preprocessing.

		--nonil
			Disallow !(...) and outputValue(...) from outputting nil.

		--novalidate
			Disable validation of outputted Lua.

		--outputextension=fileExtension
			Specify what file extension generated files should have. The
			default is "lua". If any input files end in .lua then you must
			specify another file extension with this option. (It's suggested
			that you use .lua2p (as in "Lua To Process") as extension for
			unprocessed files.)

		--outputpaths|-o
			This flag makes every other specified path be the output path
			for the previous path.

		--saveinfo|-i=pathToSaveProcessingInfoTo
			Processing information includes what files had any preprocessor
			code in them, and things like that. The format of the file is a
			lua module that returns a table. Search this file for 'SavedInfo'
			to see what information is saved.

		--silent
			Only print errors to the console.

		--debug
			Enable some preprocessing debug features. Useful if you want
			to inspect the generated metaprogram (*.meta.lua). (This also
			enables the --meta option.)

		--
			Stop options from being parsed further. Needed if you have
			paths starting with "-".

----------------------------------------------------------------

	Handler messages:

	"init"
		Sent before any other message.
		Arguments:
			inputPaths: Array of file paths to process. Paths can be added or removed freely.
			outputPaths: If the --outputpaths option is present this is an array of output paths for the respective path in inputPaths, otherwise it's nil.

	"insert"
		Sent for each @insert"name" statement. The handler is expected to return a Lua code string.
		Arguments:
			path: The file being processed.
			name: The name of the resource to be inserted (could be a file path or anything).

	"beforemeta"
		Sent before a file's metaprogram runs.
		Arguments:
			path: The file being processed.

	"aftermeta"
		Sent after a file's metaprogram has produced output (before the output is written to a file).
		Arguments:
			path: The file being processed.
			luaString: The produced Lua code. You can modify this and return the modified string.

	"filedone"
		Sent after a file has finished processing and the output written to file.
		Arguments:
			path: The file being processed.
			outputPath: Where the output of the metaprogram was written.
			info: Info about the processed file. (See 'ProcessInfo' in preprocess.lua)

	"fileerror"
		Sent if an error happens while processing a file (right before the program exits).
		Arguments:
			path: The file being processed.
			error: The error message.

--============================================================]]

local startTime  = os.time()
local startClock = os.clock()

local args = arg

local major, minor = _VERSION:match"Lua (%d+)%.(%d+)"
if not major then
	io.stderr:write("[LuaPreprocess] Warning: Could not detect Lua version.\n") -- Note: This line does not obey the --silent option.
else
	major = tonumber(major)
	minor = tonumber(minor)
end
local IS_LUA_51          = (major == 5 and minor == 1)
local IS_LUA_52          = (major == 5 and minor == 2)
local IS_LUA_53          = (major == 5 and minor == 3)
local IS_LUA_51_OR_LATER = (major == 5 and minor >= 1) or (major ~= nil and major > 5)
local IS_LUA_52_OR_LATER = (major == 5 and minor >= 2) or (major ~= nil and major > 5)
local IS_LUA_53_OR_LATER = (major == 5 and minor >= 3) or (major ~= nil and major > 5)

if not args[0] then  error("Expected to run from the Lua interpreter.")  end
local pp = dofile((args[0]:gsub("[^/\\]+$", "preprocess.lua")))

-- From args:
local addLineNumbers       = false
local allowBacktickStrings = false
local allowJitSyntax       = false
local canOutputNil         = true
local customData           = nil
local fastStrings          = false
local hasOutputExtension   = false
local hasOutputPaths       = false
local isDebug              = false
local outputExtension      = "lua"
local outputMeta           = false
local processingInfoPath   = ""
local silent               = false
local validate             = true

--==============================================================
--= Local Functions ============================================
--==============================================================
local errorLine
local F, formatBytes, formatInt
local loadLuaFile
local printf, printfNoise, printError, printfError

F = string.format
function formatBytes(n)
	if     n >= 1024*1024*1024 then
		return F("%.2f GiB", n/(1024*1024*1024))
	elseif n >= 1024*1024 then
		return F("%.2f MiB", n/(1024*1024))
	elseif n >= 1024 then
		return F("%.2f KiB", n/(1024))
	elseif n == 1 then
		return F("1 byte", n)
	else
		return F("%d bytes", n)
	end
end
-- function formatInt(n)
-- 	return
-- 		F("%.0f", n)
-- 		:reverse()
-- 		:gsub("%d%d%d", "%0,")
-- 		:gsub(",$", ""):gsub(",%-$", "-")
-- 		:reverse()
-- end

function printf(s, ...)
	print(s:format(...))
end
printfNoise = printf

function printError(s)
	io.stderr:write(s, "\n")
end
function printfError(s, ...)
	io.stderr:write(s:format(...), "\n")
end

function errorLine(err)
	printError(pp.tryToFormatError(err))
	os.exit(1)
end

if IS_LUA_52_OR_LATER then
	function loadLuaFile(path, env)
		return loadfile(path, "bt", env)
	end
else
	function loadLuaFile(path, env)
		local mainChunk, err = loadfile(path)
		if not mainChunk then  return mainChunk, err  end

		if env then  setfenv(mainChunk, env)  end

		return mainChunk
	end
end

--==============================================================
--= Preprocessor Script ========================================
--==============================================================

io.stdout:setvbuf("no")
io.stderr:setvbuf("no")

math.randomseed(os.time()) -- In case math.random() is used anywhere.
math.random() -- Must kickstart...

local processOptions     = true
local messageHandlerPath = ""
local pathsIn            = {}
local pathsOut           = {}

for _, arg in ipairs(args) do
	if not (processOptions and arg:find"^%-") then
		local paths = (hasOutputPaths and #pathsOut < #pathsIn and pathsOut or pathsIn)
		table.insert(paths, arg)

	elseif arg == "--" then
		processOptions = false

	elseif arg:find"^%-%-data=" or arg:find"^%-d=" then
		customData = arg:match"^%-%-data=(.*)$" or arg:match"^%-d=(.*)$"

	elseif arg == "--backtickstrings" then
		allowBacktickStrings = true

	elseif arg == "--debug" then
		isDebug    = true
		outputMeta = true

	elseif arg:find"^%-%-handler=" or arg:find"^%-h=" then
		messageHandlerPath = arg:match"^%-%-handler=(.*)$" or arg:match"^%-h=(.*)$"

	elseif arg == "--jitsyntax" then
		allowJitSyntax = true

	elseif arg == "--linenumbers" then
		addLineNumbers = true

	elseif arg == "--meta" then
		outputMeta = true

	elseif arg == "--nonil" then
		canOutputNil = false

	elseif arg == "--novalidate" then
		validate = false

	elseif arg:find"^%-%-outputextension=" then
		if hasOutputPaths then
			errorLine("Cannot specify both --outputextension and --outputpaths")
		end
		hasOutputExtension = true
		outputExtension    = arg:match"^%-%-outputextension=(.*)$"

	elseif arg == "--outputpaths" or arg == "-o" then
		if hasOutputExtension then
			errorLine("Cannot specify both --outputpaths and --outputextension")
		elseif pathsIn[1] then
			errorLine(arg.." must appear before any path.")
		end
		hasOutputPaths = true

	elseif arg:find"^%-%-saveinfo=" or arg:find"^%-i=" then
		processingInfoPath = arg:match"^%-%-saveinfo=(.*)$" or arg:match"^%-i=(.*)$"

	elseif arg == "--silent" then
		silent = true

	elseif arg == "--faststrings" then
		fastStrings = true

	elseif arg == "--nogc" then
		collectgarbage("stop")

	else
		errorLine("Unknown option '"..arg:gsub("=.*", "").."'.")
	end
end

if silent then
	printfNoise = function()end
end

local header = "= LuaPreprocess v"..pp.VERSION..os.date(", %Y-%m-%d %H:%M:%S =", startTime)
printfNoise(("="):rep(#header))
printfNoise("%s", header)
printfNoise(("="):rep(#header))

if hasOutputPaths and #pathsOut < #pathsIn then
	errorLine("Missing output path for "..pathsIn[#pathsIn])
end



-- Prepare metaEnvironment.
pp.metaEnvironment.dataFromCommandLine = customData -- May be nil.



-- Load message handler.
local messageHandler = nil

local function hasMessageHandler(message)
	if not messageHandler then
		return false

	elseif type(messageHandler) == "function" then
		return true

	elseif type(messageHandler) == "table" then
		return messageHandler[message] ~= nil

	else
		assert(false)
	end
end

local function sendMessage(message, ...)
	if not messageHandler then
		return

	elseif type(messageHandler) == "function" then
		local returnValues = pp.pack(messageHandler(message, ...))
		return unpack(returnValues, 1, returnValues.n)

	elseif type(messageHandler) == "table" then
		local _messageHandler = messageHandler[message]
		if not _messageHandler then  return  end

		local returnValues = pp.pack(_messageHandler(...))
		return unpack(returnValues, 1, returnValues.n)

	else
		assert(false)
	end
end

if messageHandlerPath ~= "" then
	-- Make the message handler and the metaprogram share the same environment.
	-- This way the message handler can easily define globals that the metaprogram uses.
	local mainChunk, err = loadLuaFile(messageHandlerPath, pp.metaEnvironment)
	if not mainChunk then
		errorLine("Could not load message handler...\n"..pp.tryToFormatError(err))
	end

	messageHandler = mainChunk()

	if type(messageHandler) == "function" then
		-- void
	elseif type(messageHandler) == "table" then
		for message, _messageHandler in pairs(messageHandler) do
			if type(message) ~= "string" then
				errorLine(messageHandlerPath..": Table of handlers must only contain messages as keys.")
			elseif type(_messageHandler) ~= "function" then
				errorLine(messageHandlerPath..": Table of handlers must only contain functions as values.")
			end
		end
	else
		errorLine(messageHandlerPath..": File did not return a table or a function.")
	end
end



-- Init stuff.
sendMessage("init", pathsIn, (hasOutputPaths and pathsOut or nil))

if not hasOutputPaths then
	for i, pathIn in ipairs(pathsIn) do
		pathsOut[i] = pathIn:gsub("%.%w+$", "").."."..outputExtension
	end
end

if not pathsIn[1] then
	errorLine("No path(s) specified.")
elseif #pathsIn ~= #pathsOut then
	errorLine(F("Number of input and output paths differ. (%d in, %d out)", #pathsIn, #pathsOut))
end

local pathsSetIn  = {}
local pathsSetOut = {}
for i = 1, #pathsIn do
	if pathsSetIn [pathsIn [i]] then  errorLine("Duplicate input path: " ..pathsIn [i])  end
	if pathsSetOut[pathsOut[i]] then  errorLine("Duplicate output path: "..pathsOut[i])  end
	pathsSetIn [pathsIn [i]] = true
	pathsSetOut[pathsOut[i]] = true
	if pathsSetOut[pathsIn [i]] then  errorLine("Path is both input and output: "..pathsIn [i])  end
	if pathsSetIn [pathsOut[i]] then  errorLine("Path is both input and output: "..pathsOut[i])  end
end



-- Process files.

-- :SavedInfo
local processingInfo = {
	date  = os.date("%Y-%m-%d %H:%M:%S", startTime),
	files = {},
}

local byteCount     = 0
local lineCount     = 0
local lineCountCode = 0
local tokenCount    = 0

for i, pathIn in ipairs(pathsIn) do
	local startClockForPath = os.clock()
	printfNoise("Processing '%s'...", pathIn)

	local pathOut  = pathsOut[i]
	local pathMeta = pathOut:gsub("%.%w+$", "")..".meta.lua"

	if not outputMeta then
		pathMeta = nil
	end

	local info, err = pp.processFile{
		pathIn          = pathIn,
		pathMeta        = pathMeta,
		pathOut         = pathOut,

		debug           = isDebug,
		addLineNumbers  = addLineNumbers,

		backtickStrings = allowBacktickStrings,
		jitSyntax       = allowJitSyntax,
		canOutputNil    = canOutputNil,
		fastStrings     = fastStrings,
		validate        = validate,

		onInsert = (hasMessageHandler("insert") or nil) and function(name)
			local lua = sendMessage("insert", pathIn, name)

			-- onInsert() is expected to return a Lua code string and so is the message
			-- handler. However, if the handler is a single catch-all function we allow
			-- the message to not be handled and we fall back to the default behavior of
			-- treating 'name' as a path to a file to be inserted. If we didn't allow this
			-- then it would be required for the "insert" message to be handled. I think
			-- it's better if the user can choose whether to handle a message or not!
			--
			if lua == nil and type(messageHandler) == "function" then
				return assert(pp.getFileContents(name))
			end

			return lua
		end,

		onBeforeMeta = messageHandler and function()
			sendMessage("beforemeta", pathIn)
		end,

		onAfterMeta = messageHandler and function(lua)
			local luaModified = sendMessage("aftermeta", pathIn, lua)

			if type(luaModified) == "string" then
				lua = luaModified

			elseif luaModified ~= nil then
				error(F(
					"%s: Message handler did not return a string for 'aftermeta'. (Got %s)",
					messageHandlerPath, type(luaModified)
				))
			end

			return lua
		end,

		onDone = messageHandler and function(info)
			sendMessage("filedone", pathIn, pathOut, info)
		end,

		onError = function(err)
			xpcall(function()
				sendMessage("fileerror", pathIn, err)
			end, function(err)
				printfError("Additional error in 'fileerror' message handler...\n%s", pp.tryToFormatError(err))
			end)
			os.exit(1)
		end,
	}
	assert(info, err) -- The onError() handler above should have been called and we should have exited already.

	byteCount     = byteCount     + info.processedByteCount
	lineCount     = lineCount     + info.lineCount
	lineCountCode = lineCountCode + info.linesOfCode
	tokenCount    = tokenCount    + info.tokenCount

	if processingInfoPath ~= "" then

		-- :SavedInfo
		table.insert(processingInfo.files, info) -- See 'ProcessInfo' in preprocess.lua for what more 'info' contains.

	end

	printfNoise("Processing '%s' successful! (%.3fs)", pathIn, os.clock()-startClockForPath)
	printfNoise(("-"):rep(#header))
end



-- Finalize stuff.
if processingInfoPath ~= "" then
	printfNoise("Saving processing info to '%s'.", processingInfoPath)

	local luaParts = {"return"}
	assert(pp.serialize(luaParts, processingInfo))
	local lua = table.concat(luaParts)

	local file = assert(io.open(processingInfoPath, "wb"))
	file:write(lua)
	file:close()
end

printfNoise(
	"All done! (%.3fs, %.0f file%s, %.0f LOC, %.0f line%s, %.0f token%s, %s)",
	os.clock()-startClock,
	#pathsIn,   #pathsIn   == 1 and "" or "s",
	lineCountCode,
	lineCount,  lineCount  == 1 and "" or "s",
	tokenCount, tokenCount == 1 and "" or "s",
	formatBytes(byteCount)
)



--[[!===========================================================

Copyright © 2018-2021 Marcus 'ReFreezed' Thunström

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

==============================================================]]
