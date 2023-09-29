local folderOfThisFile = (...):match("(.-)[^%.]+$")
local pp = require(folderOfThisFile.."LuaPreprocess.preprocess")
local capToBmfont = require(folderOfThisFile.."tools.caps-to-bmfont")
local fs = require(folderOfThisFile.."tools.filesystem")
local jsonParser = require(folderOfThisFile.."json.json")

local module = {}

-- TODO: move file processors to separate file

function module.skipFile(input, output, options)
  if options then
    if not options.silent then
      print("Skipping: "..input)
    end
  else
    print("Skipping: "..input)
  end
end

function module.asepriteProcessor(input, output, options)
  fs.createFolderIfNeeded(output)

  output = string.gsub(output, ".aseprite", ".png")

  -- TODO: warn if aseprite not in path?
  local asepritePath = "aseprite"
  local asepriteFlags = " -bv "

  if options and options.path then
    asepritePath = "\""..fs.sanitizePath(options.path).."\""
  end

  local asepriteVersion = io.popen(asepritePath.." --version", "r"):read("*a")
  assert(string.match(asepriteVersion, "Aseprite"), "aseprite binary not found")

  local command = asepritePath..asepriteFlags.."\""..input.."\""

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
    command = command.." --sheet \""..output.."\" --data _tmp/asprite.json"
  else
    command = command.." --save-as \""..output.."\""
  end

  io.popen(command, "w")
end

function module.waveProcessor(input, output, options)
  fs.createFolderIfNeeded(output)

  local ffmpegPath = "ffmpeg"
  if options then
    if options.path then
      ffmpegPath = "\""..fs.sanitizePath(options.path).."\""
    end
  end

  local command = ffmpegPath.." -i \""..input.."\" -ar 44100 -acodec adpcm_ima_wav \""..output.."\""
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
  fs.createFolderIfNeeded(output)
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

function module.pdxinfoProcessor(input, output, options)
  local inputFile = io.open(input, "rb")
  local contents = inputFile:read("a")
  inputFile:close()

  local metadata = jsonParser.decode(contents)

  -- increment build number
  if metadata.buildNumber and options and options.incrementBuildNumber then
    metadata.buildNumber = metadata.buildNumber + 1

    -- json lib doesn't sort properties dertministically, so order the way PD docs
    -- has it so at least its consistent between builds
    local sortedProperties = {
      "name",
      "author",
      "description",
      "bundleID",
      "version",
      "buildNumber",
      "imagePath",
      "launchSoundPath",
      "contentWarning",
      "contentWarning2",
    }

    -- rebuild json string, since the json lib also doesn't support pretty printing...
    local jsonStr = "{\n"
    local first = true
    for i = 1, #sortedProperties do
      local k = sortedProperties[i]
      if metadata[k] then
        if not first then
          jsonStr = jsonStr..",\n"
        end
        jsonStr = jsonStr..'  "'..k..'": "'..metadata[k]..'"'
        first = false  
      end
    end
    jsonStr = jsonStr.."\n}"

    -- update metadata file 
    local inputFile = io.open(input, "w+b")
    inputFile:write(jsonStr)
    inputFile:close()
  end

  -- convert to pdxinfo format
  local outputStr = ""
  for k,v in pairs(metadata) do
    outputStr = outputStr..k.."="..v.."\n"
  end

  fs.createFolderIfNeeded(output)
  local outputFile = io.open(output, "w+b")
  outputFile:write(outputStr)
  outputFile:close()
end

function module.processFile(input, output, localProcessors, globalProcessors)
  local ext = fs.getFileExtension(input)
  local processor = (localProcessors and localProcessors[ext]) or globalProcessors[ext]
  if processor then
    if type(processor) == "table" then
      assert(processor[1], "File processor for ."..ext.." is nil - are you sure you configured it correctly?")
      processor[1](input, output, processor[2])
    else
      assert(processor, "File processor for ."..ext.." is nil - are you sure you configured it correctly?")
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
    if (filePath == nil) then
      error("Invalid file path!")
    end
    local outputFilePath = fs.sanitizePath(projectFolder.."/"..buildFolder.."/"..outputPath)
    module.processFile(filePath, outputFilePath, localProcessors, globalProcessors)
  else
    -- process files in folder recursively
    local fullInputPath = fs.sanitizePath(projectFolder.."/"..inputPath)
    for i = 1, #files, 1 do
      local filePath = files[i]
      if (filePath == nil) then
        error("Invalid file path!")
      end
      local relativeFilePath = fs.getRelativePath(filePath, fullInputPath)
      local outputFilePath = fs.sanitizePath(projectFolder.."/"..buildFolder.."/"..outputPath.."/"..relativeFilePath)
      module.processFile(filePath, outputFilePath, localProcessors, globalProcessors)
    end
  end
end

---@class BuildOptions
---@field assert boolean
---@field debug boolean
---@field platform string
---@field output string
---@field clearBuildFolder boolean
---@field fileProcessors table
---@field files table

--- Make a build!
---@param options BuildOptions
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

  -- make IMPORT function globally accessible to metaprogram
  pp.metaEnvironment.IMPORT = function (path)
    -- path comes in with quotes, remove them
    path = path:sub(2, #path - 1)
    if pp.metaEnvironment.PLAYDATE then
      return pp.metaEnvironment.outputLuaTemplate("import(?)", path)
    elseif pp.metaEnvironment.LOVE2D then
      if string.match(path, "^CoreLibs/") then
        -- ignore these imports, since the playdate namespace is already reimplemented in the global namespace
        return
      end
      path = string.gsub(path, "/", ".")
      return pp.metaEnvironment.outputLuaTemplate("require(?)", path)
    else
      error("Unknown platform!")
    end
  end

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

  if options.clearBuildFolder then
    -- clear contents of old folder
    fs.deleteDirectory(buildFolder)
    fs.createDirectory(buildFolder)
  end

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
