local Steering = {}

function Steering.follow(position, orientation, targetPosition)
  local targetOrientation = targetPosition - position
  targetOrientation:normalize()
  return targetOrientation - orientation
end

function Steering.avoid(position, targetPosition)
  local v = position - targetPosition
  return v:normalized()
end

function Steering.arrive()
end

function Steering.flee()
end

function Steering.wander()
end

return Steering