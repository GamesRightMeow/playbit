local module = {}

-- Returns a random value from the list
function module.choose(list)
  local index = module.intRange(1, #list)
  return list[index]
end

--- Returns a random value between 0.0 and 1.0.
function module.value()
  --! if LOVE2D then
  return love.math.random()
  --! else
  return 0
  --! end
end

--- Returns a random integer between min and max.
function module.intRange(min, max)
  --! if LOVE2D then
  -- love does not support floating point numbers
  return love.math.random(min, max)
  --! else
  return 0
  --! end
end

--- Returns a random float between min and max, using the specified precision (defaults to 3).
function module.floatRange(min, max, precision)
  --! if LOVE2D then
	local precision = precision or 3
	local num = module.value()
	local range = math.abs(max - min)
	local offset = range * num
	local randomnum = min + offset
	return math.floor(randomnum * math.pow(10, precision) + 0.5) / math.pow(10, precision)
  --! else
  return 0
  --! end
end

return module