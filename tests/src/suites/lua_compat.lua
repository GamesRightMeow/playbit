local tests = {}

function tests.TableUnpack_ReturnsValues()
  local a, b, c = table.unpack({ 1, 2, 3 })

  pbAssert.AreEqual(a, 1)
  pbAssert.AreEqual(b, 2)
  pbAssert.AreEqual(c, 3)
end

function tests.TablePack_StoresCount()
  local t = table.pack(1, nil, 3)

  pbAssert.AreEqual(t.n, 3)
  pbAssert.AreEqual(t[1], 1)
  pbAssert.IsNil(t[2])
  pbAssert.AreEqual(t[3], 3)
end

return tests
