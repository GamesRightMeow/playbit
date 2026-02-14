local module = {}
playbit = playbit or {}
playbit.util = module

--- rounds a number to the specified number of decimal places
function module.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

--- returns a shallow copy of the given table
function module.shallowCopy(result, original)
  for k,v in pairs(original) do
    result[k] = v
  end
end

function module.sign(a)
  if a > 0 then
    return 1
  elseif a < 0 then
    return -1
  else
    return 0
  end
end

function module.clamp01(x)
  if x <= 0 then
    return 0
  elseif x >= 1 then
    return 1
  else
    return x
  end
end

function module.clamp(x, min, max)
  if x <= min then
    return min
  elseif x >= max then
    return max
  else
    return x
  end
end