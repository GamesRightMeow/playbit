-- NOTE: this is almost the exact animation implementation copied from the Playdate SDK
-- with minor modifications and optimizations

playdate.timer = {}

-- private varables
local timers = {}
local timersToRemove = {}
local max = math.max

-- metatable - to support legacy playdate.timer variables, and other variables that need to do other work when being set
playdate.timer.__index = function(table, key)
	if key == "running" then
		return not table.paused
	elseif key == "currentTime" then
		return table._currentTime
	elseif key == "timeLeft" then
		return max(0, table.duration - table._currentTime)
	elseif key == "startValue" then
		return table._startValue
	elseif key == "endValue" then
		return table._endValue
	elseif key == "easingFunction" then
		return table._easingFunction
	else
		return rawget(playdate.timer, key)
	end
end

playdate.timer.__newindex = function(table, key, value)
	if key == "running" then
		table.paused = not value
	elseif key == "timeLeft" or key == "currentTime" then -- read-only variables
		print("ERROR: playdate.timer."..key.." is read-only.")
	elseif key == "startValue" then
		table._startValue = value
		table.originalValues.startValue = value
	elseif key == "endValue" then
		table._endValue = value
		table.originalValues.endValue = value
	elseif key == "easingFunction" then
		table._easingFunction = value
		table.originalValues.easingFunction = value
	else
		rawset(table, key, value)
	end
end


function playdate.timer:__tostring()
	local repeats
	if self.repeats then repeats = "true" else repeats = "false" end
	local reverses
	if self.reverses then reverses = "true" else reverses = "false" end
    return "playdate.timer(duration:" .. self.duration .. ", repeats: " .. repeats .. ", reverses: " .. reverses  .. ")"
end

