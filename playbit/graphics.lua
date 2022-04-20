local module = {}

--! if LOVE2D then
-- #b0aea7
local COLOR_WHITE = { r = 176 / 255, g = 174 / 255, b = 167 / 255 }
-- #312f28
local COLOR_BLACK = { r = 49 / 255, g = 47 / 255, b = 40 / 255 }

module.playbitShader = love.graphics.newShader[[
extern int mode;
extern vec3 targetColor;

vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 screen_coords )
{
  vec4 outputcolor = Texel(tex, texcoord) * color;
  if (mode == 0)
  {
    return outputcolor;
  }
  else if (mode == 1)
  {
    if (outputcolor.a > 0)
    {
      // playdate white
      return vec4(targetColor.r, targetColor.g, targetColor.b, 1);
    }
    else
    {
      // transparent
      return vec4(0, 0, 0, 0);
    }
  }
}
]]

module.drawOffset = { x = 0, y = 0}

--! elseif PLAYDATE then
import("CoreLibs/graphics")
--! end

module.drawMode = "fillBlack"

-- Returns a new quad
-- Love2D requires quads to draw parts of textures, but Playdate does not
function module.newQuad(x, y, width, height, textureWidth, textureHeight)
  --! if LOVE2D then
  return love.graphics.newQuad(x, y, width, height, textureWidth, textureHeight)
  --! elseif PLAYDATE then
  return playdate.geometry.rect.new(x, y, width, height)
  --! end
end

-- Returns a new quad for a sprite in a spritesheet
function module.newSpritesheetQuad(index, image, cellWidth, cellHeight)
  -- TODO: support non-square cells
  local totalRows = (image:getWidth() / cellWidth)
  local row = math.floor(index / totalRows)
  local column = index % totalRows
  return module.newQuad(
    column * cellWidth, row * cellHeight, 
    cellWidth, cellHeight, 
    image:getWidth(), image:getHeight()
  )
end

function module.setDrawOffset(x, y)
  --! if LOVE2D then
  module.drawOffset.x = x
  module.drawOffset.y = y
  love.graphics.pop()
  love.graphics.push()
  love.graphics.translate(x, y)
  --! elseif PLAYDATE then
  playdate.graphics.setDrawOffset(x, y)
  --! end
end

function module.getDrawOffset()
  --! if LOVE2D then
  return module.drawOffset.x, module.drawOffset.y
  --! elseif PLAYDATE then
  return playdate.graphics.getDrawOffset()
  --! end
end

--- Sets the background color.
function module.setBackgroundColor(color)
  --! if LOVE2D then
  if color == 1 then
    love.graphics.setBackgroundColor(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b)
  else
    love.graphics.setBackgroundColor(COLOR_BLACK.r, COLOR_BLACK.g, COLOR_BLACK.b)
  end
  --! elseif PLAYDATE then
  if color == 1 then
    playdate.graphics.setBackgroundColor(playdate.graphics.kColorWhite)
  else
    playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)
  end
  --! end
end

--- Sets the color used to draw.
function module.setColor(color)
  --! if LOVE2D then
  if color == 1 then
    love.graphics.setColor(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b, 1)
  else
    love.graphics.setColor(COLOR_BLACK.r, COLOR_BLACK.g, COLOR_BLACK.b, 1)
  end
  --! elseif PLAYDATE then
  if color == 1 then
    playdate.graphics.setColor(playdate.graphics.kColorWhite)
  else
    playdate.graphics.setColor(playdate.graphics.kColorBlack)
  end
  --! end
end

-- "copy", "inverted", "XOR", "NXOR", "whiteTransparent", "blackTransparent", "fillWhite", or "fillBlack".
function module.setImageDrawMode(mode)
  --! if LOVE2D then
  -- TODO: set shader for images?
  -- TODO: handle other states?
  module.drawMode = mode
  --! elseif PLAYDATE then
  playdate.graphics.setImageDrawMode(mode)
  --! end
end

