local module = {}
playdate.file = module

local meta = {}
meta.__index = meta
module.__index = meta

module.kFileRead = 3
module.kFileWrite = 4
module.kFileAppend = 8

local openFileCount = 0

function module.load(path)
  if string.sub(path, #path - 3) == ".pdz" then
    path = string.sub(path, 1, #path - 4)
  end
  
  return love.filesystem.load(path..".lua")
end

function module.listFiles(path)
  path = path or "/"

  local files = love.filesystem.getDirectoryItems(path)

  -- PD appends a '/' for folder, but love2d doesn't
  for i = 1, #files do
		local file = path.."/"..files[i]
		local info = love.filesystem.getInfo(file)
    if info.type == "directory" then
      files[i] = files[i].."/"
    end
	end

  return files
end

function module.open(path, mode)
  -- playdate has a maximum open file count of 64, so emulate that
  if openFileCount >= 64 then
    return nil
  end
  openFileCount = openFileCount + 1

  mode = mode or module.kFileRead

  local data = love.filesystem.newFile(path)
  if mode == module.kFileRead then
    data:open("r")
  elseif mode == module.kFileWrite then
    data:open("w")
  elseif mode == module.kFileAppend then
    data:open("a")
  end
  
  local file = setmetatable({}, meta)
  file._data = data
  file._lastLine = data:lines()

  return file
end

function meta:close()
  openFileCount = openFileCount - 1
  self._data:close()
end

function meta:readline()
  if self._data:isEOF() then
    return nil
  end

  local line = self._lastLine()
  if not line then
    -- at the EOF, love2d returns nothing, but PD returns nil
    return nil
  end

  return line
end

function module.getSize(path)
  local info = love.filesystem.getInfo(path)
  return info.size
end

function meta:read(numberOfBytes)
  return self._data:read(numberOfBytes)
end