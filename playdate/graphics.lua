local module = {}
playdate.graphics = module

require("playdate.font")
require("playdate.image")
require("playdate.imagetable")
require("playdate.tilemap")

module.kDrawModeCopy = 0
module.kDrawModeWhiteTransparent = 1
module.kDrawModeBlackTransparent = 2
module.kDrawModeFillWhite = 3
module.kDrawModeFillBlack = 4
module.kDrawModeXOR = 5
module.kDrawModeNXOR = 6
module.kDrawModeInverted = 7

module.kImageUnflipped = 0
module.kImageFlippedX = 1
module.kImageFlippedY = 2
module.kImageFlippedXY = 3

module.kColorWhite = 1
module.kColorBlack = 0
module.kColorClear = 2
-- TODO: clear and XOR support

kTextAlignment = {
	left = 0,
	right = 1,
	center = 2,
}

function module.setDrawOffset(x, y)
  playbit.graphics._drawOffset.x = x
  playbit.graphics._drawOffset.y = y
  -- love.graphics.pop()
  -- love.graphics.push()
  -- love.graphics.translate(x, y)
end

function module.getDrawOffset()
  return playbit.graphics.drawOffset.x, playbit.graphics.drawOffset.y
end

function module.setBackgroundColor(color)
  @@ASSERT(color == 1 or color == 0, "Only values of 0 (black) or 1 (white) are supported.")
  playbit.graphics.backgroundColorIndex = color
  if color == 1 then
    playbit.graphics.backgroundColor = playbit.graphics.colorWhite
  else
    playbit.graphics.backgroundColor = playbit.graphics.colorBlack
  end
  -- don't actually set love's bg color here since doing so immediately sets the color, and this is not consistent with PD
end

function module.setColor(color)
  @@ASSERT(color == 1 or color == 0, "Only values of 0 (black) or 1 (white) are supported.")
  playbit.graphics.drawColorIndex = color
  -- when drawing without a pattern, we must flip the pattern mask for white/black because of the way the shader draws patterns
  if color == 1 then
    local c = playbit.graphics.colorWhite
    playbit.graphics.drawColor = c
    -- reset pattern, as per PD behavior
    module.setPattern({0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff})
    love.graphics.setColor(c[1], c[2], c[3], c[4])
  else
    local c = playbit.graphics.colorBlack
    playbit.graphics.drawColor = c
    -- reset pattern, as per PD behavior
    module.setPattern({0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00})
    love.graphics.setColor(c[1], c[2], c[3], c[4])
  end
end

function module.setPattern(pattern)
  playbit.graphics.drawPattern = pattern

  -- bitshifting does not work in shaders, so do it here in Lua
  local pixels = {}
  for i = 1, 8 do
    for j = 7, 0, -1 do
      local b = bit.lshift(1, j)
      if bit.band(pattern[i], b) == b then
        table.insert(pixels, 1)
      else
        table.insert(pixels, 0)
      end
    end
  end
  
  playbit.graphics.shader:send("pattern", unpack(pixels))
end
function module.setDitherPattern(alpha,ditherType)
  -- TODO Need to include patterns for other alphas and other ditherTypes
  local pattern = { 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55 }
  module.setPattern(pattern)
end
function module.clear(color)
  if not color then
    local c = playbit.graphics.backgroundColor
    love.graphics.clear(c[1], c[2], c[3], c[4])
    playbit.graphics.lastClearColor = c
  else
    @@ASSERT(color == 1 or color == 0 or color == 2, "Only values of 0 (black) or 1 (white) 2 (transparent) are supported.")
    if color == 1 then
      local c = playbit.graphics.colorWhite
      love.graphics.clear(c[1], c[2], c[3], c[4])
      playbit.graphics.lastClearColor = c
    elseif color == 0 then
      local c = playbit.graphics.colorBlack
      love.graphics.clear(c[1], c[2], c[3], c[4])
      playbit.graphics.lastClearColor = c
    else
      local c = playbit.graphics.colorClear
      love.graphics.clear(c[1], c[2], c[3], c[4])
      playbit.graphics.lastClearColor = c
    end
  end
  playbit.graphics.updateContext()