--- Draws a outlined circle.
function module.circle(x, y, radius)
  --! if LOVE2D then
  love.graphics.circle("line", x, y, radius)
  --! elseif PLAYDATE then
  playdate.graphics.drawCircleAtPoint(x, y, radius)
  --! end
end

--- Draws a filled circle.
function module.fillCircle(x, y, radius)
  --! if LOVE2D then
  love.graphics.circle("fill", x, y, radius)
  --! elseif PLAYDATE then
  playdate.graphics.fillCircleAtPoint(x, y, radius)
  --! end
end

-- Set the width of drawn lines.
function module.setLineWidth(width)
  --! if LOVE2D then
  love.graphics.setLineWidth(width)
  --! elseif PLAYDATE then
  playdate.graphics.setLineWidth(width)
  --! end
end

--- Draws a outlined rectangle.
function module.rect(x, y, width, height)
  --! if LOVE2D then
  love.graphics.rectangle("line", x, y, width, height)
  --! elseif PLAYDATE then
  playdate.graphics.drawRect(x, y, width, height) 
  --! end
end

--- Draws a filled rectangle.
function module.fillRect(x, y, width, height)
  --! if LOVE2D then
  love.graphics.rectangle("fill", x, y, width, height)
  --! elseif PLAYDATE then
  playdate.graphics.fillRect(x, y, width, height) 
  --! end
end

-- Draws a line.
function module.line(x1, y1, x2, y2)
  --! if LOVE2D then
  love.graphics.line(x1, y1, x2, y2)
  --! elseif PLAYDATE then
  playdate.graphics.drawLine(x1, y1, x2, y2)
  --! end
end

function module.texture(image, x, y)
  --! if LOVE2D then
  -- always render pure white so its not tinted
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(image.data, x, y)
  --! elseif PLAYDATE then
  image.data:draw(x, y)
  --! end
end

-- Renders a portion of an image as defined by a quad
function module.sprite(image, quad, x, y)
  --! if LOVE2D then
  -- always render pure white so texture is not tinted
  love.graphics.setColor(1, 1, 1, 1)

  love.graphics.draw(image.data, quad, x, y)
  --! elseif PLAYDATE then
  image.data:draw(x, y, playdate.graphics.kImageUnflipped, quad)
  --! end
end

-- TODO: move other drawing functions over here from graphic-renderer.lua

local fonts = {}
local activeFontName = ""
function module.createFont(name, path)
  --! if LOVE2D then
  fonts[name] = love.graphics.newFont(path..".fnt")
  --! elseif PLAYDATE then
  fonts[name] = playdate.graphics.font.new(path)
  --! end
end

function module.setFont(name)
  --! if LOVE2D then
  love.graphics.setFont(fonts[name])
  --! elseif PLAYDATE then
  playdate.graphics.setFont(fonts[name])
  --! end
  activeFontName = name
end

function module.getActiveFont()
  return fonts[activeFontName]
end

--- Draws a string.
function module.text(str, x, y, align)
  local width = module.getTextSize(str)
  if align == "center" then
    x = x - width * 0.5  
  elseif align == "right" then
    x = x - width
  end

  --! if LOVE2D then
  if module.drawMode == "fillWhite" then
    module.playbitShader:send("mode", 1)
    module.playbitShader:sendColor("targetColor", { COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b })
  elseif module.drawMode == "fillBlack" then
    module.playbitShader:send("mode", 1)
    module.playbitShader:sendColor("targetColor", { COLOR_BLACK.r, COLOR_BLACK.g, COLOR_BLACK.b })
  end
  -- TODO: other fill modes

  love.graphics.print(str, x, y)

  module.playbitShader:send("mode", 0)
  --! elseif PLAYDATE then
  -- this uses font:drawText() instead of graphics.drawText() to bypass text emphasis
  -- so that * and _ are actually rendered
  local font = playdate.graphics.getFont()
  font:drawText(str, x, y)
  --! end
end

function module.getTextSize(str)
  --! if LOVE2D then
  local font = fonts[activeFontName]
  return font:getWidth(str), font:getHeight()
  --! elseif PLAYDATE then
  return playdate.graphics.getTextSize(str)
  --! end
end

return module