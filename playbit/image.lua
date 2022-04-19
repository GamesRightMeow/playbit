local module = {}

local meta = {}
meta.__index = meta
module.__index = meta

function meta:getWidth()
  --! if LOVE2D then
  return self.data:getWidth()
  --! elseif PLAYDATE then
  return playdate.graphics.image:getSize()[1]
  --! end
end

function meta:getHeight()
  --! if LOVE2D then
  return self.data:getHeight()
  --! elseif PLAYDATE then
  return playdate.graphics.image:getSize()[2]
  --! end
end

function module.new(path)
  local img = setmetatable({}, meta)

  --! if LOVE2D then
  img.data = love.graphics.newImage(path..".png")
  --! elseif PLAYDATE then
  local data, error = playdate.graphics.image.new(path)
  img.data = data
  print(error)
  --! end
  return img
end

return module