local tests = {}

function test_point_new()
  local p = playdate.geometry.point.new(10, 20)
  
  pbAssert.AreEqual(p.x, 10)
  pbAssert.AreEqual(p.y, 20)
end

function test_point_copy()
  local p1 = playdate.geometry.point.new(10, 20)
  
  local p2 = p1:copy()
  
  pbAssert.AreEqual(p2.x, p1.x)
  pbAssert.AreEqual(p2.y, p1.y)
end

function test_point_unpack()
  local p = playdate.geometry.point.new(10, 20)
  
  local x, y = p:unpack()
  
  pbAssert.AreEqual(x, 10)
  pbAssert.AreEqual(y, 20)
end

function test_point_offset()
  local p = playdate.geometry.point.new(10, 20)
  
  p:offset(5, 10)
  
  pbAssert.AreEqual(p.x, 15)
  pbAssert.AreEqual(p.y, 30)
end

function test_point_offsetBy()
  local p = playdate.geometry.point.new(10, 20)
  
  local p2 = p:offsetBy(5, 10)
  
  pbAssert.AreEqual(p.x, 10)
  pbAssert.AreEqual(p2.x, 15)
  pbAssert.AreEqual(p2.y, 30)
end

function test_point_squaredDistanceToPoint()
  local p1 = playdate.geometry.point.new(0, 0)
  local p2 = playdate.geometry.point.new(3, 4)
  
  local dist = p1:squaredDistanceToPoint(p2)
  
  pbAssert.AreEqual(dist, 25)
end

function test_point_distanceToPoint()
  local p1 = playdate.geometry.point.new(0, 0)
  local p2 = playdate.geometry.point.new(3, 4)
  
  local dist = p1:distanceToPoint(p2)
  
  pbAssert.AreEqual(dist, 5)
end

return tests