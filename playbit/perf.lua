local module = {}

local sampleStart = 0
local frameSamples = {}

function module.beginSample()
  sampleStart = pb.time.getTime()
end

function module.endSample()
  local endTime = pb.time.getTime()
  print((endTime - sampleStart) .. "ms")
end

function module.beginFrameSample(name)
!if DEBUG then
  if frameSamples[name] == nil then
    frameSamples[name] = {
      startTime = 0,
      lastDuration = 0
    }
  end
  frameSamples[name].startTime = pb.time.getTime()
!end
end

function module.endFrameSample(name)
!if DEBUG then
  local endTime = pb.time.getTime()
  local startTime = frameSamples[name].startTime
  frameSamples[name].lastDuration = endTime - startTime
!end
end

function module.getFrameSample(name)
!if DEBUG then
  if not frameSamples[name] then
    return "--"
  end

  local time = frameSamples[name].lastDuration
  if time == 0 then
    -- fixes round not working on 0
    return "0.000"
  end

  return pb.util.round(time, 3)
!else
    return "0.000"
!end
end

-- returns average FPS
function module.getFps()
!if LOVE2D then
  -- this is averged
  return love.timer.getFPS()
!elseif PLAYDATE then
  -- TODO: this is not averaged
  return math.floor(1.0 / pb.time.avgDeltaTime())
!end
end

function module.getMemory()
  return collectgarbage("count"), 2
end

return module