local tests = {}

function test_arc_new_default_clockwise()
  local a = playdate.geometry.arc.new(10, 20, 30, 45, 90)
  
  pbAssert.AreEqual(a.x, 10)
  pbAssert.AreEqual(a.y, 20)
  pbAssert.AreEqual(a.radius, 30)
  pbAssert.AreEqual(a.startAngle, 45)
  pbAssert.AreEqual(a.endAngle, 90)
  pbAssert.AreEqual(a.clockwise, true)
end

function test_arc_new_explicit_counterclockwise()
  local a = playdate.geometry.arc.new(10, 20, 30, 90, 45, false)
  
  pbAssert.AreEqual(a.clockwise, false)
end

function test_arc_copy()
  local a1 = playdate.geometry.arc.new(10, 20, 30, 45, 90, true)
  
  local a2 = a1:copy()
  
  pbAssert.AreEqual(a2.x, a1.x)
  pbAssert.AreEqual(a2.y, a1.y)
  pbAssert.AreEqual(a2.radius, a1.radius)
  pbAssert.AreEqual(a2.clockwise, a1.clockwise)
end

function test_arc_isClockwise()
  local a = playdate.geometry.arc.new(0, 0, 1, 0, 90, true)
  
  -- Act & Assert
  pbAssert.AreEqual(a:isClockwise(), true)
end

function test_arc_setIsClockwise()
  local a = playdate.geometry.arc.new(0, 0, 1, 0, 90, true)
  
  a:setIsClockwise(false)
  
  pbAssert.AreEqual(a:isClockwise(), false)
end

function test_arc_length_clockwise()
  local a = playdate.geometry.arc.new(0, 0, 10, 0, 180, true)
  
  local len = a:length()
  
  pbAssert.AreEqual(math.floor(len + 0.5), math.floor(10 * math.pi + 0.5))
end

function test_arc_pointOnArc()
  local a = playdate.geometry.arc.new(0, 0, 10, 0, 180, true)
  
  local p = a:pointOnArc(0)
  
  pbAssert.AreEqual(math.floor(p.x + 0.5), 0)
  pbAssert.AreEqual(math.floor(p.y + 0.5), -10)
end

return tests