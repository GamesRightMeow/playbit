-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#C-graphics.animator

require("playdate.easing")

playdate.graphics = playdate.graphics or {}

local module = {}
playdate.graphics.animator = module

local meta = {}
meta.__index = meta
module.__index = meta

local function normalizeTime(anim, t)
  t = t - anim._startTimeOffset

  if t < 0 then
    return 0, false
  end

  local dur = anim._duration
  if anim.reverses then
    dur = dur * 2
  end

  local repeats = math.floor(t / dur)

  t = t % dur

  if t > anim._duration then
    t = 2 * anim._duration - t
  end

  if not anim.repeats and anim.repeatCount >= 0 and repeats > anim.repeatCount then
    if anim.reverses then
      return 0, true
    else
      return anim._duration, true
    end
  end

  return t, false
end

local function updateAnimator(anim)
  if not anim._ended then
    local t = playdate.getCurrentTimeMilliseconds() - anim._startTime
    anim._currentTime, anim._ended = normalizeTime(anim, t)
  end
end

local function getValueForNumbers(anim, time)
  return anim._easingFunction(time, anim._startValue, anim._endValue - anim._startValue, anim._duration)
end

local function getValueForPoints(anim, time)
  local startValue = anim._startValue
  local endValue = anim._endValue
  local x = anim._easingFunction(time, startValue.x, endValue.x - startValue.x, anim._duration)
  local y = anim._easingFunction(time, startValue.y, endValue.y - startValue.y, anim._duration)
  return playdate.geometry.point.new(x, y)
end

local function getValueForLineSegment(anim, time)
  local lineSegment = anim._lineSegment
  local dist = anim._easingFunction(time, 0, lineSegment:length(), anim._duration, anim.s or anim.easingAmplitude,
    anim.easingPeriod)
  return lineSegment:pointOnLine(dist, true)
end

local function getValueForArc(anim, time)
  local arc = anim._arc
  local dist = anim._easingFunction(time, 0, arc:length(), anim._duration, anim.s or anim.easingAmplitude,
    anim.easingPeriod)
  return arc:pointOnArc(dist, true)
end

local function getValueForPolygon(anim, time)
  local polygon = anim._polygon
  local dist = anim._easingFunction(time, 0, polygon:length(), anim._duration, anim.s or anim.easingAmplitude,
    anim.easingPeriod)
  return polygon:pointOnPolygon(dist, true)
end

local function getValueForPart(part, dist)
  if part._type == "lineSegment" then
    return part:pointOnLine(dist, true)
  elseif part._type == "arc" then
    return part:pointOnArc(dist, true)
  elseif part._type == "polygon" then
    return part:pointOnPolygon(dist, true)
  end
end

local function getValueForParts(anim, time)
  local parts = anim._parts
  local lengths = anim._lengths
  local dist = anim._easingFunction(time, 0, anim._totalLength, anim._duration, anim.s or anim.easingAmplitude, anim.easingPeriod)

  local i = 1
  while i < #parts and dist > lengths[i] do
    i = i + 1
  end

  local part = parts[i]
  local dist = dist - (lengths[i - 1] or 0)

  return getValueForPart(part, dist)
end

local function getValueForPartsWithDurations(anim, time)
  local parts = anim._parts
  local lengths = anim._lengths
  local durations = anim._durations

  local i = 1
  while time > durations[i] do
    time = time - durations[i]
    i = i + 1
  end

  local part = parts[i]
  local easingFunction = anim._easingFunctions[i]
  local dist = easingFunction(time, 0, part:length(), durations[i], anim.s or anim.easingAmplitude, anim.easingPeriod)

  return getValueForPart(part, dist)
end


local function newAnimator(duration, easingFunction, startTimeOffset)
  local anim = setmetatable({}, meta)
  anim._duration = duration
  anim._startTime = playdate.getCurrentTimeMilliseconds()
  anim._startTimeOffset = startTimeOffset or 0
  anim._easingFunction = easingFunction or playdate.easingFunctions.linear

  anim.repeatCount = 0
  anim.reverses = false
  anim.easingAmplitude = nil
  anim.easingPeriod = nil
  return anim
end

