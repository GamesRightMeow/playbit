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
    if love.filesystem.getInfo(widthOrPath..".png") then
      img.data = love.graphics.newImage(widthOrPath..".png")
    elseif love.filesystem.getInfo(widthOrPath) then
      img.data = love.graphics.newImage(widthOrPath)
    else
      return nil
    end
  end

  return img
end

function meta:load(path)
  error("[ERR] playdate.graphics.image:load() is not yet implemented.")
end

function meta:copy()
  local img = setmetatable({}, meta)
  img.data = self.data
  img.sx = self.sx
  img.sy = self.sy
  return img
end

function meta:getSize()
  local w, h = self.data:getWidth(), self.data:getHeight()

  if self.sx then
    w = math.floor(w * self.sx)
    h = math.floor(h * self.sy)
  end

  return w, h
end

function module.imageSizeAtPath(path)
  error("[ERR] playdate.graphics.image.imageSizeAtPath() is not yet implemented.")
end

-- TODO: handle overloaded signatures:
-- (x, y, flip, sourceRect)
-- (p, flip, sourceRect)
function meta:draw(x, y, flip, qx, qy, qw, qh)
  local sx = 1
  local sy = 1
  if flip then
    local w, h = self:getSize()
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

  playbit.graphics.setDrawMode("image")

  if qx and qy and qw and qh then
    local w, h = self:getSize()
    playbit.graphics.quad:setViewport(qx, qy, qw, qh, w, h)
    love.graphics.draw(self.data, playbit.graphics.quad, x, y, 0, sx, sy)
  else
    if self.sx then
      sx = sx * self.sx
      sy = sy * self.sy
    end
    love.graphics.draw(self.data, x, y, 0, sx, sy)
  end

  playbit.graphics.updateContext()
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

  -- playdate.image.drawRotated() draws the texture centered, so emulate that
  local w = self.data:getWidth() * 0.5
  local h = self.data:getHeight() * 0.5

  -- using fractional numbers will cause jitter and artifacting
  w = math.floor(w)
  h = math.floor(h)

  local sx = self.sx or 1
  local sy = self.sy or 1

  playbit.graphics.setDrawMode("image")

  love.graphics.draw(self.data, x, y, math.rad(angle), sx, sy, w, h)

  playbit.graphics.updateContext()
end

function meta:rotatedImage(angle, scale, yscale)
  error("[ERR] playdate.graphics.image:rotatedImage() is not yet implemented.")
end

function meta:drawScaled(x, y, scale, yscale)
  yscale = yscale or scale

  local sx = self.sx or 1
  local sy = self.sy or 1

  sx = sx * scale
  sy = sy * (yscale or scale)

  playbit.graphics.setDrawMode("image")

  love.graphics.draw(self.data, x, y, 0, sx, sy)

  playbit.graphics.updateContext()
end

function meta:scaledImage(scale, yscale)
  local img = self:copy()

  local sx = img.sx or 1
  local sy = img.sy or 1

  img.sx = sx * scale
  img.sy = sy * (yscale or scale)

  return img
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