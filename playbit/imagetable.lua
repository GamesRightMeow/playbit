local module = {}

local meta = {}
meta.__index = meta
module.__index = meta

function module.new(path, spriteWidth, spriteHeight)
  local imagetable = setmetatable({}, meta)
!if LOVE2D then
  local image = pb.image.new(path.."-table-"..spriteWidth.."-"..spriteHeight)
  imagetable.image = image
  imagetable.rows = image:getWidth() / spriteWidth
  imagetable.columns = image:getHeight() / spriteHeight
  imagetable.length = imagetable.rows * imagetable.columns
  imagetable.spriteWidth = spriteWidth
  imagetable.spriteHeight = spriteHeight
!elseif PLAYDATE then
  imagetable.imagetable = playdate.graphics.imagetable.new(path)
!end
  return imagetable
end

function meta:draw(n, x, y)
!if LOVE2D then
  -- TODO: cache index calculation
  local qx = math.floor((n - 1) % self.rows) * self.spriteHeight
  local qy = math.floor((n - 1) / self.rows) * self.spriteWidth
  pb.graphics.textureQuad(self.image, x, y, qx, qy, self.spriteWidth, self.spriteHeight)
!elseif PLAYDATE then
  self.imagetable:drawImage(n, x, y)
!end
end

function meta:getLength()
!if LOVE2D then
  return self.length
!elseif PLAYDATE then
  return self.imagetable:getLength()
!end
end

return module