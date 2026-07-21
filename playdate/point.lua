local module = {}
playdate.geometry.point = module

local meta = {}

meta.__index = meta

meta.__add = function(a, b)
  return module.new(a.x + b.dx, a.y + b.dy)
end

meta.__sub = function(a, b)
  if b._type then
    if b._type == "point" then
      return playdate.geometry.vector2D.new(a.x - b.x, a.y - b.y)
    elseif b._type == "vector2D" then
      return playdate.geometry.point.new(a.x - b.dx, a.y - b.dy)
    end
  end
end

meta.__mul = function(a, b)
  return b:transformedPoint(a)
end

meta.__concat = function(a, b)
  return playdate.geometry.lineSegment.new(a.x, a.y, b.x, b.y)
end

meta.__tostring = function(p)
  return string.format("(%s, %s)", p.x, p.y)
end

module.__index = meta

function module.new(x, y)
  local o = {}

  o._type = "point"
  o.x = x
  o.y = y

  setmetatable(o, meta)
  return o
end

function meta:copy()
  return module.new(self.x, self.y)
end

function meta:unpack()
  return self.x, self.y
end

function meta:offset(dx, dy)
  self.x = self.x + dx
  self.y = self.y + dy
end

function meta:offsetBy(dx, dy)
  return module.new(self.x + dx, self.y + dy)
end

function meta:squaredDistanceToPoint(p)
  local dx = self.x - p.x
  local dy = self.y - p.y
  return dx * dx + dy * dy
end

function meta:distanceToPoint(p)
  local dx = self.x - p.x
  local dy = self.y - p.y
  return math.sqrt(dx * dx + dy * dy)
end
