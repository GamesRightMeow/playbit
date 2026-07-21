local tests = {}

function test_geometry_squaredDistanceToPoint()
  local dist = playdate.geometry.squaredDistanceToPoint(0, 0, 3, 4)
  pbAssert.AreEqual(dist, 25)
end

function test_geometry_distanceToPoint()
  local dist = playdate.geometry.distanceToPoint(0, 0, 3, 4)
  pbAssert.AreEqual(dist, 5)
end

return tests