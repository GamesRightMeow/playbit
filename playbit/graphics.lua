local module = {}

!if LOVE2D then
-- #b0aea7
local COLOR_WHITE = { r = 176 / 255, g = 174 / 255, b = 167 / 255 }
-- #312f28
local COLOR_BLACK = { r = 49 / 255, g = 47 / 255, b = 40 / 255 }

module.playbitShader = love.graphics.newShader[[
extern int mode;

const vec4 WHITE =        vec4(176.0f / 255.0f, 174.0f / 255.0f, 167.0f / 255.0f, 1);
const vec4 BLACK =        vec4( 49.0f / 255.0f,  47.0f / 255.0f,  40.0f / 255.0f, 1);
const vec4 TRANSPARENT =  vec4(        0,         0,         0, 0);

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 screen_coords )
{
  vec4 outputcolor = Texel(tex, texcoord) * color;
  if (mode == 0) // --------------- "copy"
  {
    if (outputcolor.a > 0)
    {
      // choose white or black based on saturation
      float saturation = rgb2hsv(vec3(outputcolor)).z;
      // ideally this value is 0.5f (halfway) not sure why this doesn't work?
      if (saturation >= 0.45f)
      {
        return WHITE;
      }
      else
      {
        return BLACK;
      }
    }
    else
    {
      // transparent pixel
      return TRANSPARENT;
    }
  }
  else if (mode == 1) // ---------- "fillWhite"
  {
    if (outputcolor.a > 0)
    {
      // replace with playdate white
      return WHITE;
    }
    else
    {
      // leave transparent pixel
      return TRANSPARENT;
    }
  }
  else if (mode == 2) // ---------- "fillBlack"
  {
    if (outputcolor.a > 0)
    {
      // replace with playdate black
      return BLACK;
    }
    else
    {
      // leave transparent pixel
      return TRANSPARENT;
    }
  }
}
]]

module.drawOffset = { x = 0, y = 0}
module.drawColor = COLOR_WHITE

-- don't want to deal with these, so just reason one
module.quad = love.graphics.newQuad(0, 0, 1, 1, 1, 1)

!elseif PLAYDATE then

!end

function module.setDrawOffset(x, y)
!if LOVE2D then
  module.drawOffset.x = x
  module.drawOffset.y = y
  love.graphics.pop()
  love.graphics.push()
  love.graphics.translate(x, y)
!elseif PLAYDATE then
  playdate.graphics.setDrawOffset(x, y)
!end
end

function module.getDrawOffset()
!if LOVE2D then
  return module.drawOffset.x, module.drawOffset.y
!elseif PLAYDATE then
  return playdate.graphics.getDrawOffset()
!end
end

--- Sets the background color.
function module.setBackgroundColor(color)
!if LOVE2D then
  if color == 1 then
    love.graphics.setBackgroundColor(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b)
  else
    love.graphics.setBackgroundColor(COLOR_BLACK.r, COLOR_BLACK.g, COLOR_BLACK.b)
  end
!elseif PLAYDATE then
  if color == 1 then
    playdate.graphics.setBackgroundColor(playdate.graphics.kColorWhite)
  else
    playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)
  end
!end
end

--- Sets the color used to draw.
function module.setColor(color)
!if LOVE2D then

!if ASSERT then
  assert(color == 1 or color == 0, "Only values of 0 (black) or 1 (white) are supported")
!end

  if color == 1 then
    module.drawColor = COLOR_WHITE
    love.graphics.setColor(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b, 1)
  else
    module.drawColor = COLOR_BLACK
    love.graphics.setColor(COLOR_BLACK.r, COLOR_BLACK.g, COLOR_BLACK.b, 1)
  end
!elseif PLAYDATE then
  if color == 1 then
    playdate.graphics.setColor(playdate.graphics.kColorWhite)
  else
    playdate.graphics.setColor(playdate.graphics.kColorBlack)
  end
!end
end

-- "copy", "inverted", "XOR", "NXOR", "whiteTransparent", "blackTransparent", "fillWhite", or "fillBlack".
function module.setImageDrawMode(mode)
!if LOVE2D then
  if mode == "copy" then
    module.playbitShader:send("mode", 0)
  elseif mode == "fillWhite" then
    module.playbitShader:send("mode", 1)
  elseif mode == "fillBlack" then
    module.playbitShader:send("mode", 2)
  end
