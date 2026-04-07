local tests = {}

function tests.IsLoaded()
  local img = playdate.graphics.image.new("images/playbit-logo")
  pbAssert.IsNotNil(img)
end

function tests.IsCreated()
  local img = playdate.graphics.image.new(8, 24)
  pbAssert.IsNotNil(img)
end

function tests.GetSize_ReturnsSize()
  local img1 = playdate.graphics.image.new(8, 24)
  local width1, height1 = img1:getSize()
  local img2 = playdate.graphics.image.new("images/playbit-logo")
  local width2, height2 = img2:getSize()
  pbAssert.AreEqual(width1, 8)
  pbAssert.AreEqual(height1, 24)
  pbAssert.AreEqual(width2, 400)
  pbAssert.AreEqual(height2, 240)
end

function tests.IsDrawn()
  local img = playdate.graphics.image.new("images/playbit-logo")
  img:draw(0, 0)
  pbAssert.IsImageSimilar()
end

function tests.IsDrawn_Unflipped()
  local img = playdate.graphics.image.new("images/playbit-logo")
  img:draw(0, 0, playdate.graphics.kImageUnflipped)
  pbAssert.IsImageSimilar()
end

function tests.IsDrawn_FlippedX()
  local img = playdate.graphics.image.new("images/playbit-logo")
  img:draw(0, 0, playdate.graphics.kImageFlippedX)
  pbAssert.IsImageSimilar()
end

function tests.IsDrawn_FlippedY()
  local img = playdate.graphics.image.new("images/playbit-logo")
  img:draw(0, 0, playdate.graphics.kImageFlippedY)
  pbAssert.IsImageSimilar()
end

function tests.IsDrawn_FlippedXY()
  local img = playdate.graphics.image.new("images/playbit-logo")
  img:draw(0, 0, playdate.graphics.kImageFlippedXY)
  pbAssert.IsImageSimilar()
end

function tests.IsDrawn_WithSourceRect()
  local img = playdate.graphics.image.new("images/playbit-logo")
  img:draw(100, 100, playdate.graphics.kImageUnflipped, 100, 120, 300, 8)
  pbAssert.IsImageSimilar()
end

function tests.IsDrawn_Rotated()
  local img = playdate.graphics.image.new("images/playbit-logo")
  img:drawRotated(200, 120, 90)
  pbAssert.IsImageSimilar("90")
  img:drawRotated(200, 120, 111)
  pbAssert.IsImageSimilar("111")
end

function tests.IsDrawn_Scaled()
  local img = playdate.graphics.image.new("images/playbit-logo")
  img:drawScaled(0, 0, 0.5)
  pbAssert.IsImageSimilar("half")
  img:drawScaled(-200, -120, 2)
  pbAssert.IsImageSimilar("double")
end

return tests