require("playbit.util")

local module = {}
playdate.geometry.arc = module

local meta = {}
meta.__index = meta
module.__index = meta

function module.new(x, y, radius, startAngle, endAngle, direction)
  local o = {}

  o._type = "arc"
  o.x = x
  o.y = y
  o.radius = radius
  o.startAngle = startAngle
  o.endAngle = endAngle

  if direction == nil then
    o.clockwise = o.endAngle >= o.startAngle
  else
    o.clockwise = direction
  end

  setmetatable(o, meta)
  return o
end

function meta:copy()
  return module.new(self.x, self.y, self.radius, self.startAngle, self.endAngle, self.clockwise)
end

function meta:length()
  local angle = self.endAngle - self.startAngle

  if not self.clockwise then
    angle = -angle
  end

  -- this is not correct but this is how PD works,
  -- confirmed by experiments
  if angle < 0 then
    angle = math.abs(angle + 360)
  end

  return self.radius * math.rad(angle)
end

function meta:isClockwise()
  return self.clockwise
end

function meta:setIsClockwise(flag)
  self.clockwise = flag
end

function meta:pointOnArc(distance, extend)
  if not extend then
    local length = self:length()
    distance = playbit.util.clamp(distance, 0, length)
  end

  local startAngleRad = math.rad(self.startAngle)
  local deltaAngleRad = distance / self.radius
  local angleRad

  if self.clockwise then
    angleRad = startAngleRad + deltaAngleRad
  else
    angleRad = startAngleRad - deltaAngleRad
  end

  -- on PD angle 0 is Up.
  local x = self.x + self.radius * math.sin(angleRad)
  local y = self.y - self.radius * math.cos(angleRad)

  return playdate.geometry.point.new(x, y)
end
