local module = {}
playdate.geometry = module

require("playdate.affineTransform")
require("playdate.arc")
require("playdate.lineSegment")
require("playdate.point")
require("playdate.polygon")
require("playdate.rect")
require("playdate.size")
require("playdate.vector2D")

module.kUnflipped = 0
module.kFlippedX = 1
module.kFlippedY = 2
module.kFlippedXY = 3

function module.squaredDistanceToPoint(x1, y1, x2, y2)
  local dx = x2 - x1
  local dy = y2 - y1
  return dx * dx + dy * dy
end

function module.distanceToPoint(x1, y1, x2, y2)
  local dx = x2 - x1
  local dy = y2 - y1
  return math.sqrt(dx * dx + dy * dy)
end
