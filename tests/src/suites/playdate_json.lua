local tests = {}

function tests.DecodeSimpleObject()
  local jsonStr = '{"name": "test", "value": 42}'
  local result = json.decode(jsonStr)
  pbAssert.IsNotNil(result)
  pbAssert.AreEqual(result.name, "test")
  pbAssert.AreEqual(result.value, 42)
end

function tests.DecodeArray()
  local jsonStr = '[1, 2, 3, 4, 5]'
  local result = json.decode(jsonStr)
  pbAssert.IsNotNil(result)
  pbAssert.AreEqual(#result, 5)
  pbAssert.AreEqual(result[1], 1)
end

function tests.DecodeNestedObject()
  local jsonStr = '{"outer": {"inner": "value"}}'
  local result = json.decode(jsonStr)
  pbAssert.IsNotNil(result.outer)
  pbAssert.AreEqual(result.outer.inner, "value")
end

function tests.DecodeWithNull()
  local jsonStr = '{"key": null}'
  local result = json.decode(jsonStr)
  pbAssert.IsNotNil(result)
  pbAssert.IsNil(result.key)
end

function tests.DecodeWithBoolean()
  local jsonStr = '{"isTrue": true, "isFalse": false}'
  local result = json.decode(jsonStr)
  pbAssert.IsTrue(result.isTrue)
  pbAssert.IsFalse(result.isFalse)
end

function tests.DecodeWithString()
  local jsonStr = '{"message": "Hello, World!"}'
  local result = json.decode(jsonStr)
  pbAssert.AreEqual(result.message, "Hello, World!")
end

function tests.DecodeWithNumber()
  local jsonStr = '{"integer": 42, "float": 3.14}'
  local result = json.decode(jsonStr)
  pbAssert.AreEqual(result.integer, 42)
  pbAssert.AreEqual(result.float, 3.14)
end

function tests.DecodeEmptyObject()
  local jsonStr = '{}'
  local result = json.decode(jsonStr)
  pbAssert.IsNotNil(result)
end

function tests.DecodeEmptyArray()
  local jsonStr = '[]'
  local result = json.decode(jsonStr)
  pbAssert.IsNotNil(result)
  pbAssert.AreEqual(#result, 0)
end

return tests
