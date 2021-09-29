-- caching this locally improves perf a bit
local lshift = bit32.lshift

local Bitfield = {}
setmetatable(Bitfield, {})
Bitfield.__index = Bitfield

--- creates a bitfield from an array of flags (valid values are 0-31).
function Bitfield.new(flags)
  local newBitfield = { 
    value = 0
  }
  setmetatable(newBitfield, Bitfield)

  if flags ~= nil then
    for i = 1, #flags, 1 do
      newBitfield:set(flags[i])
    end
  end
  
  return newBitfield
end

--- sets the specified flag (valid values are 0-31).
function Bitfield:set(flag)
  local bit = lshift(1, flag)
  self.value = self.value | bit
end

--- sets the specified bit.
function Bitfield:setBit(bit)
  self.value = self.value | bit
end

--- unsets the specified flag (valid values are 0-31).
function Bitfield:unset(flag)
  local bit = lshift(1, flag)
  self.value = self.value & ~bit
end

--- unsets the specified bit.
function Bitfield:unsetBit(bit)
  self.value = self.value & ~bit
end

--- returns true if the bitfield contains the specified flag (valid values are 0-31)
function Bitfield:has(flag)
  local bit = lshift(1, flag)
  return self.value & bit == bit
end

--- returns true if the bitfield contains the specified bit(s).
function Bitfield:hasBit(bit)
  return self.value & bit == bit
end

return Bitfield