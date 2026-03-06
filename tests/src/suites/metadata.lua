local tests = {}

function tests.Name_HasValue()
  pbAssert.AreEqual(playdate.metadata.name, "Playbit Tests")
end

function tests.Author_HasValue()
  pbAssert.AreEqual(playdate.metadata.author, "Games Right Meow")
end

function tests.BundleID_HasValue()
  pbAssert.AreEqual(playdate.metadata.bundleID, "com.gamesrightmeow.playbit-tests")
end

function tests.Version_HasValue()
  pbAssert.AreEqual(playdate.metadata.version, "1.0.0")
end

function tests.BuildNumber_HasValue()
  pbAssert.AreEqual(playdate.metadata.buildNumber, "1")
end

return tests