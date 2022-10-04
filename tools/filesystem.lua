local module = {}

module.WINDOWS = 0
module.LINUX = 1
module.MACOS = 2
local platform = -1

local function run(command, failure_msg)
  local handle = io.popen(command)
  local output = handle:read("*a") -- returns "" if no stdout
  local success, _, ret_code = handle:close()
  if failure_msg and ret_code ~= 0 then
    assert(false, "RUN: '"..command.."' failed. "..failure_msg)
  end
  return output, ret_code
end

local function detectPlatform()
  if platform == -1 then
    if package.config:sub(1,1) == '\\' then
      platform = module.WINDOWS
    else
      local uname = run("uname -s")
      if uname:match("Darwin") then
        platform = module.MACOS
      elseif uname:match("Linux") then
        platform = module.LINUX
      end
    end
    assert(platform >= 0, "Could not detect operating system. Giving up.")
  end
  return platform
end

-- immediately call so that platform is detected when first imported
detectPlatform()

function module.getPlatform()
  return platform
end

local function getSlash()
  if platform == module.WINDOWS then
    return "\\"
  else
    return "/"
  end
end

function module.sanitizePath(path)
  if platform == module.WINDOWS then
    return string.gsub(path, "/", "\\")
  else
    return string.gsub(path, "\\", "/")
  end
end

function module.getFileName(path)
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
  assert(path ~= "/", "Not gonna recursively delete /. Giving up.")
  if platform == module.WINDOWS then
    os.execute("rmdir "..path.." /s /q")
  else
    os.execute("rm -rf "..path)
  end
end

function module.createDirectory(path)
  os.execute("mkdir "..path)
end

function module.createFolderIfNeeded(path)
  if platform == module.WINDOWS then
    local pathReversed = string.reverse(path)
    local start, ends = string.find(pathReversed, "\\")
    if start and ends then
      path = string.sub(path, 1, #path - ends)
    end
    os.execute("IF NOT EXIST \""..path.."\" mkdir \""..path.."\"")
  else
    local pathReversed = string.reverse(path)
    local start, ends = string.find(pathReversed, "/")
    if start and ends then
      path = string.sub(path, 1, #path - ends)
    end
    os.execute("mkdir -p \""..path.."\"")
  end 
end

function module.getRelativePath(path, folder)
  -- escape dashes do the following gsub doesn't interpret them as the special pattern char
  folder = string.gsub(folder, "%-", "%%-")

  -- remove folder
  path = path:gsub(folder, "")

  -- trim leading slash
  local char = string.sub(path, 1, 1)
  if (char == getSlash()) then
    path = string.sub(path, 2)
  end
  return path
end

function module.getProjectFolder()
  if platform == module.WINDOWS then
    local command = io.popen("cd")
    return command:read("*l")
  else
    local command = io.popen("pwd")
    return command:read("*l")
  end
end

function module.getFiles(path)
  if platform == module.WINDOWS then
    local command = io.popen("dir /a-d /s /b \""..path.."\"")
    local files = command:read("*a"):gmatch("(.-)\n")
    local result = {}
    for file in files do 
      table.insert(result, file)
    end
    return result
  else
    local readlink_cmd = "readlink -f"
    if platform == module.MACOS then
      readlink_cmd = "python3 -c 'import pathlib; import sys; print(pathlib.Path(sys.argv[1]).resolve())'"
    end
    local command = io.popen("find \""..path.."\" -type f")
    local lines = command:read("*a"):gmatch("(.-)\n")
    local result = {}
    for line in lines do 
      local command = io.popen(readlink_cmd.." \""..line.."\"")
      local path = command:read("*a"):match("(.-)\n")
      table.insert(result, path)
    end
    return result
  end
end

return module
