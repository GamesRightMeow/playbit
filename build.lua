-- this build script was only designed to run on Windows!
local folderOfThisFile = (...):match("(.-)[^%.]+$")
local pp = require(folderOfThisFile.."LuaPreprocess.preprocess")

local Build = {}

function Build.copyFile(src, dst)
  os.execute("copy \"" .. src .. "\" \"" .. dst .. "\"")
end

function Build.copyFolder(src, dst)
  os.execute("xcopy /E /H /y " .. src .. " " .. dst)
end

function Build.processLua(inputFolder, outputFolder, verbose)
  local dirCommand = io.popen("dir /a-D /S /B \"" .. inputFolder .. "\"")
  local dirOuput = dirCommand:read("*a")

  dirCommand = io.popen("cd")
  local dirOutput = dirCommand:read("*l").."\\"..inputFolder

  for path in dirOuput:gmatch("(.-)\n") do 
    local outputPath = path:gsub(dirOutput, "")
    outputPath = outputFolder .. outputPath

    -- read original source
    local file = io.open(path, "r")
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
    local outputFolder = outputPath:match("(.*\\)")

    local existCommand = io.popen("IF EXIST "..outputFolder.." ECHO true")
    local existOutput = existCommand:read("*a")
    if #existOutput == 0 then
      os.execute("mkdir " .. outputFolder)
    end

    -- save out processed file
    file = io.open(outputPath, "w+")
    file:write(processedLua)
    file:close();

    if verbose then
      print("Processed " .. path .. " " .. processedFileInfo.processedByteCount .. " bytes")
    end
  end
end

function Build.build(options)
  local timeStart = os.clock()

  local enableVerbose = options.verbose == true

  pp.metaEnvironment.USE_LOVE = arg[1] == "love"
  -- TODO: add variable for playdate sdk

  -- nuke old folder
  local outputFolder = "_dist"
  if options.output then
    outputFolder = options.output
  end
  os.execute("rmdir "..outputFolder.." /s /q")
  os.execute("mkdir "..outputFolder)

  -- process scripts
  if options.luaFolders then
    for i = 1, #options.luaFolders, 1 do
      Build.processLua(options.luaFolders[i][1], outputFolder..options.luaFolders[i][2], enableVerbose)
    end
  end

  -- copy folders
  if options.copyFolders then
    for i = 1, #options.copyFolders, 1 do
      Build.copyFolder(options.copyFolders[i][1], options.copyFolders[i][2])
    end
  end

  -- copy files
  if options.copyFiles then
    for i = 1, #options.copyFiles, 1 do
      Build.copyFile(options.copyFiles[i][1], options.copyFiles[i][2])
    end
  end

  local timeEnd = os.clock()
  print("Build completed in "..(timeEnd - timeStart).."ms")

  if options.runOnSuccess then 
    os.execute(options.runOnSuccess)
  end
end

return Build