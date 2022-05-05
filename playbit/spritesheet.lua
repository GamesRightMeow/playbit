local module = {}

local meta = {}
meta.__index = meta
module.__index = meta

function module.new(image, spriteWidth, spriteHeight)
  local spritesheet = {
    image = image,
    imageWidth = image:getWidth(),
    imageHeight = image:getHeight(),
    rows = image:getWidth() / spriteWidth,
    columns = image:getHeight() / spriteHeight,
    spriteWidth = spriteWidth,
    spriteHeight = spriteHeight,
  }
  setmetatable(spritesheet, meta)
  return spritesheet
end

function meta:draw(n, x, y)
  local qx = math.floor((n - 1) % self.rows) * self.spriteHeight
  local qy = math.floor((n - 1) / self.rows) * self.spriteWidth
  pb.graphics.textureQuad(self.image, x, y, qx, qy, self.spriteWidth, self.spriteHeight)
end

return module