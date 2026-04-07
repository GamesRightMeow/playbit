local tests = {}

function tests.UUID_ReturnsValue()
  local uuid = playdate.string.UUID(8)
  pbAssert.IsNotNil(uuid)
  pbAssert.IsTrue(#uuid, 8)

  local uuid = playdate.string.UUID(32)
  pbAssert.IsTrue(#uuid, 32)
end

function tests.UUID_IsUpper()
  local uuid = playdate.string.UUID(8)
  for i=1, #uuid do
    local byte = string.byte(uuid)
    pbAssert.IsTrue(byte >= 65)
    pbAssert.IsTrue(byte <= 90)
  end
end

function tests.TrimWhitespace_WhitespaceIsTrimmed()
  local str = "  hello world  "
  local result = playdate.string.trimWhitespace(str)
  pbAssert.AreEqual(result, "hello world")
  pbAssert.AreNotEqual(result, str)
end

function tests.TrimLeadingWhitespace_WhitespaceIsTrimmed()
  local str = "  hello world  "
  local result = playdate.string.trimLeadingWhitespace(str)
  pbAssert.AreEqual(result, "hello world  ")
  pbAssert.AreNotEqual(result, str)
end

function tests.TrimTrailingWhitespace_WhitespaceIsTrimmed()
  local str = "  hello world  "
  local result = playdate.string.trimTrailingWhitespace(str)
  pbAssert.AreEqual(result, "  hello world")
  pbAssert.AreNotEqual(result, str)
end

return tests