local module = {}
playdate.graphics = module

-- #b0aea7
local COLOR_WHITE = { r = 176 / 255, g = 174 / 255, b = 167 / 255 }
-- #312f28
local COLOR_BLACK = { r = 49 / 255, g = 47 / 255, b = 40 / 255 }

module._shader = love.graphics.newShader("playdate/shader")
module._drawOffset = { x = 0, y = 0}
module._drawColor = COLOR_WHITE
module._backgroundColor = COLOR_BLACK
module._activeFont = {}
module._drawMode = "copy"
module._canvas = love.graphics.newCanvas()
module._contextStack = {}
-- shared quad to reduce gc
module._quad = love.graphics.newQuad(0, 0, 1, 1, 1, 1)
module._lastClearColor = COLOR_WHITE
module._screenScale = 1
module._newScreenScale = 1

module.kDrawModeCopy = 0
module.kDrawModeWhiteTransparent = 1
module.kDrawModeBlackTransparent = 2
module.kDrawModeFillWhite = 3
module.kDrawModeFillBlack = 4
module.kDrawModeXOR = 5
module.kDrawModeNXOR = 6
module.kDrawModeInverted = 7

kTextAlignment = {
	left = 0,
	right = 1,
	center = 2,
}

---Converts playdate color into love rendering color.
---@return color
function module.getLoveColor(color)
  @@ASSERT(color == 1 or color == 0, "Only values of 0 (black) or 1 (white) are supported.")
  if color == 1 then
    return COLOR_WHITE
  else
    return COLOR_BLACK
  end
end

function module.setDrawOffset(x, y)
  module._drawOffset.x = x
  module._drawOffset.y = y
  love.graphics.pop()
  love.graphics.push()
  love.graphics.translate(x, y)
end

function module.getDrawOffset()
  return module._drawOffset.x, module._drawOffset.y
end

function module.setBackgroundColor(color)
  @@ASSERT(color == 1 or color == 0, "Only values of 0 (black) or 1 (white) are supported.")
  if color == 1 then
    module._backgroundColor = COLOR_WHITE
  else
    module._backgroundColor = COLOR_BLACK
  end
  -- don't actually set love's bg color here since doing so immediately sets the color, and this is not consistent with PD
end

function module.setColor(color)
  @@ASSERT(color == 1 or color == 0, "Only values of 0 (black) or 1 (white) are supported.")
  -- when drawing without a pattern, we must flip the pattern mask for white/black because of the way the shader draws patterns
  if color == 1 then
    module._drawColor = COLOR_WHITE
    -- reset pattern, as per PD behavior
    module.setPattern({0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff})
    love.graphics.setColor(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b, 1)
  else
    module._drawColor = COLOR_BLACK
    -- reset pattern, as per PD behavior
    module.setPattern({0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00})
    love.graphics.setColor(COLOR_BLACK.r, COLOR_BLACK.g, COLOR_BLACK.b, 1)
  end
end

function module.setPattern(pattern)
  module._drawPattern = pattern

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
  
  module._shader:send("pattern", unpack(pixels))
end

function module.clear(color)
  if not color then
    local c = module._backgroundColor
    love.graphics.clear(c.r, c.g, c.b, 1)
    module._lastClearColor = c
  else
    @@ASSERT(color == 1 or color == 0, "Only values of 0 (black) or 1 (white) are supported.")
    if color == 1 then
      love.graphics.clear(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b, 1)
      module._lastClearColor = COLOR_WHITE
    else
      love.graphics.clear(COLOR_BLACK.r, COLOR_BLACK.g, COLOR_BLACK.b, 1)
      module._lastClearColor = COLOR_BLACK
    end
  end
  module._updateContext()
end

-- "copy", "inverted", "XOR", "NXOR", "whiteTransparent", "blackTransparent", "fillWhite", or "fillBlack".
function module.setImageDrawMode(mode)
  module._drawMode = mode
  if mode == module.kDrawModeCopy or mode == "copy" then
    module._shader:send("mode", 0)
  elseif mode == module.kDrawModeFillWhite or mode == "fillWhite" then
    module._shader:send("mode", 1)
  elseif mode == module.kDrawModeFillBlack or mode == "fillBlack" then
    module._shader:send("mode", 2)
  else
    error("Draw mode '"..mode.."' not implemented.")
  end
