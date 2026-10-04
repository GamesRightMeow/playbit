local tests = {}

function test_polygon_new_with_numbers()
  local poly = playdate.geometry.polygon.new(1, 2, 3, 4, 5, 6)
  
  pbAssert.AreEqual(poly:count(), 3)
end

function test_polygon_new_with_vertex_count()
  local poly = playdate.geometry.polygon.new(4)
  
  pbAssert.AreEqual(poly:count(), 2)
end

function test_polygon_copy()
  local poly1 = playdate.geometry.polygon.new(1, 2, 3, 4)
  
  local poly2 = poly1:copy()
  
  pbAssert.AreEqual(poly2:count(), poly1:count())
end

function test_polygon_close()
  local poly = playdate.geometry.polygon.new(1, 2, 3, 4, 5, 6)
  
  poly:close()
  
  pbAssert.AreEqual(poly:isClosed(), true)
end

function test_polygon_count()
  local poly = playdate.geometry.polygon.new(1, 2, 3, 4, 5, 6)
  
  local count = poly:count()
  
  pbAssert.AreEqual(count, 3)
end

function test_polygon_setPointAt_and_getPointAt()
  local poly = playdate.geometry.polygon.new(1, 2, 3, 4, 5, 6)
  
  poly:setPointAt(0, 10, 20)
  local x, y = poly:getPointAt(0)
  
  pbAssert.AreEqual(x, 10)
  pbAssert.AreEqual(y, 20)
end

function test_polygon_length()
  local poly = playdate.geometry.polygon.new(0, 0, 3, 4, 6, 8)
  
  local len = poly:length()
  
  pbAssert.AreEqual(len, 10)
end

function test_polygon_pointOnPolygon()
  local poly = playdate.geometry.polygon.new(0, 0, 10, 0, 10, 10)
  
  local p = poly:pointOnPolygon(5)
  
  pbAssert.AreEqual(p.x, 5)
  pbAssert.AreEqual(p.y, 0)
end

function test_polygon_translate()
  local poly = playdate.geometry.polygon.new(1, 2, 3, 4, 5, 6)
  
  poly:translate(10, 20)
  
  local x, y = poly:getPointAt(0)
  pbAssert.AreEqual(x, 11)
  pbAssert.AreEqual(y, 22)
end

return tests