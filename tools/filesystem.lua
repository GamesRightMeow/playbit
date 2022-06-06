local module = {}

module.WINDOWS = 0
module.LINUX = 1
local platform = -1

local function detectPlatform()
  if platform > -1 then
    return
  end

  -- FIXME: detect via commands 
  platform = module.LINUX
end

local function getSlash()
  detectPlatform()

  if platform == module.WINDOWS then
    return "\\"
  elseif platform == module.LINUX then
    return "/"
  end
end

function module.getPlatform()
  detectPlatform()
  return platform
end

function module.sanitizePath(path)
  detectPlatform()
  
  if platform == module.WINDOWS then
    return string.gsub(path, "/", "\\")
  elseif platform == module.LINUX then
    return string.gsub(path, "\\", "/")
  end
end

function module.getFileName(path)
  detectPlatform()

  local name = path
  local nameReversed = string.reverse(name)
  local lastSlash = #name - string.find(nameReversed, getSlash())
  name = string.sub(name, lastSlash + 2)
  name = string.gsub(name, "%....", "")
  return name
end

function module.getFileExtension(path)
  return path:match("^.+%.(.+)$")
end

function module.deleteDirectory(path)
  detectPlatform()

  if platform == module.WINDOWS then
    os.execute("rmdir "..path.." /s /q")
  elseif platform == module.LINUX then
    os.execute("rm -rf "..path)
  end 
end

function module.createDirectory(path)
  detectPlatform()

  if platform == module.WINDOWS then
    os.execute("mkdir "..path)
  elseif platform == module.LINUX then
    os.execute("mkdir "..path)
  end 
end

function module.createFolderIfNeeded(path)
  detectPlatform()

  if platform == module.WINDOWS then
    local pathReversed = string.reverse(path)
    local start, ends = string.find(pathReversed, "\\")
    if start and ends then
      path = string.sub(path, 1, #path - ends)
    end
    os.execute("IF NOT EXIST \""..path.."\" mkdir \""..path.."\"")
  elseif platform == module.LINUX then
    local pathReversed = string.reverse(path)
    local start, ends = string.find(pathReversed, "/")
    if start and ends then
      path = string.sub(path, 1, #path - ends)
    end
    os.execute("mkdir -p \""..path.."\"")
  end 
end

function module.getRelativePath(path, folder)
  detectPlatform()

  path = path:gsub(folder, "")
  local char = string.sub(path, 1, 1)
  
  if (char == getSlash()) then
    -- trim leading slash
    path = string.sub(path, 2)
  end
  return path
end

function module.getProjectFolder()
  detectPlatform()

  if platform == module.WINDOWS then
    local command = io.popen("cd")
    return command:read("*l")
  elseif platform == module.LINUX then
    local command = io.popen("pwd")
    return command:read("*l")
  end
end

function module.getFiles(path)
  detectPlatform()

  if platform == module.WINDOWS then
    local command = io.popen("dir /a-d /s /b \""..path.."\"")
    local files = command:read("*a"):gmatch("(.-)\n")
    local result = {}
    for file in files do 
      table.insert(result, file)
    end
    return result
  elseif platform == module.LINUX then
    local command = io.popen("find "..path.." -type f")
    local lines = command:read("*a"):gmatch("(.-)\n")
    local result = {}
    for line in lines do 
      local command = io.popen("readlink -f "..line)
      local path = command:read("*a"):match("(.-)\n")
      table.insert(result, path)
    end
    return result
  end
end

return module