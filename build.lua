-- this build script was only designed to run on Windows!
local folderOfThisFile = (...):match("(.-)[^%.]+$")
local pp = require(folderOfThisFile.."LuaPreprocess.preprocess")

local Build = {}

function Build.getFileExtension(path)
  return path:match("^.+(%..+)$")
end

function Build.createFolderIfNeeded(path)
  local existCommand = io.popen("IF EXIST "..path.." ECHO true")
  local existOutput = existCommand:read("*a")
  if #existOutput == 0 then
    os.execute("mkdir " .. path)
  end
end

function Build.copyFile(src, dst)
  os.execute("copy \"" .. src .. "\" \"" .. dst .. "\"")
end

function Build.copyFolder(src, dst)
  os.execute("xcopy /E /H /y " .. src .. " " .. dst)
end

function Build.exportAseprite(inputFolder, outputFolder, ignoredLayers, verbose)
  local dirCommand = io.popen("dir /a-D /S /B \"" .. inputFolder .. "\"")
  local dirOutput = dirCommand:read("*a")

  dirCommand = io.popen("cd")
  local fullInputFolder = dirCommand:read("*l").."\\"..inputFolder
  
  for fullPath in dirOutput:gmatch("(.-)\n") do 
    if Build.getFileExtension(fullPath) ~= ".aseprite" then
      goto continue
    end

    local relativeOutputPath = fullPath:gsub(fullInputFolder, ""):gsub(".aseprite", ".png")
    relativeOutputPath = outputFolder .. relativeOutputPath

    -- create folder(s) first to fix errors when writing lua fila
    Build.createFolderIfNeeded(relativeOutputPath:match("(.*\\)"))

    -- TODO: expose param to set aseprite location
    local command = "\"C:\\Program Files\\Aseprite\\Aseprite.exe\" -bv "
    command = command..fullPath
    for i = 1, #ignoredLayers, 1 do
      command = command.." --ignore-layer "..ignoredLayers[i]
    end
    command = command.." --save-as "..relativeOutputPath
    io.popen(command, "w")

    ::continue::
  end
end

function Build.processLua(inputFolder, outputFolder, verbose)
  local dirCommand = io.popen("dir /a-D /S /B \"" .. inputFolder .. "\"")
  local dirOutput = dirCommand:read("*a")

  dirCommand = io.popen("cd")
  local fullInputFolder = dirCommand:read("*l").."\\"..inputFolder

  for fullPath in dirOutput:gmatch("(.-)\n") do 
    if Build.getFileExtension(fullPath) ~= ".lua" then
      goto continue
    end

    local relativeOutputPath = fullPath:gsub(fullInputFolder, "")
    relativeOutputPath = outputFolder .. relativeOutputPath

    -- read original source
    local file = io.open(fullPath, "r")
    local rawLua = file:read("a")
    file:close();

    -- remove comments so preprocess can...process them
    -- TODO: this is probably slow...is there a better way to handle this?
    local replacedLua = rawLua:gsub("--!", "!")

    -- run preprocess magic
    local processedLua, processedFileInfo = pp.processString {
      code = replacedLua,
    }

    -- create folder(s) first to fix errors when writing lua fila
    Build.createFolderIfNeeded(relativeOutputPath:match("(.*\\)"))

    -- save out processed file
    file = io.open(relativeOutputPath, "w+")
    file:write(processedLua)
    file:close();

    if verbose then
      print("Processed " .. fullPath .. " " .. processedFileInfo.processedByteCount .. " bytes")
    end

    ::continue::
  end
end

function Build.build(options)
  local timeStart = os.clock()

  local enableVerbose = options.verbose == true
  local targetPlatform = options.platform

  -- built in env values
  -- TODO: add variable for playdate sdk
  pp.metaEnvironment.LOVE2D = targetPlatform == "love2d"
  pp.metaEnvironment.ASSERT = options.assert
  pp.metaEnvironment.DEBUG = options.debug

  -- any game specific env values
  if options.env then
    for i = 1, #options.env, 1 do
      pp.metaEnvironment[options.env[i]] = true
    end
  end

  local outputFolder = "_dist"
  if options.output then
    outputFolder = options.output
  end

  -- nuke old folder
  os.execute("rmdir "..outputFolder.." /s /q")
  os.execute("mkdir "..outputFolder)

  -- process scripts
  if options.luaFolders then
    for i = 1, #options.luaFolders, 1 do
      Build.processLua(options.luaFolders[i][1], outputFolder..options.luaFolders[i][2], enableVerbose)
    end
  end

  -- export aseprite files as pngs
  if options.aseprite and options.aseprite.folders then
    for i = 1, #options.aseprite.folders, 1 do
      Build.exportAseprite(options.aseprite.folders[i][1], outputFolder..options.aseprite.folders[i][2], options.aseprite.excludeLayers, enableVerbose)
    end
  end

  -- copy folders
  if options.copyFolders then
    for i = 1, #options.copyFolders, 1 do
      Build.copyFolder(options.copyFolders[i][1], outputFolder..options.copyFolders[i][2])
    end
  end

  -- copy files
  if options.copyFiles then
    for i = 1, #options.copyFiles, 1 do
      Build.copyFile(options.copyFiles[i][1], outputFolder..options.copyFiles[i][2])
    end
  end

  local timeEnd = os.clock()
  print("Build completed in "..(timeEnd - timeStart).."ms")
end

return Build