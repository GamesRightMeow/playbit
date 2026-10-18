local tests = {}

-- on playdate import is resolved at compile time, so this only makes sense on love2d
!if LOVE2D then
function tests.Import_ResolvesRelativePaths()
  import("data/import/a")

  pbAssert.IsTrue(importTestA)
  pbAssert.IsTrue(importTestC)
  pbAssert.AreEqual(importTestB, 1)
end
!end

return tests
