local Graphics = {}

Graphics.COLOR_WHITE = { r = 215 / 255, g = 212 / 255, b = 204 / 255 }
Graphics.COLOR_BLACK = { r = 50 / 255, g = 47 / 255, b = 41 / 255 }

--- Sets the background color.
function Graphics.setBackgroundColor(color)
  --! if LOVE2D then
  if color == 1 then
    love.graphics.setBackgroundColor(Graphics.COLOR_WHITE.r, Graphics.COLOR_WHITE.g, Graphics.COLOR_WHITE.b)
  else
    love.graphics.setBackgroundColor(Graphics.COLOR_BLACK.r, Graphics.COLOR_BLACK.g, Graphics.COLOR_BLACK.b)
  end
  --! end
end

--- Sets the color used to draw.
function Graphics.setColor(color)
  --! if LOVE2D then
  if color == 1 then
    love.graphics.setColor(Graphics.COLOR_WHITE.r, Graphics.COLOR_WHITE.g, Graphics.COLOR_WHITE.b, 1)
  else
    love.graphics.setColor(Graphics.COLOR_BLACK.r, Graphics.COLOR_BLACK.g, Graphics.COLOR_BLACK.b, 1)
  end
  --! end
end

--- Draws a circle.
function Graphics.circle(x, y, radius, isFilled, lineWidth)
  --! if LOVE2D then
  local mode = "line"
  if isFilled then
    mode = "fill"
  end

  if lineWidth == nil then
    lineWidth = 0.5
  end

  love.graphics.push()
	love.graphics.translate(x, y)
  love.graphics.setLineWidth(lineWidth)
  love.graphics.setLineStyle("rough")
  love.graphics.circle(mode, 0, 0, radius)
  love.graphics.pop()
  --! end
end

--- Draws a rectangle.
function Graphics.rectangle(x, y, width, height, isFilled, angle, lineWidth)
  --! if LOVE2D then
  local mode = "line"
  if isFilled then
    mode = "fill"
  end

  if lineWidth == nil then
    lineWidth = 0.5
  end

  love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.rotate(angle)
  love.graphics.setLineWidth(lineWidth)
  love.graphics.setLineStyle("rough")
  love.graphics.rectangle(mode, 0, 0, width, height)
  love.graphics.pop()
  --! end
end

function Graphics.line(x1, y1, x2, y2, lineWidth)
  --! if LOVE2D then
  if lineWidth == nil then
    lineWidth = 0.5
  end

  love.graphics.push()
  love.graphics.setLineWidth(lineWidth)
  love.graphics.setLineStyle("rough")
  love.graphics.line(x1, y1, x2, y2)
  love.graphics.pop()
  --! end
end

local fonts = {}
local activeFontName = ""
function Graphics.createFont(name, path, glyphs, spacing)
  fonts[name] = love.graphics.newImageFont(path, glyphs, spacing)
end

function Graphics.setFont(name)
  --! if LOVE2D then
  love.graphics.setFont(fonts[name])
  activeFontName = name
  --! end
end

--- Draws a string.
function Graphics.text(str, x, y, align)
  --! if LOVE2D then
  local font = fonts[activeFontName]

  -- TODO: creating a new text object every frame isn't very efficent
  -- (but this is more convenient)
  local text = love.graphics.newText(font, str)
  
  -- printf() supports alignment, but it requires setting the max width which isn't always ideal
  if align == "center" then
    x = x - text:getWidth() * 0.5  
  elseif align == "right" then
    x = x - text:getWidth()
  end

  love.graphics.draw(text, x, y)
  --! end
end

return Graphics