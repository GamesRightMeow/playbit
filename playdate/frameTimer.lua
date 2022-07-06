-- NOTE: this is almost the exact animation implementation copied from the Playdate SDK
-- with minor modifications and optimizations

playdate.frameTimer = {}

local frameTimers = {}
local timersToRemove = {}

-- metatable
playdate.frameTimer.__index = function(table, key)
	if key == "frame" then
		return table._frame		
	elseif key == "framesLeft" then
		return table.duration - table._frame
	elseif key == "startValue" then
		return table._startValue
	elseif key == "endValue" then
		return table._endValue
	elseif key == "easingFunction" then
		return table._easingFunction
	else
		return rawget(playdate.frameTimer, key)
	end
end

playdate.frameTimer.__newindex = function(table, key, value)
	if key == "frame" or key == "framesLeft" then -- read-only variables
		print("ERROR: playdate.frameTimer."..key.." is read-only.")
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


-- duration is in frames
-- function playdate.frameTimer.new(duration, startValue, endValue, easingFunction)
-- function.frameTimer.new(duration, f, args), where f is the timer ended callback, args are passed to the callback
function playdate.frameTimer.new(duration, startValue, ...)
	
	assert(duration~=playdate.frameTimer, 'Please use playdate.frameTimer.new() instead of playdate.frameTimer:new()')
	
	local f = nil
	local args = nil
	local endValue = nil
	local easingFunction = nil
	

	if type(startValue) == "function" then	-- playdate.frameTimer.new(duration, f, args)
		f = startValue
		if select("#", ...) > 0 then
			args = table.pack(...)
		end
		startValue = nil
	else
		endValue, easingFunction = select(1, ...)
	end
	
	o = {}
	setmetatable(o, playdate.frameTimer)
	
	if not duration then print("playdate.frameTimer.new() requires a duration"); return nil end
	
	o.duration = duration
	o._startValue = startValue or 0
	o._endValue = endValue or 0
	
	o._frame = 0
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
	
	frameTimers[#frameTimers+1] = o
	
	return o
end


-- FrameTimer:performAfterDelay(delay, func, [...])
-- params:
	-- delay: frames until the function is fired
	-- func: the function to be called when the timer fires
	-- ...: optional list of parameters to func
function playdate.frameTimer.performAfterDelay(delay, func, ...)
	local timer = playdate.frameTimer.new(delay)
	timer.timerEndedCallback = func
	if select("#", ...) > 0 then
		timer.timerEndedArgs = table.pack(...)
	end
	return timer
end


function playdate.frameTimer:pause()
	self.paused = true
end


function playdate.frameTimer:start()
	self.paused = false
end


function playdate.frameTimer:reset()
	self._startValue = self.originalValues.startValue
	self._endValue = self.originalValues.endValue
	self._easingFunction = self.originalValues.easingFunction
	self._frame = 0
	self.active = true
	self.hasReversed = false
	self.remainingDelay = self.delay
	self.value = self._startValue
end

function playdate.frameTimer:remove()
	self.active = false
	self.discardOnCompletion = false -- in case this is being called from within the timer ended callback, don't remove the timer twice
	for i = 1, #frameTimers do
		if frameTimers[i] == self then
			timersToRemove[#timersToRemove+1] = self
			break
		end
	end
end


function playdate.frameTimer.updateTimers()
	
	local function updateActiveTimer(timer)
		
		if timer._startValue ~= timer._endValue and timer.duration ~= 0 then						
			timer.value = timer._easingFunction(timer._frame, timer._startValue, timer._endValue - timer._startValue, timer.duration, timer.easingAmplitude, timer.easingPeriod)
		else
			timer.value = timer._endValue
		end
		
		if timer.updateCallback ~= nil then
			timer.updateCallback(timer)
		end	
	end
	
	
	for i = 1, #frameTimers do

		local timer = frameTimers[i]
		
		if timer.active == true and timer.paused == false then
			
			if timer.remainingDelay == nil then		-- doing it this way so delay can be set after the timer is created without having to call reset() afterwards
				timer.remainingDelay = timer.delay
			end
			
			if timer.remainingDelay > 0 then
				timer.remainingDelay = timer.remainingDelay - 1
			else
			
				timer._frame = timer._frame + 1
				
				if timer._frame > timer.duration then
					
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
						timer._frame = 0
						timer.remainingDelay = timer.delay
						
						if timer.reverseEasingFunction ~= nil then
							timer._easingFunction = timer.reverseEasingFunction
						end
						
						timer.hasReversed = true -- so we don't reverse a second time (set repeats = true to do that)
						
					elseif timer.repeats then
						
						callEndedCallback()
						timer:reset()
						updateActiveTimer(timer)
						
					else
						
						timer.active = false
						timer._frame = timer._frame - 1	-- end up on the max frame instead of one past
				
						if timer.discardOnCompletion == true then	-- remove the timer
							timersToRemove[#timersToRemove+1] = timer
						end
						
						callEndedCallback()
					end
					
				else	-- timer is active
					updateActiveTimer(timer)
				end
			end
		end	-- active timer
	end
	
	for _, timer in pairs( timersToRemove ) do
		local timerIndex = table.indexOfElement( frameTimers, timer )
		if timerIndex then 
			table.remove( frameTimers, timerIndex )
		end
	end

	timersToRemove = {}
	
end

function playdate.frameTimer.allTimers()
	return frameTimers
end
