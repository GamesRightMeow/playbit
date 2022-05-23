local module = {}
pb = pb or {}
pb.util = module

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