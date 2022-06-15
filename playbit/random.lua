local module = {}
pb = pb or {}
pb.random = module

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

--- Returns a random float between min and max
function module.floatRange(min, max)
	return (math.random() * (max - min)) + min
end