local Ease = {}

-- Adapted from https://github.com/kikito/tween.lua.
-- For all easing functions:
-- TODO: t and d are swapped :(
-- t = duration == running time. How much time has passed *right now*
-- b = begin == starting property value
-- c = change == ending - beginning
-- d = time == how much time has to pass for the tweening to complete

local pow, sin, cos, pi, sqrt, abs, asin = math.pow, math.sin, math.cos, math.pi, math.sqrt, math.abs, math.asin

-- linear
function Ease.linear(t, b, c, d)
  return c * t / d + b
end

-- quad
function Ease.inQuad(t, b, c, d)
  return c * pow(t / d, 2) + b
end

function Ease.outQuad(t, b, c, d)
  t = t / d
  return -c * t * (t - 2) + b
end

function Ease.inOutQuad(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * pow(t, 2) + b end
  return -c / 2 * ((t - 1) * (t - 3) - 1) + b
end

function Ease.outInQuad(t, b, c, d)
  if t < d / 2 then return Ease.outQuad(t * 2, b, c / 2, d) end
  return Ease.inQuad((t * 2) - d, b + c / 2, c / 2, d)
end

-- cubic
function Ease.inCubic (t, b, c, d)
  return c * pow(t / d, 3) + b
end

function Ease.outCubic(t, b, c, d)
  return c * (pow(t / d - 1, 3) + 1) + b
end

function Ease.inOutCubic(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * t * t * t + b end
  t = t - 2
  return c / 2 * (t * t * t + 2) + b
end

function Ease.outInCubic(t, b, c, d)
  if t < d / 2 then return Ease.outCubic(t * 2, b, c / 2, d) end
  return Ease.inCubic((t * 2) - d, b + c / 2, c / 2, d)
end

-- quart
function Ease.inQuart(t, b, c, d)
  return c * pow(t / d, 4) + b
end

function Ease.outQuart(t, b, c, d)
  return -c * (pow(t / d - 1, 4) - 1) + b
end

function Ease.inOutQuart(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * pow(t, 4) + b end
  return -c / 2 * (pow(t - 2, 4) - 2) + b
end

function Ease.outInQuart(t, b, c, d)
  if t < d / 2 then return Ease.outQuart(t * 2, b, c / 2, d) end
  return Ease.inQuart((t * 2) - d, b + c / 2, c / 2, d)
end

-- quint
function Ease.inQuint(t, b, c, d)
  return c * pow(t / d, 5) + b
end

function Ease.outQuint(t, b, c, d)
  return c * (pow(t / d - 1, 5) + 1) + b
end

function Ease.inOutQuint(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * pow(t, 5) + b end
  return c / 2 * (pow(t - 2, 5) + 2) + b
end

function Ease.outInQuint(t, b, c, d)
  if t < d / 2 then return Ease.outQuint(t * 2, b, c / 2, d) end
  return Ease.inQuint((t * 2) - d, b + c / 2, c / 2, d)
end

-- sine
function Ease.inSine(t, b, c, d)
  return -c * cos(t / d * (pi / 2)) + c + b
end

function Ease.outSine(t, b, c, d)
  return c * sin(t / d * (pi / 2)) + b
end

function Ease.inOutSine(t, b, c, d)
  return -c / 2 * (cos(pi * t / d) - 1) + b
end

function Ease.outInSine(t, b, c, d)
  if t < d / 2 then return Ease.outSine(t * 2, b, c / 2, d) end
  return Ease.inSine((t * 2) -d, b + c / 2, c / 2, d)
end

-- expo
function Ease.inExpo(t, b, c, d)
  if t == 0 then return b end
  return c * pow(2, 10 * (t / d - 1)) + b - c * 0.001
end

function Ease.outExpo(t, b, c, d)
  if t == d then return b + c end
  return c * 1.001 * (-pow(2, -10 * t / d) + 1) + b
end

function Ease.inOutExpo(t, b, c, d)
  if t == 0 then return b end
  if t == d then return b + c end
  t = t / d * 2
  if t < 1 then return c / 2 * pow(2, 10 * (t - 1)) + b - c * 0.0005 end
  return c / 2 * 1.0005 * (-pow(2, -10 * (t - 1)) + 2) + b
end

function Ease.outInExpo(t, b, c, d)
  if t < d / 2 then return Ease.outExpo(t * 2, b, c / 2, d) end
  return Ease.inExpo((t * 2) - d, b + c / 2, c / 2, d)
end

-- circ
function Ease.inCirc(t, b, c, d) 
  return(-c * (sqrt(1 - pow(t / d, 2)) - 1) + b) 
end

function Ease.outCirc(t, b, c, d) 
  return(c * sqrt(1 - pow(t / d - 1, 2)) + b)
end

function Ease.inOutCirc(t, b, c, d)
  t = t / d * 2
  if t < 1 then return -c / 2 * (sqrt(1 - t * t) - 1) + b end
  t = t - 2
  return c / 2 * (sqrt(1 - t * t) + 1) + b
end

function Ease.outInCirc(t, b, c, d)
  if t < d / 2 then return Ease.outCirc(t * 2, b, c / 2, d) end
  return Ease.inCirc((t * 2) - d, b + c / 2, c / 2, d)
end

-- elastic
local function calculatePAS(p,a,c,d)
  p, a = p or d * 0.3, a or 0
  if a < abs(c) then return p, c, p / 4 end -- p, a, s
  return p, a, p / (2 * pi) * asin(c/a) -- p,a,s
end

function Ease.inElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d
  if t == 1  then return b + c end
  p,a,s = calculatePAS(p,a,c,d)
  t = t - 1
  return -(a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end

function Ease.outElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d
  if t == 1 then return b + c end
  p,a,s = calculatePAS(p,a,c,d)
  return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end

function Ease.inOutElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d * 2
  if t == 2 then return b + c end
  p,a,s = calculatePAS(p,a,c,d)
  t = t - 1
  if t < 0 then return -0.5 * (a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b end
  return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p ) * 0.5 + c + b
end

function Ease.outInElastic(t, b, c, d, a, p)
  if t < d / 2 then return Ease.outElastic(t * 2, b, c / 2, d, a, p) end
  return Ease.inElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
end

-- back
function Ease.inBack(t, b, c, d, s)
  s = s or 1.70158
  t = t / d
  return c * t * t * ((s + 1) * t - s) + b
end

function Ease.outBack(t, b, c, d, s)
  s = s or 1.70158
  t = t / d - 1
  return c * (t * t * ((s + 1) * t + s) + 1) + b
end

function Ease.inOutBack(t, b, c, d, s)
  s = (s or 1.70158) * 1.525
  t = t / d * 2
  if t < 1 then return c / 2 * (t * t * ((s + 1) * t - s)) + b end
  t = t - 2
  return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
end

function Ease.outInBack(t, b, c, d, s)
  if t < d / 2 then return Ease.outBack(t * 2, b, c / 2, d, s) end
  return Ease.inBack((t * 2) - d, b + c / 2, c / 2, d, s)
end

-- bounce
function Ease.outBounce(t, b, c, d)
  t = t / d
  if t < 1 / 2.75 then return c * (7.5625 * t * t) + b end
  if t < 2 / 2.75 then
    t = t - (1.5 / 2.75)
    return c * (7.5625 * t * t + 0.75) + b
  elseif t < 2.5 / 2.75 then
    t = t - (2.25 / 2.75)
    return c * (7.5625 * t * t + 0.9375) + b
  end
  t = t - (2.625 / 2.75)
  return c * (7.5625 * t * t + 0.984375) + b
end

function Ease.inBounce(t, b, c, d)
  return c - Ease.outBounce(d - t, 0, c, d) + b
end

function Ease.inOutBounce(t, b, c, d)
  if t < d / 2 then return Ease.inBounce(t * 2, 0, c, d) * 0.5 + b end
  return Ease.outBounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
end

function Ease.outInBounce(t, b, c, d)
  if t < d / 2 then return Ease.outBounce(t * 2, b, c / 2, d) end
  return Ease.inBounce((t * 2) - d, b + c / 2, c / 2, d)
end

return Ease