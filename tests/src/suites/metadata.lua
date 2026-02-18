local function name()
  pbAssert.AreEqual(playdate.metadata.name, "Playbit Tests")
end

local function author()
  pbAssert.AreEqual(playdate.metadata.author, "Games Right Meow")
end

local function bundleID()
  pbAssert.AreEqual(playdate.metadata.bundleID, "com.gamesrightmeow.playbit-tests")
end

local function version()
  pbAssert.AreEqual(playdate.metadata.version, "1.0.0")
end

local function buildNumber()
  pbAssert.AreEqual(playdate.metadata.buildNumber, "1")
end

return {
  { "name", name },
  { "author", author },
  { "bundleID", bundleID },
  { "version", version },
  { "buildNumber", buildNumber },
}