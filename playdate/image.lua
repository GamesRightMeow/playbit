--docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#C-graphics.image

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

function meta:load(path)
  error("[ERR] playdate.graphics.image:load() is not yet implemented.")
end

function meta:copy()
  error("[ERR] playdate.graphics.image:copy() is not yet implemented.")
end

function meta:getSize()
  return self.data:getWidth(), self.data:getHeight()
end

function module.imageSizeAtPath(path)
  error("[ERR] playdate.graphics.image.imageSizeAtPath() is not yet implemented.")
end

-- TODO: handle overloaded signatures:
-- (x, y, flip, sourceRect)
-- (p, flip, sourceRect)
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

function meta:drawAnchored(x, y, ax, ay, flip)
  error("[ERR] playdate.graphics.image:drawAnchored() is not yet implemented.")
end

function meta:drawCentered(x, y, flip)
  error("[ERR] playdate.graphics.image:drawCentered() is not yet implemented.")
end

function meta:clear(color)
  error("[ERR] playdate.graphics.image:clear() is not yet implemented.")
end

function meta:sample(x, y)
  error("[ERR] playdate.graphics.image:sample() is not yet implemented.")
end

function meta:drawRotated(x, y, angle, scale, yscale)
  @@ASSERT(scale == nil, "[ERR] Parameter scale is not yet implemented.")
  @@ASSERT(yscale == nil, "[ERR] Parameter yscale is not yet implemented.")

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

function meta:rotatedImage(angle, scale, yscale)
  error("[ERR] playdate.graphics.image:rotatedImage() is not yet implemented.")
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

function meta:scaledImage(scale, yscale)
  error("[ERR] playdate.graphics.image:scaledImage() is not yet implemented.")
end


function meta:drawWithTransform(xform, x, y)
  error("[ERR] playdate.graphics.image:drawWithTransform() is not yet implemented.")
end

function meta:transformedImage(xform)
  error("[ERR] playdate.graphics.image:transformedImage() is not yet implemented.")
end

function meta:drawSampled(x, y, width, height, centerx, centery, dxx, dyx, dxy, dyy, dx, dy, z, tiltAngle, tile)
  error("[ERR] playdate.graphics.image:drawSampled() is not yet implemented.")
end

function meta:setMaskImage(maskImage)
  error("[ERR] playdate.graphics.image:setMaskImage() is not yet implemented.")
end

function meta:getMaskImage()
  error("[ERR] playdate.graphics.image:getMaskImage() is not yet implemented.")
end

function meta:addMask(opaque)
  error("[ERR] playdate.graphics.image:addMask() is not yet implemented.")
end

function meta:removeMask()
  error("[ERR] playdate.graphics.image:removeMask() is not yet implemented.")
end

function meta:hasMask()
  error("[ERR] playdate.graphics.image:hasMask() is not yet implemented.")
end

function meta:clearMask(opaque)
  error("[ERR] playdate.graphics.image:transformedImage() is not yet implemented.")
end

-- TODO: handle overloaded signature (rect, flip)
function meta:drawTiled(x, y, width, height, flip)
  error("[ERR] playdate.graphics.image:drawTiled() is not yet implemented.")
end

function meta:drawBlurred(x, y, radius, numPasses, ditherType, flip, xPhase, yPhase)
  error("[ERR] playdate.graphics.image:drawBlurred() is not yet implemented.")
end

function meta:blurredImage(radius, numPasses, ditherType, padEdges, xPhase, yPhase)
  error("[ERR] playdate.graphics.image:blurredImage() is not yet implemented.")
end

function meta:drawFaded(x, y, alpha, ditherType)
  error("[ERR] playdate.graphics.image:drawFaded() is not yet implemented.")
end

function meta:fadedImage(alpha, ditherType)
  error("[ERR] playdate.graphics.image:fadedImage() is not yet implemented.")
end

function meta:setInverted(flag)
  error("[ERR] playdate.graphics.image:setInverted() is not yet implemented.")
end

function meta:invertedImage()
  error("[ERR] playdate.graphics.image:invertedImage() is not yet implemented.")
end

function meta:blendWithImage(image, alpha, ditherType)
  error("[ERR] playdate.graphics.image:blendWithImage() is not yet implemented.")
end

function meta:vcrPauseFilterImage()
  error("[ERR] playdate.graphics.image:vcrPauseFilterImage() is not yet implemented.")
end