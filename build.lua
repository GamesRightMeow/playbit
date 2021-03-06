-- this build script was only designed to run on Windows!
local folderOfThisFile = (...):match("(.-)[^%.]+$")
local pp = require(folderOfThisFile.."LuaPreprocess.preprocess")
local capToBmfont = require(folderOfThisFile.."tools.caps-to-bmfont")
local fs = require(folderOfThisFile.."tools.filesystem")

local module = {}

function module.asepriteProcessor(input, output, options)
  fs.createFolderIfNeeded(output)

  output = string.gsub(output, ".aseprite", ".png")
  
  -- TODO: warn if aseprite not in path?
  local command = "aseprite -bv "
  command = command..input

  if options then
    if options.ignoredLayers then
      for i = 1, #options.ignoredLayers, 1 do
        command = command.." --ignore-layer "..options.ignoredLayers[i]
      end
    end

    if options.scale then
      command = command.." --scale "..options.scale
    end
  end

  if string.find(input, "-table-") then
    -- json isn't needed, but if its not saved, it fills the console
    command = command.." --sheet "..output.." --data _tmp/asprite.json"
  else
    command = command.." --save-as "..output
  end

  io.popen(command, "w")
end

function module.waveProcessor(input, output, options)
  fs.createFolderIfNeeded(output)
  local command = "ffmpeg -i "..input.." -acodec adpcm_ima_wav "..output
  io.popen(command, "w")
end

function module.defaultProcessor(input, output, options)
  local inputFile = io.open(input, "rb")
  local contents = inputFile:read("a")
  inputFile:close()

  fs.createFolderIfNeeded(output)
  local outputFile = io.open(output, "w+b")
  outputFile:write(contents)
  outputFile:close()
end

function module.fntProcessor(input, output, options)
  capToBmfont(input, output)
end

function module.luaProcessor(input, output)
  fs.createFolderIfNeeded(output)
  local settings = {
    pathIn = input,
    pathOut = output,
  }
  if not enableAssert then
    settings.release = true
  end
  local processedFileInfo = pp.processFile(settings)
end

function module.processFile(input, output, localProcessors, globalProcessors)
  local ext = fs.getFileExtension(input)
  local processor = (localProcessors and localProcessors[ext]) or globalProcessors[ext]
  if processor then
    if type(processor) == "table" then
      processor[1](input, output, processor[2])
    else
      processor(input, output, nil)
    end
  else
    module.defaultProcessor(input, output, nil)
  end
end

function module.processPath(projectFolder, buildFolder, inputPath, outputPath, localProcessors, globalProcessors)
  local files = fs.getFiles(inputPath)
  -- TODO: this will misclassify files without an extension as a folder
  if fs.getFileExtension(inputPath) then
    -- process single file
    local filePath = files[1]
    local outputFilePath = fs.sanitizePath(projectFolder.."/"..buildFolder.."/"..outputPath)
    module.processFile(filePath, outputFilePath, localProcessors, globalProcessors)
  else
    -- process files in folder recursively
    local fullInputPath = fs.sanitizePath(projectFolder.."/"..inputPath)
    for i = 1, #files, 1 do
      local filePath = files[i]
      local relativeFilePath = fs.getRelativePath(filePath, fullInputPath)
      local outputFilePath = fs.sanitizePath(projectFolder.."/"..buildFolder.."/"..outputPath.."/"..relativeFilePath)
      module.processFile(filePath, outputFilePath, localProcessors, globalProcessors)
    end
  end
end

function module.build(options)
  local timeStart = os.clock()

  local targetPlatform = options.platform
  local projectFolder = fs.getProjectFolder()
  local globalProcessors = options.fileProcessors
  enableAssert = options.assert

  -- built in env values
  pp.metaEnvironment.PLAYDATE = targetPlatform == "playdate"
  pp.metaEnvironment.LOVE2D = targetPlatform == "love2d"
  pp.metaEnvironment.DEBUG = options.debug

  -- any game specific env values
  if options.env then
    for i = 1, #options.env, 1 do
      pp.metaEnvironment[options.env[i]] = true
    end
  end

  local buildFolder = "_game"
  if options.output then
    buildFolder = fs.sanitizePath(options.output)
  end

  -- nuke old folder
  -- TODO: does pdc support incremental builds?
  fs.deleteDirectory(buildFolder)
  fs.createDirectory(buildFolder)

  for i = 1, #options.files, 1 do
    local input = fs.sanitizePath(options.files[i][1])
    local output = fs.sanitizePath(options.files[i][2])
    local folderProcessors = options.files[i][3]
    module.processPath(projectFolder, buildFolder, input, output, folderProcessors, globalProcessors)
  end

  local timeEnd = os.clock()
  print("Build completed in "..(timeEnd - timeStart).."ms")
end

return module