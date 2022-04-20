local module = {}

-- Returns a random value from the list
function module.choose(list)
  local index = module.intRange(1, #list)
  return list[index]
end

--- Returns a random value between 0.0 and 1.0.
function module.value()
  return math.random()
end

--- Returns a random integer between min and max.
function module.intRange(min, max)
  return math.random(min, max)
end

--- Returns a random float between min and max, using the specified precision (defaults to 3).
function module.floatRange(min, max, precision)
  -- math.random does not support floating point numbers
	local precision = precision or 3
	local num = module.value()
	local range = math.abs(max - min)
	local offset = range * num
	local randomnum = min + offset
	return math.floor(randomnum * math.pow(10, precision) + 0.5) / math.pow(10, precision)
end

return module