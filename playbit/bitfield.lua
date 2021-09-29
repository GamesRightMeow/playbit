-- caching this locally improves perf a bit
local lshift = bit.lshift
local bor = bit.bor
local band = bit.band
local bnot = bit.bnot

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
  self.value = bor(self.value, bit)
end

--- sets the specified bit.
function Bitfield:setBit(bit)
  self.value = bor(self.value, bit)
end

--- unsets the specified flag (valid values are 0-31).
function Bitfield:unset(flag)
  local bit = lshift(1, flag)
  self.value = band(self.value, bnot(bit))
end

--- unsets the specified bit.
function Bitfield:unsetBit(bit)
  self.value = band(self.value, bnot(bit))
end

--- returns true if the bitfield contains the specified flag (valid values are 0-31)
function Bitfield:has(flag)
  local bit = lshift(1, flag)
  return band(self.value, bit) == bit
end

--- returns true if the bitfield contains the specified bit(s).
function Bitfield:hasBit(bit)
  return band(self.value, bit) == bit
end

return Bitfield