local module = {}
playdate.graphics.image = module

local meta = {}
meta.__index = meta
module.__index = meta

function module.new(widthOrPath, height, bgcolor)
  @@ASSERT(bgcolor == nil, "[ERR] Parameter bgcolor is not yet implemented.")
  local img = setmetatable({}, meta)

  if height then
    -- creating empty image with dimensions
    local imageData = love.image.newImageData(widthOrPath, height)
    img.data = love.graphics.newImage(imageData)  
  else
    -- creating image from file
    img.data = love.graphics.newImage(widthOrPath..".png")  
  end

  return img
end

function meta:getSize()
  return self.data:getWidth(), self.data:getHeight()
end

function meta:draw(x, y, flip, qx, qy, qw, qh)
  -- always render pure white so its not tinted
  local r, g, b = love.graphics.getColor()
  love.graphics.setColor(1, 1, 1, 1)

  local sx = 1
  local sy = 1
  if flip then
    local w = self.data:getWidth()
    local h = self.data:getHeight()
    if flip == playdate.graphics.kImageFlippedX then
      sx = -1
      x = x + w
    elseif flip == playdate.graphics.kImageFlippedY then
      sy = -1
      y = y + h
    elseif flip == playdate.graphics.kImageFlippedXY then
      sx = -1
      sy = -1
      x = x + w
      y = y + h
    end
  end
  
  if qx and qy and qw and qh then
    local w, h = self:getSize()
    playdate.graphics._quad:setViewport(qx, qy, qw, qh, w, h)
    love.graphics.draw(self.data, playdate.graphics._quad, x, y, sx, sy)
  else
    love.graphics.draw(self.data, x, y, 0, sx, sy)
  end

  love.graphics.setColor(r, g, b, 1)
  playdate.graphics._updateContext()
end

function meta:drawRotated(x, y, angle)
  -- always render pure white so its not tinted
  local r, g, b = love.graphics.getColor()
  love.graphics.setColor(1, 1, 1, 1)

  -- playdate.image.drawRotated() draws the texture centered, so emulate that
  love.graphics.push()
  local w = self.data:getWidth() * 0.5
  local h = self.data:getHeight() * 0.5

  -- using fractional numbers will cause jitter and artifacting
  w = math.floor(w)
  h = math.floor(h)

  love.graphics.translate(x, y)
  love.graphics.rotate(math.rad(angle))
  love.graphics.draw(self.data, -w, -h)
  love.graphics.pop()

  love.graphics.setColor(r, g, b, 1)
  playdate.graphics._updateContext()
end

function meta:drawScaled(x, y, scale, yscale)
  yscale = yscale or scale

  -- always render pure white so its not tinted
  local r, g, b = love.graphics.getColor()
  love.graphics.setColor(1, 1, 1, 1)

  love.graphics.push()
  love.graphics.translate(x, y)
  love.graphics.scale(scale, yscale)
  love.graphics.draw(self.data, 0, 0)
  love.graphics.pop()

  love.graphics.setColor(r, g, b, 1)
  playdate.graphics._updateContext()
end