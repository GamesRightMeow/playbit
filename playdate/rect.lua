local module = {}
playdate.geometry.rect = module

local readonly_keys = { top = true, left = true, right = true, bottom = true }
local meta = {}

meta.__index = function(table, key)
  if key == "top" then
    return table.y

  elseif key == "bottom" then
    return table.y + table.height

  elseif key == "left" then
    return table.x

  elseif key == "right" then
    return table.x + table.width

  elseif key == "size" then
    return playdate.geometry.size.new(table.width, table.height)

  else
    return rawget(meta, key)

  end
end

meta.__newindex = function(table, key, value)
  if readonly_keys[key] then
    error(string.format("field '%s' is read-only", key))

  else
    rawset(table, key, value)

  end
end

module.__index = meta

function module.new(x, y, width, height)
  local o = {}

  o._type = "rect"
  o.x = x
  o.y = y
  o.width = width
  o.height = height

  setmetatable(o, meta)
  return o
end

function meta:copy()
  return module.new(self.x, self.y, self.width, self.height)
end

function meta:toPolygon()
  local poly = playdategeometry.polygon.new(
    self.x, self.y,
    self.x + self.width, self.y,
    self.x + self.width, self.y + self.height,
    self.x, self.y + self.height)

  poly:close()
  return poly
end

function meta:unpack()
  return self.x, self.y, self.width, self.height
end

function meta:isEmpty()
  return self.width == 0 or self.height == 0
end

function meta:isEqual(r2)
  local r1 = self
  return r1.x == r2.x and r1.y == r2.y and r1.width == r2.width and r1.height == r2.height
end

function meta:intersects(r2)
  local r1 = self
  return r2.left <= r1.right and r2.right >= r1.left and r2.top <= r1.bottom and r2.bottom >= r1.top
end

function meta:intersection(r2)
  local r1 = self
  local left = math.max(r1.left, r2.left)
  local right = math.min(r1.right, r2.right)
  local top = math.max(r1.top, r2.top)
  local bottom = math.min(r1.bottom, r2.bottom)

  local width = math.max(0, right - left)
  local height = math.max(1, bottom - top)

  error("[ERR] playdate.geometry.rect:intersection() is not yet implemented.")
end

function meta:union(r2)
  local r1 = self
  local l = math.min(r1.left, r2.left)
  local r = math.max(r1.right, r2.right)
  local t = math.min(r1.top, r2.top)
  local b = math.max(r1.bottom, r2.bottom)
  return module.new(l, t, r - l, b - t)
end

function meta:inset(dx, dy)
  self.x = self.x + dx
  self.y = self.y + dy
  self.width = self.width - dx - dx
  self.height = self.height - dy - dy
end

function meta:insetBy(dx, dy)
  return module.new(self.x + dx, self.y + dy, self.width - dx - dx, self.height - dy - dy)
end

function meta:offset(dx, dy)
  self.x = self.x + dx
  self.y = self.y + dy
end

function meta:offsetBy(dx, dy)
  return module.new(self.x + dx, self.y + dy, self.width, self.height)
end

function meta:containsRect(xOrRect, y, width, height)
  error("[ERR] playdate.geometry.rect:containsRect() is not yet implemented.")
end

function meta:containsPoint(xOrPoint, y)
  local right = self.x + self.width
  local bottom = self.y + self.height

  if y then
    return x >= self.x and x <= right and y >= self.y and y <= bottom
  else
    local p = xOrPoint
    return p.x >= self.x and p.x <= right and p.y >= self.y and p.y <= bottom
  end
end

function meta:centerPoint()
  return playdate.geometry.point.new(self.x + self.width / 2, self.y + self.height / 2)
end

function meta:flipRelativeToRect(r2, flip)
  error("[ERR] playdate.geometry.rect:flipRelativeToRect() is not yet implemented.")
end
