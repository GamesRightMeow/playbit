local module = {}
playdate.graphics.image = module

local meta = {}
meta.__index = meta
module.__index = meta

function module.new(widthOrPath, height, bgcolor)
  @@ASSERT(bgcolor == nil, "Parameter 'bgcolor' is not implemented.")
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

local maskEffect = love.graphics.newShader[[
   vec4 effect (vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
      if (Texel(texture, texture_coords).r < 0.5) {
         // a discarded pixel wont be applied as the stencil.
         discard;
      }
      return vec4(1.0);
   }
]]

local maskEffectImage = nil

local function maskEffectStencilFunction()
   love.graphics.setShader(maskEffect)
   love.graphics.draw(maskEffectImage, 0, 0)
   love.graphics.setShader()
end

function meta:setMaskImage(maskImage)
  if self.maskImage then
    self.maskImage = nil
    -- Force releasing image data to avoid memory leaks
    collectgarbage('collect')
  end
  
  self.maskImage = maskImage
end

function meta:getMaskImage()
  return self.maskImage
end

local function beginDraw(img)
  @@ASSERT(maskEffectImage == nil, "Detected beginDraw() and endDraw() mismatch.")
  if img.maskImage then
    maskEffectImage = img.maskImage.data
    love.graphics.stencil(maskEffectStencilFunction, "replace", 1)
	love.graphics.setStencilTest("greater", 0)
  end
end

local function endDraw(img)
  if img.maskImage then
    @@ASSERT(maskEffectImage ~= nil, "Detected beginDraw() and endDraw() mismatch.")
    maskEffectImage = nil
    love.graphics.setStencilTest()
  else
    @@ASSERT(maskEffectImage == nil, "Detected beginDraw() and endDraw() mismatch.")
  end
end

function meta:draw(x, y, flip, qx, qy, qw, qh)
  beginDraw(self)

  -- always render pure white so its not tinted
  local r, g, b = love.graphics.getColor()
  love.graphics.setColor(1, 1, 1, 1)

  @@ASSERT(not flip or flip == 0, "Flip not implemented.")
  
  if qx and qy and qw and qh then
    local w, h = self:getSize()
    playdate.graphics._quad:setViewport(qx, qy, qw, qh, w, h)
    love.graphics.draw(self.data, playdate.graphics._quad, x, y)
  else
    love.graphics.draw(self.data, x, y)
  end

  love.graphics.setColor(r, g, b, 1)
  playdate.graphics._updateContext()
  
  endDraw(self)
end

function meta:drawRotated(x, y, angle)
  beginDraw(self)
  
  -- always render pure white so its not tinted
  local r, g, b = love.graphics.getColor()
  love.graphics.setColor(1, 1, 1, 1)

  -- playdate.image.drawRotated() draws the texture centered, so emulate that
  love.graphics.push()
  local w = self.data:getWidth() * 0.5
  local h = self.data:getHeight() * 0.5
  love.graphics.translate(x, y)
  love.graphics.rotate(math.rad(angle))
  love.graphics.draw(self.data, -w, -h)
  love.graphics.pop()

  love.graphics.setColor(r, g, b, 1)
  playdate.graphics._updateContext()
  
  endDraw(self)
end

function meta:drawScaled(x, y, scale, yscale)
  beginDraw(self)
  
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
  
  endDraw(self)
end