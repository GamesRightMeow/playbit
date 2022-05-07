local module = {}

function module.load(path)
!if LOVE2D then
  return love.filesystem.read(path)
!else
  local file = playdate.file.open(path)
  local size = playdate.file.getSize(path)
  local data = file:read(size)
  file:close()
  return data
!end
end

return module