!elseif PLAYDATE then
  playdate.graphics.setImageDrawMode(mode)
!end
end

--- Draws a outlined circle.
function module.circle(x, y, radius)
!if LOVE2D then
  love.graphics.circle("line", x, y, radius)
!elseif PLAYDATE then
  playdate.graphics.drawCircleAtPoint(x, y, radius)
!end
end

--- Draws a filled circle.
function module.fillCircle(x, y, radius)
!if LOVE2D then
  love.graphics.circle("fill", x, y, radius)
!elseif PLAYDATE then
  playdate.graphics.fillCircleAtPoint(x, y, radius)
!end
end

-- Set the width of drawn lines.
function module.setLineWidth(width)
!if LOVE2D then
  love.graphics.setLineWidth(width)
!elseif PLAYDATE then
  playdate.graphics.setLineWidth(width)
!end
end

--- Draws a outlined rectangle.
function module.rect(x, y, width, height)
!if LOVE2D then
  love.graphics.rectangle("line", x, y, width, height)
!elseif PLAYDATE then
  playdate.graphics.drawRect(x, y, width, height) 
!end
end

--- Draws a filled rectangle.
function module.fillRect(x, y, width, height)
!if LOVE2D then
  love.graphics.rectangle("fill", x, y, width, height)
!elseif PLAYDATE then
  playdate.graphics.fillRect(x, y, width, height) 
!end
end

-- Draws a line.
function module.line(x1, y1, x2, y2)
!if LOVE2D then
  love.graphics.line(x1, y1, x2, y2)
!elseif PLAYDATE then
  playdate.graphics.drawLine(x1, y1, x2, y2)
!end
end

function module.texture(image, x, y)
!if LOVE2D then
  -- always render pure white so its not tinted
  love.graphics.setColor(1, 1, 1, 1)

  love.graphics.draw(image.data, x, y)

  love.graphics.setColor(module.drawColor.r, module.drawColor.g, module.drawColor.b, 1)
!elseif PLAYDATE then
  image.data:draw(x, y)
!end
end

-- Renders a portion of an image
function module.textureQuad(image, x, y, qx, qy, qw, qh)
!if LOVE2D then
  -- always render pure white so texture is not tinted
  love.graphics.setColor(1, 1, 1, 1)

  module.quad:setViewport(qx, qy, qw, qh, image:getWidth(), image:getHeight())
  love.graphics.draw(image.data, module.quad, x, y)

  love.graphics.setColor(module.drawColor.r, module.drawColor.g, module.drawColor.b, 1)
!elseif PLAYDATE then
  -- TODO: bug in playdate SDK where draw offset affect source rect
  -- https://devforum.play.date/t/image-drawoffset-affects-sourcerect-instead-of-location/3778/6
  local ox, oy = playdate.graphics.getDrawOffset()
  playdate.graphics.setDrawOffset(0, 0)
  image.data:draw(ox + x, oy + y, playdate.graphics.kImageUnflipped, qx, qy, qw, qh )
  playdate.graphics.setDrawOffset(ox, oy)
!end
end

-- TODO: move other drawing functions over here from graphic-renderer.lua

local fonts = {}
local activeFontName = ""
function module.createFont(name, path)
!if LOVE2D then
  fonts[name] = love.graphics.newFont(path..".fnt")
!elseif PLAYDATE then
  fonts[name] = playdate.graphics.font.new(path)
!end
end

function module.setFont(name)
!if LOVE2D then
  love.graphics.setFont(fonts[name])
!elseif PLAYDATE then
  playdate.graphics.setFont(fonts[name])
!end
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

!if LOVE2D then
  love.graphics.print(str, x, y)
!elseif PLAYDATE then
  -- this uses font:drawText() instead of graphics.drawText() to bypass text emphasis
  -- so that * and _ are actually rendered
  local font = playdate.graphics.getFont()
  font:drawText(str, x, y)
!end
end

function module.getTextSize(str)
!if LOVE2D then
  local font = fonts[activeFontName]
  return font:getWidth(str), font:getHeight()
!elseif PLAYDATE then
  return playdate.graphics.getTextSize(str)
!end
end

return module