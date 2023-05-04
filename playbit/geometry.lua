local module = {}
playbit = playbit or {}
playbit.geometry = module

--- Gets the difference of two angles, wrapped around to the range -180 to 180.
function module.angleDiff(a, b)
  local diff = b - a

  while (diff > 180) do
    diff = diff - 360 
  end

  while (diff <= -180) do 
    diff = diff + 360 
  end

  return diff
end

function module.lineLineIntersection(x1, y1, x2, y2, x3, y3, x4, y4)
  -- line intercept math by Paul Bourke http://paulbourke.net/geometry/pointlineplane/

  -- Check if none of the lines are of length 0
  if ((x1 == x2 and y1 == y2) or (x3 == x4 and y3 == y4)) then
    return false, 0, 0
  end

  local denominator = ((y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1))

  -- Lines are parallel
  if (denominator == 0) then
    return false, 0, 0
  end

  local ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denominator
  local ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / denominator

  -- is the intersection along the segments
  if (ua < 0 or ua > 1 or ub < 0 or ub > 1) then
    return false, 0, 0
  end

  -- Return a object with the x and y coordinates of the intersection
  local x = x1 + ua * (x2 - x1)
  local y = y1 + ua * (y2 - y1)

  return true, x, y
end