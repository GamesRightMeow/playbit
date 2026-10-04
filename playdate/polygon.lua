require("playbit.vector")
require("playbit.util")

local module = {}
playdate.geometry.polygon = module

local meta = {}

meta.__index = meta

meta.__mul = function(a, b)
  error("[ERR] playdate.geometry.polygon.__mul is not yet implemented.")
end

module.__index = meta

function module.new(x1, y1, ...)
  local o = {}

  o._type = "polygon"
  o._points = {...}
  o._closed = false

  local pts = { }

  if type(x1) == "number" then
    if y1 then
      pts = { x1, y1, ... }
    else
      local numberOfVertices = x1
      for i = 1, numberOfVertices, 2 do
        pts[i], pts[i + 1] = 0, 0
      end
    end
  else
    local args = {...}
    for i = 1, #args do
      local pt = args[i]
      pts[i * 2 - 1] = pt.x
      pts[i * 2]     = pt.y
    end
  end

  o._points = pts

  setmetatable(o, meta)
  return o
end

function meta:copy()
  local o = module.new(table.unpack(self._points))
  o._closed = self._closed
  return o
end

function meta:close()
  self._closed = true
  self._length = nil
end

function meta:isClosed()
  return self._closed
end

function meta:containsPoint(p, fillRule)
  error("[ERR] playdate.geometry.polygon:containsPoint() is not yet implemented.")
end

function meta:containsPoint(x, y, fillRule)
  error("[ERR] playdate.geometry.polygon:containsPoint() is not yet implemented.")
end

-- Returns multiple values (x, y, width, height) giving the axis-aligned bounding box for the polygon.
function meta:getBounds()
  error("[ERR] playdate.geometry.polygon:getBounds() is not yet implemented.")
end

function meta:getBoundsRect()
  local x, y, w, h = self:getBounds()
  return playdate.geometry.rect.new(x, y, w, h)
end

-- Returns the number of points in the polygon.
function meta:count()
  return #self._points / 2
end

local function calculateLength(pts, closed)
  if #pts < 4 then return 0 end

  local len = 0
  local x1, y1 = pts[1], pts[2]

  for i = 3, #pts, 2 do
    local x2, y2 = pts[i], pts[i + 1]
    len = len + playbit.vector.distance(x1, y1, x2, y2)
    x1, y1 = x2, y2
  end

  if closed then
    len = len + playbit.vector.distance(x1, y1, pts[1], pts[2])
  end

  return len
end

-- Returns the total length of all line segments in the polygon.
function meta:length()

  if not self._length then
    self._length = calculateLength(self._points, self._closed)
  end

  return self._length
end

function meta:setPointAt(n, x, y)
  self._points[n * 2 + 1] = x
  self._points[n * 2 + 2] = y
  self._length = nil
end

-- TODO: Check the return type because Playdate docs does not specify it.
function meta:getPointAt(n)
  return self._points[n * 2 + 1], self._points[n * 2 + 2]
end

function meta:intersects(p)
  error("[ERR] playdate.geometry.polygon:intersects() is not yet implemented.")
end

local function pointOnLine(dist, len, x1, y1, x2, y2)
  local d = dist / len
  local x = x1 + (x2 - x1) * d
  local y = y1 + (y2 - y1) * d
  return playdate.geometry.point.new(x, y)
end

function meta:pointOnPolygon(distance, extend)
  local pts = self._points

  -- todo: Check what PD returns for 0 or 1 point polygons.
  if #pts < 4 then return end

  local length = self:length()

  if not extend and not self._closed then
    distance = playbit.util.clamp(distance, 0, length)
  end

  if self._closed then
    -- Normalize distance making it positive.
    distance = (distance % length + length) % length

  else
    -- Extrapolate the first segment.
    if distance < 0 then
      local x1, y1, x2, y2 = pts[1], pts[2], pts[3], pts[4]
      local len = playbit.vector.distance(x1, y1, x2, y2)
      return pointOnLine(distance, len, x1, y1, x2, y2)
    end

    -- Extrapolate the last segment.
    if distance >= length then
      local cnt = #pts
      local x1, y1, x2, y2 = pts[cnt - 3], pts[cnt - 2], pts[cnt - 1], pts[cnt]
      local len = playbit.vector.distance(x1, y1, x2, y2)
      return pointOnLine(distance - length + len, len, x1, y1, x2, y2)
    end
  end

  local x1, y1 = pts[1], pts[2]
  local dist = distance
  for i = 3, #pts, 2 do
    local x2, y2 = pts[i], pts[i + 1]
    local len = playbit.vector.distance(x1, y1, x2, y2)
    if dist <= len and len > 1e-5 then
      return pointOnLine(dist, len, x1, y1, x2, y2)
    end
    dist = dist - len
    x1, y1 = x2, y2
  end

  local x2, y2 = pts[1], pts[2]
  local len = playbit.vector.distance(x1, y1, x2, y2)
  return pointOnLine(dist, len, x1, y1, x2, y2)
end

function meta:translate(dx, dy)
  local pts = self._points
  for i = 1, #pts, 2 do
    local j = i + 1
    pts[i] = pts[i] + dx
    pts[j] = pts[j] + dy
  end
end
