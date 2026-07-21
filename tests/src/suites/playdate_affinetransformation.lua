local tests = {}

function tests.new_default()
  local t = playdate.geometry.affineTransform.new()
  
  pbAssert.AreEqual(t.m11, 1)
  pbAssert.AreEqual(t.m12, 0)
  pbAssert.AreEqual(t.m21, 0)
  pbAssert.AreEqual(t.m22, 1)
  pbAssert.AreEqual(t.tx, 0)
  pbAssert.AreEqual(t.ty, 0)
end

function tests.new_with_values()
  local t = playdate.geometry.affineTransform.new(2, 3, 4, 5, 6, 7)
  
  pbAssert.AreEqual(t.m11, 2)
  pbAssert.AreEqual(t.m12, 3)
  pbAssert.AreEqual(t.m21, 4)
  pbAssert.AreEqual(t.m22, 5)
  pbAssert.AreEqual(t.tx, 6)
  pbAssert.AreEqual(t.ty, 7)
end

function tests.copy()
  local t1 = playdate.geometry.affineTransform.new(2, 3, 4, 5, 6, 7)
  
  local t2 = t1:copy()
  
  pbAssert.AreEqual(t2.m11, t1.m11)
  pbAssert.AreEqual(t2.m12, t1.m12)
  pbAssert.AreEqual(t2.m21, t1.m21)
  pbAssert.AreEqual(t2.m22, t1.m22)
  pbAssert.AreEqual(t2.tx, t1.tx)
  pbAssert.AreEqual(t2.ty, t1.ty)
end

function tests.reset()
  local t = playdate.geometry.affineTransform.new(2, 3, 4, 5, 6, 7)
  
  t:reset()
  
  pbAssert.AreEqual(t.m11, 1)
  pbAssert.AreEqual(t.m12, 0)
  pbAssert.AreEqual(t.m21, 0)
  pbAssert.AreEqual(t.m22, 1)
  pbAssert.AreEqual(t.tx, 0)
  pbAssert.AreEqual(t.ty, 0)
end

function tests.translate()
  local t = playdate.geometry.affineTransform.new()
  
  t:translate(5, 10)
  
  pbAssert.AreEqual(t.tx, 5)
  pbAssert.AreEqual(t.ty, 10)
end

function tests.translatedBy()
  local t = playdate.geometry.affineTransform.new(1, 0, 0, 1, 2, 3)
  
  local t2 = t:translatedBy(5, 10)
  
  pbAssert.AreEqual(t.tx, 2)
  pbAssert.AreEqual(t.ty, 3)
  pbAssert.AreEqual(t2.tx, 7)
  pbAssert.AreEqual(t2.ty, 13)
end

function tests.scale()
  local t = playdate.geometry.affineTransform.new()
  
  t:scale(2, 3)
  
  pbAssert.AreEqual(t.m11, 2)
  pbAssert.AreEqual(t.m22, 3)
end

function tests.scaledBy()
  local t = playdate.geometry.affineTransform.new()
  
  local t2 = t:scaledBy(2, 3)
  
  pbAssert.AreEqual(t.m11, 1)
  pbAssert.AreEqual(t.m22, 1)
  pbAssert.AreEqual(t2.m11, 2)
  pbAssert.AreEqual(t2.m22, 3)
end

function tests.rotate()
  local t = playdate.geometry.affineTransform.new()
  
  t:rotate(90)
  
  pbAssert.AreEqual(math.floor(t.m11 + 0.5), 0)
  pbAssert.AreEqual(math.floor(t.m12 + 0.5), -1)
  pbAssert.AreEqual(math.floor(t.m21 + 0.5), 1)
  pbAssert.AreEqual(math.floor(t.m22 + 0.5), 0)
end

function tests.rotatedBy()
  local t = playdate.geometry.affineTransform.new()
  
  local t2 = t:rotatedBy(90)
  
  pbAssert.AreEqual(t.m11, 1)
  pbAssert.AreEqual(math.floor(t2.m11 + 0.5), 0)
end

function tests.transformXY()
  local t = playdate.geometry.affineTransform.new(1, 0, 0, 1, 5, 10)
  
  local x, y = t:transformXY(3, 4)
  
  pbAssert.AreEqual(x, 8)
  pbAssert.AreEqual(y, 14)
end

function tests.invert()
  local t = playdate.geometry.affineTransform.new(2, 0, 0, 2, 4, 6)
  
  t:invert()
  
  pbAssert.AreEqual(t.m11, 0.5)
  pbAssert.AreEqual(t.m22, 0.5)
  pbAssert.AreEqual(t.tx, -2)
  pbAssert.AreEqual(t.ty, -3)
end

function tests.transformPoint()
  local t = playdate.geometry.affineTransform.new(1, 0, 0, 1, 5, 10)
  local p = playdate.geometry.point.new(3, 4)
  
  t:transformPoint(p)
  
  pbAssert.AreEqual(p.x, 8)
  pbAssert.AreEqual(p.y, 14)
end

function tests.transformedPoint()
  local t = playdate.geometry.affineTransform.new(1, 0, 0, 1, 5, 10)
  local p = playdate.geometry.point.new(3, 4)
  
  local p2 = t:transformedPoint(p)
  
  pbAssert.AreEqual(p.x, 3)
  pbAssert.AreEqual(p.y, 4)
  pbAssert.AreEqual(p2.x, 8)
  pbAssert.AreEqual(p2.y, 14)
end

function tests.concat()
  local t1 = playdate.geometry.affineTransform.new(2, 0, 0, 2, 0, 0)
  local t2 = playdate.geometry.affineTransform.new(1, 0, 0, 1, 5, 10)
  
  t1:concat(t2)
  
  pbAssert.AreEqual(t1.m11, 2)
  pbAssert.AreEqual(t1.m22, 2)
  pbAssert.AreEqual(t1.tx, 5)
  pbAssert.AreEqual(t1.ty, 10)
end

return tests