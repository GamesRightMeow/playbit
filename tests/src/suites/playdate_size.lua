local tests = {}

function test_size_new()
  local s = playdate.geometry.size.new(10, 20)
  
  pbAssert.AreEqual(s.width, 10)
  pbAssert.AreEqual(s.height, 20)
end

function test_size_copy()
  local s1 = playdate.geometry.size.new(10, 20)
  
  local s2 = s1:copy()
  
  pbAssert.AreEqual(s2.width, s1.width)
  pbAssert.AreEqual(s2.height, s1.height)
end

function test_size_unpack()
  local s = playdate.geometry.size.new(10, 20)
  
  local w, h = s:unpack()
  
  pbAssert.AreEqual(w, 10)
  pbAssert.AreEqual(h, 20)
end

return tests