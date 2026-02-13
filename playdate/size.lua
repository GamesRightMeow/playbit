local module = {}
playdate.geometry.size = module

local meta = {}
meta.__index = meta
module.__index = meta

function module.new(width, height)
  local o = {}

  o.width = width
  o.height = height

  setmetatable(o, meta)
  return o
end

function meta:copy()
  return module.new(self.width, self.height)
end

function meta:unpack()
  return self.width, self.height
end
