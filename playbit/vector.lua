local Vector = {}
Vector.__index = Vector

function Vector.new(x, y)
  return setmetatable({ x = x or 0, y = y or 0 }, Vector)
end

function Vector.__add(a, b)
  if type(a) == "number" then
    return Vector.new(b.x + a, b.y + a)
  elseif type(b) == "number" then
    return Vector.new(a.x + b, a.y + b)
  else
    return Vector.new(a.x + b.x, a.y + b.y)
  end
end

function Vector.__sub(a, b)
  if type(a) == "number" then
    return Vector.new(a - b.x, a - b.y)
  elseif type(b) == "number" then
    return Vector.new(a.x - b, a.y - b)
  else
    return Vector.new(a.x - b.x, a.y - b.y)
  end
end

function Vector.__mul(a, b)
  if type(a) == "number" then
    return Vector.new(b.x * a, b.y * a)
  elseif type(b) == "number" then
    return Vector.new(a.x * b, a.y * b)
  else
    return Vector.new(a.x * b.x, a.y * b.y)
  end
end

function Vector.__div(a, b)
  if type(a) == "number" then
    return Vector.new(a / b.x, a / b.y)
  elseif type(b) == "number" then
    return Vector.new(a.x / b, a.y / b)
  else
    return Vector.new(a.x / b.x, a.y / b.y)
  end
end

function Vector.__eq(a, b)
  return a.x == b.x and a.y == b.y
end

function Vector.__lt(a, b)
  return a.x < b.x or (a.x == b.x and a.y < b.y)
end

function Vector.__le(a, b)
  return a.x <= b.x and a.y <= b.y
end

function Vector.__tostring(a)
  return "(" .. a.x .. ", " .. a.y .. ")"
end

function Vector.distance(a, b)
  return (b - a):len()
end

function Vector:clone()
  return Vector.new(self.x, self.y)
end

function Vector:unpack()
  return self.x, self.y
end

function Vector:len()
  return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vector:lenSq()
  return self.x * self.x + self.y * self.y
end

function Vector:normalize()
  local len = self:len()
  self.x = self.x / len
  self.y = self.y / len
  return self
end

function Vector:normalized()
  return self / self:len()
end

function Vector:rotate(phi)
  local c = math.cos(phi)
  local s = math.sin(phi)
  self.x = c * self.x - s * self.y
  self.y = s * self.x + c * self.y
  return self
end

function Vector:rotated(phi)
  return self:clone():rotate(phi)
end

function Vector:perpendicular()
  return Vector.new(-self.y, self.x)
end

function Vector:projectOn(other)
  return (self * other) * other / other:lenSq()
end

function Vector:cross(other)
  return self.x * other.y - self.y * other.x
end

function Vector:dot(other)
  return self.x * other.x + self.y * other.y
end

return Vector