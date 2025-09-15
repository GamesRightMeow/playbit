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
-- TODO: clear and XOR support

kTextAlignment = {
	left = 0,
	right = 1,
	center = 2,
}

function module.setDrawOffset(x, y)
  playbit.graphics.drawOffset.x = x
  playbit.graphics.drawOffset.y = y
  love.graphics.pop()
  love.graphics.push()
  love.graphics.translate(x, y)
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

function module.clear(color)
  if not color then
    local c = playbit.graphics.backgroundColor
    love.graphics.clear(c[1], c[2], c[3], c[4])
    playbit.graphics.lastClearColor = c
  else
    @@ASSERT(color == 1 or color == 0, "Only values of 0 (black) or 1 (white) are supported.")
    if color == 1 then
      local c = playbit.graphics.colorWhite
      love.graphics.clear(c[1], c[2], c[3], c[4])
      playbit.graphics.lastClearColor = c
    else
      local c = playbit.graphics.colorBlack
      love.graphics.clear(c[1], c[2], c[3], c[4])
      playbit.graphics.lastClearColor = c
    end
  end
  playbit.graphics.updateContext()
end

-- "copy", "inverted", "XOR", "NXOR", "whiteTransparent", "blackTransparent", "fillWhite", or "fillBlack".
function module.setImageDrawMode(mode)
  playbit.graphics.drawMode = mode
  if mode == module.kDrawModeCopy or mode == "copy" then
    playbit.graphics.shader:send("mode", 0)
  elseif mode == module.kDrawModeFillWhite or mode == "fillWhite" then
    playbit.graphics.shader:send("mode", 1)
  elseif mode == module.kDrawModeFillBlack or mode == "fillBlack" then
    playbit.graphics.shader:send("mode", 2)
  elseif mode == module.kDrawModeFillBlack or mode == "inverted" then
    playbit.graphics.shader:send("mode", 6)
  elseif mode == module.kDrawModeFillBlack or mode == "whiteTransparent" then
    playbit.graphics.shader:send("mode", 4)
  else
    error("[ERR] Draw mode '"..mode.."' is not yet implemented.")
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
  -- TODO: love's rectangle function doesn't draw the same way as Playdate's
  -- playbit.graphics.shader:send("mode", 8)

  -- love.graphics.rectangle("line", x, y, width, height, radius, radius, 0)
  -- playbit.graphics.updateContext()

  -- module.setImageDrawMode(playbit.graphics.drawMode)
  error("[ERR] playdate.graphics.drawRoundRect() is not yet implemented.")
end

function module.fillRoundRect(x, y, width, height, radius)
  -- TODO: love's rectangle function doesn't draw the same way as Playdate's
  -- playbit.graphics.shader:send("mode", 8)

  -- love.graphics.rectangle("fill", x, y, width, height, radius, radius, 0)
  -- playbit.graphics.updateContext()

  -- module.setImageDrawMode(playbit.graphics.drawMode)
  error("[ERR] playdate.graphics.fillRoundRect() is not yet implemented.")
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

function module.getTextSize(str, fontFamily, leadingAdjustment)
  @@ASSERT(fontFamily == nil, "[ERR] Parameter fontFamily is not yet implemented.")
  @@ASSERT(leadingAdjustment == nil, "[ERR] Parameter leadingAdjustment is not yet implemented.")

  local font = playbit.graphics.activeFont
  return font:getWidth(str), font:getHeight()
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

  return font:_drawTextInRect(text, x, y, width, height, leadingAdjustment, truncationString, textAlignment)
end

-- TODO: handle the overloaded signature (text, rect, fontFamily, leadingAdjustment, wrapMode, alignment)
function module.drawText(text, x, y, width, height, fontFamily, leadingAdjustment, wrapMode, alignment)
  @@ASSERT(width == nil, "[ERR] Parameter width is not yet implemented.")
  @@ASSERT(height == nil, "[ERR] Parameter height is not yet implemented.")
  @@ASSERT(wrapMode == nil, "[ERR] Parameter wrapMode is not yet implemented.")
  @@ASSERT(alignment == nil, "[ERR] Parameter alignment is not yet implemented.")

  @@ASSERT(text ~= nil, "Text is nil")
  local font = playbit.graphics.activeFont
  font:drawText(text, x, y, fontFamily, leadingAdjustment)
  playbit.graphics.updateContext()
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
  error("[ERR] playdate.graphics.getTextSizeForMaxWidth() is not yet implemented.")
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

  -- create canvas if it doesn't exist
  if not image._canvas then
    image._canvas = love.graphics.newCanvas(image:getSize())
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
  -- update current render target
  if #playbit.graphics.contextStack == 0 then
    love.graphics.setCanvas(playbit.graphics.canvas)
  else
    local activeContext = playbit.graphics.contextStack[#playbit.graphics.contextStack]
    love.graphics.setCanvas(activeContext._canvas)
  end
end