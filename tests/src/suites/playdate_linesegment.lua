local tests = {}

function test_lineSegment_new()
  local ls = playdate.geometry.lineSegment.new(1, 2, 3, 4)
  
  pbAssert.AreEqual(ls.x1, 1)
  pbAssert.AreEqual(ls.y1, 2)
  pbAssert.AreEqual(ls.x2, 3)
  pbAssert.AreEqual(ls.y2, 4)
end

function test_lineSegment_copy()
  local ls1 = playdate.geometry.lineSegment.new(1, 2, 3, 4)
  
  local ls2 = ls1:copy()
  
  pbAssert.AreEqual(ls2.x1, ls1.x1)
  pbAssert.AreEqual(ls2.y1, ls1.y1)
  pbAssert.AreEqual(ls2.x2, ls1.x2)
  pbAssert.AreEqual(ls2.y2, ls1.y2)
end

function test_lineSegment_unpack()
  local ls = playdate.geometry.lineSegment.new(1, 2, 3, 4)
  
  local x1, y1, x2, y2 = ls:unpack()
  
  pbAssert.AreEqual(x1, 1)
  pbAssert.AreEqual(y1, 2)
  pbAssert.AreEqual(x2, 3)
  pbAssert.AreEqual(y2, 4)
end

function test_lineSegment_length()
  local ls = playdate.geometry.lineSegment.new(0, 0, 3, 4)
  
  local len = ls:length()
  
  pbAssert.AreEqual(len, 5)
end

function test_lineSegment_offset()
  local ls = playdate.geometry.lineSegment.new(1, 2, 3, 4)
  
  ls:offset(5, 10)
  
  pbAssert.AreEqual(ls.x1, 6)
  pbAssert.AreEqual(ls.y1, 12)
  pbAssert.AreEqual(ls.x2, 8)
  pbAssert.AreEqual(ls.y2, 14)
end

function test_lineSegment_offsetBy()
  local ls = playdate.geometry.lineSegment.new(1, 2, 3, 4)
  
  local ls2 = ls:offsetBy(5, 10)
  
  pbAssert.AreEqual(ls.x1, 1)
  pbAssert.AreEqual(ls2.x1, 6)
  pbAssert.AreEqual(ls2.y1, 12)
end

function test_lineSegment_midPoint()
  local ls = playdate.geometry.lineSegment.new(0, 0, 4, 4)
  
  local p = ls:midPoint()
  
  pbAssert.AreEqual(p.x, 2)
  pbAssert.AreEqual(p.y, 2)
end

function test_lineSegment_pointOnLine()
  local ls = playdate.geometry.lineSegment.new(0, 0, 10, 0)
  
  local p = ls:pointOnLine(5)
  
  pbAssert.AreEqual(p.x, 5)
  pbAssert.AreEqual(p.y, 0)
end

function test_lineSegment_segmentVector()
  local ls = playdate.geometry.lineSegment.new(1, 2, 4, 6)
  
  local v = ls:segmentVector()
  
  pbAssert.AreEqual(v.dx, 3)
  pbAssert.AreEqual(v.dy, 4)
end

function test_lineSegment_closestPointOnLineToPoint()
  local ls = playdate.geometry.lineSegment.new(0, 0, 10, 0)
  local p = playdate.geometry.point.new(5, 5)
  
  local closest = ls:closestPointOnLineToPoint(p)
  
  pbAssert.AreEqual(closest.x, 5)
  pbAssert.AreEqual(closest.y, 0)
end

return tests