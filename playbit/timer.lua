local module = {}
playbit = playbit or {}
playbit.timer = module

local meta = {}
meta.__index = meta
module.__index = meta

local timers = {}
local timerCount = 0

module.IND_ACTIVE = 1
module.IND_TIME = 2
module.IND_DURATION = 3
module.IND_VALUE = 4
module.IND_START_VALUE = 5
module.IND_END_VALUE = 6
module.IND_EASING_FUNCTION = 7
module.IND_EASING_AMPLITUDE = 8
module.IND_EASING_PERIOD = 9
module.IND_TO_REMOVE = 10
module.IND_COMPLETE = 11
module.IND_REPEATS = 12
module.IND_HAS_EASING = 13
module.IND_REMOVED = 14

---Creates and automatically starts a new timer. Timers are stored as contiguous arrays for faster updates.
---@param duration number Duration the timer should run. 
---@param repeats boolean Optional. Defaults to false. If true, the timer will repeat when it completes indefinitely.
---@param startValue number Optional. Defaults to 1. The starting value to interpolate from.
---@param endValue number Optional. Defaults to 1. The ending value to interpolate to.
---@param easingFunction function Optional. Defaults to easingFunctions.linear. The function used to interpolate between the startValue and endValue.
---@return table The new timer.
function module.new(duration, repeats, startValue, endValue, easingFunction)
  local timer = {}
  timer[module.IND_ACTIVE] = true
  timer[module.IND_REPEATS] = repeats or false
  timer[module.IND_TIME] = 0
  timer[module.IND_DURATION] = duration
  timer[module.IND_VALUE] = startValue or 0
  timer[module.IND_START_VALUE] = startValue or 0
  timer[module.IND_END_VALUE] = endValue or 1
  timer[module.IND_HAS_EASING] = startValue and endValue
  timer[module.IND_EASING_FUNCTION] = easingFunction or playdate.easingFunctions.linear
  timer[module.IND_EASING_AMPLITUDE] = nil
  timer[module.IND_EASING_PERIOD] = nil
  timer[module.IND_TO_REMOVE] = false
  timer[module.IND_REMOVED] = false
  timer[module.IND_COMPLETE] = false
  setmetatable(timer, meta)
  timerCount = timerCount + 1
  timers[timerCount] = timer
  return timer
end

---Call in playdate.update to tick all timers.
---@param dt number The time elapsed since the last frame.
function module.update(dt)
  for i = timerCount, 1, -1 do
    local timer = timers[i]

    if timer[module.IND_TO_REMOVE] then
      table.remove(timers, i)
      timerCount = timerCount - 1
      timer[module.IND_REMOVED] = true
      goto continue
    end

    if not timer[module.IND_ACTIVE] then
      goto continue
    end

    local time = timer[module.IND_TIME]
    local duration = timer[module.IND_DURATION]
    local startValue = timer[module.IND_START_VALUE]
    local endValue = timer[module.IND_END_VALUE]

    timer[module.IND_COMPLETE] = false
    if time == duration then
      if timer[module.IND_REPEATS] then
        timer[module.IND_TIME] = 0
        timer[module.IND_VALUE] = startValue
      else
        timer[module.IND_ACTIVE] = false
        timer[module.IND_TO_REMOVE] = true
      end
      -- always flag as complete so that repeating timers are at least complete for one frame
      timer[module.IND_COMPLETE] = true
      goto continue
    end

    time = time + dt
    
    local value = 0
    if timer[module.IND_HAS_EASING] then
      value = timer[module.IND_EASING_FUNCTION](
        time, startValue, endValue - startValue, duration,
        timer[module.IND_EASING_AMPLITUDE], timer[module.IND_EASING_PERIOD]
      )
    else
      value = time / duration
    end

    if time > duration then
      time = duration
      value = endValue
    end

    timer[module.IND_TIME] = time
    timer[module.IND_VALUE] = value

    ::continue::
  end
end

---Returns all active timers.
---@return table
function module.allTimers()
  return timers
end

---Removes all active timers.
function module.removeAll()
  timers = {}
  timerCount = 0
end

---Returns the specified property. Use the raw int value, or one of the IND_ constants e.g. `myTimer:getValue(playbit.timer.IND_ACTIVE)`.
---@param index number
---@return unknown
function meta:getValue(index)
  return self[index]
end

---Resets the timer back to zero, but does not pause the timer. If the timer has already completed, you'll need to call start()
function meta:reset()
  self[module.IND_ACTIVE] = true
  self[module.IND_TIME] = 0
  self[module.IND_VALUE] = self[module.IND_START_VALUE] or 0
  self[module.IND_COMPLETE] = false
end

---Pauses the timer.
function meta:pause()
  self[module.IND_ACTIVE] = false
end

---Starts/resumes the timer.
function meta:start()
  self[module.IND_ACTIVE] = true
  if self[module.IND_REMOVED] then
    self[module.IND_TO_REMOVE] = false
    self[module.IND_REMOVED] = false
    timerCount = timerCount + 1
    timers[timerCount] = self
  end
end

---Marks the timer for removal in the next update. This is normally automatically done when the timer is completed.
function meta:remove()
  self[module.IND_TO_REMOVE] = true
  self[module.IND_REMOVED] = true
end