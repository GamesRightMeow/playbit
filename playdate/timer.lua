local module = {}
playdate.timer = module

local meta = {}
meta.__index = meta
module.__index = meta

local timers = {}
local timersToRemove = {}

function module.new(duration, startValue, ...)
  local f = nil
	local args = nil
	local endValue = nil
	local easingFunction = nil

	if type(startValue) == "function" then
		f = startValue
		if select("#", ...) > 0 then
			args = table.pack(...)
		end
		startValue = nil
	else
		endValue, easingFunction = select(1, ...)
	end

  local timer = setmetatable({}, meta)
  timer._remainingDelay = nil 
  timer._hasReversed = false

  timer.currentTime = 0
  timer.startValue = startValue or 0
	timer.endValue = endValue or 0
  timer.duration = duration
  timer.easingFunction = easingFunction or playdate.easingFunctions.linear
	timer.value = timer.startValue
	timer.active = true
	timer.delay = 0
	timer.paused = false
	timer.reverses = false
	timer.reverseEasingFunction = nil
	timer.repeats = false
	timer.discardOnCompletion = true
	timer.easingAmplitude = nil
	timer.easingPeriod = nil
	timer.updateCallback = nil
	timer.timerEndedCallback = f or nil
	timer.timerEndedArgs = args or nil

	timer.originalValues = {}
	timer.originalValues.startValue = timer.startValue
	timer.originalValues.endValue = timer.endValue
	timer.originalValues.easingFunction = timer.easingFunction

  table.insert(timers, timer)

  return timer
end

function module.performAfterDelay(delay, func, ...)
	error("not implemented!")
end

function module.keyRepeatTimerWithDelay(initialDelay, repeatDelay, func, ...)
  error("not implemented!")
end

function module.keyRepeatTimer(func, ...)
	error("not implemented!")
end

local function updateTimerValue(timer)
  if timer.startValue ~= timer.endValue and timer.duration ~= 0 then
    timer.value = timer.easingFunction(
      timer.currentTime, timer.startValue, timer.endValue - timer.startValue, 
      timer.duration, timer.easingAmplitude, timer.easingPeriod
    )
  else
    timer.value = timer.endValue
  end
end

local function updateTimer(timer)
  if not timer.updateCallback then
    return
  end

  if timer.timerEndedArgs then
    timer.updateCallback(table.unpack(timer.timerEndedArgs))
  else
    timer.updateCallback(timer)
  end
end

local function completeTimer(timer)
  if not timer.timerEndedCallback then
    return
  end

  if timer.timerEndedArgs then
    timer.timerEndedCallback(table.unpack(timer.timerEndedArgs))
  else
    timer.timerEndedCallback(timer)
  end
end

function module.updateTimers()
  local currentTime = playdate.getCurrentTimeMilliseconds()

  for i = 1, #timers do
    local timer = timers[i]

    if not timer.active or timer.paused then
      -- skip inactive timers
      goto continue
    end

    --[[
      Delta time should be calculated outside of the loop, not per timer. This causes an issue where paused timers that
      are later resumed suddenly jump forward. This is a bug in the PD SDK, so retaining it in Playbit until fixed
      https://devforum.play.date/t/playdate-timer-value-increases-between-calling-pause-and-start/2096/12
    ]]--
    local dt = 0
    if timer._lastTime then
      dt = currentTime - timer._lastTime
    end
    timer._lastTime = currentTime

    -- start delay
    if not timer._remainingDelay then 
      --[[
        remainingDelay is intially sent to nil so delay can be 
        set after the timer is created without having to call reset() afterwards
      ]]--
      timer._remainingDelay = timer.delay
    end
    if timer._remainingDelay > 0 then
      timer._remainingDelay = timer._remainingDelay - dt
      goto continue
    end

    -- update timer
    timer.currentTime = timer.currentTime + dt
    if timer.currentTime <= timer.duration then
      -- timer still running
      updateTimer(timer)
      updateTimerValue(timer)
      goto continue
    end

    -- timer complete
    if timer.reverses and not timer._hasReversed then
      -- reverse timer
      local temp = timer.startValue
      timer.startValue = timer.endValue
      timer.endValue = temp
      timer.currentTime = 0
      timer._remainingDelay = timer.delay

      if timer.reverseEasingFunction then
        timer.easingFunction = timer.reverseEasingFunction
      end

      -- so we don't reverse a second time (set repeats to true to do that)
      timer._hasReversed = true 
    elseif timer.repeats then
      -- repeat timer
      completeTimer(timer)

      local ct = timer.currentTime
      timer:reset()
      -- record that the callback was invoked while repeating
      timer._calledOnRepeat = true 
      -- continue off from where the timer ended so there isn't a huge gap on first tick
      timer.currentTime = ct - timer.duration 

      updateTimer(timer)
      updateTimerValue(timer)
    else
      -- complete timer
      timer.active = false
      timer.currentTime = timer.duration
      timer.value = timer.endValue

      -- when .repeats is true, then set to false, we shouldn't ever invoke the callback again
      if not timer._calledOnRepeat then
        completeTimer(timer)
      end

      if timer.discardOnCompletion then
        table.insert(timers, self)
      end
    end

    ::continue::
  end
  
  -- remove timers
  for i = 1, #timersToRemove do
		local index = table.indexOfElement(timers, timer)
		if index then 
			table.remove(timers, index)
		end
	end
	timersToRemove = {}
end

function module.allTimers()
	return timers
end

function meta:pause()
	self.paused = true
end

function meta:start()
	self.paused = false
end

function meta:reset()
	self.startValue = self.originalValues.startValue
	self.endValue = self.originalValues.endValue
	self.easingFunction = self.originalValues.easingFunction
	self.currentTime = 0
	self._lastTime = nil
	self.active = true
	self._hasReversed = false
	self._remainingDelay = self.delay
	self.value = self.startValue
	self._calledOnRepeat = nil
end

function meta:remove()
  self.active = false
	table.insert(timers, self)
end
