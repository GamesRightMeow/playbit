--docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#C-graphics.image

local module = {}
playdate.graphics.image = module

local meta = {}
meta.__index = meta
module.__index = meta

function module.new(widthOrPath, height, bgcolor)
  local bgColorConst = playbit.graphics.colorClear
  if bgcolor == playdate.graphics.kColorBlack then
    bgColorConst = playbit.graphics.colorBlack
  elseif bgcolor == playdate.graphics.kColorWhite then
    bgColorConst = playbit.graphics.colorWhite
  end
  local img = setmetatable({}, meta)

  if height then
    -- creating empty image with dimensions
    local imageData = love.image.newImageData(widthOrPath, height)
    for i = 0, widthOrPath-1, 1 do
      for j = 0, height-1 ,1 do
        imageData:setPixel(i,j,bgColorConst[1],bgColorConst[2],bgColorConst[3],bgColorConst[4])
      end
    end
    img.data = love.graphics.newImage(imageData)
    img.imageData = imageData
  else
    -- creating image from file
    img.imageData = love.image.newImageData( widthOrPath..".png" )
    img.data = love.graphics.newImage(img.imageData)  
  end

  return img
end

function meta:load(path)
  error("[ERR] playdate.graphics.image:load() is not yet implemented.")
end

function meta:copy()
  --TODO use clone to copy imagedata?
  local img = setmetatable({}, meta)
  local imageData
  if self.imageData == nil then
    imageData = love.image.newImageData(self.data:getWidth(), self.data:getHeight())
  else
    imageData = self.imageData:clone()
  end
  img.data = love.graphics.newImage(imageData)
  img.imageData = imageData
  return img
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
  local dx,dy = 0,0
  -- if #playbit.graphics.contextStack ~= 0 then
  --   dx = playbit.graphics.drawOffset.x
  --   dy = playbit.graphics.drawOffset.y
  -- end
  if qx and qy and qw and qh then
    local w, h = self:getSize()
    playbit.graphics.quad:setViewport(qx, qy, qw, qh, w, h)
    love.graphics.draw(self.data, playbit.graphics.quad, x-dx, y-dy, sx, sy)
  elseif qx then
    love.graphics.draw(self.data, qx, x-dx, y-dy,0, sx, sy)
  else
    love.graphics.draw(self.data, x-dx, y-dy, 0, sx, sy)
  end

  love.graphics.setColor(r, g, b, 1)
  playbit.graphics.updateContext()
end

function meta:drawAnchored(x, y, ax, ay, flip)
  error("[ERR] playdate.graphics.image:drawAnchored() is not yet implemented.")
end

function meta:drawCentered(x, y, flip)
  self:draw(x-self.data:getWidth()/2,y-self.data:getHeight()/2)
  
end

function meta:clear(color)
  self._canvas = nil
  local clearColor = playbit.graphics.colorWhite
  if color == playdate.graphics.kColorBlack then
    clearColor = playbit.graphics.colorBlack
  elseif color == playdate.graphics.kColorClear then
    clearColor = playbit.graphics.colorClear
  end
  if self.imageData == nil then
    self.imageData = love.image.newImageData(self.data:getWidth(), self.data:getHeight())
  end
  -- for i = 0, self.data:getWidth()-1, 1 do
  --   for j = 0, self.data:getHeight()-1 ,1 do
  --     self.imageData:setPixel(i,j,clearColor[1],clearColor[2],clearColor[3],clearColor[4])
  --     --self.imageData:setPixel(i,j,math.random(),math.random(),math.random(),1)
  --   end
  -- end
  
  local curcanvas = love.graphics.getCanvas( )
  if self._canvas == nil then
    self._canvas = love.graphics.newCanvas(self:getSize())
  end
  love.graphics.push()
  love.graphics.setCanvas(self._canvas)
  love.graphics.clear( clearColor[1],clearColor[2],clearColor[3],clearColor[4] )
  love.graphics.pop()
  love.graphics.setCanvas(curcanvas)
  
  self.imageData = self._canvas:newImageData()
  self.data = love.graphics.newImage(self.imageData)
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
  playbit.graphics.updateContext()
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
  playbit.graphics.updateContext()
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
  
  local imgWidth , imgHeight = self:getSize()
  self.data:setWrap("repeat", "repeat")
	quad = love.graphics.newQuad( 0,0, width,height, imgWidth,imgHeight )	-- assuming the image is 16x16
  local r, g, b = love.graphics.getColor()
  love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(self.data, quad, x,y, 0, 1,1)
  love.graphics.setColor(r, g, b, 1)
  playbit.graphics.updateContext()
end

function meta:drawBlurred(x, y, radius, numPasses, ditherType, flip, xPhase, yPhase)
  error("[ERR] playdate.graphics.image:drawBlurred() is not yet implemented.")
end

function meta:blurredImage(radius, numPasses, ditherType, padEdges, xPhase, yPhase)
  if self.imageData == nil then
    return self:copy()
  end
  error("[ERR] playdate.graphics.image:blurredImage() is not yet implemented.")
end

function meta:drawFaded(x, y, alpha, ditherType)
  error("[ERR] playdate.graphics.image:drawFaded() is not yet implemented.")
end

function meta:fadedImage(alpha, ditherType)
  local ditherArray = {0.28125,0.65625,0.84375,0.21875,0.09375,0.53125,0.46875,0.71875,0.78125,0.59375,0.90625,0.40625,0.34375,0.96875,0.03125,0.15625}
  local ditherArray = {0/16,12/16,3/16,15/16,8/16,4/16,11/16,7/16,2/16,14/16,1/16,13/16,10/16,6/16,9/16,5/16}
  local counter = 1
  local offset = 0
  local maxcounter = #ditherArray
  local fadedImg = self:copy()

  local width , height = fadedImg.imageData:getWidth(), fadedImg.imageData:getHeight()
  local startFade = love.timer.getTime()
  for i = 0, width -1, 1 do
    for j = 0, height -1, 1 do
      counter = counter + 1 
      if counter > maxcounter then
        counter = 1
      end
      counter = 1+i+j*4
      if ditherArray[(counter+offset)%maxcounter+1] > alpha then
        fadedImg.imageData:setPixel(i,j,playbit.graphics.colorClear)
      end
    end
  end
  fadedImg.data = love.graphics.newImage(fadedImg.imageData)
  return fadedImg
  --error("[ERR] playdate.graphics.image:fadedImage() is not yet implemented.")
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