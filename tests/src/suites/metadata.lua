local tests = {}

function tests.name()
  pbAssert.AreEqual(playdate.metadata.name, "Playbit Tests")
end

function tests.author()
  pbAssert.AreEqual(playdate.metadata.author, "Games Right Meow")
end

function tests.bundleID()
  pbAssert.AreEqual(playdate.metadata.bundleID, "com.gamesrightmeow.playbit-tests")
end

function tests.version()
  pbAssert.AreEqual(playdate.metadata.version, "1.0.0")
end

function tests.buildNumber()
  pbAssert.AreEqual(playdate.metadata.buildNumber, "1")
end

return tests