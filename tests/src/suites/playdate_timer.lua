local tests = {}

function tests.IsCreated()
  local timer = playdate.timer.new(1000)
  pbAssert.IsNotNil(timer)
end

function tests.HasCorrectDuration()
  local duration = 5000
  local timer = playdate.timer.new(duration)
  pbAssert.AreEqual(timer.duration, duration)
end

function tests.HasCorrectStartValue()
  local startValue = 10
  local timer = playdate.timer.new(1000, startValue, 20)
  pbAssert.AreEqual(timer.startValue, startValue)
end

function tests.HasCorrectEndValue()
  local endValue = 100
  local timer = playdate.timer.new(1000, 0, endValue)
  pbAssert.AreEqual(timer.endValue, endValue)
end

function tests.StartsActive()
  local timer = playdate.timer.new(1000)
  pbAssert.IsTrue(timer.active)
end

function tests.CanBePaused()
  local timer = playdate.timer.new(1000)
  timer:pause()
  pbAssert.IsTrue(timer.paused)
end

function tests.CanBeResumed()
  local timer = playdate.timer.new(1000)
  timer:pause()
  timer:start()
  pbAssert.IsFalse(timer.paused)
end

function tests.CanBeRemoved()
  local timer = playdate.timer.new(1000)
  timer:remove()
  pbAssert.IsFalse(timer.active)
end

function tests.CanBeReset()
  local timer = playdate.timer.new(1000, 0, 100)
  timer.currentTime = 500
  timer.value = 50
  timer:reset()
  pbAssert.AreEqual(timer.currentTime, 0)
  pbAssert.AreEqual(timer.value, timer.startValue)
end

function tests.CanReverse()
  local timer = playdate.timer.new(1000)
  timer.reverses = true
  pbAssert.IsTrue(timer.reverses)
end

function tests.CanRepeat()
  local timer = playdate.timer.new(1000)
  timer.repeats = true
  pbAssert.IsTrue(timer.repeats)
end

function tests.CanHaveDelay()
  local delayMs = 500
  local timer = playdate.timer.new(1000)
  timer.delay = delayMs
  pbAssert.AreEqual(timer.delay, delayMs)
end

function tests.DiscardOnCompletionDefault()
  local timer = playdate.timer.new(1000)
  pbAssert.IsTrue(timer.discardOnCompletion)
end

function tests.LinearEasingFunction()
  local timer = playdate.timer.new(1000, 0, 100, playdate.easingFunctions.linear)
  pbAssert.AreEqual(timer.easingFunction, playdate.easingFunctions.linear)
end

function tests.InQuadEasingFunction()
  local timer = playdate.timer.new(1000, 0, 100, playdate.easingFunctions.inQuad)
  pbAssert.AreEqual(timer.easingFunction, playdate.easingFunctions.inQuad)
end

function tests.OutQuadEasingFunction()
  local timer = playdate.timer.new(1000, 0, 100, playdate.easingFunctions.outQuad)
  pbAssert.AreEqual(timer.easingFunction, playdate.easingFunctions.outQuad)
end

function tests.AllTimersReturnsTable()
  playdate.timer.new(1000)
  local allTimers = playdate.timer.allTimers()
  pbAssert.IsNotNil(allTimers)
end

function tests.MultipleTimersCanCoexist()
  local timer1 = playdate.timer.new(1000)
  local timer2 = playdate.timer.new(2000)
  local allTimers = playdate.timer.allTimers()
  pbAssert.IsTrue(#allTimers >= 2)
end

function tests.UpdateIncrementsCurrentTime()
  local timer = playdate.timer.new(1000, 0, 100)
  local initialTime = timer.currentTime
  playdate.timer.updateTimers()
  pbAssert.IsTrue(timer.currentTime >= initialTime)
end

return tests
