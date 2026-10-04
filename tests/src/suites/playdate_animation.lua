local tests = {}

function tests.Loop_IsCreated()
  local img = playdate.graphics.imagetable.new("images/pie-fill")
  local loop = playdate.graphics.animation.loop.new(1, img, true)
  pbAssert.IsNotNil(loop)
end

function tests.Loop_CorrectImageIsReturned()
  local img = playdate.graphics.imagetable.new("images/pie-fill")
  local loop = playdate.graphics.animation.loop.new(1, img, true)
  pbAssert.AreEqual(loop:image(), img:getImage(1))
  loop.frame = 3
  pbAssert.AreEqual(loop:image(), img:getImage(3))
end

function tests.Loop_IsDrawn()
  -- set custom time function so we dont need to wait real time
  local time = 1
  local oldFunc = playdate.getCurrentTimeMilliseconds
  playdate.getCurrentTimeMilliseconds = function ()
    return time
  end

  local img = playdate.graphics.imagetable.new("images/pie-fill")
  local loop = playdate.graphics.animation.loop.new(1, img, true)
  local len = img:getLength()
  local width = img:getImage(1):getSize()
  for i=1, len do
    time = time + 1
    loop:draw(i * width, 1, playdate.graphics.kImageUnflipped)
  end
  pbAssert.IsImageSimilar()
  
  playdate.getCurrentTimeMilliseconds = oldFunc
end

function tests.Loop_IsValid_WhenLooping_IsAlwaysTrue()
  local img = playdate.graphics.imagetable.new("images/pie-fill")
  local loop = playdate.graphics.animation.loop.new(1, img, true)
  local len = img:getLength() + 5
  for i=1, len do
    pbAssert.IsTrue(loop:isValid())
  end
end

function tests.Loop_IsValid_WhenPlaying_IsTrue()
  local img = playdate.graphics.imagetable.new("images/pie-fill")
  local loop = playdate.graphics.animation.loop.new(1, img, false)
  local len = img:getLength()
  for i=1, len do
    loop.frame = i
    pbAssert.IsTrue(loop:isValid())
  end
end

-- TODO: isvalid is not working, revisit when PR is merged https://github.com/GamesRightMeow/playbit/pull/98
-- function tests.Loop_IsValid_WhenComplete_IsFalse()
--   local img = playdate.graphics.imagetable.new("images/pie-fill")
--   local loop = playdate.graphics.animation.loop.new(1, img, false)
--   local len = img:getLength()
--   loop.frame = len + 2
--   pbAssert.IsFalse(loop:isValid())
-- end

-- TODO: frame is not capped to table image length

return tests