local module = {}
playdate.graphics = module

require("playdate.font")
require("playdate.image")
require("playdate.imagetable")
require("playdate.tilemap")
require("playdate.sprites")

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

module.kStrokeCentered = 0
module.kStrokeInside = 1
module.kStrokeOutside = 2

module.kLineCapStyleButt = 0
module.kLineCapStyleSquare = 1
module.kLineCapStyleRound = 2

module.kPolygonFillNonZero = 0
module.kPolygonFillEvenOdd = 1

kTextAlignment = {
	left = 0,
	right = 1,
	center = 2,
}

local colorByIndex = {
  [0] = { 0, 0, 0, 1 },
  [1] = { 1, 1, 1, 1 },
  [2] = { 0, 0, 0, 0 }
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
  playbit.graphics.backgroundColor = colorByIndex[color]
  -- don't actually set love's bg color here since doing so immediately sets the color, and this is not consistent with PD
end

function module.getBackgroundColor(color)
  return playbit.graphics.backgroundColorIndex
end

function module.setColor(color)
  @@ASSERT(color == 1 or color == 0, "Only values of 0 (black) or 1 (white) are supported.")
  playbit.graphics.drawColorIndex = color
  local c = colorByIndex[color]
  playbit.graphics.drawColor = c
  playbit.graphics.shaders.color:send("drawColor", c)
  -- color and pattern modes are mutually exclusive
  playbit.graphics.drawPattern = nil
end

function module.getColor()
  return playbit.graphics.drawColorIndex
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

  playbit.graphics.shaders.pattern:send("pattern", unpack(pixels))
end

function module.setDitherPattern(alpha, ditherType)
  error("[ERR] playdate.graphics.setDitherPattern() is not yet implemented.")
end

function module.clear(color)
  if not color then
    local c = playbit.graphics.backgroundColor
    love.graphics.clear(c[1], c[2], c[3], c[4])
    playbit.graphics.lastClearColor = c
  else
    @@ASSERT(color == 1 or color == 0, "Only values of 0 (black) or 1 (white) are supported.")
    local c = colorByIndex[color]
    love.graphics.clear(c[1], c[2], c[3], c[4])
    playbit.graphics.lastClearColor = c
  end
end

-- "copy", "inverted", "XOR", "NXOR", "whiteTransparent", "blackTransparent", "fillWhite", or "fillBlack".
function module.setImageDrawMode(mode)
  if type(mode) == "string" then
    mode = playbit.graphics.textToImageDrawMode[string.lower(mode)]
  end

  playbit.graphics.imageDrawMode = mode
end

function module.getImageDrawMode()
  return playbit.graphics.imageDrawMode
end

function module.drawCircleAtPoint(x, y, radius)
  playbit.graphics.setDrawMode("line")

  if type(x) ~= "number" then
    local pt = x
    radius = y
    x, y = pt.x, pt.y
  end

  love.graphics.circle("line", x, y, radius)
end

function module.fillCircleAtPoint(x, y, radius)
  playbit.graphics.setDrawMode("fill")

  if type(x) ~= "number" then
    local pt = x
    radius = y
    x, y = pt.x, pt.y
  end

  love.graphics.circle("fill", x, y, radius)
end

function module.drawEllipseInRect(x, y, width, height, startAngle, endAngle)
  error("[ERR] playdate.graphics.drawEllipseInRect() is not yet implemented.")
end

function module.fillEllipseInRect(x, y, width, height, startAngle, endAngle)
  error("[ERR] playdate.graphics.fillEllipseInRect() is not yet implemented.")
end

function module.drawPolygon(x1, y1, x2, y2, ...)
  error("[ERR] playdate.graphics.drawPolygon() is not yet implemented.")
end

function module.fillPolygon(x1, y1, x2, y2, ...)
  error("[ERR] playdate.graphics.fillPolygon() is not yet implemented.")
end

function module.setPolygonFillRule(rule)
  error("[ERR] playdate.graphics.setPolygonFillRule() is not yet implemented.")
end

function module.drawTriangle(x1, y1, x2, y2, x3, y3)
  error("[ERR] playdate.graphics.drawTriangle() is not yet implemented.")
end

function module.fillTriangle(x1, y1, x2, y2, x3, y3)
  error("[ERR] playdate.graphics.fillTriangle() is not yet implemented.")
end

function module.setLineWidth(width)
  -- PD examples use line width 0 but love2d does not support it.
  if width < 1 then width = 1 end
  playbit.graphics.lineWidth = width
  love.graphics.setLineWidth(width)
end

function module.getLineWidth()
  return playbit.graphics.lineWidth
end

function module.setLineCapStyle(style)
  error("[ERR] playdate.graphics.setLineCapStyle() is not yet implemented.")
end

function module.drawRect(x, y, width, height)
  playbit.graphics.setDrawMode("line")

  if type(x) ~= "number" then
    local r = x
    x, y, width, height = r:unpack()
  end

  love.graphics.rectangle("line", x, y, width, height)
end

function module.fillRect(x, y, width, height)
  playbit.graphics.setDrawMode("fill")

  if type(x) ~= "number" then
    local r = x
    x, y, width, height = r:unpack()
  end

  love.graphics.rectangle("fill", x, y, width, height)
end

function module.drawRoundRect(x, y, width, height, radius)
  -- TODO: love's rectangle function doesn't draw the same way as Playdate's
  -- playbit.graphics.setDrawMode("line")

  -- love.graphics.rectangle("line", x, y, width, height, radius, radius, 0)
  error("[ERR] playdate.graphics.drawRoundRect() is not yet implemented.")
end

function module.fillRoundRect(x, y, width, height, radius)
  -- TODO: love's rectangle function doesn't draw the same way as Playdate's
  --   playbit.graphics.setDrawMode("fill")

  -- love.graphics.rectangle("fill", x, y, width, height, radius, radius, 0)
  error("[ERR] playdate.graphics.fillRoundRect() is not yet implemented.")
end

function module.drawLine(x1, y1, x2, y2)
  playbit.graphics.setDrawMode("line")

  if type(x1) ~= "number" then
    local ls = x1
    x1, y1, x2, y2 = ls:unpack()
  end

  love.graphics.line(x1, y1, x2, y2)
end

function module.drawPolygon(x1, y1, x2, y2, ...)
  playbit.graphics.setDrawMode("line")

  if type(x1) ~= "number" then
    local poly = x1
    if poly:isClosed() then
      love.graphics.polygon("line", unpack(poly._points))
    else
      love.graphics.line(unpack(poly._points))
    end
  else
    love.graphics.polygon("line", x1, y1, x2, y2, ...)
  end
end

function module.drawArc(x, y, radius, startAngle, endAngle)

  local function normalizeAngle(deg)
      return (deg % 360 + 360) % 360
  end

  if type(x) ~= "number" then
    local arc = x
    x, y, radius, startAngle, endAngle = arc.x, arc.y, arc.radius, arc.startAngle, arc.endAngle
  end

  -- Bring angles to interval [0, 360)
  startAngle = normalizeAngle(startAngle)
  endAngle = normalizeAngle(endAngle)

  -- PD always draws from startAngle to endAngle clockwise.
  if startAngle >= endAngle then
    endAngle = endAngle + 360
  end

  -- 0 degrees is 270 when drawing an arc on PD...
  startAngle = startAngle - 90
  endAngle = endAngle - 90

  playbit.graphics.setDrawMode("line")

  love.graphics.arc("line", "open", x, y, radius, math.rad(startAngle), math.rad(endAngle), 32)
end

function module.drawPixel(x, y)
  playbit.graphics.setDrawMode("line")

  love.graphics.points(x, y)
end

function module.perlin(x, y, z, rep, octaves, persistence)
  error("[ERR] playdate.graphics.perlin() is not yet implemented.")
end

function module.perlinArray(count, x, dx, y, dy, z, dz, rep, octaves, persistence)
  error("[ERR] playdate.graphics.perlinArray() is not yet implemented.")
end

function module.generateQRCode(stringToEncode, desiredEdgeDimension, callback)
  error("[ERR] playdate.graphics.generateQRCode() is not yet implemented.")
end

function module.drawSineWave(startX, startY, endX, endY, startAmplitude, endAmplitude, period, phaseShift)
  error("[ERR] playdate.graphics.drawSineWave() is not yet implemented.")
end

function module.setClipRect(x, y, width, height)
  error("[ERR] playdate.graphics.setClipRect() is not yet implemented.")
end

function module.getClipRect()
  error("[ERR] playdate.graphics.getClipRect() is not yet implemented.")
end

function module.setScreenClipRect(x, y, width, height)
  error("[ERR] playdate.graphics.setScreenClipRect() is not yet implemented.")
end

function module.getScreenClipRect()
  error("[ERR] playdate.graphics.getScreenClipRect() is not yet implemented.")
end

function module.clearClipRect()
  error("[ERR] playdate.graphics.clearClipRect() is not yet implemented.")
end

function module.setStencilImage(image, tile)
  error("[ERR] playdate.graphics.setStencilImage() is not yet implemented.")
end

-- setStencilPattern(pattern)
-- setStencilPattern(level, [ditherType])
function module.setStencilPattern(row1, row2, row3, row4, row5, row6, row7, row8)
  error("[ERR] playdate.graphics.setStencilPattern() is not yet implemented.")
end

function module.clearStencil()
  error("[ERR] playdate.graphics.clearStencil() is not yet implemented.")
end

function module.clearStencilImage()
  error("[ERR] playdate.graphics.clearStencilImage() is not yet implemented.")
end

function module.setStrokeLocation(location)
  error("[ERR] playdate.graphics.setStrokeLocation() is not yet implemented.")
end

function module.getStrokeLocation()
  error("[ERR] playdate.graphics.getStrokeLocation() is not yet implemented.")
end

function module.lockFocus(image)
  error("[ERR] playdate.graphics.lockFocus() is not yet implemented.")
end

function module.unlockFocus()
  error("[ERR] playdate.graphics.unlockFocus() is not yet implemented.")
end

function module.getDisplayImage()
  error("[ERR] playdate.graphics.getDisplayImage() is not yet implemented.")
end

function module.getWorkingImage()
  error("[ERR] playdate.graphics.getWorkingImage() is not yet implemented.")
end

function module.setFont(font)
  playbit.graphics.activeFont = font
  love.graphics.setFont(font.data)
end

function module.getFont()
  return playbit.graphics.activeFont
end

function module.setFontFamily(fontFamily)
  error("[ERR] playdate.graphics.setFontFamily() is not yet implemented.")
end

function module.setFontTracking(pixels)
  error("[ERR] playdate.graphics.setFontTracking() is not yet implemented.")
end

function module.getFontTracking()
  error("[ERR] playdate.graphics.getFontTracking() is not yet implemented.")
end

function module.getSystemFont(variant)
  error("[ERR] playdate.graphics.getSystemFont() is not yet implemented.")
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
  local context = {
    drawOffset = playbit.graphics.drawOffset,
    drawColorIndex = playbit.graphics.drawColorIndex,
    drawColor = playbit.graphics.drawColor,
    backgroundColorIndex = playbit.graphics.backgroundColorIndex,
    backgroundColor = playbit.graphics.backgroundColor,
    activeFont = playbit.graphics.activeFont,
    imageDrawMode = playbit.graphics.imageDrawMode,
    canvas = playbit.graphics.canvas,
    drawPattern = playbit.graphics.drawPattern,
    lineWidth = playbit.graphics.lineWidth
  }

  -- push context
  table.insert(playbit.graphics.contextStack, context)

  if image then
    -- create canvas if it doesn't exist
    if not image._canvas then
      image._canvas = love.graphics.newCanvas(image:getSize())
    end

    -- update current render target
    module.canvas = image._canvas
    love.graphics.setCanvas(image._canvas)
  end
end

function module.popContext()
  @@ASSERT(#playbit.graphics.contextStack > 0, "No pushed context.")

  -- pop context
  local context = table.remove(playbit.graphics.contextStack)

  -- restore canvas
  playbit.graphics.canvas = context.canvas
  love.graphics.setCanvas(context.canvas)

  module.setImageDrawMode(context.imageDrawMode)
  module.setDrawOffset(context.drawOffset.x, context.drawOffset.y)
  module.setBackgroundColor(context.backgroundColorIndex)
  module.setColor(context.drawColorIndex)
  module.setFont(context.activeFont)
  module.setLineWidth(context.lineWidth)

  if context.drawPattern then
    module.setPattern(context.drawPattern)
  end

  playbit.graphics.shader = nil
end