end
function module._refreshXORNXOR()
  -- refresh the XOR or NXOR image in the shader before drawing
  local mode = playbit.graphics.drawMode
  if mode == module.kDrawModeXOR or mode == "XOR" or mode == module.kDrawModeNXOR or mode == "NXOR" then
    module.setImageDrawMode(mode)
  end
end
-- "copy", "inverted", "XOR", "NXOR", "whiteTransparent", "blackTransparent", "fillWhite", or "fillBlack".
function module.setImageDrawMode(mode)
  if mode == nil then
    mode = "copy"
  end
  playbit.graphics.drawMode = mode
  if mode == module.kDrawModeCopy or mode == "copy" then
    playbit.graphics.shader:send("mode", 0)
  elseif mode == module.kDrawModeFillWhite or mode == "fillWhite" then
    playbit.graphics.shader:send("mode", 1)
  elseif mode == module.kDrawModeFillBlack or mode == "fillBlack" then
    playbit.graphics.shader:send("mode", 2)
  elseif mode == module.kDrawModeInverted or mode == "inverted" then
    playbit.graphics.shader:send("mode", 6)
  elseif mode == module.kDrawModeWhiteTransparent or mode == "whiteTransparent" then
    playbit.graphics.shader:send("mode", 4)
  elseif mode == module.kDrawModeXOR or mode == "XOR" then
    playbit.graphics.updateContext()
    local curCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas()
    local imageData = curCanvas:newImageData()
    love.graphics.setCanvas(curCanvas)
    local image = love.graphics.newImage(imageData)
    local xCol = {}
    playbit.graphics.shader:send("XORtexture",image)
    playbit.graphics.shader:send("mode", 7)
  elseif mode == module.kDrawModeNXOR or mode == "NXOR" then
    playbit.graphics.updateContext()
    -- local activeContext = playbit.graphics.contextStack[#playbit.graphics.contextStack]
    -- local imageData = activeContext._canvas:newImageData()
    -- local image = love.graphics.newImage(imageData)
    local curCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas()
    local imageData = curCanvas:newImageData()
    love.graphics.setCanvas(curCanvas)
    local image = love.graphics.newImage(imageData)
    local xCol = {}
    local width,height = image:getDimensions()
    playbit.graphics.shader:send("XORSizeX", width)
    playbit.graphics.shader:send("XORSizeY", height)
    playbit.graphics.shader:send("XORtexture",image)
    playbit.graphics.shader:send("mode", 3)
  else
    -- TODO implement "XOR", "NXOR" mode
    -- print("[Warning] Draw mode '"..mode.."' is not yet implemented.")
    playbit.graphics.shader:send("mode", 0)
  end
end

function module.drawCircleAtPoint(x, y, radius)
  playbit.graphics.shader:send("mode", 8)

  love.graphics.circle("line", x, y, radius)
  playbit.graphics.updateContext()

  module.setImageDrawMode(playbit.graphics.drawMode)
end

function module.fillCircleAtPoint(x, y, radius)
  playbit.graphics.shader:send("mode", 8)

  love.graphics.circle("fill", x, y, radius)
  playbit.graphics.updateContext()

  module.setImageDrawMode(playbit.graphics.drawMode)
end

function module.setLineWidth(width)
  love.graphics.setLineWidth(width)
end

function module.drawRect(x, y, width, height)
  playbit.graphics.shader:send("mode", 8)

  love.graphics.rectangle("line", x, y, width, height)
  playbit.graphics.updateContext()

  module.setImageDrawMode(playbit.graphics.drawMode)
end

function module.fillRect(x, y, width, height)
  playbit.graphics.shader:send("mode", 8)

  love.graphics.rectangle("fill", x, y, width, height)
  playbit.graphics.updateContext()

  module.setImageDrawMode(playbit.graphics.drawMode)
end

function module.drawRoundRect(x, y, width, height, radius)
  playbit.graphics.shader:send("mode", 8)
  
  if radius > 0.5 * width then
    radius = 0.5*width
  end
  if radius > 0.5 * height then
    radius = 0.5*height
  end
  local X1,X2,X3,X4 = x,x+radius,x+width-radius,x+width
  local Y1,Y2,Y3,Y4 = y,y+radius,y+height-radius,y+height
  love.graphics.line(X2,Y1,X3,Y1)
  love.graphics.line(X2,Y4,X3,Y4)
  love.graphics.line(X1,Y2,X1,Y3)
  love.graphics.line(X4,Y2,X4,Y3)

  love.graphics.arc("line", "open", x+radius, y+radius, radius, math.rad(180), math.rad(270), radius)
  love.graphics.arc("line", "open", x+radius, y-radius+height, radius, math.rad(90), math.rad(180), radius)
  love.graphics.arc("line", "open", x-radius+width, y+radius, radius, math.rad(270), math.rad(360), radius)
  love.graphics.arc("line", "open", x-radius+width, y-radius+height, radius, math.rad(0), math.rad(90), radius)

  playbit.graphics.updateContext()

  module.setImageDrawMode(playbit.graphics.drawMode)
end

function module.fillRoundRect(x, y, width, height, radius)
  playbit.graphics.shader:send("mode", 8)
  if radius > 0.5 * width then
    radius = 0.5*width
  end
  if radius > 0.5 * height then
    radius = 0.5*height
  end
  love.graphics.arc("fill", "pie", x+radius, y+radius, radius, math.rad(180), math.rad(270), radius)
  love.graphics.arc("fill", "pie", x+radius, y-radius+height, radius, math.rad(90), math.rad(180), radius)
  love.graphics.arc("fill", "pie", x-radius+width, y+radius, radius, math.rad(270), math.rad(360), radius)
  love.graphics.arc("fill", "pie", x-radius+width, y-radius+height, radius, math.rad(0), math.rad(90), radius)
  love.graphics.rectangle("fill", x+radius, y, width-radius*2, height)
  love.graphics.rectangle("fill", x, y+radius, width, height-radius*2)
  module.setImageDrawMode(playbit.graphics.drawMode)
  -- TODO: love's rectangle function doesn't draw the same way as Playdate's
  -- playbit.graphics.shader:send("mode", 8)

  -- love.graphics.rectangle("fill", x, y, width, height, radius, radius, 0)
  -- playbit.graphics.updateContext()

  -- module.setImageDrawMode(playbit.graphics.drawMode)
  --error("[ERR] playdate.graphics.fillRoundRect() is not yet implemented.")
end

function module.drawLine(x1, y1, x2, y2)
  playbit.graphics.shader:send("mode", 8)

  love.graphics.line(x1, y1, x2, y2)
  playbit.graphics.updateContext()

  module.setImageDrawMode(playbit.graphics.drawMode)
end

function module.drawArc(x, y, radius, startAngle, endAngle)
  playbit.graphics.shader:send("mode", 8)

  -- 0 degrees is 270 when drawing an arc on PD...
  startAngle = startAngle - 90
  endAngle = endAngle - 90

  if startAngle == endAngle then
    -- if startAngle and endAngle are the same, PD draws a full circle
    love.graphics.arc("line", "open", x, y, radius, math.rad(startAngle), math.rad(endAngle + 360), 16)
  elseif startAngle > endAngle then
    -- love2d adjusts for when the startAngle is larger, but PD does not, so we need to compensate
    love.graphics.arc("line", "open", x, y, radius, math.rad(startAngle), math.rad(endAngle + 360), 16)
  else
    love.graphics.arc("line", "open", x, y, radius, math.rad(endAngle), math.rad(startAngle), 16)
  end
  playbit.graphics.updateContext()

  module.setImageDrawMode(playbit.graphics.drawMode)
end

function module.drawPixel(x, y)
  playbit.graphics.shader:send("mode", 8)

  love.graphics.points(x, y)
  playbit.graphics.updateContext()

  module.setImageDrawMode(playbit.graphics.drawMode)
end

function module.setFont(font)
  playbit.graphics.activeFont = font
  love.graphics.setFont(font.data)
end

function module.getFont()
  return playbit.graphics.activeFont
end
function module.getSystemFont()
  return SYSTEM_FONT
end
function module.getTextSize(str, fontFamily, leadingAdjustment)
  @@ASSERT(fontFamily == nil, "[ERR] Parameter fontFamily is not yet implemented.")
  @@ASSERT(leadingAdjustment == nil, "[ERR] Parameter leadingAdjustment is not yet implemented.")
  if playbit.graphics.activeFont == nil then
    print('No current font')
  end
  local font = playbit.graphics.activeFont
  return font:getTextWidth(str), font:getHeight()
end

-- playdate.graphics.drawTextInRect(str, x, y, width, height, [leadingAdjustment, [truncationString, [alignment, [font]]]]) 
function module.drawTextInRect(text, x, ...)
  local y, width, height, leadingAdjustment, truncationString, textAlignment, font
  if type(x) == "number" then
    y, width, height, leadingAdjustment, truncationString, textAlignment, font = select(1, ...)
  else
    -- rect
    error("[ERR] Support for the rect parameter is not yet implemented.")
  end
  font = font or playbit.graphics.activeFont
  playdate.graphics._refreshXORNXOR()
  return font:_drawTextInRect(text, x, y, width, height, leadingAdjustment, truncationString, textAlignment)
end

-- TODO: handle the overloaded signature (text, rect, fontFamily, leadingAdjustment, wrapMode, alignment)
function module.drawText(text, x, y, width, height, fontFamily, leadingAdjustment, wrapMode, alignment)
  --@@ASSERT(width == nil, "[ERR] Parameter width is not yet implemented.")
  --@@ASSERT(height == nil, "[ERR] Parameter height is not yet implemented.")
  @@ASSERT(wrapMode == nil, "[ERR] Parameter wrapMode is not yet implemented.")
  @@ASSERT(alignment == nil, "[ERR] Parameter alignment is not yet implemented.")

  @@ASSERT(text ~= nil, "Text is nil")
  playdate.graphics._refreshXORNXOR()
  local font = playbit.graphics.activeFont
  local outwidth, outheight = font:drawText(text, x, y, fontFamily, leadingAdjustment)
  playbit.graphics.updateContext()
  return outwidth, outheight
end

-- TODO: handle the overloaded signature (key, rect, language, leadingAdjustment)
function module.drawLocalizedText(key, x, y, width, height, language, leadingAdjustment, wrapMode, alignment)
  error("[ERR] playdate.graphics.drawLocalizedText() is not yet implemented.")
end

function module.getLocalizedText(key, language)
  error("[ERR] playdate.graphics.getLocalizedText() is not yet implemented.")
end

function module.drawTextAligned(text, x, y, alignment, leadingAdjustment)
  module.getFont():drawTextAligned(text, x, y, alignment, leadingAdjustment)
end

function module.drawLocalizedTextAligned(text, x, y, alignment, language, leadingAdjustment)
  error("[ERR] playdate.graphics.drawLocalizedTextAligned() is not yet implemented.")
end

-- TODO: handle the overloaded signature (text, rect, leadingAdjustment, truncationString, alignment, font, language)
function module.drawLocalizedTextInRect(text, x, y, width, height, leadingAdjustment, truncationString, alignment, font, language)
  error("[ERR] playdate.graphics.drawLocalizedTextInRect() is not yet implemented.")
end

function module.getTextSizeForMaxWidth(text, maxWidth, leadingAdjustment, font)
  @@ASSERT(font, "Default font not yet implemented.")
  local width, height = font:_getTextSizeForMaxWidth(text,maxWidth,leadingAdjustment)
  return width, height
  --error("[ERR] playdate.graphics.getTextSizeForMaxWidth() is not yet implemented.")
end

function module.imageWithText(text, maxWidth, maxHeight, backgroundColor, leadingAdjustment, truncationString, alignment, font)
  error("[ERR] playdate.graphics.imageWithText() is not yet implemented.")
end

function module.checkAlphaCollision(image1, x1, y1, flip1, image2, x2, y2, flip2)
  error("[ERR] playdate.graphics.checkAlphaCollision() is not yet implemented.")
end

function module.pushContext(image)

  -- TODO: PD docs say image is optional, but not passing an image just results in drawing to last context?
  @@ASSERT(image, "Missing image parameter.")

  love.graphics.push()
  love.graphics.origin()
  -- create canvas if it doesn't exist
  if not image._canvas then
    image._canvas = love.graphics.newCanvas(image:getSize())
    love.graphics.setCanvas(image._canvas)
    local tempPattern = playbit.graphics.drawPattern
    local tempColor = playbit.graphics.drawColorIndex
    playdate.graphics.setColor(1)
    image:draw(0,0)
    playdate.graphics.setColor(tempColor)
    playdate.graphics.setPattern(tempPattern)
    playbit.graphics.updateContext()
  end
  
  -- push context
  table.insert(playbit.graphics.contextStack, image)

  -- update current render target
  love.graphics.setCanvas(image._canvas)
end

function module.popContext()
  @@ASSERT(#playbit.graphics.contextStack > 0, "No pushed context.")

  -- pop context
  table.remove(playbit.graphics.contextStack)
  love.graphics.pop()
  -- update current render target
  if #playbit.graphics.contextStack == 0 then
    love.graphics.setCanvas(playbit.graphics.canvas)
    --love.graphics.translate(playbit.graphics.drawOffset.x, playbit.graphics.drawOffset.y)
  else
    local activeContext = playbit.graphics.contextStack[#playbit.graphics.contextStack]
    love.graphics.setCanvas(activeContext._canvas)    
  end
end

----- Perlin Noise
--playdate.graphics.perlin(x, y, z, repeat, [octaves, persistence])
function module.perlin(x,y,z,_repeat,octaves,persistence)
  local perlinValue = 0
  local cumPersistence = 1
  local numOctaves = octaves or 1
  local maxValue = 0 
  for curOctaveInd = 1, numOctaves , 1 do
    local curOctave = math.pow(2,curOctaveInd-1)
    if _repeat ~= 0 then
      error('[ERR] non zero repeat for perlin noise not implemented')
      _repeat = _repeat*2
      x = (x+_repeat/2)%_repeat-_repeat/2
      y = (y+_repeat/2)%_repeat-_repeat/2
      z = (z+_repeat/2)%_repeat-_repeat/2
      perlinValue = perlinValue + cumPersistence*(0.5*perlin:noise(x*curOctave, y*curOctave, z*curOctave))
    else
      perlinValue = perlinValue + cumPersistence*(0.5*perlin:noise(x*curOctave, y*curOctave, z*curOctave))
    end
    maxValue = maxValue + cumPersistence
    cumPersistence = cumPersistence * persistence
  end
  return 0.5 + perlinValue/maxValue
end

--playdate.graphics.perlinArray(count, x, dx, [y, dy, z, dz, repeat, octaves, persistence])

--[[
    Implemented as described here:
    http://flafla2.github.io/2014/08/09/perlinnoise.html
]]--
--https://gist.github.com/kymckay/25758d37f8e3872e1636d90ad41fe2ed
perlin = {}
perlin.p = {}

-- Hash lookup table as defined by Ken Perlin
-- This is a randomly arranged array of all numbers from 0-255 inclusive
local permutation = {151,160,137,91,90,15,
  131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
  190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
  88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
  77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
  102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
  135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
  5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
  223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
  129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
  251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
  49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
  138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
}

-- p is used to hash unit cube coordinates to [0, 255]
for i=0,255 do
    -- Convert to 0 based index table
    perlin.p[i] = permutation[i+1]
    -- Repeat the array to avoid buffer overflow in hash function
    perlin.p[i+256] = permutation[i+1]
end

-- Return range: [-1, 1]
function perlin:noise(x, y, z)
    y = y or 0
    z = z or 0

    -- Calculate the "unit cube" that the point asked will be located in
    local xi = bit.band(math.floor(x),255)
    local yi = bit.band(math.floor(y),255)
    local zi = bit.band(math.floor(z),255)

    -- Next we calculate the location (from 0 to 1) in that cube
    x = x - math.floor(x)
    y = y - math.floor(y)
    z = z - math.floor(z)

    -- We also fade the location to smooth the result
    local u = self.fade(x)
    local v = self.fade(y)
    local w = self.fade(z)

    -- Hash all 8 unit cube coordinates surrounding input coordinate
    local p = self.p
    local A, AA, AB, AAA, ABA, AAB, ABB, B, BA, BB, BAA, BBA, BAB, BBB
    A   = p[xi  ] + yi
    AA  = p[A   ] + zi
    AB  = p[A+1 ] + zi
    AAA = p[ AA ]
    ABA = p[ AB ]
    AAB = p[ AA+1 ]
    ABB = p[ AB+1 ]

    B   = p[xi+1] + yi
    BA  = p[B   ] + zi
    BB  = p[B+1 ] + zi
    BAA = p[ BA ]
    BBA = p[ BB ]
    BAB = p[ BA+1 ]
    BBB = p[ BB+1 ]

    -- Take the weighted average between all 8 unit cube coordinates
    return self.lerp(w,
        self.lerp(v,
            self.lerp(u,
                self:grad(AAA,x,y,z),
                self:grad(BAA,x-1,y,z)
            ),
            self.lerp(u,
                self:grad(ABA,x,y-1,z),
                self:grad(BBA,x-1,y-1,z)
            )
        ),
        self.lerp(v,
            self.lerp(u,
                self:grad(AAB,x,y,z-1), self:grad(BAB,x-1,y,z-1)
            ),
            self.lerp(u,
                self:grad(ABB,x,y-1,z-1), self:grad(BBB,x-1,y-1,z-1)
            )
        )
    )
end

-- Gradient function finds dot product between pseudorandom gradient vector
-- and the vector from input coordinate to a unit cube vertex
perlin.dot_product = {
    [0x0]=function(x,y,z) return  x + y end,
    [0x1]=function(x,y,z) return -x + y end,
    [0x2]=function(x,y,z) return  x - y end,
    [0x3]=function(x,y,z) return -x - y end,
    [0x4]=function(x,y,z) return  x + z end,
    [0x5]=function(x,y,z) return -x + z end,
    [0x6]=function(x,y,z) return  x - z end,
    [0x7]=function(x,y,z) return -x - z end,
    [0x8]=function(x,y,z) return  y + z end,
    [0x9]=function(x,y,z) return -y + z end,
    [0xA]=function(x,y,z) return  y - z end,
    [0xB]=function(x,y,z) return -y - z end,
    [0xC]=function(x,y,z) return  y + x end,
    [0xD]=function(x,y,z) return -y + z end,
    [0xE]=function(x,y,z) return  y - x end,
    [0xF]=function(x,y,z) return -y - z end
}
function perlin:grad(hash, x, y, z)
    return self.dot_product[bit.band(hash,0xF)](x,y,z)
end

-- Fade function is used to smooth final output
function perlin.fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

function perlin.lerp(t, a, b)
    return a + t * (b - a)
end