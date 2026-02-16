require("playbit.util")

local module = {}
playdate.geometry.lineSegment = module

local meta = {}
meta.__index = meta
module.__index = meta

function module.new(x1, y1, x2, y2)
  local o = {}

  o._type = "lineSegment"
  o.x1 = x1
  o.y1 = y1
  o.x2 = x2
  o.y2 = y2

  setmetatable(o, meta)
  return o
end

function module.fast_intersection(x1, y1, x2, y2, x3, y3, x4, y4)
  error("[ERR] playdate.geometry.lineSegment.fast_intersection() is not yet implemented.")
end

function meta:copy()
  return module.new(self.x1, self.y1, self.x2, self.y2)
end

function meta:unpack()
  return self.x1, self.y1, self.x2, self.y2
end

function meta:length()
  local dx = self.x2 - self.x1
  local dy = self.y2 - self.y1
  return math.sqrt(dx * dx + dy * dy)
end

function meta:offset(dx, dy)
  self.x1 = self.x1 + dx
  self.x2 = self.x2 + dx
  self.y1 = self.y1 + dy
  self.y2 = self.y2 + dy
end

function meta:offsetBy(dx, dy)
  return module.new(self.x1 + dx, self.y1 + dy, self.x2 + dx, self.y2 + dy)
end

function meta:midPoint()
  return playdate.geometry.point.new((self.x1 + self.x2) / 2, (self.y1 + self.y2) / 2)
end

function meta:pointOnLine(distance, extend)
  local len = self:length()

  if not extend then
    distance = playbit.util.clamp(distance, 0, len)
  end

  local d = distance / len
  local x = self.x1 + (self.x2 - self.x1) * d
  local y = self.y1 + (self.y2 - self.y1) * d

  return playdate.geometry.point.new(x, y)
end

-- TODO: Check what PD does here.
function meta:segmentVector()
  return playdate.geometry.vector2D.new(self.x2 - self.x1, self.y2 - self.y1)
end

function meta:closestPointOnLineToPoint(p, extend)
  local vx = p.x - self.x1
  local vy = p.y - self.y1

  local dx = self.x2 - self.x1
  local dy = self.y2 - self.y1

  local d = (vx * dx + vy * dy) / (dx * dx + dy * dy)

  if not extend or extend ~= true then
    if d < 0 then
      d = 0
    elseif d > 1 then
      d = 1
    end
  end

  return playdate.geometry.point.new(self.x1 + d * dx, self.y1 + d * dy)
end

function meta:intersectsLineSegment(ls)
  error("[ERR] playdate.geometry.lineSegment:intersectsLineSegment() is not yet implemented.")
end

function meta:intersectsPolygon(poly)
  error("[ERR] playdate.geometry.lineSegment:intersectsPolygon() is not yet implemented.")
end

function meta:intersectsRect(rect)
  error("[ERR] playdate.geometry.lineSegment:intersectsRect() is not yet implemented.")
end
