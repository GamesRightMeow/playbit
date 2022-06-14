local module = {}
playdate.file = module

local meta = {}
meta.__index = meta
module.__index = meta

module.kFileRead = 3
module.kFileWrite = 4
module.kFileAppend = 8

function module.listFiles(path)
  path = path or "/"
  return love.filesystem.getDirectoryItems(path)
end

function module.open(path, mode)
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