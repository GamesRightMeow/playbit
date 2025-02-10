-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#C-frameTimer

local module = {}
playdate.frameTimer = module

module.value = nil
module.startValue = nil
module.endValue = nil
module.easingFunction = nil
module.easingAmplitude = nil
module.easingPeriod = nil
module.reverseEasingFunction = nil
module.delay = nil
module.discardOnCompletion = nil
module.duration = nil
module.frame = nil
module.repeats = nil
module.reverses = nil
module.timerEndedArgs = nil

-- duration is in frames
-- function playdate.frameTimer.new(duration, startValue, endValue, easingFunction)
-- function.frameTimer.new(duration, f, args), where f is the timer ended callback, args are passed to the callback
function module.new(duration, startValue, ...)
	error("[ERR] playdate.frameTimer.new() is not yet implemented.")
end

-- FrameTimer:performAfterDelay(delay, func, [...])
-- params:
	-- delay: frames until the function is fired
	-- func: the function to be called when the timer fires
	-- ...: optional list of parameters to func
function module.performAfterDelay(delay, func, ...)
	error("[ERR] playdate.frameTimer.performAfterDelay() is not yet implemented.")
end

function module:pause()
	error("[ERR] playdate.frameTimer.pause() is not yet implemented.")
end

function module:start()
	error("[ERR] playdate.frameTimer.start() is not yet implemented.")
end

function module:reset()
	error("[ERR] playdate.frameTimer.reset() is not yet implemented.")
end

function module:remove()
	error("[ERR] playdate.frameTimer.remove() is not yet implemented.")
end

function module.updateTimers()
	error("[ERR] playdate.frameTimer.updateTimers() is not yet implemented.")
end

function module.allTimers()
	error("[ERR] playdate.frameTimer.allTimers() is not yet implemented.")
end