local function newAnimatorFromNumber(duration, startValue, endValue, easingFunction, startTimeOffset)
  local anim = newAnimator(duration, easingFunction, startTimeOffset)
  anim._startValue = startValue
  anim._endValue = endValue
  anim._getValue = getValueForNumbers
  return anim
end

local function newAnimatorFromPoints(duration, startValue, endValue, easingFunction, startTimeOffset)
  local anim = newAnimator(duration, easingFunction, startTimeOffset)
  anim._startValue = startValue
  anim._endValue = endValue
  anim._getValue = getValueForNumbers
  return anim
end

local function newAnimatorFromLineSegment(duration, lineSegment, easingFunction, startTimeOffset)
  local anim = newAnimator(duration, easingFunction, startTimeOffset)
  anim._lineSegment = lineSegment
  anim._getValue = getValueForLineSegment
  return anim
end

local function newAnimatorFromArc(duration, arc, easingFunction, startTimeOffset)
  local anim = newAnimator(duration, easingFunction, startTimeOffset)
  anim._arc = arc
  anim._getValue = getValueForArc
  return anim
end

local function newAnimatorFromPolygon(duration, polygon, easingFunction, startTimeOffset)
  local anim = newAnimator(duration, easingFunction, startTimeOffset)
  anim._polygon = polygon
  anim._getValue = getValueForPolygon
  return anim
end

local function calculatePartsLength(parts)
  local totalLength = 0
  local lengths = {}
  for i = 1, #parts do
    local part = parts[i]
    totalLength = totalLength + part:length()
    lengths[i] = totalLength
  end
  return lengths, totalLength
end

local function newAnimatorFromPartsWithDurations(durations, parts, easingFunctions, startTimeOffset)
  assert(#durations == #parts)
  assert(#easingFunctions == #parts)

  local totalDuration = 0
  for i = 1, #durations do
    totalDuration = totalDuration + durations[i]
  end

  local anim = newAnimator(totalDuration, nil, startTimeOffset)
  anim._durations = durations
  anim._easingFunctions = easingFunctions
  anim._parts = parts
  anim._getValue = getValueForPartsWithDurations
  anim._lengths, anim._totalLength = calculatePartsLength(parts)

  return anim
end

local function newAnimatorFromParts(duration, parts, easingFunction, startTimeOffset)
  local anim = newAnimator(duration, easingFunction, startTimeOffset)
  anim._parts = parts
  anim._getValue = getValueForParts
  anim._lengths, anim._totalLength = calculatePartsLength(parts)
  return anim
end

-- note: this function has 5 overloaded definitions as of 2.6.2.
-- the parameters will first need to be interpreted, then passed off to an appropriate local function for processing.
function module.new(a, b, c, d, e)
  if type(b) == "table" then
    if b._type then
      if b._type == "point" then
        return newAnimatorFromPoints(a, b, c, d, e)
      elseif b._type == "lineSegment" then
        return newAnimatorFromLineSegment(a, b, c, d)
      elseif b._type == "arc" then
        return newAnimatorFromArc(a, b, c, d)
      elseif b._type == "polygon" then
        return newAnimatorFromPolygon(a, b, c, d)
      end
    else
      if type(a) == "number" then
        return newAnimatorFromParts(a, b, c, d)
      else
        return newAnimatorFromPartsWithDurations(a, b, c, d)
      end
    end
  else
    return newAnimatorFromNumber(a, b, c, d, e)
  end
end

function meta:currentValue()
  updateAnimator(self)
  return self:_getValue(self._currentTime)
end

function meta:valueAtTime(time)
  time = normalizeTime(self, time)
  return self:_getValue(time)
end

function meta:progress()
  updateAnimator(self)

  if self.repeats or self.repeatCount < 0 then
    return nil
  end

  if self._ended then
    return 1
  end

  local dur = self._duration
  if self.reverses then
    dur = dur * 2
  end

  dur = dur + self.repeatCount * dur

  local t = playdate.getCurrentTimeMilliseconds() - self._startTime

  return playbit.util.clamp01(t / dur)
end

function meta:reset(duration)
  self._duration = duration or self._duration
  self._startTime = playdate.getCurrentTimeMilliseconds()
  self._currentTime = 0
  self._ended = false
end

function meta:ended()
  updateAnimator(self)
  return self._ended
end

module.easingAmplitude = nil
module.easingPeriod = nil
