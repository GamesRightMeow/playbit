-- this build script was only designed to run on Windows!
local folderOfThisFile = (...):match("(.-)[^%.]+$")
local pp = require(folderOfThisFile.."LuaPreprocess.preprocess")
local capToBmfont = require(folderOfThisFile.."tools.caps-to-bmfont")

local module = {}

function module.listFiles(folder)
  local dirCommand = io.popen("dir /a-D /S /B \""..folder.."\"")
  local output = dirCommand:read("*a")
  return output:gmatch("(.-)\n")
end

function module.getFileExtension(path)
  return path:match("^.+%.(.+)$")
end

function module.createFolderIfNeeded(path)
  local pathReversed = string.reverse(path)
  local start, ends = string.find(pathReversed, "\\")
  if start and ends then
    path = string.sub(path, 1, #path - ends)
  end
  os.execute("IF NOT EXIST \""..path.."\" mkdir \""..path.."\"")
end

function module.getAbsolutePath(path)
  local dirCommand = io.popen("cd")
  return dirCommand:read("*l").."\\"..path
end

function module.getRelativePath(path, folder)
  path = path:gsub(folder, "")
  local char = string.sub(path, 1, 1)
  if (char == "\\") then
    -- trim leading slash
    path = string.sub(path, 2)
  end
  return path
end

function module.asepriteProcessor(input, output, options)
  module.createFolderIfNeeded(output)

  output = string.gsub(output, ".aseprite", ".png")
  
  local command = "\""..options.path.."\" -bv "
  command = command..input

  if options.ignoredLayers then
    for i = 1, #options.ignoredLayers, 1 do
      command = command.." --ignore-layer "..options.ignoredLayers[i]
    end
  end

  if options.scale then
    command = command.." --scale "..options.scale
  end

  if string.find(input, "-table-") then
    -- json isn't needed, but if its not saved, it fills the console
    command = command.." --sheet "..output.." --data _tmp\\asprite.json"
  else
    command = command.." --save-as "..output
  end

  io.popen(command, "w")
end

function module.waveProcessor(input, output, options)
  module.createFolderIfNeeded(output)
  local command = "ffmpeg -i "..input.." -acodec adpcm_ima_wav "..output
  io.popen(command, "w")
end

function module.defaultProcessor(input, output, options)
  local inputFile = io.open(input, "rb")
  local contents = inputFile:read("a")
  inputFile:close()

  module.createFolderIfNeeded(output)
  local outputFile = io.open(output, "w+b")
  outputFile:write(contents)
  outputFile:close()
end

function module.fntProcessor(input, output, options)
  capToBmfont(input, output)
end

function module.luaProcessor(input, output)
  module.createFolderIfNeeded(output)
  local settings = {
    pathIn = input,
    pathOut = output,
  }
  if not enableAssert then
    settings.release = true
  end
  local processedFileInfo = pp.processFile(settings)
end

function module.getProjectFolder()
  local cdCommand = io.popen("cd")
  return cdCommand:read("*l")
end

function module.getFiles(path)
  local dirCommand = io.popen("dir /a-d /s /b \""..path.."\"")
  local files = dirCommand:read("*a"):gmatch("(.-)\n")
  local result = {}
  for path in files do 
    table.insert(result, path)
  end
  return result
end

function module.processFile(input, output, fileProcessors)
  local ext = module.getFileExtension(input)
  local processor = fileProcessors[ext]

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

function module.processPath(projectFolder, buildFolder, inputPath, outputPath, fileProcessors)
  local files = module.getFiles(inputPath)
  if #files == 1 then
    -- process single file
    local filePath = files[1]
    local outputFilePath = projectFolder.."\\"..buildFolder.."\\"..outputPath
    module.processFile(filePath, outputFilePath, fileProcessors)
  else
    -- process files in folder recursively
    local fullInputPath = projectFolder.."\\"..inputPath
    for i = 1, #files, 1 do
      local filePath = files[i]
      local relativeFilePath = module.getRelativePath(filePath, fullInputPath)
      local outputFilePath = projectFolder.."\\"..buildFolder.."\\"..outputPath.."\\"..relativeFilePath
      module.processFile(filePath, outputFilePath, fileProcessors)
    end
  end
end

function module.build(options)
  local timeStart = os.clock()

  local enableVerbose = options.verbose == true
  local targetPlatform = options.platform
  local projectFolder = module.getProjectFolder()
  local processors = options.fileProcessors
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
    buildFolder = options.output
  end

  -- nuke old folder
  os.execute("rmdir "..buildFolder.." /s /q")
  os.execute("mkdir "..buildFolder)

  for i = 1, #options.folders, 1 do
    module.processPath(projectFolder, buildFolder, options.folders[i][1], options.folders[i][2], processors)
  end

  local timeEnd = os.clock()
  print("Build completed in "..(timeEnd - timeStart).."ms")
end

return module