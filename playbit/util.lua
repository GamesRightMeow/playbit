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
  --! if LOVE2D then
  return love.math.random()
  --! else
  return 0
  --! end
end

--- Returns a random integer between min and max.
function Util.randomRangeInt(min, max)
  --! if LOVE2D then
  -- love does not support floating point numbers
  return love.math.random(min, max)
  --! else
  return 0
  --! end
end

--- Returns a random float between min and max, using the specified precision (defaults to 3).
function Util.randomRangeFloat(min, max, precision)
  --! if LOVE2D then
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
  --! if LOVE2D then
  return love.timer.getDelta()
  --! else
  return 0
  --! end
end

--- Gets the difference of two angles, wrapped around to the range -180 to 180.
function Util.angleDiff(a, b)
  local diff = b - a

  while (diff > 180) do
    diff = diff - 360 
  end

  while (diff <= -180) do 
    diff = diff + 360 
  end

  return diff
end

return Util