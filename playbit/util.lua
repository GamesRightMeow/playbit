local Util = {}

--- rounds a number to the specified number of decimal places
function Util.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

--- returns a shallow copy of the given table
function Util.shallowCopy(result, original)
  for k,v in pairs(original) do
    result[k] = v
  end
end

--- Returns a random value between 0.0 and 1.0.
function Util.random()
  --! if USE_LOVE then
  return love.math.random()
  --! else
  return 0
  --! end
end

--- Returns a random integer between min and max.
function Util.randomRangeInt(min, max)
  --! if USE_LOVE then
  -- love does not support floating point numbers
  return love.math.random(min, max)
  --! else
  return 0
  --! end
end

--- Returns a random float between min and max, using the specified precision (defaults to 3).
function Util.randomRangeFloat(min, max, precision)
  --! if USE_LOVE then
	local precision = precision or 3
	local num = Util.random()
	local range = math.abs(max - min)
	local offset = range * num
	local randomnum = min + offset
  ---@diagnostic disable-next-line: deprecated
	return math.floor(randomnum * math.pow(10, precision) + 0.5) / math.pow(10, precision)
  --! else
  return 0
  --! end
end

function Util.deltaTime()
  --! if USE_LOVE then
  return love.timer.getDelta()
  --! else
  return 0
  --! end
end

function Util.toDegree(rads)
  return rads * 180 / math.pi
end

function Util.toRads(degrees)
  while degrees > 360 do
    degrees = degrees - 360
  end
  return degrees * math.pi / 180;
end

return Util