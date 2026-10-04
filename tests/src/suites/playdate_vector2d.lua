local tests = {}

function test_vector2D_new()
  local v = playdate.geometry.vector2D.new(3, 4)
  
  pbAssert.AreEqual(v.dx, 3)
  pbAssert.AreEqual(v.dy, 4)
end

function test_vector2D_newPolar()
  local v = playdate.geometry.vector2D.newPolar(10, 0)
  
  pbAssert.AreEqual(math.floor(v.dx + 0.5), 0)
  pbAssert.AreEqual(math.floor(v.dy + 0.5), -10)
end

function test_vector2D_copy()
  local v1 = playdate.geometry.vector2D.new(3, 4)
  
  local v2 = v1:copy()
  
  pbAssert.AreEqual(v2.dx, v1.dx)
  pbAssert.AreEqual(v2.dy, v1.dy)
end

function test_vector2D_unpack()
  local v = playdate.geometry.vector2D.new(3, 4)
  
  local dx, dy = v:unpack()
  
  pbAssert.AreEqual(dx, 3)
  pbAssert.AreEqual(dy, 4)
end

function test_vector2D_magnitude()
  local v = playdate.geometry.vector2D.new(3, 4)
  
  local mag = v:magnitude()
  
  pbAssert.AreEqual(mag, 5)
end

function test_vector2D_magnitudeSquared()
  local v = playdate.geometry.vector2D.new(3, 4)
  
  local mag = v:magnitudeSquared()
  
  pbAssert.AreEqual(mag, 25)
end

function test_vector2D_scale()
  local v = playdate.geometry.vector2D.new(3, 4)
  
  v:scale(2)
  
  pbAssert.AreEqual(v.dx, 6)
  pbAssert.AreEqual(v.dy, 8)
end

function test_vector2D_scaledBy()
  local v = playdate.geometry.vector2D.new(3, 4)
  
  local v2 = v:scaledBy(2)
  
  pbAssert.AreEqual(v.dx, 3)
  pbAssert.AreEqual(v2.dx, 6)
end

function test_vector2D_addVector()
  local v1 = playdate.geometry.vector2D.new(1, 2)
  local v2 = playdate.geometry.vector2D.new(3, 4)
  
  v1:addVector(v2)
  
  pbAssert.AreEqual(v1.dx, 4)
  pbAssert.AreEqual(v1.dy, 6)
end

function test_vector2D_normalize()
  local v = playdate.geometry.vector2D.new(3, 4)
  
  v:normalize()
  
  pbAssert.AreEqual(math.floor(v:magnitude() + 0.5), 1)
end

function test_vector2D_normalized()
  local v = playdate.geometry.vector2D.new(3, 4)
  
  local v2 = v:normalized()
  
  pbAssert.AreEqual(v:magnitude(), 5)
  pbAssert.AreEqual(math.floor(v2:magnitude() + 0.5), 1)
end

function test_vector2D_dotProduct()
  local v1 = playdate.geometry.vector2D.new(1, 0)
  local v2 = playdate.geometry.vector2D.new(0, 1)
  
  local dot = v1:dotProduct(v2)
  
  pbAssert.AreEqual(dot, 0)
end

function test_vector2D_leftNormal()
  local v = playdate.geometry.vector2D.new(1, 2)
  
  local n = v:leftNormal()
  
  pbAssert.AreEqual(n.dx, 2)
  pbAssert.AreEqual(n.dy, -1)
end

function test_vector2D_rightNormal()
  local v = playdate.geometry.vector2D.new(1, 2)
  
  local n = v:rightNormal()
  
  pbAssert.AreEqual(n.dx, -2)
  pbAssert.AreEqual(n.dy, 1)
end

return tests