local module = {}
playdate.timer = module

function playdate.timer.new(duration, startValue, ...)
  error("not implemented!")
end

-- timer:performAfterDelay(delay, func, [...])
-- params:
	-- delay: milliseconds until the function is fired
	-- func: the function to be called when the timer fires
	-- ...: optional list of parameters to func. If none are provided the timer will be passed as the single argument
function playdate.timer.performAfterDelay(delay, func, ...)
	error("not implemented!")
end

-- timer:keyRepeatTimer(delay, func, [...])
-- returns:
	-- a timer that calls a callback function at key-repeat intervals. Once immediately, then once after `initialDelay` milliseconds, then every `repeatDelay milliseconds
-- params:
	-- initialDelay: the delay before the first repeated callback is fired
	-- repeatDelay: the delay before each subsequent repeated callback is fired
	-- func: the function to be called when the timer fires
	-- ...: optional list of parameters to func. If none are provided the timer will be passed as the single argument
function playdate.timer.keyRepeatTimerWithDelay(initialDelay, repeatDelay, func, ...)
  error("not implemented!")
end

-- timer:keyRepeatTimer(func, [...])
-- returns:
	-- a timer that calls a callback function at key-repeat intervals. Once immediately, then once after 0.3 seconds, then every 0.1 seconds
-- params:
	-- func: the function to be called when the timer fires
	-- ...: optional list of parameters to func. If none are provided the timer will be passed as the single argument

function playdate.timer.keyRepeatTimer(func, ...)
	error("not implemented!")
end

function playdate.timer:pause()
	error("not implemented!")
end

function playdate.timer:start()
	error("not implemented!")
end

function playdate.timer:reset()
	error("not implemented!")
end

function playdate.timer:remove()
	error("not implemented!")
end

function playdate.timer.updateTimers()
  error("not implemented!")
end

function playdate.timer.allTimers()
	error("not implemented!")
end
