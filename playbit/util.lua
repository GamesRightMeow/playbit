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

-- Decode chars from a string buffer at given pos
function module.readChars(data, dataSize, pos, size)
  @@ASSERT(pos + size <= dataSize, "Failed to load data, chars out of range at pos: " .. pos)
  return string.sub(data, pos + 1, pos + size)
end

-- Decode 8-bit unsigned int from a string buffer at given pos
function module.readUInt8(data, dataSize, pos)
  @@ASSERT(pos + 1 <= dataSize, "Failed to load data, uint8 out of range at pos: " .. pos)
  local b1 = string.byte(data, pos + 1)
  return b1
end

-- Decode 16-bit signed int from a string buffer at given pos
function module.readInt16(data, dataSize, pos)
  @@ASSERT(pos + 2 <= dataSize, "Failed to load data, int16 out of range at pos: " .. pos)
  local b1, b2 = string.byte(data, pos + 1, pos + 2)
  return b2 * 256 + b1
end

-- Decode 32-bit unsigned int from a string buffer at given pos
function module.readUInt32(data, dataSize, pos)
  @@ASSERT(pos + 4 <= dataSize, "Failed to load data, uint32 out of range at pos: " .. pos)
  local b1, b2, b3, b4 = string.byte(data, pos + 1, pos + 4)
  return b1 + b2 * 0x100 + b3 * 0x10000 + b4 * 0x1000000
end

-- Decode 32-bit float from a string buffer at given pos
function module.readFloat32(data, dataSize, pos)
  @@ASSERT(pos + 4 <= dataSize, "Failed to load data, float32 out of range at pos: " .. pos)
  local b1, b2, b3, b4 = string.byte(data, pos + 1, pos + 4)

  local exponent = (b4 % 128) * 2 + math.floor(b3 / 128)
  if exponent == 0 then return 0 end
  
  local sign = 1
  if b4 > 127 then sign = -1 end
  
  local mantissa = (b3 % 128)
  mantissa = mantissa * 256 + b2
  mantissa = mantissa * 256 + b1
  mantissa = (math.ldexp(mantissa, -23) + 1) * sign
  return math.ldexp(mantissa, exponent - 127)
end
