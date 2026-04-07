local tests = {}

function tests.LoadReturnsFunction()
  local func = playdate.file.load("data/script")
  pbAssert.IsNotNil(func)
  pbAssert.AreEqual(func(), 100)
end

function tests.ListFilesContainsItems()
  local files = playdate.file.listFiles("/")
  pbAssert.IsTrue(#files > 0)
end

function tests.OpenForReading()
  local file = playdate.file.open("data/text.txt", playdate.file.kFileRead)
  pbAssert.IsNotNil(file)
  if file then file:close() end
end

function tests.OpenReturnsNilWhenTooManyOpen()
  -- Open many files to hit the limit of 64
  local files = {}
  for i = 1, 65 do
    local file = playdate.file.open("data/text.txt", playdate.file.kFileRead)
    if i == 65 then
      pbAssert.IsNil(file)
    else
      pbAssert.IsNotNil(file)
    end
    table.insert(files, file)
  end
  -- Clean up
  for i = 1, #files do
    if files[i] then files[i]:close() end
  end
end

function tests.Constants_AreCorrect()
  pbAssert.AreEqual(playdate.file.kFileRead, 3)
  pbAssert.AreEqual(playdate.file.kFileWrite, 4)
  pbAssert.AreEqual(playdate.file.kFileAppend, 8)
end

function tests.CanReadLine()
  local file = playdate.file.open("data/text.txt", playdate.file.kFileRead)
  local line = file:readline()
  pbAssert.AreEqual(line, "hello world!")
  file:close()
end

function tests.CanWrite()
  local path = "write.txt"
  local data = "test"
  local file, msg = playdate.file.open(path, playdate.file.kFileWrite)
  local success, msg = file:write(data)
  pbAssert.IsTrue(success)
  file:flush()
  file:close()

  local file = playdate.file.open(path, playdate.file.kFileRead)
  local line = file:readline()
  pbAssert.AreEqual(line, data)
end

function tests.ReadReturnsNilAtEOF()
  local file = playdate.file.open("data/text.txt", playdate.file.kFileRead)
  local line
  repeat
    line = file:readline()
  until not line
  pbAssert.IsNil(line)
  file:close()
end

function tests.CanReadBytes()
  local file = playdate.file.open("data/text.txt", playdate.file.kFileRead)
  local data = file:read(10)
  pbAssert.AreEqual(data, "hello worl")
  file:close()
end

function tests.GetSizeReturnsNumber()
  local size = playdate.file.getSize("data/text.txt")
  pbAssert.AreEqual(size, 58)
end

return tests
