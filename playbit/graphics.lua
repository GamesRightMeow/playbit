local Graphics = {}

local colorWhite = { r = 215 / 255, g = 212 / 255, b = 204 / 255 }
local colorBlack = { r = 50 / 255, g = 47 / 255, b = 41 / 255 }

--- Sets the background color.
function Graphics.setBackgroundColor(color)
  --! if USE_LOVE then
  if color == 1 then
    love.graphics.setBackgroundColor(colorWhite.r, colorWhite.g, colorWhite.b);
  else
    love.graphics.setBackgroundColor(colorBlack.r, colorBlack.g, colorBlack.b);
  end
  --! end
end

--- Sets the color used to draw.
function Graphics.setColor(color)
  --! if USE_LOVE then
  if color == 1 then
    love.graphics.setColor(colorWhite.r, colorWhite.g, colorWhite.b);
  else
    love.graphics.setColor(colorBlack.r, colorBlack.g, colorBlack.b);
  end
  --! end
end

--- Draws a circle.
function Graphics.circle(x, y, radius, isFilled, angle)
  --! if USE_LOVE then
  local mode = "line"
  if isFilled then
    mode = "fill"
  end

  love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.rotate(angle)
  love.graphics.circle(mode, 0, 0, radius)
  love.graphics.pop()
  --! end
end

--- Draws a rectangle.
function Graphics.rectangle(x, y, width, height, isFilled, angle)
  --! if USE_LOVE then
  local mode = "line"
  if isFilled then
    mode = "fill"
  end
  love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.rotate(angle)
  love.graphics.rectangle(mode, 0, 0, width, height)
  love.graphics.pop()
  --! end
end

local fonts = {}
function Graphics.createFont(name, path)
  fonts[name] = love.graphics.newImageFont(path, " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`_*#=[]'{}", 1)
end

function Graphics.setFont(name)
  --! if USE_LOVE then
  love.graphics.setFont(fonts[name])
  --! end
end

--- Draws a string.
function Graphics.text(str, x, y, align)
  --! if USE_LOVE then
  love.graphics.printf(str, x, y, 400, align)
  --! end
end

return Graphics