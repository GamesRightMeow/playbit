local module = {}
playdate.frameTimer = module

-- duration is in frames
-- function playdate.frameTimer.new(duration, startValue, endValue, easingFunction)
-- function.frameTimer.new(duration, f, args), where f is the timer ended callback, args are passed to the callback
function module.new(duration, startValue, ...)
	error("not implemented!")
end

-- FrameTimer:performAfterDelay(delay, func, [...])
-- params:
	-- delay: frames until the function is fired
	-- func: the function to be called when the timer fires
	-- ...: optional list of parameters to func
function module.performAfterDelay(delay, func, ...)
	error("not implemented!")
end

function module:pause()
	error("not implemented!")
end

function module:start()
	error("not implemented!")
end

function module:reset()
	error("not implemented!")
end

function module:remove()
	error("not implemented!")
end

function module.updateTimers()
	error("not implemented!")
end

function module.allTimers()
	error("not implemented!")
end
