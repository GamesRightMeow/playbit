local function name()
  pbAssert_IsEqual("Playbit Tests", playdate.metadata.name)
end

local function author()
  pbAssert_IsEqual("Games Right Meow", playdate.metadata.author)
end

local function bundleID()
  pbAssert_IsEqual("com.gamesrightmeow.playbit-tests", playdate.metadata.bundleID)
end

local function version()
  pbAssert_IsEqual("1.0.0", playdate.metadata.version)
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