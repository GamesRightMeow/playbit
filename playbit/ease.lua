local module = {}
pb = pb or {}
pb.ease = module

-- Adapted from https://github.com/kikito/tween.lua.
-- For all easing functions:
-- TODO: t and d are swapped :(
-- t = duration == running time. How much time has passed *right now*
-- b = begin == starting property value
-- c = change == ending - beginning
-- d = time == how much time has to pass for the tweening to complete

local pow, sin, cos, pi, sqrt, abs, asin = math.pow, math.sin, math.cos, math.pi, math.sqrt, math.abs, math.asin

-- linear
function module.linear(t, b, c, d)
  return c * t / d + b
end

-- quad
function module.inQuad(t, b, c, d)
  return c * pow(t / d, 2) + b
end

function module.outQuad(t, b, c, d)
  t = t / d
  return -c * t * (t - 2) + b
end

function module.inOutQuad(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * pow(t, 2) + b end
  return -c / 2 * ((t - 1) * (t - 3) - 1) + b
end

function module.outInQuad(t, b, c, d)
  if t < d / 2 then return module.outQuad(t * 2, b, c / 2, d) end
  return module.inQuad((t * 2) - d, b + c / 2, c / 2, d)
end

-- cubic
function module.inCubic (t, b, c, d)
  return c * pow(t / d, 3) + b
end

function module.outCubic(t, b, c, d)
  return c * (pow(t / d - 1, 3) + 1) + b
end

function module.inOutCubic(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * t * t * t + b end
  t = t - 2
  return c / 2 * (t * t * t + 2) + b
end

function module.outInCubic(t, b, c, d)
  if t < d / 2 then return module.outCubic(t * 2, b, c / 2, d) end
  return module.inCubic((t * 2) - d, b + c / 2, c / 2, d)
end

-- quart
function module.inQuart(t, b, c, d)
  return c * pow(t / d, 4) + b
end

function module.outQuart(t, b, c, d)
  return -c * (pow(t / d - 1, 4) - 1) + b
end

function module.inOutQuart(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * pow(t, 4) + b end
  return -c / 2 * (pow(t - 2, 4) - 2) + b
end

function module.outInQuart(t, b, c, d)
  if t < d / 2 then return module.outQuart(t * 2, b, c / 2, d) end
  return module.inQuart((t * 2) - d, b + c / 2, c / 2, d)
end

-- quint
function module.inQuint(t, b, c, d)
  return c * pow(t / d, 5) + b
end

function module.outQuint(t, b, c, d)
  return c * (pow(t / d - 1, 5) + 1) + b
end

function module.inOutQuint(t, b, c, d)
  t = t / d * 2
  if t < 1 then return c / 2 * pow(t, 5) + b end
  return c / 2 * (pow(t - 2, 5) + 2) + b
end

function module.outInQuint(t, b, c, d)
  if t < d / 2 then return module.outQuint(t * 2, b, c / 2, d) end
  return module.inQuint((t * 2) - d, b + c / 2, c / 2, d)
end

-- sine
function module.inSine(t, b, c, d)
  return -c * cos(t / d * (pi / 2)) + c + b
end

function module.outSine(t, b, c, d)
  return c * sin(t / d * (pi / 2)) + b
end

function module.inOutSine(t, b, c, d)
  return -c / 2 * (cos(pi * t / d) - 1) + b
end

function module.outInSine(t, b, c, d)
  if t < d / 2 then return module.outSine(t * 2, b, c / 2, d) end
  return module.inSine((t * 2) -d, b + c / 2, c / 2, d)
end

-- expo
function module.inExpo(t, b, c, d)
  if t == 0 then return b end
  return c * pow(2, 10 * (t / d - 1)) + b - c * 0.001
end

function module.outExpo(t, b, c, d)
  if t == d then return b + c end
  return c * 1.001 * (-pow(2, -10 * t / d) + 1) + b
end

function module.inOutExpo(t, b, c, d)
  if t == 0 then return b end
  if t == d then return b + c end
  t = t / d * 2
  if t < 1 then return c / 2 * pow(2, 10 * (t - 1)) + b - c * 0.0005 end
  return c / 2 * 1.0005 * (-pow(2, -10 * (t - 1)) + 2) + b
end

function module.outInExpo(t, b, c, d)
  if t < d / 2 then return module.outExpo(t * 2, b, c / 2, d) end
  return module.inExpo((t * 2) - d, b + c / 2, c / 2, d)
end

-- circ
function module.inCirc(t, b, c, d) 
  return(-c * (sqrt(1 - pow(t / d, 2)) - 1) + b) 
end

function module.outCirc(t, b, c, d) 
  return(c * sqrt(1 - pow(t / d - 1, 2)) + b)
end

function module.inOutCirc(t, b, c, d)
  t = t / d * 2
  if t < 1 then return -c / 2 * (sqrt(1 - t * t) - 1) + b end
  t = t - 2
  return c / 2 * (sqrt(1 - t * t) + 1) + b
end

function module.outInCirc(t, b, c, d)
  if t < d / 2 then return module.outCirc(t * 2, b, c / 2, d) end
  return module.inCirc((t * 2) - d, b + c / 2, c / 2, d)
end

-- elastic
local function calculatePAS(p,a,c,d)
  p, a = p or d * 0.3, a or 0
  if a < abs(c) then return p, c, p / 4 end -- p, a, s
  return p, a, p / (2 * pi) * asin(c/a) -- p,a,s
end

function module.inElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d
  if t == 1  then return b + c end
  p,a,s = calculatePAS(p,a,c,d)
  t = t - 1
  return -(a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end

function module.outElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d
  if t == 1 then return b + c end
  p,a,s = calculatePAS(p,a,c,d)
  return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end

function module.inOutElastic(t, b, c, d, a, p)
  local s
  if t == 0 then return b end
  t = t / d * 2
  if t == 2 then return b + c end
  p,a,s = calculatePAS(p,a,c,d)
  t = t - 1
  if t < 0 then return -0.5 * (a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b end
  return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p ) * 0.5 + c + b
end

function module.outInElastic(t, b, c, d, a, p)
  if t < d / 2 then return module.outElastic(t * 2, b, c / 2, d, a, p) end
  return module.inElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
end

-- back
function module.inBack(t, b, c, d, s)
  s = s or 1.70158
  t = t / d
  return c * t * t * ((s + 1) * t - s) + b
end

function module.outBack(t, b, c, d, s)
  s = s or 1.70158
  t = t / d - 1
  return c * (t * t * ((s + 1) * t + s) + 1) + b
end

function module.inOutBack(t, b, c, d, s)
  s = (s or 1.70158) * 1.525
  t = t / d * 2
  if t < 1 then return c / 2 * (t * t * ((s + 1) * t - s)) + b end
  t = t - 2
  return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
end

function module.outInBack(t, b, c, d, s)
  if t < d / 2 then return module.outBack(t * 2, b, c / 2, d, s) end
  return module.inBack((t * 2) - d, b + c / 2, c / 2, d, s)
end

-- bounce
function module.outBounce(t, b, c, d)
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

function module.inBounce(t, b, c, d)
  return c - module.outBounce(d - t, 0, c, d) + b
end

function module.inOutBounce(t, b, c, d)
  if t < d / 2 then return module.inBounce(t * 2, 0, c, d) * 0.5 + b end
  return module.outBounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
end

function module.outInBounce(t, b, c, d)
  if t < d / 2 then return module.outBounce(t * 2, b, c / 2, d) end
  return module.inBounce((t * 2) - d, b + c / 2, c / 2, d)
end

return module