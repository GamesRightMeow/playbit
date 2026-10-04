local tests = {}

function tests.ReadAndWritesData()
  local writeData = {
    string_value = "hello world",
    int_value = 90,
    bool_value = false,
  }
  playdate.datastore.write(writeData, "ReadAndWritesData")
  local readData = playdate.datastore.read("ReadAndWritesData")
  pbAssert.AreEqual(writeData.string_value, readData.string_value)
  pbAssert.AreEqual(writeData.int_value, readData.int_value)
  pbAssert.AreEqual(writeData.bool_value, readData.bool_value)
end

function tests.DefaultFilenameIsUsed()
  -- explicitly write some old data we don't want to see
  playdate.datastore.write({ value = "old" }, "data")
  -- now write new data to make sure its overridden
  playdate.datastore.write({ value = "new" })
  local readDefault = playdate.datastore.read()
  local readExplicit = playdate.datastore.read("data")
  pbAssert.AreEqual(readDefault.value, "new")
  pbAssert.AreEqual(readExplicit.value, "new")
end

function tests.FileIsDeleted()
  playdate.datastore.write({ value = "hello!" }, "FileIsDeleted")
  pbAssert.IsNotNil(playdate.datastore.read("FileIsDeleted"))
  playdate.datastore.delete("FileIsDeleted")
  pbAssert.IsNil(playdate.datastore.read("FileIsDeleted"))
end

return tests