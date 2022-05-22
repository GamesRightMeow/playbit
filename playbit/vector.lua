local module = {}
pb = pb or {}
pb.vector = module

function module.angle(x, y)
  return math.deg(math.atan2(-y, x))
end

function module.distanceSq(x1, y1, x2, y2)
  local x = x1 - x2
  local y = y1 - y2
  return x * x + y * y
end

function module.distance(x1, y1, x2, y2)
  local x = x1 - x2
  local y = y1 - y2
  return math.sqrt(x * x + y * y)
end

function module.lenSq(x, y)
  return x * x + y * y
end

function module.perpendicular(x, y)
  return -self.y, self.x
end

function module.len(x, y)
  return math.sqrt(x * x + y * y)
end

function module.normalize(x, y)
  local len = math.sqrt(x * x + y * y)
  x = x / len
  y = y / len
  return x, y
end

function module.cross(x1, y1, x2, y2)
  return x1 * y2 - y1 * x2
end

function module.dot(x1, y1, x2, y2)
  return x1 * x2 + y1 * y2
end