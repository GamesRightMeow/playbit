local Vector = {}

local meta = {}
meta.__index = meta
Vector.__index = meta

function meta.__add(a, b)
  if type(a) == "number" then
    return Vector.new(b.x + a, b.y + a)
  elseif type(b) == "number" then
    return Vector.new(a.x + b, a.y + b)
  else
    return Vector.new(a.x + b.x, a.y + b.y)
  end
end

function meta.__sub(a, b)
  if type(a) == "number" then
    return Vector.new(a - b.x, a - b.y)
  elseif type(b) == "number" then
    return Vector.new(a.x - b, a.y - b)
  else
    return Vector.new(a.x - b.x, a.y - b.y)
  end
end

function meta.__mul(a, b)
  if type(a) == "number" then
    return Vector.new(b.x * a, b.y * a)
  elseif type(b) == "number" then
    return Vector.new(a.x * b, a.y * b)
  else
    return Vector.new(a.x * b.x, a.y * b.y)
  end
end

function meta.__div(a, b)
  if type(a) == "number" then
    return Vector.new(a / b.x, a / b.y)
  elseif type(b) == "number" then
    return Vector.new(a.x / b, a.y / b)
  else
    return Vector.new(a.x / b.x, a.y / b.y)
  end
end

function meta.__eq(a, b)
  return a.x == b.x and a.y == b.y
end

function meta.__lt(a, b)
  return a.x < b.x or (a.x == b.x and a.y < b.y)
end

function meta.__le(a, b)
  return a.x <= b.x and a.y <= b.y
end

function meta.__tostring(a)
  return "(" .. a.x .. ", " .. a.y .. ")"
end

function meta:clone()
  return meta.new(self.x, self.y)
end

function meta:unpack()
  return self.x, self.y
end

function meta:len()
  return math.sqrt(self.x * self.x + self.y * self.y)
end

function meta:lenSq()
  return self.x * self.x + self.y * self.y
end

function meta:normalize()
  local len = self:len()
  self.x = self.x / len
  self.y = self.y / len
  return self
end

function meta:normalized()
  return self / self:len()
end

function meta:rotate(phi)
  local c = math.cos(phi)
  local s = math.sin(phi)
  self.x = c * self.x - s * self.y
  self.y = s * self.x + c * self.y
  return self
end

function meta:rotated(phi)
  return self:clone():rotate(phi)
end

function meta:perpendicular()
  return meta.new(-self.y, self.x)
end

function meta:projectOn(other)
  return (self * other) * other / other:lenSq()
end

function meta:cross(other)
  return self.x * other.y - self.y * other.x
end

function meta:dot(other)
  return self.x * other.x + self.y * other.y
end

function meta:toRad()
  ---@diagnostic disable-next-line: deprecated
  return -math.atan2(-self.y, self.x)
end

-- Static functions
function Vector.new(x, y)
  return setmetatable({ x = x or 0, y = y or 0 }, meta)
end

function Vector.distance(x1, y1, x2, y2)
  local x = x1 - x2
  local y = y1 - y2
  return math.sqrt(x * x + y * y)
end

function Vector.len(x, y)
  return math.sqrt(x * x + y * y)
end

function Vector.normalize(x, y)
  local len = math.sqrt(x * x + y * y)
  x = x / len
  y = y / len
  return { x = x, y = y }
end

function Vector.cross(x1, y1, x2, y2)
  return x1 * y2 - y1 * x2
end

function Vector.dot(x1, y1, x2, y2)
  return x1 * x2 + y1 * y2
end

return Vector