end

function module.drawCircleAtPoint(x, y, radius)
  module._shader:send("mode", 8)

  love.graphics.circle("line", x, y, radius)
  module._updateContext()

  module.setImageDrawMode(module._drawMode)
end

function module.fillCircleAtPoint(x, y, radius)
  module._shader:send("mode", 8)

  love.graphics.circle("fill", x, y, radius)
  module._updateContext()

  module.setImageDrawMode(module._drawMode)
end

function module.setLineWidth(width)
  love.graphics.setLineWidth(width)
end

function module.drawRect(x, y, width, height)
  module._shader:send("mode", 8)

  love.graphics.rectangle("line", x, y, width, height)
  module._updateContext()

  module.setImageDrawMode(module._drawMode)
end

function module.fillRect(x, y, width, height)
  module._shader:send("mode", 8)

  love.graphics.rectangle("fill", x, y, width, height)
  module._updateContext()

  module.setImageDrawMode(module._drawMode)
end

function module.drawLine(x1, y1, x2, y2)
  module._shader:send("mode", 8)

  love.graphics.line(x1, y1, x2, y2)
  module._updateContext()

  module.setImageDrawMode(module._drawMode)
end

function module.drawArc(x, y, radius, startAngle, endAngle)
  module._shader:send("mode", 8)

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
  module._updateContext()

  module.setImageDrawMode(module._drawMode)
end

function module.drawPixel(x, y)
  module._shader:send("mode", 8)

  love.graphics.points(x, y)
  module._updateContext()

  module.setImageDrawMode(module._drawMode)
end

function module.setFont(font)
  module._activeFont = font
  love.graphics.setFont(font.data)
end

function module.getFont()
  return module._activeFont
end

function module.getTextSize(str)
  local font = module._activeFont
  return font:getWidth(str), font:getHeight()
end

-- playdate.graphics.drawTextInRect(str, x, y, width, height, [leadingAdjustment, [truncationString, [alignment, [font]]]]) 
function module.drawTextInRect(text, x, ...)
  local y, width, height, leadingAdjustment, truncationString, textAlignment, font
  if type(x) == "number" then
    y, width, height, leadingAdjustment, truncationString, textAlignment, font = select(1, ...)
  else
    -- rect
    error("Rect support not implemented!")
  end

  font = font or module._activeFont

  return font:_drawTextInRect(text, x, y, width, height, leadingAdjustment, truncationString, textAlignment)
end

function module.drawText(text, x, y, fontFamily, leadingAdjustment)
  @@ASSERT(text ~= nil, "Text is nil")
  local font = module._activeFont
  font:drawText(text, x, y, fontFamily, leadingAdjustment)
  module._updateContext()
end

function module:_updateContext()
  if #module._contextStack == 0 then
    return
  end

  local activeContext = module._contextStack[#module._contextStack]

  -- love2d doesn't allow calling newImageData() when canvas is active
  love.graphics.setCanvas()
  local imageData = activeContext._canvas:newImageData()
  love.graphics.setCanvas(activeContext._canvas)

  -- update image
  activeContext.data:replacePixels(imageData)
end

function module.pushContext(image)
  -- TODO: PD docs say image is optional, but not passing an image just results in drawing to last context?
  @@ASSERT(image, "Missing image parameter.")

  -- create canvas if it doesn't exist
  if not image._canvas then
    image._canvas = love.graphics.newCanvas(image:getSize())
  end
  
  -- push context
  table.insert(module._contextStack, image)

  -- update current render target
  love.graphics.setCanvas(image._canvas)
end

function module.popContext()
  @@ASSERT(#module._contextStack > 0, "No pushed context.")

  -- pop context
  table.remove(module._contextStack)
  -- update current render target
  if #module._contextStack == 0 then
    love.graphics.setCanvas(module._canvas)
  else
    local activeContext = module._contextStack[#module._contextStack]
    love.graphics.setCanvas(activeContext._canvas)
  end
end