local module = {}
playdate.graphics = module

-- #b0aea7
local COLOR_WHITE = { r = 176 / 255, g = 174 / 255, b = 167 / 255 }
-- #312f28
local COLOR_BLACK = { r = 49 / 255, g = 47 / 255, b = 40 / 255 }

module.shader = love.graphics.newShader[[
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
module.backgroundColor = COLOR_BLACK
module.activeFont = {}
module.drawMode = "copy"

function module.setDrawOffset(x, y)
  module.drawOffset.x = x
  module.drawOffset.y = y
  love.graphics.pop()
  love.graphics.push()
  love.graphics.translate(x, y)
end

function module.getDrawOffset()
  return module.drawOffset.x, module.drawOffset.y
end

function module.setBackgroundColor(color)
  @@ASSERT(color == 1 or color == 0, "Only values of 0 (black) or 1 (white) are supported")
  if color == 1 then
    module.backgroundColor = COLOR_WHITE
    love.graphics.setBackgroundColor(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b)
  else
    module.backgroundColor = COLOR_BLACK
    love.graphics.setBackgroundColor(COLOR_BLACK.r, COLOR_BLACK.g, COLOR_BLACK.b)
  end
end

function module.setColor(color)
  @@ASSERT(color == 1 or color == 0, "Only values of 0 (black) or 1 (white) are supported")
  if color == 1 then
    module.drawColor = COLOR_WHITE
    love.graphics.setColor(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b, 1)
  else
    module.drawColor = COLOR_BLACK
    love.graphics.setColor(COLOR_BLACK.r, COLOR_BLACK.g, COLOR_BLACK.b, 1)
  end
end

function module.clear(color)
  if not color then
    local c = module.backgroundColor
    love.graphics.clear(c.r, c.g, c.b, 1)
  else
    @@ASSERT(color == 1 or color == 0, "Only values of 0 (black) or 1 (white) are supported")
    if color == 1 then
      module.drawColor = COLOR_WHITE
      love.graphics.clear(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b, 1)
    else
      module.drawColor = COLOR_BLACK
      love.graphics.clear(COLOR_BLACK.r, COLOR_BLACK.g, COLOR_BLACK.b, 1)
    end
  end
end

-- "copy", "inverted", "XOR", "NXOR", "whiteTransparent", "blackTransparent", "fillWhite", or "fillBlack".
function module.setImageDrawMode(mode)
  module.drawMode = mode
  if mode == "copy" then
    module.shader:send("mode", 0)
  elseif mode == "fillWhite" then
    module.shader:send("mode", 1)
  elseif mode == "fillBlack" then
    module.shader:send("mode", 2)
  else
    error("draw mode not implemented!")
  end
end

function module.drawCircleAtPoint(x, y, radius)
  love.graphics.circle("line", x, y, radius)
end

function module.fillCircleAtPoint(x, y, radius)
  love.graphics.circle("fill", x, y, radius)
end

function module.setLineWidth(width)
  love.graphics.setLineWidth(width)
end

function module.drawRect(x, y, width, height)
  love.graphics.rectangle("line", x, y, width, height)
end

function module.fillRect(x, y, width, height)
  love.graphics.rectangle("fill", x, y, width, height)
end

function module.drawLine(x1, y1, x2, y2)
  love.graphics.line(x1, y1, x2, y2)
end

function module.setFont(font)
  module.activeFont = font
  love.graphics.setFont(font.data)
end

function module.getFont()
  return module.activeFont
end

function module.getTextSize(str)
  local font = module.activeFont
  return font:getWidth(str), font:getHeight()
end