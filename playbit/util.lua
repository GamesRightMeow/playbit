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

function Util.sign(a)
  if a > 0 then
    return 1
  elseif a < 0 then
    return -1
  else
    return 0
  end
end

function Util.lineLineIntersection(x1, y1, x2, y2, x3, y3, x4, y4)
  -- line intercept math by Paul Bourke http://paulbourke.net/geometry/pointlineplane/

  -- Check if none of the lines are of length 0
  if ((x1 == x2 and y1 == y2) or (x3 == x4 and y3 == y4)) then
    return false, 0, 0
  end

  local denominator = ((y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1))

  -- Lines are parallel
  if (denominator == 0) then
    return false, 0, 0
  end

  local ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denominator
  local ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / denominator

  -- is the intersection along the segments
  if (ua < 0 or ua > 1 or ub < 0 or ub > 1) then
    return false, 0, 0
  end

  -- Return a object with the x and y coordinates of the intersection
  local x = x1 + ua * (x2 - x1)
  local y = y1 + ua * (y2 - y1)

  return true, x, y
end

return Util