local tests = {}

function tests.GetSampleRateIsCorrect()
  local sampleRate = playdate.sound.getSampleRate()
  pbAssert.AreEqual(sampleRate, 44100.0)
end

function tests.SamplePlayerIsCreated()
  local player = playdate.sound.sampleplayer.new("sounds/playbit-startup")
  pbAssert.IsNotNil(player)
end

function tests.SamplePlayerCanStop()
  local player = playdate.sound.sampleplayer.new("sounds/playbit-startup")
  player:play()
  player:stop()
  pbAssert.IsFalse(player:isPlaying())
end

function tests.SamplePlayerIsPlayingWhenPlayed()
  local player = playdate.sound.sampleplayer.new("sounds/playbit-startup")
  player:play()
  pbAssert.IsTrue(player:isPlaying())
end

function tests.SamplePlayerCanSetVolume()
  local player = playdate.sound.sampleplayer.new("sounds/playbit-startup")
  player:setVolume(0.5)
  pbAssert.AreEqual(player:getVolume(), 0.5)
end

function tests.SamplePlayerCanGetVolume()
  local player = playdate.sound.sampleplayer.new("sounds/playbit-startup")
  local volume = player:getVolume()
  pbAssert.IsNotNil(volume)
end

function tests.SamplePlayerCanSetRate()
  local player = playdate.sound.sampleplayer.new("sounds/playbit-startup")
  player:setRate(1.5)
  pbAssert.AreEqual(player:getRate(), 1.5)
end

function tests.FilePlayerIsCreated()
  local player = playdate.sound.fileplayer.new("sounds/playbit-startup")
  pbAssert.IsNotNil(player)
end

function tests.FilePlayerCanStop()
  local player = playdate.sound.fileplayer.new("sounds/playbit-startup")
  player:play()
  player:stop()
  pbAssert.IsFalse(player:isPlaying())
end

function tests.FilePlayerCanPause()
  local player = playdate.sound.fileplayer.new("sounds/playbit-startup")
  player:play()
  player:pause()
  pbAssert.IsFalse(player:isPlaying())
end

function tests.FilePlayerCanSetVolume()
  local player = playdate.sound.fileplayer.new("sounds/playbit-startup")
  player:setVolume(0.5)
  local vol = player:getVolume()
  pbAssert.AreEqual(vol, 0.5)
end

function tests.FilePlayerCanSetRate()
  local player = playdate.sound.fileplayer.new("sounds/playbit-startup")
  player:setRate(1.2)
  --[[ TODO: seems to be a rounding error in love 2d? this returns 1.2000000476837
  As a work around, round the number to just check its in the ballpark ]]--
  local result = math.floor(player:getRate() * 10) / 10
  pbAssert.AreEqual(result, 1.2)
end

function tests.FilePlayerCanGetLength()
  local player = playdate.sound.fileplayer.new("sounds/playbit-startup")
  local length = player:getLength()
  pbAssert.IsNotNil(length)
end

return tests
