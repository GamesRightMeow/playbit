--[[============================================================
--=
--=  LuaPreprocess library
--=  by Marcus 'ReFreezed' Thunström
--=
--=  License: MIT (see the bottom of this file)
--=  Website: http://luapreprocess.refreezed.com/
--=  Documentation: http://luapreprocess.refreezed.com/docs/
--=
--=  Tested with Lua 5.1, 5.2, 5.3 and 5.4.
--=
--==============================================================

	API:

	Global functions in metaprograms:
	- copyTable
	- escapePattern
	- getFileContents, fileExists
	- pack
	- printf
	- run
	- tokenize, newToken, concatTokens, removeUselessTokens, eachToken, isToken, getNextUsefulToken
	- toLua, serialize
	Only during processing:
	- getCurrentPathIn, getCurrentPathOut
	- getOutputSoFar, getOutputSizeSoFar, getCurrentLineNumberInOutput
	- outputValue, outputLua, outputLuaTemplate
	Search this file for 'EnvironmentTable' for more info.

	Exported stuff from the library:
	- (all the functions above)
	- VERSION
	- metaEnvironment
	- processFile, processString
	Search this file for 'ExportTable' for more info.

----------------------------------------------------------------

	How to metaprogram:

	The exclamation mark (!) is used to indicate what code is part of
	the metaprogram. There are 4 main ways to write metaprogram code:

	!...     The line will simply run during preprocessing. The line can span multiple actual lines if it contains brackets.
	!!...    The line will appear in both the metaprogram and the final program. The line must be an assignment.
	!(...)   The result of the parenthesis will be outputted as a literal if it's an expression, otherwise it'll just run.
	!!(...)  The result of the expression in the parenthesis will be outputted as Lua code. The result must be a string.

	Short examples:

	!if not isDeveloper then
		sendTelemetry()
	!end

	!!local tau = 2*math.pi -- The expression will be evaluated in the metaprogram and the result will appear in the final program as a literal.

	local bigNumber = !(5^10)

	local font = !!(isDeveloper and "loadDevFont()" or "loadUserFont()")

	-- See the full documentation for additional features:
	-- http://luapreprocess.refreezed.com/docs/extra-functionality/

----------------------------------------------------------------

	-- Example program:

	-- Normal Lua.
	local n = 0
	doTheThing()

	-- Preprocessor lines.
	local n = 0
	!if math.random() < 0.5 then
		n = n+10 -- Normal Lua.
		-- Note: In the final program, this will be in the
		-- same scope as 'local n = 0' here above.
	!end

	!for i = 1, 3 do
		print("3 lines with print().")
	!end

	-- Extended preprocessor line. (Lines are consumed until brackets
	-- are balanced when the end of the line has been reached.)
	!newClass{ -- Starts here.
		name  = "Entity",
		props = {x=0, y=0},
	} -- Ends here.

	-- Preprocessor block.
	!(
	local dogWord = "Woof "
	function getDogText()
		return dogWord:rep(3)
	end
	)

	-- Preprocessor inline block. (Expression that returns a value.)
	local text = !("The dog said: "..getDogText())

	-- Preprocessor inline block variant. (Expression that returns a Lua code string.)
	_G.!!("myRandomGlobal"..math.random(5)) = 99

	-- Dual code (both preprocessor line and final output).
	!!local partial = "Hello"
	local   whole   = partial .. !(partial..", world!")
	print(whole) -- HelloHello, world!

	-- Beware in preprocessor blocks that only call a single function!
	!( func()  ) -- This will bee seen as an inline block and output whatever value func() returns as a literal.
	!( func(); ) -- If that's not wanted then a trailing `;` will prevent that. This line won't output anything by itself.
	-- When the full metaprogram is generated, `!(func())` translates into `outputValue(func())`
	-- while `!(func();)` simply translates into `func();` (because `outputValue(func();)` would be invalid Lua code).
	-- Though in this specific case a preprocessor line (without the parenthesis) would be nicer:
	!func()

	-- For the full documentation, see:
	-- http://luapreprocess.refreezed.com/docs/

--============================================================]]



local PP_VERSION = "1.15.0"

local MAX_DUPLICATE_FILE_INSERTS = 1000 -- @Incomplete: Make this a parameter for processFile()/processString().

local KEYWORDS = {
	"and","break","do","else","elseif","end","false","for","function","if","in",
	"local","nil","not","or","repeat","return","then","true","until","while",
	-- Lua 5.2
	"goto",
} for i, v in ipairs(KEYWORDS) do  KEYWORDS[v], KEYWORDS[i] = true, nil  end

local PREPROCESSOR_KEYWORDS = {
	"file","insert","line",
} for i, v in ipairs(PREPROCESSOR_KEYWORDS) do  PREPROCESSOR_KEYWORDS[v], PREPROCESSOR_KEYWORDS[i] = true, nil  end

local PUNCTUATION = {
	"+",  "-",  "*",  "/",  "%",  "^",  "#",
	"==", "~=", "<=", ">=", "<",  ">",  "=",
	"(",  ")",  "{",  "}",  "[",  "]",
	";",  ":",  ",",  ".",  "..", "...",
	-- Lua 5.2
	"::",
	-- Lua 5.3
	"//", "&",  "|",  "~",  ">>", "<<",
} for i, v in ipairs(PUNCTUATION) do  PUNCTUATION[v], PUNCTUATION[i] = true, nil  end

