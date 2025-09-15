local module = playdate or {}

local lastCrankPos = 0

function module.getCrankTicks(ticksPerRevolution)
  local degreesPerTick = 360 / ticksPerRevolution
  local crankPos = playdate.getCrankPosition()

  local thisTick = math.ceil(crankPos / degreesPerTick)

  -- handle crossing 360/0 border
  local delta = math.abs(crankPos - lastCrankPos)
  if delta > 180 then
    if lastCrankPos >= 180 then
        lastCrankPos = lastCrankPos - 360
    else
        lastCrankPos = lastCrankPos + 360
    end
  end
  local lastTick = math.ceil(lastCrankPos / degreesPerTick)
  
  local tickDelta = thisTick - lastTick

  lastCrankPos = crankPos

  return tickDelta
end