-- duration is in milliseconds
-- playdate.timer.new(duration, startValue, endValue, easingFunction)
-- also allow playdate.timer.new(duration, f, args), where f is the timer ended callback, args are passed to the callback
function playdate.timer.new(duration, startValue, ...)

	assert(duration~=playdate.timer, 'Please use playdate.timer.new() instead of playdate.timer:new()')

	local f = nil
	local args = nil
	local endValue = nil
	local easingFunction = nil

	if type(startValue) == "function" then	-- playdate.timer.new(duration, f, args)
		f = startValue
		if select("#", ...) > 0 then
			args = table.pack(...)
		end
		startValue = nil
	else
		endValue, easingFunction = select(1, ...)
	end

	local o = {}
	setmetatable(o, playdate.timer)

	if not duration then print("playdate.timer.new() requires a duration"); return nil end

	o.duration = duration
	o._startValue = startValue or 0
	o._endValue = endValue or 0

	o._currentTime = 0
	o.value = o._startValue
	o.active = true
	o.delay = 0
	o.remainingDelay = nil
	o.paused = false
	o.reverses = false
	o.hasReversed = false
	o.reverseEasingFunction = nil
	o.repeats = false
	o.discardOnCompletion = true

	o._easingFunction = easingFunction or playdate.easingFunctions.linear
	o.easingAmplitude = nil
	o.easingPeriod = nil

	o.updateCallback = nil
	o.timerEndedCallback = f or nil
	o.timerEndedArgs = args or nil

	o.attributes = {}
	o.originalValues = {}
	o.originalValues.startValue = o._startValue
	o.originalValues.endValue = o._endValue
	o.originalValues.easingFunction = o._easingFunction

	timers[#timers+1] = o

	return o
end

-- timer:performAfterDelay(delay, func, [...])
-- params:
	-- delay: milliseconds until the function is fired
	-- func: the function to be called when the timer fires
	-- ...: optional list of parameters to func. If none are provided the timer will be passed as the single argument

function playdate.timer.performAfterDelay(delay, func, ...)
	assert(type(delay) == "number", "playdate.timer.performAfterDelay: 'delay' must be a number.")
	assert(type(func) == "function", "playdate.timer.performAfterDelay: 'callback' must be a function.")
	local timer = playdate.timer.new(delay)
	timer.timerEndedCallback = func
	if select("#", ...) > 0 then
		timer.timerEndedArgs = table.pack(...)
	end
	return timer
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

	-- print("func", initialDelay, repeatDelay, func)

	local function callCallback(timer)
		if func ~= nil then
			if timer.timerEndedArgs == nil then
				func(timer)
			else
				func(table.unpack(timer.timerEndedArgs))
			end
		end
	end

	local timer = playdate.timer.new(initialDelay)
	if select("#", ...) > 0 then
		timer.timerEndedArgs = table.pack(...)
	end
	timer.repeats = true

	-- call the callback function once immediately, then once after initialDelay milliseconds, then every repeatDelay milliseconds
	callCallback(timer)

	local function timerRemoved(timer)
		for i = 1, #timers do
			if timers[i] == timer then
				return false
			end
		end
		return true
	end

	local function initialTimerFired(...)

		callCallback(timer)

		if timerRemoved(timer) == false then
			timer.duration = repeatDelay
			timer._currentTime = repeatDelay
			timer.timerEndedCallback = func
		end
	end

	timer.timerEndedCallback = initialTimerFired

	return timer
end


-- timer:keyRepeatTimer(func, [...])
-- returns:
	-- a timer that calls a callback function at key-repeat intervals. Once immediately, then once after 0.3 seconds, then every 0.1 seconds
-- params:
	-- func: the function to be called when the timer fires
	-- ...: optional list of parameters to func. If none are provided the timer will be passed as the single argument

function playdate.timer.keyRepeatTimer(func, ...)
	return playdate.timer.keyRepeatTimerWithDelay(300, 100, func, ...)
end


function playdate.timer:pause()
	self.paused = true
end


function playdate.timer:start()
	self.paused = false
end

function playdate.timer:reset()
	self._startValue = self.originalValues.startValue
	self._endValue = self.originalValues.endValue
	self._easingFunction = self.originalValues.easingFunction
	self._currentTime = 0
	self._lastTime = nil
	self.active = true
	self.hasReversed = false
	self.remainingDelay = self.delay
	self.value = self._startValue
	self._calledOnRepeat = nil
end


function playdate.timer:remove()
	self.active = false
	self.discardOnCompletion = false -- in case this is being called from within the timer ended callback, don't remove the timer twice
	for i = 1, #timers do
		if timers[i] == self then
			timersToRemove[#timersToRemove+1] = self
			break
		end
	end
end


function playdate.timer.updateTimers()

	local currentTime = playdate.getCurrentTimeMilliseconds()


	local function updateActiveTimer(timer)

		if timer._startValue ~= timer._endValue and timer.duration ~= 0 then
			timer.value = timer._easingFunction(timer._currentTime, timer._startValue, timer._endValue - timer._startValue, timer.duration, timer.easingAmplitude, timer.easingPeriod)
		else
			timer.value = timer._endValue
		end

		if timer.updateCallback ~= nil then
			if timer.timerEndedArgs == nil then
				timer.updateCallback(timer)
			else
				timer.updateCallback(table.unpack(timer.timerEndedArgs))
			end
		end
	end


	for i = 1, #timers do

		local timer = timers[i]

		if timer.active == true and timer.paused == false then

			local dt = 0
			if timer._lastTime then
				dt = currentTime - timer._lastTime
			end
			timer._lastTime = currentTime
			
			if timer.remainingDelay == nil then		-- doing it this way so delay can be set after the timer is created without having to call reset() afterwards
				timer.remainingDelay = timer.delay
			end

			if timer.remainingDelay > 0 then
				timer.remainingDelay = timer.remainingDelay - dt
			else

				timer._currentTime = timer._currentTime + dt

				if timer._currentTime > timer.duration then
					
					local function callEndedCallback()
						if timer.timerEndedCallback ~= nil then
							if timer.timerEndedArgs == nil then
								timer.timerEndedCallback(timer)
							else
								timer.timerEndedCallback(table.unpack(timer.timerEndedArgs))
							end
						end
					end

					if timer.reverses and timer.hasReversed == false then

						local temp = timer._startValue
						timer._startValue = timer._endValue
						timer._endValue = temp
						timer._currentTime = 0
						timer.remainingDelay = timer.delay

						if timer.reverseEasingFunction ~= nil then
							timer._easingFunction = timer.reverseEasingFunction
						end

						timer.hasReversed = true -- so we don't reverse a second time (set repeats = true to do that)

					elseif timer.repeats then

						callEndedCallback()

						local ct = timer._currentTime
						timer:reset()
						timer._calledOnRepeat = true -- record that the callback was invoked while repeating
						timer._currentTime = ct - timer.duration -- so we don't get continues values rather than a hard reset and pause

						updateActiveTimer(timer)

					else

						timer.active = false
						timer._currentTime = timer.duration	-- end up on the max time
						timer.value = timer._endValue

						-- handle the case when .repeats is true, then false
						-- in that case, if the callback has been called and .repeats is set back to false
						-- we shouldn't ever call the callback again.
						if timer._calledOnRepeat ~= true then
							callEndedCallback()
						end

						if timer.discardOnCompletion == true then	-- remove the timer
							timersToRemove[#timersToRemove+1] = timer
						end
					end

				else	-- timer is active
					updateActiveTimer(timer)
				end
			end
		end	-- active timer
	end

	for _, timer in pairs( timersToRemove ) do
		local timerIndex = table.indexOfElement( timers, timer )
		if timerIndex then 
			table.remove( timers, timerIndex )
		end
	end

	timersToRemove = {}
end

function playdate.timer.allTimers()
	return timers
end
