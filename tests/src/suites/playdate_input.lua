local tests = {}

function tests.Button_IsPressedAndReleased()
  love.keypressed("left")

  pbAssert.IsTrue(playdate.buttonJustPressed("left"))
  pbAssert.IsTrue(playdate.buttonIsPressed("left"))
  pbAssert.IsFalse(playdate.buttonJustReleased("left"))

  playdate._updateInput()

  pbAssert.IsFalse(playdate.buttonJustPressed("left"))
  pbAssert.IsTrue(playdate.buttonIsPressed("left"))
  pbAssert.IsFalse(playdate.buttonJustReleased("left"))

  love.keyreleased("left")

  pbAssert.IsFalse(playdate.buttonJustPressed("left"))
  pbAssert.IsFalse(playdate.buttonIsPressed("left"))
  pbAssert.IsTrue(playdate.buttonJustReleased("left"))

  playdate._updateInput()

  pbAssert.IsFalse(playdate.buttonJustPressed("left"))
  pbAssert.IsFalse(playdate.buttonIsPressed("left"))
  pbAssert.IsFalse(playdate.buttonJustReleased("left"))
end

function tests.GetButtonState_ReturnsZeroWithNoButtonsPressed()
  local current, justPressed, justReleased = playdate.getButtonState()
  pbAssert.AreEqual(current, 0)
  pbAssert.AreEqual(justPressed, 0)
  pbAssert.AreEqual(justReleased, 0)
end

function tests.GetButtonState_ReturnsCorrectBitMask()
  love.keypressed("left")
  playdate._updateInput()
  pbAssert.AreEqual(playdate.getButtonState(), 1)
  love.keyreleased("left")

  love.keypressed("right")
  playdate._updateInput()
  pbAssert.AreEqual(playdate.getButtonState(), 2)
  love.keyreleased("right")

  love.keypressed("up")
  playdate._updateInput()
  pbAssert.AreEqual(playdate.getButtonState(), 4)
  love.keyreleased("up")

  love.keypressed("down")
  playdate._updateInput()
  pbAssert.AreEqual(playdate.getButtonState(), 8)
  love.keyreleased("down")

  love.keypressed("s")
  playdate._updateInput()
  pbAssert.AreEqual(playdate.getButtonState(), 16)
  love.keyreleased("s")

  love.keypressed("a")
  playdate._updateInput()
  pbAssert.AreEqual(playdate.getButtonState(), 32)
  love.keyreleased("a")
  playdate._updateInput()
end

function tests.GetButtonState_ReturnsCombinedBitMask()
  love.keypressed("left")
  love.keypressed("right")
  playdate._updateInput()
  pbAssert.AreEqual(playdate.getButtonState(), 3)

  love.keyreleased("left")
  playdate._updateInput()
  pbAssert.AreEqual(playdate.getButtonState(), 2)
  love.keyreleased("right")
  playdate._updateInput()
end

function tests.GetButtonState_JustPressedAndJustReleased_AreCorrect()
  love.keypressed("left")
  local current, justPressed, justReleased = playdate.getButtonState()
  pbAssert.AreEqual(current, 1)
  pbAssert.AreEqual(justPressed, 1)
  pbAssert.AreEqual(justReleased, 0)

  playdate._updateInput()

  local current, justPressed, justReleased = playdate.getButtonState()
  pbAssert.AreEqual(current, 1)
  pbAssert.AreEqual(justPressed, 0)
  pbAssert.AreEqual(justReleased, 0)

  love.keyreleased("left")
  playdate._updateInput()
  local current, justPressed, justReleased = playdate.getButtonState()
  pbAssert.AreEqual(current, 0)
  pbAssert.AreEqual(justPressed, 0)
  pbAssert.AreEqual(justReleased, 0)
end

-- its not possible to run the input tests on PD since we cant simulate presses
return tests, "love2d"
