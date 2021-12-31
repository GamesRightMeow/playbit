local Steering = {}

local function intersectsCircle(obstacle, ahead1, ahead2, radius)
  if pb.vector.distance(obstacle, ahead1) < radius then
    return true
  end

  return pb.vector.distance(obstacle, ahead2) < radius
end

local function findClosestObstacle(obstacles, position, ahead1, ahead2)
  local closestObstacle = nil
  local closestObstacleDistance = -1
  for i = 1, #obstacles, 1 do
    local obstacle = obstacles[i]
    local doesIntersect = intersectsCircle(obstacle.position, ahead1, ahead2, obstacle.radius)
    if doesIntersect then
      local distance = pb.vector.distance(position, obstacle.position)
      if closestObstacleDistance == -1 or distance < closestObstacleDistance then
        closestObstacle = obstacle
        closestObstacleDistance = distance
      end
    end
  end
  return closestObstacle
end

function Steering.avoid(position, velocity, obstacles, maxSeeAhead)
  local normalizedVelocity = velocity:normalized()
  local ahead1 = position + normalizedVelocity * maxSeeAhead
  local ahead2 = position + normalizedVelocity * maxSeeAhead * 0.5
  local closestObstacle = findClosestObstacle(obstacles, position, ahead1, ahead2)
  if not closestObstacle then
    return pb.vector.new()
  end
  
  local steering = ahead1 - closestObstacle.position
  return steering:normalize()
end

function Steering.seek(position, targetPosition)
  return (targetPosition - position):normalize()
end

function Steering.flee()
  -- TODO: implement
end

function Steering.arrive()
  -- TODO: implement
end

function Steering.pursue()
  -- TODO: implement
end

function Steering.evade()
  -- TODO: implement
end

function Steering.wander()
  -- TODO: implement
end

return Steering