local Graphics = {}

local colorWhite = { r = 215 / 255, g = 212 / 255, b = 204 / 255 }
local colorBlack = { r = 50 / 255, g = 47 / 255, b = 41 / 255 }

--- sets the background color
function Graphics.setBackgroundColor(color)
  --! if USE_LOVE then
  if color == 1 then
    love.graphics.setBackgroundColor(colorWhite.r, colorWhite.g, colorWhite.b);
  else
    love.graphics.setBackgroundColor(colorBlack.r, colorBlack.g, colorBlack.b);
  end
  --! end
end

function Graphics.setColor(color)
  --! if USE_LOVE then
  if color == 1 then
    love.graphics.setColor(colorWhite.r, colorWhite.g, colorWhite.b);
  else
    love.graphics.setColor(colorBlack.r, colorBlack.g, colorBlack.b);
  end
  --! end
end

--- draws a filled rectangle
function Graphics.rectangle(color, x, y, width, height)
  --! if USE_LOVE then
  Graphics.setColor(color)
  love.graphics.rectangle("fill", x, y, width, height)
  --! end
end

function Graphics.text(color, str, x, y, align)
  --! if USE_LOVE then
  Graphics.setColor(color)
  love.graphics.printf(str, x, y, 400, align)
  --! end
end

return Graphics