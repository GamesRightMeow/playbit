local module = {}
playdate.geometry.vector2D = module

local meta = {}
meta.__index = meta

meta.__unm = function(v)
  return module.new(-v.dx, -v.dy)
end

meta.__add = function(v1, v2)
  return module.new(v1.dx + v2.dx, v1.dy + v2.dy)
end

meta.__sub = function(v1, v2)
  return module.new(v1.dx - v2.dx, v1.dy - v2.dy)
end

meta.__mul = function(v1, v2)
  if type(v2) == "table" and v2._type then
    if v2._type == "vector2D" then
      return v1.dx * v2.dx + v1.dy * v2.dy

    elseif v2._type == "affineTransform" then
      return module.new(v1.dx * v2.m11 + v1.dy * v2.m12, v1.dx * v2.m21 + v1.dy * v2.m22)

    end

  else
    local s = v2
    return module.new(v1.dx * s, v1.dy * s)

  end
end

meta.__div = function(v1, s)
    return module.new(v1.dx / s, v1.dy / s)
end

module.__index = meta

function module.new(dx, dy)
  local o = {}

  o._type = "vector2D"
  o.dx = dx
  o.dy = dy

  setmetatable(o, meta)
  return o
end

function module.newPolar(length, angle)
  local o = {}

  angle = angle * math.pi / 180

  o._type = "vector2D"
  o.dx =  length * math.sin(angle)
  o.dy = -length * math.cos(angle)

  setmetatable(o, meta)
  return o
end

function meta:copy()
  return module.new(self.dx, self.dy)
end

function meta:unpack()
  return self.dx, self.dy
end

function meta:addVector(v)
  self.dx = self.dx + v.dx
  self.dy = self.dy + v.dy
end

function meta:scale(s)
  self.dx = self.dx * s
  self.dy = self.dy * s
end

function meta:scaledBy(s)
  return module.new(self.dx * s, self.dy * s)
end

function meta:normalize()
  local len = self:magnitude()
  self.dx = self.dx / len
  self.dy = self.dy / len
end

function meta:normalized()
  local len = self:magnitude()
  return module.new(self.dx / len, self.dy / len)
end

function meta:dotProduct(v)
  return self.dx * v.dx + self.dy * v.dy
end

function meta:magnitude()
  local dx, dy = self.dx, self.dy
  return math.sqrt(dx * dx + dy * dy)
end

function meta:magnitudeSquared()
  local dx, dy = self.dx, self.dy
  return dx * dx + dy * dy
end

function meta:projectAlong(v)
  error("[ERR] playdate.geometry.vector2D:projectAlong() is not yet implemented.")
end

function meta:projectedAlong(v)
  error("[ERR] playdate.geometry.vector2D:projectedAlong() is not yet implemented.")
end

function meta:angleBetween(v)
  error("[ERR] playdate.geometry.vector2D:angleBetween() is not yet implemented.")
end

function meta:leftNormal()
  return module.new(self.dy, -self.dx)
end

function meta:rightNormal()
  return module.new(-self.dy, self.dx)
end
