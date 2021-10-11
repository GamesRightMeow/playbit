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

function Util.random()
  --! if USE_LOVE then
  return love.math.random()
  --! else
  return 0
  --! end
end

function Util.randomRange(min, max)
  --! if USE_LOVE then
  return min + (love.math.random() * (max - min))
  --! else
  return 0
  --! end
end

return Util