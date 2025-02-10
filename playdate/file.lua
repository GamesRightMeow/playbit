-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#M-file

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

function module.listFiles(path, showHidden)
  @@ASSERT(showHidden == nil, "[ERR] showHidden parameter is not yet implemented.")
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

function meta:write(string)
  error("[ERR] playdate.file:write() is not yet implemented.")
end

function meta:flush()
  error("[ERR] playdate.file:flush() is not yet implemented.")
end

function meta:seek(offset, whence)
  error("[ERR] playdate.file:seek() is not yet implemented.")
end

function meta:tell()
  error("[ERR] playdate.file:tell() is not yet implemented.")
end

function module.exists(path)
  error("[ERR] playdate.file.exists() is not yet implemented.")
end

function module.isdir(path)
  error("[ERR] playdate.file.isdir() is not yet implemented.")
end

function module.mkdir(path)
  error("[ERR] playdate.file.mkdir() is not yet implemented.")
end

function module.delete(path, recursive)
  error("[ERR] playdate.file.delete() is not yet implemented.")
end

function module.getType(path)
  error("[ERR] playdate.file.getType() is not yet implemented.")
end

function module.modtime(path)
  error("[ERR] playdate.file.modtime() is not yet implemented.")
end

function module.rename(path, newPath)
  error("[ERR] playdate.file.rename() is not yet implemented.")
end

function module.load(path, env)
  error("[ERR] playdate.file.load() is not yet implemented.")
end

function module.run(path, env)
  error("[ERR] playdate.file.run() is not yet implemented.")
end