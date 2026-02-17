local function name()
  return pbAssert_IsTrue("Playbit Tests", playdate.metadata.name)
end

return {
  { "name", name },
}