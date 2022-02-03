local Image = {}

local meta = {}
meta.__index = meta
Image.__index = meta

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

function Image.new(path)
  local img = setmetatable({}, meta)

  --! if LOVE2D then
  img.data = love.graphics.newImage(path)
  --! elseif PLAYDATE then
  img.data = playdate.graphics.image.new(path)
  --! end
  return img
end

return Image