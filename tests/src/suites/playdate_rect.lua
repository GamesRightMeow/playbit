local tests = {}

function test_rect_new()
  local r = playdate.geometry.rect.new(10, 20, 30, 40)
  
  pbAssert.AreEqual(r.x, 10)
  pbAssert.AreEqual(r.y, 20)
  pbAssert.AreEqual(r.width, 30)
  pbAssert.AreEqual(r.height, 40)
end

function test_rect_copy()
  local r1 = playdate.geometry.rect.new(10, 20, 30, 40)
  
  local r2 = r1:copy()
  
  pbAssert.AreEqual(r2.x, r1.x)
  pbAssert.AreEqual(r2.y, r1.y)
  pbAssert.AreEqual(r2.width, r1.width)
  pbAssert.AreEqual(r2.height, r1.height)
end

function test_rect_unpack()
  local r = playdate.geometry.rect.new(10, 20, 30, 40)
  
  local x, y, w, h = r:unpack()
  
  pbAssert.AreEqual(x, 10)
  pbAssert.AreEqual(y, 20)
  pbAssert.AreEqual(w, 30)
  pbAssert.AreEqual(h, 40)
end

function test_rect_properties()
  local r = playdate.geometry.rect.new(10, 20, 30, 40)
  
  -- Act & Assert
  pbAssert.AreEqual(r.left, 10)
  pbAssert.AreEqual(r.top, 20)
  pbAssert.AreEqual(r.right, 40)
  pbAssert.AreEqual(r.bottom, 60)
end

function test_rect_isEmpty()
  local r1 = playdate.geometry.rect.new(0, 0, 0, 10)
  local r2 = playdate.geometry.rect.new(0, 0, 10, 10)
  
  -- Act & Assert
  pbAssert.AreEqual(r1:isEmpty(), true)
  pbAssert.AreEqual(r2:isEmpty(), false)
end

function test_rect_isEqual()
  local r1 = playdate.geometry.rect.new(10, 20, 30, 40)
  local r2 = playdate.geometry.rect.new(10, 20, 30, 40)
  local r3 = playdate.geometry.rect.new(5, 20, 30, 40)
  
  -- Act & Assert
  pbAssert.AreEqual(r1:isEqual(r2), true)
  pbAssert.AreEqual(r1:isEqual(r3), false)
end

function test_rect_intersects()
  local r1 = playdate.geometry.rect.new(0, 0, 10, 10)
  local r2 = playdate.geometry.rect.new(5, 5, 10, 10)
  local r3 = playdate.geometry.rect.new(20, 20, 10, 10)
  
  -- Act & Assert
  pbAssert.AreEqual(r1:intersects(r2), true)
  pbAssert.AreEqual(r1:intersects(r3), false)
end

function test_rect_union()
  local r1 = playdate.geometry.rect.new(0, 0, 10, 10)
  local r2 = playdate.geometry.rect.new(5, 5, 10, 10)
  
  local r3 = r1:union(r2)
  
  pbAssert.AreEqual(r3.x, 0)
  pbAssert.AreEqual(r3.y, 0)
  pbAssert.AreEqual(r3.width, 15)
  pbAssert.AreEqual(r3.height, 15)
end

function test_rect_inset()
  local r = playdate.geometry.rect.new(10, 20, 30, 40)
  
  r:inset(5, 10)
  
  pbAssert.AreEqual(r.x, 15)
  pbAssert.AreEqual(r.y, 30)
  pbAssert.AreEqual(r.width, 20)
  pbAssert.AreEqual(r.height, 20)
end

function test_rect_insetBy()
  local r = playdate.geometry.rect.new(10, 20, 30, 40)
  
  local r2 = r:insetBy(5, 10)
  
  pbAssert.AreEqual(r.x, 10)
  pbAssert.AreEqual(r2.x, 15)
  pbAssert.AreEqual(r2.width, 20)
end

function test_rect_offset()
  local r = playdate.geometry.rect.new(10, 20, 30, 40)
  
  r:offset(5, 10)
  
  pbAssert.AreEqual(r.x, 15)
  pbAssert.AreEqual(r.y, 30)
end

function test_rect_offsetBy()
  local r = playdate.geometry.rect.new(10, 20, 30, 40)
  
  local r2 = r:offsetBy(5, 10)
  
  pbAssert.AreEqual(r.x, 10)
  pbAssert.AreEqual(r2.x, 15)
end

function test_rect_containsPoint_with_point_object()
  local r = playdate.geometry.rect.new(0, 0, 10, 10)
  local p1 = playdate.geometry.point.new(5, 5)
  local p2 = playdate.geometry.point.new(15, 15)
  
  -- Act & Assert
  pbAssert.AreEqual(r:containsPoint(p1), true)
  pbAssert.AreEqual(r:containsPoint(p2), false)
end

function test_rect_centerPoint()
  local r = playdate.geometry.rect.new(0, 0, 10, 20)
  
  local p = r:centerPoint()
  
  pbAssert.AreEqual(p.x, 5)
  pbAssert.AreEqual(p.y, 10)
end

return tests