local ESCAPE_SEQUENCES_EXCEPT_QUOTES = {
	["\a"] = [[\a]],
	["\b"] = [[\b]],
	["\f"] = [[\f]],
	["\n"] = [[\n]],
	["\r"] = [[\r]],
	["\t"] = [[\t]],
	["\v"] = [[\v]],
	["\\"] = [[\\]],
}
local ESCAPE_SEQUENCES = {
	["\""] = [[\"]],
	["\'"] = [[\']],
} for k, v in pairs(ESCAPE_SEQUENCES_EXCEPT_QUOTES) do  ESCAPE_SEQUENCES[k] = v  end

local USELESS_TOKENS = {whitespace=true, comment=true}

local major, minor = _VERSION:match"Lua (%d+)%.(%d+)"
if not major then
	io.stderr:write("[LuaPreprocess] Warning: Could not detect Lua version.\n")
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

local metaEnv = nil

local isDebug = false -- Controlled by processFileOrString().

local isRunningMeta            = false
local currentPathIn            = ""
local currentPathOut           = ""
local metaPathForErrorMessages = ""
local outputFromMeta           = nil
local canOutputNil             = true
local fastStrings              = false



--==============================================================
--= Local Functions ============================================
--==============================================================

local _concatTokens
local _tokenize
local assertarg
local cleanError
local copyArray, copyTable
local countString, countSubString
local errorf, errorLine, errorfLine, errorOnLine, errorInFile, errorAtToken, errorAfterToken
local errorIfNotRunningMeta
local escapePattern
local F, tryToFormatError
local getFileContents, fileExists
local getLineNumber
local getNextUsableToken
local getRelativeLocationText
local insertTokenRepresentations
local isAny
local isToken, isTokenAndNotNil
local loadLuaString, loadLuaFile
local outputLineNumber, maybeOutputLineNumber
local pack, unpack
local printf, printTokens, printError, printfError, printErrorTraceback
local serialize, toLua
local tableInsert, tableRemove, tableInsertFormat
local utf8GetCharLength, utf8GetCodepointAndLength



F = string.format

function tryToFormatError(err0)
	local err, path, ln = nil

	if type(err0) == "string" then
		do               path, ln, err = err0:match"^(%a:[%w_/\\.]+):(%d+): (.*)"
		if not err then  path, ln, err = err0:match"^([%w_/\\.]+):(%d+): (.*)"
		if not err then  path, ln, err = err0:match"^(%S-):(%d+): (.*)"
		end end end
	end

	if err then
		return F("Error @ %s:%s: %s", path, ln, err)
	else
		return "Error: "..tostring(err0)
	end
end



function printf(s, ...)
	print(s:format(...))
end

-- printTokens( tokens [, filterUselessTokens ] )
function printTokens(tokens, filter)
	for i, tok in ipairs(tokens) do
		if not (filter and USELESS_TOKENS[tok.type]) then
			printf("%d  %-12s '%s'", i, tok.type, (F("%q", tostring(tok.value)):sub(2, -2):gsub("\\\n", "\\n")))
		end
	end
end

function printError(s)
	io.stderr:write(s, "\n")
end
function printfError(s, ...)
	printError(s:format(...))
end

-- printErrorTraceback( message [, level=1 ] )
function printErrorTraceback(message, level)
	printError(tryToFormatError(message))
	printError("stack traceback:")

	level       = 1 + (level or 1)
	local stack = {}

	while level < 1/0 do
		local info = debug.getinfo(level, "nSl")
		if not info then  break  end

		local isFile     = info.source:find"^@" ~= nil
		local sourceName = (isFile and info.source:sub(2) or info.short_src)

		local buffer = {"\t"}
		tableInsertFormat(buffer, "%s:", sourceName)

		if info.currentline > 0 then
			tableInsertFormat(buffer, "%d:", info.currentline)
		end

		if (info.name or "") ~= "" then
			tableInsertFormat(buffer, " in '%s'", info.name)
		elseif info.what == "main" then
			tableInsert(buffer, " in main chunk")
		elseif info.what == "C" or info.what == "tail" then
			tableInsert(buffer, " ?")
		else
			tableInsertFormat(buffer, " in <%s:%d>", sourceName:gsub("^.*[/\\]", ""), info.linedefined)
		end

		tableInsert(stack, table.concat(buffer))
		level = level + 1
	end

	while stack[#stack] == "\t[C]: ?" do
		stack[#stack] = nil
	end

	for _, s in ipairs(stack) do
		printError(s)
	end
end



-- errorf( [ level=1, ] string, ... )
function errorf(sOrLevel, ...)
	if type(sOrLevel) == "number" then
		error(string.format(...), (sOrLevel == 0 and 0 or 1+sOrLevel))
	else
		error(sOrLevel:format(...), 2)
	end
end

-- function errorLine(err) -- Unused.
-- 	if type(err) ~= "string" then  error(err)  end
-- 	error("\0"..err, 0) -- The 0 tells our own error handler not to print the traceback.
-- end
function errorfLine(s, ...)
	errorf(0, "\0"..s, ...) -- The 0 tells our own error handler not to print the traceback.
end

-- errorOnLine( path, lineNumber, agent=nil, s, ... )
function errorOnLine(path, ln, agent, s, ...)
	s = s:format(...)
	if agent then
		errorfLine("%s:%d: [%s] %s", path, ln, agent, s)
	else
		errorfLine("%s:%d: %s",      path, ln,        s)
	end
end

do
	local function findStartOfLine(s, pos, canBeEmpty)
		while pos > 1 do
			if s:byte(pos-1) == 10--[[\n]] and (canBeEmpty or s:byte(pos) ~= 10--[[\n]]) then  break  end
			pos = pos - 1
		end
		return math.max(pos, 1)
	end
	local function findEndOfLine(s, pos)
		while pos < #s do
			if s:byte(pos+1) == 10--[[\n]] then  break  end
			pos = pos + 1
		end
		return math.min(pos, #s)
	end

	function errorInFile(contents, path, pos, agent, s, ...)
		s = s:format(...)

		pos      = math.min(math.max(pos, 1), #contents+1)
		local ln = getLineNumber(contents, pos)

		local lineStart     = findStartOfLine(contents, pos, true)
		local lineEnd       = findEndOfLine  (contents, pos-1)
		local linePre1Start = findStartOfLine(contents, lineStart-1, false)
		local linePre1End   = findEndOfLine  (contents, linePre1Start-1)
		local linePre2Start = findStartOfLine(contents, linePre1Start-1, false)
		local linePre2End   = findEndOfLine  (contents, linePre2Start-1)
		-- printfError("pos %d | lines %d..%d, %d..%d, %d..%d", pos, linePre2Start,linePre2End+1, linePre1Start,linePre1End+1, lineStart,lineEnd+1) -- DEBUG

		errorOnLine(path, ln, agent, "%s\n>\n%s%s%s>-%s^",
			s,
			(linePre2Start < linePre1Start and linePre2Start <= linePre2End) and F("> %s\n", (contents:sub(linePre2Start, linePre2End):gsub("\t", "    "))) or "",
			(linePre1Start < lineStart     and linePre1Start <= linePre1End) and F("> %s\n", (contents:sub(linePre1Start, linePre1End):gsub("\t", "    "))) or "",
			(                                  lineStart     <= lineEnd    ) and F("> %s\n", (contents:sub(lineStart,     lineEnd    ):gsub("\t", "    "))) or ">\n",
			("-"):rep(pos - lineStart + 3*countSubString(contents, lineStart, lineEnd, "\t", true))
		)
	end
end

-- errorAtToken( fileBuffers, token, position=token.position, agent, s, ... )
function errorAtToken(fileBuffers, tok, pos, agent, s, ...)
	errorInFile(fileBuffers[tok.file], tok.file, (pos or tok.position), agent, s, ...)
end

-- errorAfterToken( fileBuffers, token, agent, s, ... )
function errorAfterToken(fileBuffers, tok, agent, s, ...)
	errorInFile(fileBuffers[tok.file], tok.file, tok.position+#tok.representation, agent, s, ...)
end



function cleanError(err)
	if type(err) == "string" then
		err = err:gsub("%z", "")
	end
	return err
end



local ERROR_UNFINISHED_STRINGLIKE = 1

local function parseStringlike(s, ptr)
	local reprStart = ptr
	local reprEnd

	local valueStart
	local valueEnd

	local longEqualSigns = s:match("^%[(=*)%[", ptr)
	local isLong = (longEqualSigns ~= nil)

	-- Single line.
	if not isLong then
		valueStart = ptr

		local i1, i2 = s:find("\r?\n", ptr)
		if not i1 then
			reprEnd  = #s
			valueEnd = #s
			ptr      = reprEnd+1
		else
			reprEnd  = i2
			valueEnd = i1-1
			ptr      = reprEnd+1
		end

	-- Multiline.
	else
		ptr        = ptr+1+#longEqualSigns+1
		valueStart = ptr

		local i1, i2 = s:find("%]"..longEqualSigns.."%]", ptr)
		if not i1 then
			return nil, ERROR_UNFINISHED_STRINGLIKE
		end

		reprEnd  = i2
		valueEnd = i1-1
		ptr      = reprEnd+1
	end

	local repr = s:sub(reprStart,  reprEnd)
	local v    = s:sub(valueStart, valueEnd)
	local tok  = {type="stringlike", representation=repr, value=v, long=isLong}

	return tok, ptr
end



local NUM_HEX_FRAC_EXP = ("^( 0[Xx] (%x*) %.(%x+) [Pp]([-+]?%x+) )"):gsub(" +", "")
local NUM_HEX_FRAC     = ("^( 0[Xx] (%x*) %.(%x+)                )"):gsub(" +", "")
local NUM_HEX_EXP      = ("^( 0[Xx] (%x+) %.?     [Pp]([-+]?%x+) )"):gsub(" +", "")
local NUM_HEX          = ("^( 0[Xx]  %x+  %.?                    )"):gsub(" +", "")
local NUM_DEC_FRAC_EXP = ("^(        %d*  %.%d+   [Ee][-+]?%d+   )"):gsub(" +", "")
local NUM_DEC_FRAC     = ("^(        %d*  %.%d+                  )"):gsub(" +", "")
local NUM_DEC_EXP      = ("^(        %d+  %.?     [Ee][-+]?%d+   )"):gsub(" +", "")
local NUM_DEC          = ("^(        %d+  %.?                    )"):gsub(" +", "")

-- tokens = _tokenize( luaString, path, allowPreprocessorTokens, allowBacktickStrings, allowJitSyntax )
function _tokenize(s, path, allowPpTokens, allowBacktickStrings, allowJitSyntax)
	local tokens = {}
	local ptr    = 1
	local ln     = 1

	while ptr <= #s do
		local tok
		local tokenPos = ptr

		-- Whitespace.
		if s:find("^%s", ptr) then
			local i1, i2, whitespace = s:find("^(%s+)", ptr)

			ptr = i2+1
			tok = {type="whitespace", representation=whitespace, value=whitespace}

		-- Identifier/keyword.
		elseif s:find("^[%a_]", ptr) then
			local i1, i2, word = s:find("^([%a_][%w_]*)", ptr)
			ptr = i2+1

			if KEYWORDS[word] then
				tok = {type="keyword",    representation=word, value=word}
			else
				tok = {type="identifier", representation=word, value=word}
			end

		-- Number.
		elseif s:find("^%.?%d", ptr) then
			local           pat, maybeInt, lua52Hex, i1, i2, numStr = NUM_HEX_FRAC_EXP, false, true,  s:find(NUM_HEX_FRAC_EXP, ptr)
			if not i1 then  pat, maybeInt, lua52Hex, i1, i2, numStr = NUM_HEX_FRAC,     false, true,  s:find(NUM_HEX_FRAC,     ptr)
			if not i1 then  pat, maybeInt, lua52Hex, i1, i2, numStr = NUM_HEX_EXP,      false, true,  s:find(NUM_HEX_EXP,      ptr)
			if not i1 then  pat, maybeInt, lua52Hex, i1, i2, numStr = NUM_HEX,          true,  false, s:find(NUM_HEX,          ptr)
			if not i1 then  pat, maybeInt, lua52Hex, i1, i2, numStr = NUM_DEC_FRAC_EXP, false, false, s:find(NUM_DEC_FRAC_EXP, ptr)
			if not i1 then  pat, maybeInt, lua52Hex, i1, i2, numStr = NUM_DEC_FRAC,     false, false, s:find(NUM_DEC_FRAC,     ptr)
			if not i1 then  pat, maybeInt, lua52Hex, i1, i2, numStr = NUM_DEC_EXP,      false, false, s:find(NUM_DEC_EXP,      ptr)
			if not i1 then  pat, maybeInt, lua52Hex, i1, i2, numStr = NUM_DEC,          true,  false, s:find(NUM_DEC,          ptr)
			end end end end end end end

			if not numStr then
				errorInFile(s, path, ptr, "Tokenizer", "Malformed number.")
			end

			local numStrFallback = numStr

			if allowJitSyntax then
				if s:find("^[Ii]", i2+1) then -- Imaginary part of complex number.
					numStr = s:sub(i1, i2+1)
					i2     = i2 + 1

				elseif not maybeInt or numStr:find(".", 1, true) then
					-- void
				elseif s:find("^[Uu][Ll][Ll]", i2+1) then -- Unsigned 64-bit integer.
					numStr = s:sub(i1, i2+3)
					i2     = i2 + 3
				elseif s:find("^[Ll][Ll]", i2+1) then -- Signed 64-bit integer.
					numStr = s:sub(i1, i2+2)
					i2     = i2 + 2
				end
			end

			local n = tonumber(numStr) or tonumber(numStrFallback)

			-- Support hexadecimal floats in Lua 5.1.
			if not n and lua52Hex then
				-- Note: We know we're not running LuaJIT here as it supports hexadecimal floats, thus we use numStrFallback instead of numStr.
				local                                _, intStr, fracStr, expStr
				if     pat == NUM_HEX_FRAC_EXP then  _, intStr, fracStr, expStr = numStrFallback:match(NUM_HEX_FRAC_EXP)
				elseif pat == NUM_HEX_FRAC     then  _, intStr, fracStr         = numStrFallback:match(NUM_HEX_FRAC) ; expStr  = "0"
				elseif pat == NUM_HEX_EXP      then  _, intStr,          expStr = numStrFallback:match(NUM_HEX_EXP)  ; fracStr = ""
				else assert(false) end

				n = tonumber(intStr, 16) or 0 -- intStr may be "".

				local fracValue = 1
				for i = 1, #fracStr do
					fracValue = fracValue/16
					n         = n+tonumber(fracStr:sub(i, i), 16)*fracValue
				end

				n = n*2^expStr:gsub("^+", "")
			end

			if not n then
				errorInFile(s, path, ptr, "Tokenizer", "Invalid number.")
			end

			if s:find("^[%w_]", i2+1) then
				-- This is actually only an error in Lua 5.1. Maybe we should issue a warning instead of an error here?
				errorInFile(s, path, i2+1, "Tokenizer", "Malformed number.")
			end

			ptr = i2+1
			tok = {type="number", representation=numStr, value=n}

		-- Comment.
		elseif s:find("^%-%-", ptr) then
			local reprStart = ptr
			ptr = ptr+2

			tok, ptr = parseStringlike(s, ptr)
			if not tok then
				local errCode = ptr
				if errCode == ERROR_UNFINISHED_STRINGLIKE then
					errorInFile(s, path, reprStart, "Tokenizer", "Unfinished long comment.")
				else
					errorInFile(s, path, reprStart, "Tokenizer", "Invalid comment.")
				end
			end

			if tok.long then
				-- Check for nesting of [[...]], which is depricated in Lua.
				local chunk, err = loadLuaString("--"..tok.representation, "@")

				if not chunk then
					local lnInString, luaErr = err:match'^:(%d+): (.*)'
					if luaErr then
						errorOnLine(path, getLineNumber(s, reprStart)+tonumber(lnInString)-1, "Tokenizer", "Malformed long comment. (%s)", luaErr)
					else
						errorInFile(s, path, reprStart, "Tokenizer", "Malformed long comment.")
					end
				end
			end

			tok.type           = "comment"
			tok.representation = s:sub(reprStart, ptr-1)

		-- String (short).
		elseif s:find([=[^["']]=], ptr) then
			local reprStart = ptr
			local reprEnd

			local quoteChar = s:sub(ptr, ptr)
			ptr = ptr+1

			local valueStart = ptr
			local valueEnd

			while true do
				local c = s:sub(ptr, ptr)

				if c == "" then
					errorInFile(s, path, reprStart, "Tokenizer", "Unfinished string.")

				elseif c == quoteChar then
					reprEnd  = ptr
					valueEnd = ptr-1
					ptr      = reprEnd+1
					break

				elseif c == "\\" then
					-- Note: We don't have to look for multiple characters after
					-- the escape, like \nnn - this algorithm works anyway.
					if ptr+1 > #s then
						errorInFile(s, path, reprStart, "Tokenizer", "Unfinished string after escape.")
					end
					ptr = ptr+2

				elseif c == "\n" then
					-- Can't have unescaped newlines. Lua, this is a silly rule! @Ugh
					errorInFile(s, path, ptr, "Tokenizer", "Newlines must be escaped in strings.")

				else
					ptr = ptr+1
				end
			end

			local repr = s:sub(reprStart, reprEnd)

			local valueChunk = loadLuaString("return"..repr)
			if not valueChunk then
				errorInFile(s, path, reprStart, "Tokenizer", "Malformed string.")
			end

			local v = valueChunk()
			assert(type(v) == "string")

			tok = {type="string", representation=repr, value=valueChunk(), long=false}

		-- Long string.
		elseif s:find("^%[=*%[", ptr) then
			local reprStart = ptr

			tok, ptr = parseStringlike(s, ptr)
			if not tok then
				local errCode = ptr
				if errCode == ERROR_UNFINISHED_STRINGLIKE then
					errorInFile(s, path, reprStart, "Tokenizer", "Unfinished long string.")
				else
					errorInFile(s, path, reprStart, "Tokenizer", "Invalid long string.")
				end
			end

			-- Check for nesting of [[...]], which is depricated in Lua.
			local valueChunk, err = loadLuaString("return"..tok.representation, "@")

			if not valueChunk then
				local lnInString, luaErr = err:match'^:(%d+): (.*)'
				if luaErr then
					errorOnLine(path, getLineNumber(s, reprStart)+tonumber(lnInString)-1, "Tokenizer", "Malformed long string. (%s)", luaErr)
				else
					errorInFile(s, path, reprStart, "Tokenizer", "Malformed long string.")
				end
			end

			local v = valueChunk()
			assert(type(v) == "string")

			tok.type  = "string"
			tok.value = v

		-- Backtick string.
		elseif s:find("^`", ptr) then
			if not allowBacktickStrings then
				errorInFile(s, path, ptr, "Tokenizer", "Encountered backtick string. (Feature not enabled.)")
			end

			local i1, i2, repr, v = s:find("^(`([^`]*)`)", ptr)
			if not i2 then
				errorInFile(s, path, ptr, "Tokenizer", "Unfinished backtick string.")
			end

			ptr = i2+1
			tok = {type="string", representation=repr, value=v, long=false}

		-- Punctuation etc.
		elseif s:find("^%.%.%.", ptr) then -- 3
			local repr = s:sub(ptr, ptr+2)
			tok = {type="punctuation", representation=repr, value=repr}
			ptr = ptr+#repr
		elseif s:find("^%.%.", ptr) or s:find("^[=~<>]=", ptr) or s:find("^::", ptr) or s:find("^//", ptr) or s:find("^<<", ptr) or s:find("^>>", ptr) then -- 2
			local repr = s:sub(ptr, ptr+1)
			tok = {type="punctuation", representation=repr, value=repr}
			ptr = ptr+#repr
		elseif s:find("^[+%-*/%%^#<>=(){}[%];:,.&|~]", ptr) then -- 1
			local repr = s:sub(ptr, ptr)
			tok = {type="punctuation", representation=repr, value=repr}
			ptr = ptr+#repr

		-- Preprocessor entry.
		elseif s:find("^!", ptr) then
			if not allowPpTokens then
				errorInFile(s, path, ptr, "Tokenizer", "Encountered preprocessor entry. (Feature not enabled.)")
			end

			local double = s:find("^!", ptr+1) ~= nil
			local repr   = s:sub(ptr, ptr+(double and 1 or 0))

			tok = {type="pp_entry", representation=repr, value=repr, double=double}
			ptr = ptr+#repr

		-- Preprocessor keyword.
		elseif s:find("^@", ptr) then
			if not allowPpTokens then
				errorInFile(s, path, ptr, "Tokenizer", "Encountered preprocessor keyword. (Feature not enabled.)")
			end

			if s:find("^@@", ptr) then
				ptr = ptr+2
				tok = {type="pp_keyword", representation="@@", value="insert"}
			else
				local i1, i2, repr, word = s:find("^(@([%a_][%w_]*))", ptr)
				if not i1 then
					errorInFile(s, path, ptr+1, "Tokenizer", "Expected an identifier.")
				elseif not PREPROCESSOR_KEYWORDS[word] then
					errorInFile(s, path, ptr+1, "Tokenizer", "Invalid preprocessor keyword '%s'.", word)
				end
				ptr = i2+1
				tok = {type="pp_keyword", representation=repr, value=word}
			end

		else
			errorInFile(s, path, ptr, "Tokenizer", "Unknown character.")
		end

		tok.line     = ln
		tok.position = tokenPos
		tok.file     = path

		ln = ln+countString(tok.representation, "\n", true)
		tok.lineEnd = ln

		tableInsert(tokens, tok)
		-- print(#tokens, tok.type, tok.representation)
	end

	return tokens
end



-- luaString = _concatTokens( tokens, lastLn=nil, addLineNumbers, fromIndex=1, toIndex=#tokens )
function _concatTokens(tokens, lastLn, addLineNumbers, i1, i2)
	local parts = {}

	if addLineNumbers then
		for i = (i1 or 1), (i2 or #tokens) do
			local tok = tokens[i]
			lastLn    = maybeOutputLineNumber(parts, tok, lastLn)
			tableInsert(parts, tok.representation)
		end

	else
		for i = (i1 or 1), (i2 or #tokens) do
			tableInsert(parts, tokens[i].representation)
		end
	end

	return table.concat(parts)
end



function insertTokenRepresentations(parts, tokens, i1, i2)
	for i = i1, i2 do
		tableInsert(parts, tokens[i].representation)
	end
end



function getFileContents(path, isTextFile)
	assertarg(1, path,       "string")
	assertarg(2, isTextFile, "boolean","nil")

	local file, err = io.open(path, "r"..(isTextFile and "" or "b"))
	if not file then  return nil, err  end

	local contents = file:read"*a"
	file:close()
	return contents
end

function fileExists(path)
	assertarg(1, path, "string")

	local file = io.open(path, "r")
	if not file then  return false  end

	file:close()
	return true
end



-- assertarg( argumentNumber, value, expectedValueType1, ... )
function assertarg(n, v, ...)
	local vType = type(v)

	for i = 1, select("#", ...) do
		if vType == select(i, ...) then  return  end
	end

	local fName   = debug.getinfo(2, "n").name
	local expects = table.concat({...}, " or ")

	if fName == "" then  fName = "?"  end

	errorf(3, "bad argument #%d to '%s' (%s expected, got %s)", n, fName, expects, vType)
end



-- count = countString( haystack, needle [, plain=false ] )
function countString(s, needle, plain)
	local count = 0
	local i     = 0
	local _

	while true do
		_, i = s:find(needle, i+1, plain)
		if not i then  return count  end

		count = count+1
	end
end

-- count = countSubString( string, startPosition, endPosition, needle [, plain=false ] )
function countSubString(s, pos, posEnd, needle, plain)
	local count = 0

	while true do
		local _, i2 = s:find(needle, pos, plain)
		if not i2 or i2 > posEnd then  return count  end

		count = count + 1
		pos   = i2    + 1
	end
end



-- (Table generated by misc/generateStringEscapeSequenceInfo.lua)
local UNICODE_RANGES_NOT_TO_ESCAPE = {
	{from=32, to=126},
	{from=161, to=591},
	{from=880, to=887},
	{from=890, to=895},
	{from=900, to=906},
	{from=908, to=908},
	{from=910, to=929},
	{from=931, to=1154},
	{from=1162, to=1279},
	{from=7682, to=7683},
	{from=7690, to=7691},
	{from=7710, to=7711},
	{from=7744, to=7745},
	{from=7766, to=7767},
	{from=7776, to=7777},
	{from=7786, to=7787},
	{from=7808, to=7813},
	{from=7835, to=7835},
	{from=7922, to=7923},
	{from=8208, to=8208},
	{from=8210, to=8231},
	{from=8240, to=8286},
	{from=8304, to=8305},
	{from=8308, to=8334},
	{from=8336, to=8348},
	{from=8352, to=8383},
	{from=8448, to=8587},
	{from=8592, to=9254},
	{from=9312, to=10239},
	{from=10496, to=11007},
	{from=64256, to=64262},
}

local function shouldCodepointBeEscaped(cp)
	for _, range in ipairs(UNICODE_RANGES_NOT_TO_ESCAPE) do -- @Speed: Don't use a loop?
		if cp >= range.from and cp <= range.to then  return false  end
	end
	return true
end

-- success, error = serialize( buffer, value )
-- @Speed: Cache all possible values!
function serialize(buffer, v)
	local vType = type(v)

	if vType == "table" then
		local first = true
		tableInsert(buffer, "{")

		local indices = {}
		for i, item in ipairs(v) do
			if not first then  tableInsert(buffer, ",")  end
			first = false

			local ok, err = serialize(buffer, item)
			if not ok then  return false, err  end

			indices[i] = true
		end

		local keys = {}
		for k, item in pairs(v) do
			if indices[k] then
				-- void
			elseif type(k) == "table" then
				return false, "Table keys cannot be tables."
			else
				tableInsert(keys, k)
			end
		end

		table.sort(keys, function(a, b)
			return tostring(a) < tostring(b)
		end)

		for _, k in ipairs(keys) do
			local item = v[k]

			if not first then  tableInsert(buffer, ",")  end
			first = false

			if not KEYWORDS[k] and type(k) == "string" and k:find"^[%a_][%w_]*$" then
				tableInsert(buffer, k)
				tableInsert(buffer, "=")

			else
				tableInsert(buffer, "[")

				local ok, err = serialize(buffer, k)
				if not ok then  return false, err  end

				tableInsert(buffer, "]=")
			end

			local ok, err = serialize(buffer, item)
			if not ok then  return false, err  end
		end

		tableInsert(buffer, "}")

	elseif vType == "string" then
		if v == "" then
			tableInsert(buffer, '""')
			return true
		end

		local useApostrophe = v:find('"', 1, true) and not v:find("'", 1, true)
		local quote         = useApostrophe and "'" or '"'

		tableInsert(buffer, quote)

		if fastStrings or not v:find"[^\32-\126\t\n]" then
			-- print(">> FAST", #v) -- DEBUG

			local s = v:gsub((useApostrophe and "[\t\n\\']" or '[\t\n\\"]'), function(c)
				return ESCAPE_SEQUENCES[c] or errorf("Internal error. (%d)", c:byte())
			end)
			tableInsert(buffer, s)

		else
			-- print(">> SLOW", #v) -- DEBUG
			local pos = 1

			-- @Speed: There are optimizations to be made here!
			while pos <= #v do
				local c       = v:sub(pos, pos)
				local cp, len = utf8GetCodepointAndLength(v, pos)

				-- Named escape sequences.
				if ESCAPE_SEQUENCES_EXCEPT_QUOTES[c] then  tableInsert(buffer, ESCAPE_SEQUENCES_EXCEPT_QUOTES[c])  ; pos = pos+1
				elseif c == quote                    then  tableInsert(buffer, [[\]]) ; tableInsert(buffer, quote) ; pos = pos+1

				-- UTF-8 character.
				elseif len == 1 and not shouldCodepointBeEscaped(cp) then  tableInsert(buffer, v:sub(pos, pos      )) ; pos = pos+1 -- @Speed: We can insert multiple single-byte characters sometimes!
				elseif len      and not shouldCodepointBeEscaped(cp) then  tableInsert(buffer, v:sub(pos, pos+len-1)) ; pos = pos+len

				-- Anything else.
				else
					tableInsert(buffer, F((v:find("^%d", pos+1) and "\\%03d" or "\\%d"), v:byte(pos)))
					pos = pos + 1
				end
			end
		end

		tableInsert(buffer, quote)

	elseif v == 1/0 then
		tableInsert(buffer, "(1/0)")
	elseif v == -1/0 then
		tableInsert(buffer, "(-1/0)")
	elseif v ~= v then
		tableInsert(buffer, "(0/0)") -- NaN.
	elseif v == 0 then
		tableInsert(buffer, "0") -- In case it's actually -0 for some reason, which would be silly to output.
	elseif vType == "number" then
		if v < 0 then
			tableInsert(buffer, " ") -- The space prevents an accidental comment if a "-" is right before.
		end
		tableInsert(buffer, tostring(v)) -- (I'm not sure what precision tostring() uses for numbers. Maybe we should use string.format() instead.)

	elseif vType == "boolean" or v == nil then
		tableInsert(buffer, tostring(v))

	else
		return false, F("Cannot serialize value of type '%s'. (%s)", vType, tostring(v))
	end
	return true
end



-- luaString = toLua( value )
-- Returns nil and a message on error.
function toLua(v)
	local buffer = {}

	local ok, err = serialize(buffer, v)
	if not ok then  return nil, err  end

	return table.concat(buffer)
end



function escapePattern(s)
	return (s:gsub("[-+*^?$.%%()[%]]", "%%%0"))
end



function outputLineNumber(parts, ln)
	tableInsert(parts, "--[[@")
	tableInsert(parts, ln)
	tableInsert(parts, "]]")
end

function maybeOutputLineNumber(parts, tok, lastLn)
	if tok.line == lastLn or USELESS_TOKENS[tok.type] then  return lastLn  end

	outputLineNumber(parts, tok.line)
	return tok.line
end
--[=[
function maybeOutputLineNumber(parts, tok, lastLn, fromMetaToOutput)
	if tok.line == lastLn or USELESS_TOKENS[tok.type] then  return lastLn  end

	if fromMetaToOutput then
		tableInsert(parts, '__LUA"--[[@'..tok.line..']]"\n')
	else
		tableInsert(parts, "--[[@"..tok.line.."]]")
	end
	return tok.line
end
]=]



function isAny(v, ...)
	for i = 1, select("#", ...) do
		if v == select(i, ...) then  return true  end
	end
	return false
end



function errorIfNotRunningMeta(level)
	if not isRunningMeta then
		error("No file is being processed.", 1+level)
	end
end



function copyArray(t)
	local copy = {}
	for i, v in ipairs(t) do
		copy[i] = v
	end
	return copy
end

-- copy = copyTable( table [, deep=false ] )
do
	local function deepCopy(t, copy, tableCopies)
		for k, v in pairs(t) do
			if type(v) == "table" then
				local vCopy = tableCopies[v]

				if vCopy then
					copy[k] = vCopy
				else
					vCopy          = {}
					tableCopies[v] = vCopy
					copy[k]        = deepCopy(v, vCopy, tableCopies)
				end

			else
				copy[k] = v
			end
		end
		return copy
	end

	function copyTable(t, deep)
		local copy = {}

		if deep then
			return deepCopy(t, copy, {[t]=copy})
		end

		for k, v in pairs(t) do  copy[k] = v  end

		return copy
	end
end



-- values = pack( value1, ... )
-- values.n is the amount of values (which can be zero).
if IS_LUA_52_OR_LATER then
	pack = table.pack
else
	function pack(...)
		return {n=select("#", ...), ...}
	end
end

unpack = IS_LUA_52_OR_LATER and table.unpack or _G.unpack



if IS_LUA_52_OR_LATER then
	function loadLuaString(lua, chunkName, env)
		return load(lua, chunkName, "bt", env)
	end
else
	function loadLuaString(lua, chunkName, env)
		local chunk, err = loadstring(lua, chunkName)
		if not chunk then  return nil, err  end

		if env then  setfenv(chunk, env)  end

		return chunk
	end
end

if IS_LUA_52_OR_LATER then
	function loadLuaFile(path, env)
		return loadfile(path, "bt", env)
	end
else
	function loadLuaFile(path, env)
		local chunk, err = loadfile(path)
		if not chunk then  return nil, err  end

		if env then  setfenv(chunk, env)  end

		return chunk
	end
end



-- token, index = getNextUsableToken( tokens, startIndex [, indexLimit, direction=1 ] )
function getNextUsableToken(tokens, iStart, iLimit, dir)
	dir = dir or 1

	iLimit = (
		dir < 0
		and math.max((iLimit or 1  ), 1)
		or  math.min((iLimit or 1/0), #tokens)
	)

	for i = iStart, iLimit, dir do
		if not USELESS_TOKENS[tokens[i].type] then
			return tokens[i], i
		end
	end

	return nil
end



-- bool = isToken( token, tokenType [, tokenValue=any ] )
function isToken(tok, tokType, v)
	return tok.type == tokType and (v == nil or tok.value == v)
end

-- bool = isTokenAndNotNil( token, tokenType [, tokenValue=any ] )
function isTokenAndNotNil(tok, tokType, v)
	return tok ~= nil and tok.type == tokType and (v == nil or tok.value == v)
end



function getLineNumber(s, pos)
	return 1 + countSubString(s, 1, pos-1, "\n", true)
end



-- text = getRelativeLocationText( tokenOfInterest, otherToken )
-- text = getRelativeLocationText( tokenOfInterest, otherFilename, otherLineNumber )
function getRelativeLocationText(tokOfInterest, otherFilename, otherLn)
	if type(otherFilename) == "table" then
		return getRelativeLocationText(tokOfInterest, otherFilename.file, otherFilename.line)
	end

	if not (tokOfInterest.file and tokOfInterest.line) then
		return "at <UnknownLocation>"
	end

	if tokOfInterest.file   ~= otherFilename then  return F("at %s:%d", tokOfInterest.file, tokOfInterest.line)  end
	if tokOfInterest.line+1 == otherLn       then  return F("on the previous line")  end
	if tokOfInterest.line-1 == otherLn       then  return F("on the next line")  end
	if tokOfInterest.line   ~= otherLn       then  return F("on line %d", tokOfInterest.line)  end
	return "on the same line"
end



tableInsert = table.insert
tableRemove = table.remove

function tableInsertFormat(t, s, ...)
	tableInsert(t, s:format(...))
end



-- length|nil = utf8GetCharLength( string [, position=1 ] )
function utf8GetCharLength(s, pos)
	pos                  = pos or 1
	local b1, b2, b3, b4 = s:byte(pos, pos+3)

	if b1 > 0 and b1 <= 127 then
		return 1

	elseif b1 >= 194 and b1 <= 223 then
		if not b2               then  return nil  end -- UTF-8 string terminated early.
		if b2 < 128 or b2 > 191 then  return nil  end -- Invalid UTF-8 character.
		return 2

	elseif b1 >= 224 and b1 <= 239 then
		if not b3                               then  return nil  end -- UTF-8 string terminated early.
		if b1 == 224 and (b2 < 160 or b2 > 191) then  return nil  end -- Invalid UTF-8 character.
		if b1 == 237 and (b2 < 128 or b2 > 159) then  return nil  end -- Invalid UTF-8 character.
		if               (b2 < 128 or b2 > 191) then  return nil  end -- Invalid UTF-8 character.
		if               (b3 < 128 or b3 > 191) then  return nil  end -- Invalid UTF-8 character.
		return 3

	elseif b1 >= 240 and b1 <= 244 then
		if not b4                               then  return nil  end -- UTF-8 string terminated early.
		if b1 == 240 and (b2 < 144 or b2 > 191) then  return nil  end -- Invalid UTF-8 character.
		if b1 == 244 and (b2 < 128 or b2 > 143) then  return nil  end -- Invalid UTF-8 character.
		if               (b2 < 128 or b2 > 191) then  return nil  end -- Invalid UTF-8 character.
		if               (b3 < 128 or b3 > 191) then  return nil  end -- Invalid UTF-8 character.
		if               (b4 < 128 or b4 > 191) then  return nil  end -- Invalid UTF-8 character.
		return 4
	end

	return nil -- Invalid UTF-8 character.
end

-- codepoint, length = utf8GetCodepointAndLength( string [, position=1 ] )
-- Returns nil if the text is invalid at the position.
function utf8GetCodepointAndLength(s, pos)
	pos       = pos or 1
	local len = utf8GetCharLength(s, pos)
	if not len then  return nil  end

	-- 2^6=64, 2^12=4096, 2^18=262144
	if len == 1 then                                              return                                              s:byte(pos), len  end
	if len == 2 then  local b1, b2         = s:byte(pos, pos+1) ; return                                   (b1-192)*64 + (b2-128), len  end
	if len == 3 then  local b1, b2, b3     = s:byte(pos, pos+2) ; return                   (b1-224)*4096 + (b2-128)*64 + (b3-128), len  end
	do                local b1, b2, b3, b4 = s:byte(pos, pos+3) ; return (b1-240)*262144 + (b2-128)*4096 + (b3-128)*64 + (b4-128), len  end
end



--==============================================================
--= Preprocessor Functions =====================================
--==============================================================



-- :EnvironmentTable
metaEnv = copyTable(_G, true) -- Include all standard Lua stuff.
metaEnv._G = metaEnv

local metaFuncs = {}

-- printf()
--   printf( format, value1, ... )
--   Print a formatted string.
metaFuncs.printf = printf

-- getFileContents()
--   contents = getFileContents( path [, isTextFile=false ] )
--   Get the entire contents of a binary file or text file. Returns nil and a message on error.
metaFuncs.getFileContents = getFileContents

-- fileExists()
--   bool = fileExists( path )
--   Check if a file exists.
metaFuncs.fileExists = fileExists

-- toLua()
--   luaString = toLua( value )
--   Convert a value to a Lua literal. Does not work with certain types, like functions or userdata.
--   Returns nil and a message on error.
metaFuncs.toLua = toLua

-- serialize()
--   success, error = serialize( buffer, value )
--   Same as toLua() except adds the result to an array instead of returning the Lua code as a string.
--   This could avoid allocating unnecessary strings.
metaFuncs.serialize = serialize

-- escapePattern()
--   escapedString = escapePattern( string )
--   Escape a string so it can be used in a pattern as plain text.
metaFuncs.escapePattern = escapePattern

-- isToken()
--   bool = isToken( token, tokenType [, tokenValue=any ] )
--   Check if a token is of a specific type, optionally also check it's value.
metaFuncs.isToken = isToken

-- copyTable()
--   copy = copyTable( table [, deep=false ] )
--   Copy a table, optionally recursively (deep copy).
--   Multiple references to the same table and self-references are preserved during deep copying.
metaFuncs.copyTable = copyTable

-- unpack()
--   value1, ... = unpack( table [, fromIndex=1, toIndex=#table ] )
--   Is _G.unpack() in Lua 5.1 and alias for table.unpack() in Lua 5.2+.
metaFuncs.unpack = unpack

-- pack()
--   values = pack( value1, ... )
--   Put values in a new table. values.n is the amount of values (which can be zero)
--   including nil values. Alias for table.pack() in Lua 5.2+.
metaFuncs.pack = pack

-- run()
--   returnValue1, ... = run( path [, arg1, ... ] )
--   Execute a Lua file. Similar to dofile().
function metaFuncs.run(path, ...)
	assertarg(1, path, "string")

	local main_chunk, err = loadLuaFile(path, metaEnv)
	if not main_chunk then  error(err, 0)  end

	-- We want multiple return values while avoiding a tail call to preserve stack info.
	local returnValues = pack(main_chunk(...))
	return unpack(returnValues, 1, returnValues.n)
end

-- outputValue()
--   outputValue( value )
--   outputValue( value1, value2, ... ) -- Outputted values will be separated by commas.
--   Output one or more values, like strings or tables, as literals.
--   Raises an error if no file or string is being processed.
function metaFuncs.outputValue(...)
	errorIfNotRunningMeta(2)

	local argCount = select("#", ...)
	if argCount == 0 then
		error("No values to output.", 2)
	end

	for i = 1, argCount do
		local v = select(i, ...)

		if v == nil and not canOutputNil then
			local ln = debug.getinfo(2, "l").currentline
			errorOnLine(metaPathForErrorMessages, ln, "MetaProgram", "Trying to output nil which is disallowed through params.canOutputNil .")
		end

		if i > 1 then
			tableInsert(outputFromMeta, (isDebug and ", " or ","))
		end

		local ok, err = serialize(outputFromMeta, v)

		if not ok then
			local ln = debug.getinfo(2, "l").currentline
			errorOnLine(metaPathForErrorMessages, ln, "MetaProgram", "%s", err)
		end
	end
end

-- outputLua()
--   outputLua( luaString1, ... )
--   Output one or more strings as raw Lua code.
--   Raises an error if no file or string is being processed.
function metaFuncs.outputLua(...)
	errorIfNotRunningMeta(2)

	local argCount = select("#", ...)
	if argCount == 0 then
		error("No Lua code to output.", 2)
	end

	for i = 1, argCount do
		local lua = select(i, ...)
		assertarg(i, lua, "string")
		tableInsert(outputFromMeta, lua)
	end
end

-- outputLuaTemplate()
--   outputLuaTemplate( luaStringTemplate, value1, ... )
--   Use a string as a template for outputting Lua code with values.
--   Question marks (?) are replaced with the values.
--   Raises an error if no file or string is being processed.
--   Examples:
--     outputLuaTemplate("local name, age = ?, ?", "Harry", 48)
--     outputLuaTemplate("dogs[?] = ?", "greyhound", {italian=false, count=5})
function metaFuncs.outputLuaTemplate(lua, ...)
	errorIfNotRunningMeta(2)
	assertarg(1, lua, "string")

	local args = {...}
	local n    = 0
	local v, err

	lua = lua:gsub("%?", function()
		n      = n+1
		v, err = toLua(args[n])

		if not v then
			errorf(3, "Bad argument %d: %s", 1+n, err)
		end

		return assert(v)
	end)

	tableInsert(outputFromMeta, lua)
end

-- getOutputSoFar()
--   luaString = getOutputSoFar( [ asTable=false ] )
--   Get Lua code that's been outputted so far.
--   If asTable is false then the full Lua code string is returned.
--   If asTable is true then an array of Lua code segments is returned. (This avoids allocating, possibly large, strings.)
--   Raises an error if no file or string is being processed.
function metaFuncs.getOutputSoFar(asTable)
	errorIfNotRunningMeta(2)
	return asTable and copyArray(outputFromMeta) or table.concat(outputFromMeta)
end

-- getOutputSizeSoFar()
--   size = getOutputSizeSoFar( )
--   Get the amount of bytes outputted so far.
--   Raises an error if no file or string is being processed.
function metaFuncs.getOutputSizeSoFar()
	errorIfNotRunningMeta(2)

	local size = 0

	for _, lua in ipairs(outputFromMeta) do
		size = size + #lua
	end

	return size
end

-- getCurrentLineNumberInOutput()
--   lineNumber = getCurrentLineNumberInOutput( )
--   Get the current line number in the output.
function metaFuncs.getCurrentLineNumberInOutput()
	errorIfNotRunningMeta(2)

	local ln = 1

	for _, lua in ipairs(outputFromMeta) do
		ln = ln + countString(lua, "\n", true)
	end

	return ln
end

-- getCurrentPathIn()
--   path = getCurrentPathIn( )
--   Get what file is currently being processed, if any.
function metaFuncs.getCurrentPathIn()
	return currentPathIn
end

-- getCurrentPathOut()
--   path = getCurrentPathOut( )
--   Get what file the currently processed file will be written to, if any.
function metaFuncs.getCurrentPathOut()
	return currentPathOut
end

-- tokenize()
--   tokens = tokenize( luaString [, allowPreprocessorCode=false ] )
--   token = {
--     type=tokenType, representation=representation, value=value,
--     line=lineNumber, lineEnd=lineNumber, position=bytePosition, file=filePath,
--     ...
--   }
--   Convert Lua code to tokens. Returns nil and a message on error. (See newToken() for token types.)
function metaFuncs.tokenize(lua, allowPpCode)
	local ok, errOrTokens = pcall(_tokenize, lua, "<string>", allowPpCode, allowPpCode, true) -- @Incomplete: Make allowJitSyntax a parameter to tokenize()?
	if not ok then
		return nil, cleanError(errOrTokens)
	end
	return errOrTokens
end

-- removeUselessTokens()
--   removeUselessTokens( tokens )
--   Remove whitespace and comment tokens.
function metaFuncs.removeUselessTokens(tokens)
	local len    = #tokens
	local offset = 0

	for i, tok in ipairs(tokens) do
		if USELESS_TOKENS[tok.type] then
			offset = offset-1
		else
			tokens[i+offset] = tok
		end
	end

	for i = len, len+offset+1, -1 do
		tokens[i] = nil
	end
end

-- eachToken()
--   for index, token in eachToken( tokens [, ignoreUselessTokens=false ] ) do
--   Loop through tokens.
local function nextUsefulToken(tokens, i)
	while true do
		i = i+1
		local tok = tokens[i]
		if not tok                      then  return         end
		if not USELESS_TOKENS[tok.type] then  return i, tok  end
	end
end
function metaFuncs.eachToken(tokens, ignoreUselessTokens)
	if ignoreUselessTokens then
		return nextUsefulToken, tokens, 0
	else
		return ipairs(tokens)
	end
end

-- getNextUsefulToken()
--   token, index = getNextUsefulToken( tokens, startIndex [, steps=1 ] )
--   Get the next token that isn't a whitespace or comment. Returns nil if no more tokens are found.
--   Specify a negative steps value to get an earlier token.
function metaFuncs.getNextUsefulToken(tokens, i1, steps)
	steps = (steps or 1)

	local i2, dir
	if steps == 0 then
		return tokens[i1], i1
	elseif steps < 0 then
		i2, dir = 1, -1
	else
		i2, dir = #tokens, 1
	end

	for i = i1, i2, dir do
		local tok = tokens[i]
		if not USELESS_TOKENS[tok.type] then
			steps = steps-dir
			if steps == 0 then  return tok, i  end
		end
	end

	return nil
end

local numberFormatters = {
	-- @Incomplete: Hexadecimal floats.
	auto        = function(n) return tostring(n) end,
	integer     = function(n) return F("%d", n) end,
	int         = function(n) return F("%d", n) end,
	float       = function(n) return F("%f", n):gsub("(%d)0+$", "%1") end,
	scientific  = function(n) return F("%e", n):gsub("(%d)0+e", "%1e"):gsub("0+(%d+)$", "%1") end,
	SCIENTIFIC  = function(n) return F("%E", n):gsub("(%d)0+E", "%1E"):gsub("0+(%d+)$", "%1") end,
	e           = function(n) return F("%e", n):gsub("(%d)0+e", "%1e"):gsub("0+(%d+)$", "%1") end,
	E           = function(n) return F("%E", n):gsub("(%d)0+E", "%1E"):gsub("0+(%d+)$", "%1") end,
	hexadecimal = function(n) return (n == math.floor(n) and F("0x%x", n) or error("Hexadecimal floats not supported yet.", 3)) end,
	HEXADECIMAL = function(n) return (n == math.floor(n) and F("0x%X", n) or error("Hexadecimal floats not supported yet.", 3)) end,
	hex         = function(n) return (n == math.floor(n) and F("0x%x", n) or error("Hexadecimal floats not supported yet.", 3)) end,
	HEX         = function(n) return (n == math.floor(n) and F("0x%X", n) or error("Hexadecimal floats not supported yet.", 3)) end,
}

-- newToken()
--   token = newToken( tokenType, ... )
--   Create a new token. Different token types take different arguments.
--
--   commentToken     = newToken( "comment",     contents [, forceLongForm=false ] )
--   identifierToken  = newToken( "identifier",  identifier )
--   keywordToken     = newToken( "keyword",     keyword )
--   numberToken      = newToken( "number",      number [, numberFormat="auto" ] )
--   punctuationToken = newToken( "punctuation", symbol )
--   stringToken      = newToken( "string",      contents [, longForm=false ] )
--   whitespaceToken  = newToken( "whitespace",  contents )
--   ppEntryToken     = newToken( "pp_entry",    isDouble )
--   ppKeywordToken   = newToken( "pp_keyword",  ppKeyword ) -- ppKeyword can be "@".
--
--   commentToken     = { type="comment",     representation=string, value=string, long=isLongForm }
--   identifierToken  = { type="identifier",  representation=string, value=string }
--   keywordToken     = { type="keyword",     representation=string, value=string }
--   numberToken      = { type="number",      representation=string, value=number }
--   punctuationToken = { type="punctuation", representation=string, value=string }
--   stringToken      = { type="string",      representation=string, value=string, long=isLongForm }
--   whitespaceToken  = { type="whitespace",  representation=string, value=string }
--   ppEntryToken     = { type="pp_entry",    representation=string, value=string, double=isDouble }
--   ppKeywordToken   = { type="pp_keyword",  representation=string, value=string }
--
-- Number formats:
--   "integer"      E.g. 42
--   "int"          Same as integer, e.g. 42
--   "float"        E.g. 3.14
--   "scientific"   E.g. 0.7e+12
--   "SCIENTIFIC"   E.g. 0.7E+12 (upper case)
--   "e"            Same as scientific, e.g. 0.7e+12
--   "E"            Same as SCIENTIFIC, e.g. 0.7E+12 (upper case)
--   "hexadecimal"  E.g. 0x19af
--   "HEXADECIMAL"  E.g. 0x19AF (upper case)
--   "hex"          Same as hexadecimal, e.g. 0x19af
--   "HEX"          Same as HEXADECIMAL, e.g. 0x19AF (upper case)
--   "auto"         Note: Infinite numbers and NaN always get automatic format.
--
function metaFuncs.newToken(tokType, ...)
	if tokType == "comment" then
		local comment, long = ...
		long                = not not (long or comment:find"[\r\n]")
		assertarg(2, comment, "string")

		local repr
		if long then
			local equalSigns = ""

			while comment:find(F("]%s]", equalSigns), 1, true) do
				equalSigns = equalSigns.."="
			end

			repr = F("--[%s[%s]%s]", equalSigns, comment, equalSigns)

		else
			repr = F("--%s\n", comment)
		end

		return {type="comment", representation=repr, value=comment, long=long}

	elseif tokType == "identifier" then
		local ident = ...
		assertarg(2, ident, "string")

		if ident == "" then
			error("Identifier length is 0.", 2)
		elseif not ident:find"^[%a_][%w_]*$" then
			errorf(2, "Bad identifier format: '%s'", ident)
		end

		return {type="identifier", representation=ident, value=ident}

	elseif tokType == "keyword" then
		local keyword = ...
		assertarg(2, keyword, "string")

		if not KEYWORDS[keyword] then
			errorf(2, "Bad keyword '%s'.", keyword)
		end

		return {type="keyword", representation=keyword, value=keyword}

	elseif tokType == "number" then
		local n, numberFormat = ...
		numberFormat          = numberFormat or "auto"
		assertarg(2, n,            "number")
		assertarg(3, numberFormat, "string")

		-- Some of these are technically multiple other tokens. We could raise an error but ehhh...
		local numStr = (
			n ~=  n   and "(0/0)"  or
			n ==  1/0 and "(1/0)"  or
			n == -1/0 and "(-1/0)" or
			numberFormatters[numberFormat] and numberFormatters[numberFormat](n) or
			errorf(2, "Invalid number format '%s'.", numberFormat)
		)

		return {type="number", representation=numStr, value=n}

	elseif tokType == "punctuation" then
		local symbol = ...
		assertarg(2, symbol, "string")

		-- Note: "!" and "!!" are of a different token type (pp_entry).
		if not PUNCTUATION[symbol] then
			errorf(2, "Bad symbol '%s'.", symbol)
		end

		return {type="punctuation", representation=symbol, value=symbol}

	elseif tokType == "string" then
		local s, long = ...
		long          = not not long
		assertarg(2, s, "string")

		local repr

		if long then
			local equalSigns = ""

			while s:find(F("]%s]", equalSigns), 1, true) do
				equalSigns = equalSigns .. "="
			end

			repr = F("[%s[%s]%s]", equalSigns, s, equalSigns)

		else
			repr = toLua(s)
		end

		return {type="string", representation=repr, value=s, long=long}

	elseif tokType == "whitespace" then
		local whitespace = ...
		assertarg(2, whitespace, "string")

		if whitespace == "" then
			error("String is empty.", 2)
		elseif whitespace:find"%S" then
			error("String contains non-whitespace characters.", 2)
		end

		return {type="whitespace", representation=whitespace, value=whitespace}

	elseif tokType == "pp_entry" then
		local double = ...
		assertarg(2, double, "boolean")

		local symbol = double and "!!" or "!"

		return {type="pp_entry", representation=symbol, value=symbol, double=double}

	elseif tokType == "pp_keyword" then
		local keyword = ...
		assertarg(2, keyword, "string")

		if keyword == "@" then
			return {type="pp_keyword", representation="@@", value="insert"}
		elseif not PREPROCESSOR_KEYWORDS[keyword] then
			errorf(2, "Bad preprocessor keyword '%s'.", keyword)
		else
			return {type="pp_keyword", representation="@"..keyword, value=keyword}
		end

	else
		errorf(2, "Invalid token type '%s'.", tostring(tokType))
	end
end

-- concatTokens()
--   luaString = concatTokens( tokens )
--   Concatenate tokens by their representations.
function metaFuncs.concatTokens(tokens)
	return _concatTokens(tokens, nil, false, nil, nil)
end

-- Extra stuff used by the command line program:
metaFuncs.tryToFormatError = tryToFormatError



for k, v in pairs(metaFuncs) do  metaEnv[k] = v  end

metaEnv.__LUA = metaEnv.outputLua
metaEnv.__VAL = metaEnv.outputValue

function metaEnv.__TOLUA(v)
	return (assert(toLua(v)))
end
function metaEnv.__ASSERTLUA(lua)
	if type(lua) ~= "string" then
		error("Value is not Lua code.", 2)
	end
	return lua
end



local function getLineCountWithCode(tokens)
	local lineCount = 0
	local lastLine  = 0

	for _, tok in ipairs(tokens) do
		if not USELESS_TOKENS[tok.type] and tok.lineEnd > lastLine then
			lineCount = lineCount+(tok.lineEnd-tok.line+1)
			lastLine  = tok.lineEnd
		end
	end

	return lineCount
end

local function popTokens(tokens, lastIndexToPop)
	for i = #tokens, lastIndexToPop, -1 do
		tokens[i] = nil
	end
end
local function popUseless(tokens)
	for i = #tokens, 1, -1 do
		if not USELESS_TOKENS[tokens[i].type] then  break  end
		tokens[i] = nil
	end
end

local function isLastToken(tokens, ...)
	return isTokenAndNotNil(tokens[#tokens], ...)
end

local function newTokenAt(tok, locationTok)
	tok.line     = tok.line     or locationTok and locationTok.line
	tok.lineEnd  = tok.lineEnd  or locationTok and locationTok.lineEnd
	tok.position = tok.position or locationTok and locationTok.position
	tok.file     = tok.file     or locationTok and locationTok.file
	return tok
end

local function doEarlyExpansions(tokensToExpand, fileBuffers, params, stats)
	--
	-- Here we expand simple things that makes it easier for
	-- doLateExpansions*() to do more elaborate expansions.
	--
	-- Expand expressions:
	--   @file
	--   @line
	--   ` ... `
	--
	if not stats.hasPreprocessorCode then
		return tokensToExpand
	end

	local tokenStack = {} -- We process the last token first, and we may push new tokens onto the stack.
	local tokens     = {} -- To return.

	for i = #tokensToExpand, 1, -1 do
		tableInsert(tokenStack, tokensToExpand[i])
	end

	while tokenStack[1] do
		local tok = tokenStack[#tokenStack]

		-- Keyword.
		if isToken(tok, "pp_keyword") then
			local ppKeywordTok = tok

			-- @file
			-- @line
			if ppKeywordTok.value == "file" then
				tableRemove(tokenStack) -- '@file'
				tableInsert(tokens, newTokenAt({type="string", value=ppKeywordTok.file, representation=F("%q",ppKeywordTok.file)}, ppKeywordTok))
			elseif ppKeywordTok.value == "line" then
				tableRemove(tokenStack) -- '@line'
				tableInsert(tokens, newTokenAt({type="number", value=ppKeywordTok.line, representation=F(" %d ",ppKeywordTok.line)}, ppKeywordTok)) -- Is it fine for the representation to have spaces? Probably.

			else
				-- Expand later.
				tableInsert(tokens, ppKeywordTok)
				tableRemove(tokenStack) -- '@...'
			end

		-- Backtick string.
		elseif isToken(tok, "string") and tok.representation:find"^`" then
			local stringTok = tok
			stringTok.representation = F("%q", stringTok.value)

			tableInsert(tokens, stringTok)
			tableRemove(tokenStack) -- the string

		-- Anything else.
		else
			tableInsert(tokens, tok)
			tableRemove(tokenStack) -- anything
		end
	end--while tokenStack

	return tokens
end

local function doLateExpansionsResources(tokensToExpand, fileBuffers, params, stats)
	--
	-- Expand expressions:
	--   @insert "name"
	--
	if not stats.hasPreprocessorCode then
		return tokensToExpand
	end

	local tokenStack = {} -- We process the last token first, and we may push new tokens onto the stack.
	local tokens     = {} -- To return.

	local insertCount = 0

	for i = #tokensToExpand, 1, -1 do
		tableInsert(tokenStack, tokensToExpand[i])
	end

	while tokenStack[1] do
		local tok = tokenStack[#tokenStack]

		-- Keyword.
		if isToken(tok, "pp_keyword") then
			local ppKeywordTok   = tok
			local tokNext, iNext = getNextUsableToken(tokenStack, #tokenStack-1, nil, -1)

			-- @insert "name"
			if ppKeywordTok.value == "insert" and isTokenAndNotNil(tokNext, "string") and tokNext.file == ppKeywordTok.file then
				local nameTok = tokNext
				popTokens(tokenStack, iNext) -- the string

				local toInsertName = nameTok.value
				local toInsertLua  = fileBuffers[toInsertName]

				if not toInsertLua then
					if params.onInsert then
						toInsertLua = params.onInsert(toInsertName)

						if type(toInsertLua) ~= "string" then
							errorAtToken(
								fileBuffers, nameTok, nameTok.position+1,
								"Parser/MetaProgram", "Expected a string from params.onInsert(). (Got %s)", type(toInsertLua)
							)
						end

					else
						local err
						toInsertLua, err = getFileContents(toInsertName, true)

						if not toInsertLua then
							errorAtToken(fileBuffers, nameTok, nameTok.position+1, "Parser", "Could not read file '%s'. (%s)", toInsertName, tostring(err))
						end
					end

					fileBuffers[toInsertName] = toInsertLua
					tableInsert(stats.insertedNames, toInsertName)

				else
					insertCount = insertCount+1 -- Note: We don't count insertions of newly encountered files.

					if insertCount > MAX_DUPLICATE_FILE_INSERTS then
						errorAtToken(
							fileBuffers, nameTok, nameTok.position+1, "Parser",
							"Too many duplicate inserts. We may be stuck in a recursive loop. (Unique files inserted so far: %s)",
							table.concat(stats.insertedNames, ", ")
						)
					end
				end

				local toInsertTokens = _tokenize(toInsertLua, toInsertName, true, params.backtickStrings, params.jitSyntax)
				toInsertTokens       = doEarlyExpansions(toInsertTokens, fileBuffers, params, stats)

				for i = #toInsertTokens, 1, -1 do
					tableInsert(tokenStack, toInsertTokens[i])
				end

				local lastTok            = toInsertTokens[#toInsertTokens]
				stats.processedByteCount = stats.processedByteCount + #toInsertLua
				stats.lineCount          = stats.lineCount          + (lastTok and lastTok.line + countString(lastTok.representation, "\n", true) or 0)
				stats.lineCountCode      = stats.lineCountCode      + getLineCountWithCode(toInsertTokens)

			-- @insert identifier ( argument1, ... )
			-- @insert identifier " ... "
			-- @insert identifier { ... }
			-- @insert identifier !( ... )
			-- @insert identifier !!( ... )
			elseif ppKeywordTok.value == "insert" and isTokenAndNotNil(tokNext, "identifier") and tokNext.file == ppKeywordTok.file then
				local identTok = tokNext
				tokNext, iNext = getNextUsableToken(tokenStack, iNext-1, nil, -1)

				if not (tokNext and (
					tokNext.type == "string"
					or (tokNext.type == "punctuation" and isAny(tokNext.value, "(","{",".",":","["))
					or tokNext.type == "pp_entry"
				)) then
					errorAtToken(fileBuffers, identTok, identTok.position+#identTok.representation, "Macro", "Syntax error: Expected '(' after macro name '%s'.", identTok.value)
				end

				-- Expand later.
				tableInsert(tokens, tok)
				tableRemove(tokenStack) -- '@insert'

			elseif ppKeywordTok.value == "insert" then
				errorAtToken(
					fileBuffers, ppKeywordTok, (tokNext and tokNext.position or ppKeywordTok.position+#ppKeywordTok.representation),
					"Parser", "Expected a string or identifier after %s.", ppKeywordTok.representation
				)

			else
				errorAtToken(fileBuffers, ppKeywordTok, nil, "Macro", "Internal error. (%s)", ppKeywordTok.value)
			end

		-- Anything else.
		else
			tableInsert(tokens, tok)
			tableRemove(tokenStack) -- anything
		end
	end--while tokenStack

	return tokens
end

-- luaString = insertTokensAsStringLiteral( tokens, tokensToConcat, locationToken )
local function insertTokensAsStringLiteral(tokens, tokensToConcat, locationTok)
	local lua = _concatTokens(tokensToConcat, nil, false, nil, nil)

	tableInsert(tokens, newTokenAt({
		type           = "string",
		value          = lua,
		representation = F("%q", lua):gsub("\n", "n"),
		long           = false,
	}, locationTok))

	return lua
end

local function prepareForNewPartOfMacroArgument(tokens, argNonPpTokens, argNonPpStartTok, upcomingTok, isFirstPart)
	if not isFirstPart then
		tableInsert(tokens, newTokenAt({type="punctuation", value="..", representation=".."}, argNonPpStartTok))
	end
	if argNonPpTokens[1] then
		insertTokensAsStringLiteral(tokens, argNonPpTokens, argNonPpStartTok)
		tableInsert(tokens, newTokenAt({type="punctuation", value="..", representation=".."}, upcomingTok))
	end
end

local function processPreprocessorBlockInMacroArgument(tokens, fileBuffers, tokenStack)
	local ppEntryTok = tableRemove(tokenStack) -- '!' or '!!'
	assert(isToken(ppEntryTok, "pp_entry"))

	local ident = (ppEntryTok.value == "!") and "__TOLUA" or "__ASSERTLUA"
	tableInsert(tokens, newTokenAt({type="identifier", value=ident, representation=ident}, ppEntryTok))
	tableInsert(tokens, tableRemove(tokenStack)) -- '('
	local exprStartTokIndex = #tokens

	local parensDepth = 1

	while true do
		local tok = tableRemove(tokenStack) -- anything
		if not tok then
			errorAtToken(fileBuffers, ppEntryTok, nil, "Parser", "Missing end of preprocessor block.")
		end
		tableInsert(tokens, tok)

		if isToken(tok, "punctuation", "(") then
			parensDepth = parensDepth + 1
		elseif isToken(tok, "punctuation", ")") then
			parensDepth = parensDepth - 1
			if parensDepth == 0 then  break  end
		elseif tok.type:find"^pp_" then
			errorAtToken(fileBuffers, tok, nil, "Parser", "Preprocessor token inside metaprogram (starting %s).", getRelativeLocationText(ppEntryTok, tok))
		end
	end

	local chunk, err = loadLuaString("return ".._concatTokens(tokens, nil, false, exprStartTokIndex, nil), "@")
	if not chunk then
		errorAtToken(fileBuffers, tokens[exprStartTokIndex+1], nil, "Macro", "Syntax error: Invalid expression in preprocessor block.")
		-- err = err:gsub("^:%d+: ", "")
		-- errorAtToken(fileBuffers, tokens[exprStartTokIndex+1], nil, "Macro", "Syntax error: Invalid expression in preprocessor block. (%s)", err)
	end
end

local function expandMacro(tokens, fileBuffers, tokenStack, macroStartTok, isNested)
	-- @Robustness: Make sure key tokens came from the same source file.
	-- Add '!!(' for start of preprocessor block.
	if isNested then
		tableInsert(tokens, newTokenAt({type="identifier", value="__ASSERTLUA", representation="__ASSERTLUA"}, macroStartTok))
	else
		tableInsert(tokens, newTokenAt({type="pp_entry", value="!!", representation="!!", double=true}, macroStartTok))
	end
	tableInsert(tokens, newTokenAt({type="punctuation", value="(", representation="("}, macroStartTok))

	--
	-- Callee.
	--

	-- Add 'ident' for start of (or whole) callee.
	local tokNext, iNext = getNextUsableToken(tokenStack, #tokenStack-1, nil, -1)
	if not isTokenAndNotNil(tokNext, "identifier") then
		printErrorTraceback("Internal error.")
		errorAtToken(fileBuffers, tokNext, nil, "Macro", "Internal error. (%s)", (tokNext and tokNext.type or "?"))
	end
	popTokens(tokenStack, iNext) -- the identifier
	tableInsert(tokens, tokNext)
	local lastCalleeTok = tokNext

	-- Maybe add '.field[expr]:method' for rest of callee.
	tokNext, iNext = getNextUsableToken(tokenStack, #tokenStack, nil, -1)

	while tokNext do
		if isToken(tokNext, "punctuation", ".") or isToken(tokNext, "punctuation", ":") then
			local punctTok = tokNext
			popTokens(tokenStack, iNext) -- '.' or ':'
			tableInsert(tokens, tokNext)

			tokNext, iNext = getNextUsableToken(tokenStack, #tokenStack, nil, -1)
			if not tokNext then
				errorAfterToken(fileBuffers, punctTok, "Macro", "Syntax error: Expected an identifier after '%s'.", punctTok.value)
			end
			popTokens(tokenStack, iNext) -- the identifier
			tableInsert(tokens, tokNext)

			lastCalleeTok  = tokNext
			tokNext, iNext = getNextUsableToken(tokenStack, #tokenStack, nil, -1)

			if punctTok.value == ":" then  break  end

		elseif isToken(tokNext, "punctuation", "[") then
			local punctTok = tokNext
			popTokens(tokenStack, iNext) -- '['
			tableInsert(tokens, tokNext)

			local bracketBalance = 1

			while true do
				tokNext = tableRemove(tokenStack) -- anything
				if not tokNext then
					errorAtToken(
						fileBuffers, punctTok, nil, "Macro",
						"Syntax error: Could not find matching bracket before EOF. (Macro starts %s)",
						getRelativeLocationText(macroStartTok, punctTok)
					)
				end
				tableInsert(tokens, tokNext)

				if isToken(tokNext, "punctuation", "[") then
					bracketBalance = bracketBalance + 1
				elseif isToken(tokNext, "punctuation", "]") then
					bracketBalance = bracketBalance - 1
					if bracketBalance == 0 then  break  end
				elseif tokNext.type:find"^pp_" then
					errorAtToken(fileBuffers, tokNext, nil, "Macro", "Preprocessor token inside metaprogram/macro name expression (starting %s).", getRelativeLocationText(macroStartTok, tokNext))
				end
			end

			lastCalleeTok  = tokNext
			tokNext, iNext = getNextUsableToken(tokenStack, #tokenStack, nil, -1)

		else
			break
		end
	end

	--
	-- Arguments.
	--

	-- @insert identifier " ... "
	if isTokenAndNotNil(tokNext, "string") then
		local stringTok = tokNext
		popTokens(tokenStack, iNext) -- the string

		-- Note: We don't need parenthesis for this macro variant.
		stringTok.value          = stringTok.representation
		stringTok.representation = F("%q", stringTok.value):gsub("\n", "n")
		tableInsert(tokens, stringTok)

	-- @insert identifier { ... }
	elseif isTokenAndNotNil(tokNext, "punctuation", "{") then
		popTokens(tokenStack, iNext) -- '{'

		--
		-- (Similar code as `@insert identifier()` below.)
		--

		-- Add '(' for start of call.
		tableInsert(tokens, newTokenAt({type="punctuation", value="(", representation="("}, tokNext))

		-- Collect tokens for the table arg.
		-- We're looking for the closing '}'.
		local argNonPpStartTok = tokNext -- Used for location info.
		local argNonPpTokens   = {argNonPpStartTok}
		local bracketDepth     = 1
		local isFirstPart      = true

		while true do
			local len = #tokenStack
			local tok = tokenStack[len]

			if not tok then
				errorAtToken(fileBuffers, argNonPpStartTok, nil, "Macro", "Syntax error: Could not find end of table constructor before EOF.")

			-- Preprocessor block in macro.
			elseif tok.type == "pp_entry" and isTokenAndNotNil(tokenStack[len-1], "punctuation", "(") then
				prepareForNewPartOfMacroArgument(tokens, argNonPpTokens, argNonPpStartTok, tok, isFirstPart)
				processPreprocessorBlockInMacroArgument(tokens, fileBuffers, tokenStack)

				argNonPpStartTok = tokenStack[#tokenStack] -- Could be nil, but that should be fine I think.
				argNonPpTokens   = argNonPpTokens[1] and {} or argNonPpTokens
				isFirstPart      = false

			-- Nested macro.
			elseif isToken(tok, "pp_keyword", "insert") then
				prepareForNewPartOfMacroArgument(tokens, argNonPpTokens, argNonPpStartTok, tok, isFirstPart)
				expandMacro(tokens, fileBuffers, tokenStack, tok, true)

				argNonPpStartTok = tokenStack[#tokenStack] -- Could be nil, but that should be fine I think.
				argNonPpTokens   = argNonPpTokens[1] and {} or argNonPpTokens
				isFirstPart      = false

			-- Other preprocessor code in macro. (Not sure we ever get here.)
			elseif tok.type:find"^pp_" then
				errorAtToken(fileBuffers, tok, nil, "Macro", "Unsupported preprocessor code in macro. (Macro starts %s)", getRelativeLocationText(macroStartTok, tok))

			-- End of table and argument.
			elseif bracketDepth == 1 and isToken(tok, "punctuation", "}") then
				tableInsert(argNonPpTokens, tableRemove(tokenStack)) -- '}'
				break

			-- Normal token.
			else
				if isToken(tok, "punctuation", "{") then
					bracketDepth = bracketDepth + 1
				elseif isToken(tok, "punctuation", "}") then
					bracketDepth = bracketDepth - 1
				end
				tableInsert(argNonPpTokens, tableRemove(tokenStack)) -- anything
			end
		end

		-- Add last part of argument value.
		if argNonPpTokens[1] then
			if not isFirstPart then
				tableInsert(tokens, newTokenAt({type="punctuation", value="..", representation=".."}, argNonPpStartTok))
			end
			local argStr = insertTokensAsStringLiteral(tokens, argNonPpTokens, argNonPpStartTok)

			if isFirstPart then
				local chunk, err = loadLuaString("return ("..argStr..")", "@")

				if not chunk then
					errorAtToken(fileBuffers, argNonPpStartTok, nil, "Macro", "Syntax error: Invalid table constructor expression.")
					-- err = err:gsub("^:%d+: ", "")
					-- errorAtToken(fileBuffers, argNonPpStartTok, nil, "Macro", "Syntax error: Invalid table constructor expression. (%s)", err)
				end
			end
		end

		-- Add ')' for end of call.
		tableInsert(tokens, newTokenAt({type="punctuation", value=")", representation=")"}, tokens[#tokens]))

	-- @insert identifier ( argument1, ... )
	elseif isTokenAndNotNil(tokNext, "punctuation", "(") then
		-- Apply the same 'ambiguous syntax' rule as Lua.
		if isTokenAndNotNil(tokenStack[iNext+1], "whitespace") and tokenStack[iNext+1].value:find"\n" then
			errorAtToken(fileBuffers, tokNext, nil, "Macro", "Ambiguous syntax near '(' - part of macro, or new statement?")
		end

		local parensStartTok = tokNext
		popTokens(tokenStack, iNext) -- '('

		-- Add '(' for start of call.
		tableInsert(tokens, parensStartTok)

		tokNext, iNext = getNextUsableToken(tokenStack, #tokenStack, nil, -1)
		if isTokenAndNotNil(tokNext, "punctuation", ")") then
			popUseless(tokenStack)

		else
			local lastArgSeparatorTok = nil

			for argNum = 1, 1/0 do
				-- Add ',' as argument separator.
				if lastArgSeparatorTok then
					tableInsert(tokens, lastArgSeparatorTok)
				end

				-- Collect tokens for this arg.
				-- We're looking for the next comma at depth 0 or closing ')'.
				local argNonPpStartTok = tokenStack[#tokenStack] -- Used for location info.
				local argNonPpTokens   = {}
				local depthStack       = {}
				local isFirstPart      = true
				popUseless(tokenStack) -- Trim leading useless tokens.

				while true do
					local len = #tokenStack
					local tok = tokenStack[len]

					if not tok then
						errorAtToken(fileBuffers, parensStartTok, nil, "Macro", "Syntax error: Could not find end of argument list before EOF.")

					-- Preprocessor block in macro.
					elseif tok.type == "pp_entry" and isTokenAndNotNil(tokenStack[len-1], "punctuation", "(") then
						prepareForNewPartOfMacroArgument(tokens, argNonPpTokens, argNonPpStartTok, tok, isFirstPart)
						processPreprocessorBlockInMacroArgument(tokens, fileBuffers, tokenStack)

						argNonPpStartTok = tokenStack[#tokenStack] -- Could be nil, but that should be fine I think.
						argNonPpTokens   = argNonPpTokens[1] and {} or argNonPpTokens
						isFirstPart      = false

					-- Nested macro.
					elseif isToken(tok, "pp_keyword", "insert") then
						prepareForNewPartOfMacroArgument(tokens, argNonPpTokens, argNonPpStartTok, tok, isFirstPart)
						expandMacro(tokens, fileBuffers, tokenStack, tok, true)

						argNonPpStartTok = tokenStack[#tokenStack] -- Could be nil, but that should be fine I think.
						argNonPpTokens   = argNonPpTokens[1] and {} or argNonPpTokens
						isFirstPart      = false

					-- Other preprocessor code in macro. (Not sure we ever get here.)
					elseif tok.type:find"^pp_" then
						errorAtToken(fileBuffers, tok, nil, "Macro", "Unsupported preprocessor code in macro. (Macro starts %s)", getRelativeLocationText(macroStartTok, tok))

					-- End of argument.
					elseif not depthStack[1] and (isToken(tok, "punctuation", ",") or isToken(tok, "punctuation", ")")) then
						break

					-- Normal token.
					else
						if isToken(tok, "punctuation", "(") then
							tableInsert(depthStack, {startToken=tok, [1]="punctuation", [2]=")"})
						elseif isToken(tok, "punctuation", "[") then
							tableInsert(depthStack, {startToken=tok, [1]="punctuation", [2]="]"})
						elseif isToken(tok, "punctuation", "{") then
							tableInsert(depthStack, {startToken=tok, [1]="punctuation", [2]="}"})
						elseif isToken(tok, "keyword", "function") or isToken(tok, "keyword", "if") or isToken(tok, "keyword", "do") then
							tableInsert(depthStack, {startToken=tok, [1]="keyword", [2]="end"})
						elseif isToken(tok, "keyword", "repeat") then
							tableInsert(depthStack, {startToken=tok, [1]="keyword", [2]="until"})

						elseif
							isToken(tok, "punctuation", ")")   or
							isToken(tok, "punctuation", "]")   or
							isToken(tok, "punctuation", "}")   or
							isToken(tok, "keyword",     "end") or
							isToken(tok, "keyword",     "until")
						then
							if not depthStack[1] then
								errorAtToken(fileBuffers, tok, nil, "Macro", "Unexpected '%s'.", tok.value)
							elseif not isToken(tok, unpack(depthStack[#depthStack])) then
								local startTok = depthStack[#depthStack].startToken
								errorAtToken(
									fileBuffers, tok, nil, "Macro",
									"Expected '%s' (to close '%s' %s) but got '%s'.",
									depthStack[#depthStack][2], startTok.value, getRelativeLocationText(startTok, tok), tok.value
								)
							end
							tableRemove(depthStack)
						end

						tableInsert(argNonPpTokens, tableRemove(tokenStack)) -- anything
					end
				end

				-- Add last part of argument value.
				popUseless(argNonPpTokens) -- Trim trailing useless tokens.

				if argNonPpTokens[1] then
					if not isFirstPart then
						tableInsert(tokens, newTokenAt({type="punctuation", value="..", representation=".."}, argNonPpStartTok))
					end
					local argStr = insertTokensAsStringLiteral(tokens, argNonPpTokens, argNonPpStartTok)

					if isFirstPart then
						local chunk, err = loadLuaString("return ("..argStr..")", "@")

						if not chunk then
							errorAtToken(fileBuffers, argNonPpStartTok, nil, "Macro", "Syntax error: Invalid expression for argument #%d.", argNum)
							-- err = err:gsub("^:%d+: ", "")
							-- errorAtToken(fileBuffers, argNonPpStartTok, nil, "Macro", "Syntax error: Invalid expression for argument #%d. (%s)", argNum, err)
						end
					end

				elseif isFirstPart then
					-- There were no useful tokens for the argument!
					errorAtToken(fileBuffers, argNonPpStartTok, nil, "Macro", "Syntax error: Expected argument #%d.", argNum)
				end

				-- Do next argument or finish arguments.
				if isLastToken(tokenStack, "punctuation", ")") then
					break
				end

				lastArgSeparatorTok = tableRemove(tokenStack) -- ','
				assert(isToken(lastArgSeparatorTok, "punctuation", ","))
			end--for argNum
		end

		-- Add ')' for end of call.
		tableInsert(tokens, tableRemove(tokenStack)) -- ')'

	-- @insert identifier !( ... )
	-- @insert identifier !!( ... )
	elseif isTokenAndNotNil(tokNext, "pp_entry") then
		popTokens(tokenStack, iNext+1) -- until '!' or '!!'

		-- Add '(' for start of call.
		if not isTokenAndNotNil(tokenStack[#tokenStack-1], "punctuation", "(") then
			local tok = (tokenStack[#tokenStack-1] or tokenStack[#tokenStack])
			errorAtToken(fileBuffers, tok, nil, "Macro", "Expected '(' after '!'.")
		end
		tableInsert(tokens, newTokenAt({type="punctuation", value="(", representation="("}, tokNext))

		processPreprocessorBlockInMacroArgument(tokens, fileBuffers, tokenStack)

		-- Add ')' for end of call.
		assert(isTokenAndNotNil(tokens[#tokens], "punctuation", ")"))
		tableInsert(tokens, newTokenAt({type="punctuation", value=")", representation=")"}, tokens[#tokens]))

	else
		errorAfterToken(fileBuffers, lastCalleeTok, "Macro", "Syntax error: Expected '(' after macro name.")
	end

	--
	-- End.
	--

	-- Add ')' for end of preprocessor block.
	tableInsert(tokens, newTokenAt({type="punctuation", value=")", representation=")"}, tokens[#tokens]))
end

local function doLateExpansionsMacros(tokensToExpand, fileBuffers, params, stats)
	--
	-- Expand expressions:
	--   @insert identifier ( argument1, ... )
	--   @insert identifier " ... "
	--   @insert identifier { ... }
	--   @insert identifier !( ... )
	--   @insert identifier !!( ... )
	--
	if not stats.hasPreprocessorCode then
		return tokensToExpand
	end

	local tokenStack = {} -- We process the last token first, and we may push new tokens onto the stack.
	local tokens     = {} -- To return.

	for i = #tokensToExpand, 1, -1 do
		tableInsert(tokenStack, tokensToExpand[i])
	end

	while tokenStack[1] do
		local tok = tokenStack[#tokenStack]

		-- Keyword.
		if isToken(tok, "pp_keyword") then
			local ppKeywordTok = tok

			-- @insert identifier ( argument1, ... )
			-- @insert identifier " ... "
			-- @insert identifier { ... }
			-- @insert identifier !( ... )
			-- @insert identifier !!( ... )
			if ppKeywordTok.value == "insert" then
				expandMacro(tokens, fileBuffers, tokenStack, ppKeywordTok, false)

			else
				errorAtToken(fileBuffers, ppKeywordTok, nil, "Macro", "Internal error. (%s)", ppKeywordTok.value)
			end

		-- Anything else.
		else
			tableInsert(tokens, tok)
			tableRemove(tokenStack) -- anything
		end
	end--while tokenStack

	return tokens
end

local function _processFileOrString(params, isFile)
	if isFile then
		if not params.pathIn  then  error("Missing 'pathIn' in params.",  2)  end
		if not params.pathOut then  error("Missing 'pathOut' in params.", 2)  end

		if params.pathOut == params.pathIn then  error("'pathIn' and 'pathOut' are the same in params.", 2)  end

	else
		if not params.code then  error("Missing 'code' in params.", 2)  end
	end

	local luaUnprocessed, pathIn

	if isFile then
		local err

		pathIn              = params.pathIn
		luaUnprocessed, err = getFileContents(pathIn, true)

		if not luaUnprocessed then
			errorf("Could not read file '%s'. (%s)", pathIn, err)
		end

		currentPathIn  = params.pathIn
		currentPathOut = params.pathOut

	else
		pathIn         = "<code>"
		luaUnprocessed = params.code
	end

	local fileBuffers = {[pathIn]=luaUnprocessed} -- Doesn't have to be the contents of files if params.onInsert() is defined.

	local specialFirstLine, rest = luaUnprocessed:match"^(#[^\r\n]*\r?\n?)(.*)$"
	if specialFirstLine then
		luaUnprocessed = rest
	end

	local tokens = _tokenize(luaUnprocessed, pathIn, true, params.backtickStrings, params.jitSyntax)
	-- printTokens(tokens)

	-- Info variables.
	local lastTok = tokens[#tokens]

	local stats = {
		processedByteCount  = #luaUnprocessed,
		lineCount           = (specialFirstLine and 1 or 0) + (lastTok and lastTok.line + countString(lastTok.representation, "\n", true) or 0),
		lineCountCode       = getLineCountWithCode(tokens),
		tokenCount          = 0, -- Set later.
		hasPreprocessorCode = false,
		hasMetaprogram      = false,
		insertedNames       = {},
	}

	for _, tok in ipairs(tokens) do
		if isToken(tok, "pp_entry") or isToken(tok, "pp_keyword", "insert") then
			stats.hasPreprocessorCode = true
			stats.hasMetaprogram      = true
			break
		elseif isToken(tok, "pp_keyword") or (isToken(tok, "string") and tok.representation:find"^`") then
			stats.hasPreprocessorCode = true
			-- Keep going as there may be metaprogram.
		end
	end

	tokens           = doEarlyExpansions        (tokens, fileBuffers, params, stats)
	tokens           = doLateExpansionsResources(tokens, fileBuffers, params, stats)
	tokens           = doLateExpansionsMacros   (tokens, fileBuffers, params, stats)
	stats.tokenCount = #tokens

	-- Generate metaprogram.
	--==============================================================

	local tokensToProcess = {}
	local metaParts       = {}

	local tokenIndex      = 1
	local ln              = 0

	local function flushTokensToProcess()
		if not tokensToProcess[1] then  return  end

		local lua = _concatTokens(tokensToProcess, ln, params.addLineNumbers, nil, nil)
		local luaMeta

		if isDebug then
			luaMeta = F("__LUA(%q)\n", lua):gsub("\\\n", "\\n")
		else
			luaMeta = F("__LUA%q", lua)
		end

		tableInsert(metaParts, luaMeta)
		ln = tokensToProcess[#tokensToProcess].line

		tokensToProcess = {}
	end

	local function outputFinalDualValueStatement(metaLineIndexStart, metaLineIndexEnd)
		-- We expect the statement to look like any of these:
		-- !!local x = ...
		-- !!x = ...

		-- Check whether local or not.
		local iPrev, tok, i = metaLineIndexStart-1, getNextUsableToken(tokens, metaLineIndexStart, metaLineIndexEnd)
		local isLocal       = isTokenAndNotNil(tok, "keyword", "local")

		if isLocal then
			iPrev, tok, i = i, getNextUsableToken(tokens, i+1, metaLineIndexEnd)
		end

		-- Check for identifier.
		if isTokenAndNotNil(tok, "identifier") then
			-- void
		elseif isLocal then
			errorAfterToken(fileBuffers, tokens[iPrev], "Parser/DualCodeLine", "Expected an identifier.")
		else
			errorAfterToken(fileBuffers, tokens[iPrev], "Parser/DualCodeLine", "Expected an identifier or 'local'.")
		end

		local identTokens = {tok}
		iPrev, tok, i     = i, getNextUsableToken(tokens, i+1, metaLineIndexEnd)

		while isTokenAndNotNil(tok, "punctuation", ",") do
			iPrev, tok, i = i, getNextUsableToken(tokens, i+1, metaLineIndexEnd)
			if not isTokenAndNotNil(tok, "identifier") then
				errorAfterToken(fileBuffers, tokens[iPrev], "Parser/DualCodeLine", "Expected an identifier after ','.")
			end

			tableInsert(identTokens, tok)
			iPrev, tok, i = i, getNextUsableToken(tokens, i+1, metaLineIndexEnd)
		end

		-- Check for "=".
		if not isTokenAndNotNil(tok, "punctuation", "=") then
			errorAfterToken(fileBuffers, tokens[iPrev], "Parser/DualCodeLine", "Expected '='.")
		end

		local indexAfterEqualSign = i+1

		-- Check if the rest of the line is an expression.
		local parts = {"return'',"}
		insertTokenRepresentations(parts, tokens, indexAfterEqualSign, metaLineIndexEnd)

		if not loadLuaString(table.concat(parts)) then
			iPrev, tok, i = i, getNextUsableToken(tokens, indexAfterEqualSign, metaLineIndexEnd)
			if tok then
				errorAtToken(fileBuffers, tok, nil, "Parser/DualCodeLine", "Invalid value expression after '='.")
			else
				errorAfterToken(fileBuffers, tokens[indexAfterEqualSign-1], "Parser/DualCodeLine", "Invalid value expression after '='.")
			end
		end

		-- Output.
		local s = metaParts[#metaParts]
		if s and s:sub(#s) ~= "\n" then
			tableInsert(metaParts, "\n")
		end

		if isDebug then
			tableInsert(metaParts, '__LUA("')

			if params.addLineNumbers then
				outputLineNumber(metaParts, tokens[metaLineIndexStart].line)
			end

			if isLocal then  tableInsert(metaParts, "local ")  end

			for identIndex, identTok in ipairs(identTokens) do
				if identIndex > 1 then  tableInsert(metaParts, ", ")  end
				tableInsert(metaParts, identTok.value)
			end
			tableInsert(metaParts, ' = ")')
			for identIndex, identTok in ipairs(identTokens) do
				if identIndex > 1 then  tableInsert(metaParts, '; __LUA(", ")')  end
				tableInsert(metaParts, "; __VAL(")
				tableInsert(metaParts, identTok.value)
				tableInsert(metaParts, ")")
			end

			if isToken(getNextUsableToken(tokens, metaLineIndexEnd, 1, -1), "punctuation", ";") then
				tableInsert(metaParts, '; __LUA(";\\n");\n')
			else
				tableInsert(metaParts, '; __LUA("\\n")\n')
			end

		else
			tableInsert(metaParts, '__LUA"')

			if params.addLineNumbers then
				outputLineNumber(metaParts, tokens[metaLineIndexStart].line)
			end

			if isLocal then  tableInsert(metaParts, "local ")  end

			for identIndex, identTok in ipairs(identTokens) do
				if identIndex > 1 then  tableInsert(metaParts, ", ")  end
				tableInsert(metaParts, identTok.value)
			end
			tableInsert(metaParts, ' = "')
			for identIndex, identTok in ipairs(identTokens) do
				if identIndex > 1 then  tableInsert(metaParts, '__LUA", "')  end
				tableInsert(metaParts, "__VAL(")
				tableInsert(metaParts, identTok.value)
				tableInsert(metaParts, ")")
			end

			if isToken(getNextUsableToken(tokens, metaLineIndexEnd, 1, -1), "punctuation", ";") then
				tableInsert(metaParts, '__LUA";\\n";\n')
			else
				tableInsert(metaParts, '__LUA"\\n"\n')
			end
		end

		flushTokensToProcess()
	end--outputFinalDualValueStatement()

	-- Note: Can be multiple actual lines if extended.
	local function processMetaLine(isDual, metaStartTok)
		local metaLineIndexStart = tokenIndex
		local depthStack         = {}

		while true do
			local tok = tokens[tokenIndex]

			if not tok then
				if depthStack[1] then
					tok = depthStack[#depthStack].startToken
					errorAtToken(
						fileBuffers, tok, nil, "Parser",
						"Syntax error: Could not find matching bracket before EOF. (Preprocessor line starts %s)",
						getRelativeLocationText(metaStartTok, tok)
					)
				end
				if isDual then
					outputFinalDualValueStatement(metaLineIndexStart, tokenIndex-1)
				end
				return
			end

			local tokType = tok.type
			if
				not depthStack[1] and (
					(tokType == "whitespace" and tok.value:find("\n", 1, true)) or
					(tokType == "comment"    and not tok.long)
				)
			then
				if tokType == "comment" then
					tableInsert(metaParts, tok.representation)
				else
					tableInsert(metaParts, "\n")
				end

				if isDual then
					outputFinalDualValueStatement(metaLineIndexStart, tokenIndex-1)
				end

				-- Fix whitespace after the line.
				local tokNext = tokens[tokenIndex]
				if isDual or isTokenAndNotNil(tokNext, "pp_entry") then
					-- void

				elseif tokType == "whitespace" then
					local tokExtra          = copyTable(tok)
					tokExtra.value          = tok.value:gsub("^[^\n]+", "")
					tokExtra.representation = tokExtra.value
					tokExtra.position       = tokExtra.position+#tok.value-#tokExtra.value
					tableInsert(tokensToProcess, tokExtra)

				elseif tokType == "comment" and not tok.long then
					local tokExtra = newTokenAt({type="whitespace", representation="\n", value="\n"}, tok)
					tableInsert(tokensToProcess, tokExtra)
				end

				return

			elseif tokType == "pp_entry" then
				errorAtToken(fileBuffers, tok, nil, "Parser", "Preprocessor token inside metaprogram (starting %s).", getRelativeLocationText(metaStartTok, tok))

			else
				tableInsert(metaParts, tok.representation)

				if isToken(tok, "punctuation", "(") then
					tableInsert(depthStack, {startToken=tok, [1]="punctuation", [2]=")"})
				elseif isToken(tok, "punctuation", "[") then
					tableInsert(depthStack, {startToken=tok, [1]="punctuation", [2]="]"})
				elseif isToken(tok, "punctuation", "{") then
					tableInsert(depthStack, {startToken=tok, [1]="punctuation", [2]="}"})

				elseif
					isToken(tok, "punctuation", ")") or
					isToken(tok, "punctuation", "]") or
					isToken(tok, "punctuation", "}")
				then
					if not depthStack[1] then
						errorAtToken(fileBuffers, tok, nil, "Parser", "Unexpected '%s'.", tok.value)
					elseif not isToken(tok, unpack(depthStack[#depthStack])) then
						local startTok = depthStack[#depthStack].startToken
						errorAtToken(
							fileBuffers, tok, nil, "Parser",
							"Expected '%s' (to close '%s' %s) but got '%s'. (Preprocessor line starts %s)",
							depthStack[#depthStack][2], startTok.value, getRelativeLocationText(startTok, tok), tok.value, getRelativeLocationText(metaStartTok, tok)
						)
					end
					tableRemove(depthStack)
				end
			end

			tokenIndex = tokenIndex+1
		end
	end

	while true do
		local tok = tokens[tokenIndex]
		if not tok then  break  end

		local tokType = tok.type

		-- Metaprogram.
		--------------------------------

		-- Preprocessor block. Examples:
		-- !( function sum(a, b) return a+b; end )
		-- local text = !("Hello, mr. "..getName())
		-- _G.!!("myRandomGlobal"..math.random(5)) = 99
		if tokType == "pp_entry" and isTokenAndNotNil(tokens[tokenIndex+1], "punctuation", "(") then
			local startTok    = tok
			local startIndex  = tokenIndex
			local doOutputLua = startTok.double
			tokenIndex        = tokenIndex + 2 -- Eat "!(" or "!!("

			flushTokensToProcess()

			local tokensInBlock = {}
			local parensDepth   = 1 -- @Incomplete: Use depthStack like in other places.

			while true do
				tok = tokens[tokenIndex]

				if not tok then
					errorAtToken(fileBuffers, startTok, nil, "Parser", "Missing end of preprocessor block.")

				elseif isToken(tok, "punctuation", "(") then
					parensDepth = parensDepth + 1

				elseif isToken(tok, "punctuation", ")") then
					parensDepth = parensDepth - 1
					if parensDepth == 0 then  break  end

				elseif tok.type:find"^pp_" then
					errorAtToken(fileBuffers, tok, nil, "Parser", "Preprocessor token inside metaprogram (starting %s).", getRelativeLocationText(startTok, tok))
				end

				tableInsert(tokensInBlock, tok)
				tokenIndex = tokenIndex+1
			end

			local metaBlock = _concatTokens(tokensInBlock, nil, params.addLineNumbers, nil, nil)

			if loadLuaString("return("..metaBlock..")") then
				tableInsert(metaParts, (doOutputLua and "__LUA((" or "__VAL(("))
				tableInsert(metaParts, metaBlock)
				tableInsert(metaParts, "))\n")

			elseif doOutputLua then
				-- We could do something other than error here. Room for more functionality.
				errorAfterToken(fileBuffers, tokens[startIndex+1], "Parser", "Preprocessor block does not contain a valid value expression.")

			else
				tableInsert(metaParts, metaBlock)
				tableInsert(metaParts, "\n")
			end

		-- Preprocessor line. Example:
		-- !for i = 1, 3 do
		--     print("Marco? Polo!")
		-- !end
		--
		-- Preprocessor line, extended. Example:
		-- !newClass{
		--     name  = "Entity",
		--     props = {x=0, y=0},
		-- }
		--
		-- Dual code. Example:
		-- !!local foo = "A"
		-- local bar = foo..!(foo)
		--
		elseif tokType == "pp_entry" then
			flushTokensToProcess()

			tokenIndex = tokenIndex+1
			processMetaLine(tok.double, tok)

		-- Normal code.
		--------------------------------
		else
			tableInsert(tokensToProcess, tok)
		end
		--------------------------------

		tokenIndex = tokenIndex+1
	end

	flushTokensToProcess()

	-- Run metaprogram.
	--==============================================================

	local luaMeta = table.concat(metaParts)
	--[[ :PrintCode
	print("=META===============================")
	print(luaMeta)
	print("====================================")
	--]]

	metaPathForErrorMessages = params.pathMeta or "<meta>"
	outputFromMeta           = {}
	canOutputNil             = params.canOutputNil ~= false
	fastStrings              = params.fastStrings

	if params.pathMeta then
		local file = assert(io.open(params.pathMeta, "wb"))
		file:write(luaMeta)
		file:close()
	end

	local main_chunk, err = loadLuaString(luaMeta, "@"..metaPathForErrorMessages, metaEnv)
	if not main_chunk then
		local ln, _err = err:match"^.-:(%d+): (.*)"
		errorOnLine(metaPathForErrorMessages, (tonumber(ln) or 0), nil, "%s", (_err or err))
	end

	if params.onBeforeMeta then  params.onBeforeMeta()  end

	isRunningMeta = true
	main_chunk() -- Note: Our caller should clean up metaPathForErrorMessages etc. on error.
	isRunningMeta = false

	if not isDebug and params.pathMeta then
		os.remove(params.pathMeta)
	end

	local lua = table.concat(outputFromMeta)
	--[[ :PrintCode
	print("=OUTPUT=============================")
	print(lua)
	print("====================================")
	--]]

	metaPathForErrorMessages = ""
	outputFromMeta           = nil
	canOutputNil             = true

	if params.onAfterMeta then
		local luaModified = params.onAfterMeta(lua)

		if type(luaModified) == "string" then
			lua = luaModified
		elseif luaModified ~= nil then
			errorf("onAfterMeta() did not return a string. (Got %s)", type(luaModified))
		end
	end

	-- Write output file.
	----------------------------------------------------------------

	local pathOut = isFile and params.pathOut or "<output>"

	if isFile then
		local file = assert(io.open(pathOut, "wb"))
		file:write(specialFirstLine or "")
		file:write(lua)
		file:close()
	end

	-- Check if the output is valid Lua.
	if params.validate ~= false then
		local luaToCheck = lua:gsub("^#![^\n]*", "")
		local chunk, err = loadLuaString(luaToCheck, "@"..pathOut)

		if not chunk then
			local ln, _err = err:match"^.-:(%d+): (.*)"
			errorOnLine(pathOut, (tonumber(ln) or 0), nil, "%s", (_err or err))
		end
	end

	-- :ProcessInfo
	local info = {
		path                = isFile and params.pathIn  or "",
		outputPath          = isFile and params.pathOut or "",
		processedByteCount  = stats.processedByteCount,
		lineCount           = stats.lineCount,
		linesOfCode         = stats.lineCountCode,
		tokenCount          = stats.tokenCount,
		hasPreprocessorCode = stats.hasPreprocessorCode,
		hasMetaprogram      = stats.hasMetaprogram,
		insertedFiles       = stats.insertedNames,
	}

	if params.onDone then  params.onDone(info)  end

	currentPathIn  = ""
	currentPathOut = ""
	fastStrings    = false

	if isFile then
		return info
	else
		if specialFirstLine then
			lua = specialFirstLine..lua
		end
		return lua, info
	end
end



local function processFileOrString(params, isFile)
	local returnValues = nil

	isDebug = params.debug

	local xpcallOk, xpcallErr = xpcall(
		function()
			returnValues = pack(_processFileOrString(params, isFile))
		end,
		function(err)
			if type(err) == "string" and err:find("\0", 1, true) then
				printError(tryToFormatError(cleanError(err)))
			else
				printErrorTraceback(err, 2) -- The level should be at error().
			end

			if params.onError then
				local cbOk, cbErr = pcall(params.onError, err)
				if not cbOk then
					printfError("Additional error in params.onError()...\n%s", tryToFormatError(cbErr))
				end
			end

			return err
		end
	)

	isDebug = false

	-- Cleanup in case an error happened.
	isRunningMeta            = false
	currentPathIn            = ""
	currentPathOut           = ""
	metaPathForErrorMessages = ""
	outputFromMeta           = nil
	canOutputNil             = true
	fastStrings              = false

	if xpcallOk then
		return unpack(returnValues, 1, returnValues.n)
	else
		return nil, cleanError(xpcallErr or "Unknown processing error.")
	end
end



local function processFile(params)
	local returnValues = pack(processFileOrString(params, true))
	return unpack(returnValues, 1, returnValues.n)
end

local function processString(params)
	local returnValues = pack(processFileOrString(params, false))
	return unpack(returnValues, 1, returnValues.n)
end



-- :ExportTable
local pp = {

	-- Processing functions.
	----------------------------------------------------------------

	-- processFile()
	-- Process a Lua file. Returns nil and a message on error.
	--
	-- info = processFile( params )
	-- info: Table with various information. (See 'ProcessInfo' for more info.)
	--
	-- params: Table with these fields:
	--   pathIn          = pathToInputFile       -- [Required]
	--   pathOut         = pathToOutputFile      -- [Required]
	--   pathMeta        = pathForMetaprogram    -- [Optional] You can inspect this temporary output file if an error occurs in the metaprogram.
	--
	--   debug           = boolean               -- [Optional] Debug mode. The metaprogram file is formatted more nicely and does not get deleted automatically.
	--   addLineNumbers  = boolean               -- [Optional] Add comments with line numbers to the output.
	--
	--   backtickStrings = boolean               -- [Optional] Enable the backtick (`) to be used as string literal delimiters. Backtick strings don't interpret any escape sequences and can't contain other backticks. (Default: false)
	--   jitSyntax       = boolean               -- [Optional] Allow LuaJIT-specific syntax. (Default: false)
	--   canOutputNil    = boolean               -- [Optional] Allow !() and outputValue() to output nil. (Default: true)
	--   fastStrings     = boolean               -- [Optional] Force fast serialization of string values. (Non-ASCII characters will look ugly.) (Default: false)
	--   validate        = boolean               -- [Optional] Validate output. (Default: true)
	--
	--   onInsert        = function( name )      -- [Optional] Called for each @insert"name" instruction. It's expected to return a Lua code string. By default 'name' is a path to a file to be inserted.
	--   onBeforeMeta    = function( )           -- [Optional] Called before the metaprogram runs.
	--   onAfterMeta     = function( luaString ) -- [Optional] Here you can modify and return the Lua code before it's written to 'pathOut'.
	--   onError         = function( error )     -- [Optional] You can use this to get traceback information. 'error' is the same value as what is returned from processFile().
	--
	processFile = processFile,

	-- processString()
	-- Process Lua code. Returns nil and a message on error.
	--
	-- luaString, info = processString( params )
	-- info: Table with various information. (See 'ProcessInfo' for more info.)
	--
	-- params: Table with these fields:
	--   code            = luaString             -- [Required]
	--   pathMeta        = pathForMetaprogram    -- [Optional] You can inspect this temporary output file if an error occurs in the metaprogram.
	--
	--   debug           = boolean               -- [Optional] Debug mode. The metaprogram file is formatted more nicely and does not get deleted automatically.
	--   addLineNumbers  = boolean               -- [Optional] Add comments with line numbers to the output.
	--
	--   backtickStrings = boolean               -- [Optional] Enable the backtick (`) to be used as string literal delimiters. Backtick strings don't interpret any escape sequences and can't contain other backticks. (Default: false)
	--   jitSyntax       = boolean               -- [Optional] Allow LuaJIT-specific syntax. (Default: false)
	--   canOutputNil    = boolean               -- [Optional] Allow !() and outputValue() to output nil. (Default: true)
	--   fastStrings     = boolean               -- [Optional] Force fast serialization of string values. (Non-ASCII characters will look ugly.) (Default: false)
	--   validate        = boolean               -- [Optional] Validate output. (Default: true)
	--
	--   onInsert        = function( name )      -- [Optional] Called for each @insert"name" instruction. It's expected to return a Lua code string. By default 'name' is a path to a file to be inserted.
	--   onBeforeMeta    = function( )           -- [Optional] Called before the metaprogram runs.
	--   onError         = function( error )     -- [Optional] You can use this to get traceback information. 'error' is the same value as the second returned value from processString().
	--
	processString = processString,

	-- Values.
	----------------------------------------------------------------

	VERSION         = PP_VERSION, -- The version of LuaPreprocess.
	metaEnvironment = metaEnv,    -- The environment used for metaprograms.
}

-- Include all functions from the metaprogram environment.
for k, v in pairs(metaFuncs) do  pp[k] = v  end

return pp



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
