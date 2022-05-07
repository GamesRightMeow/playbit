local module = {}

local meta = {}
meta.__index = meta
module.__index = meta

function module.new(path, spriteWidth, spriteHeight)
  local spritesheet = setmetatable({}, meta)
!if LOVE2D then
  local image = pb.image.new(path.."-table-"..spriteWidth.."-"..spriteHeight)
  spritesheet.image = image
  spritesheet.rows = image:getWidth() / spriteWidth
  spritesheet.columns = image:getHeight() / spriteHeight
  spritesheet.spriteWidth = spriteWidth
  spritesheet.spriteHeight = spriteHeight
!elseif PLAYDATE then
  spritesheet.imagetable = playdate.graphics.imagetable.new("textures/tiles")
!end
  return spritesheet
end

function meta:draw(n, x, y)
!if LOVE2D then
  local qx = math.floor((n - 1) % self.rows) * self.spriteHeight
  local qy = math.floor((n - 1) / self.rows) * self.spriteWidth
  pb.graphics.textureQuad(self.image, x, y, qx, qy, self.spriteWidth, self.spriteHeight)
!elseif PLAYDATE then
  self.imagetable:drawImage(n, x, y)
!end
end

return module