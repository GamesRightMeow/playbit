local module = {}
playbit = playbit or {}
playbit.perf = module

local samples = {}
local frameSamples = {}

!(
function PROFILER_BEGIN_SAMPLE(name)
  if PROFILER then
    return "playbit.perf.beginSample("..name..")"
  end
  return ""
end

function PROFILER_END_SAMPLE(name)
  if PROFILER then
    return "playbit.perf.endSample("..name..")"
  end
  return ""
end
)

function module.beginSample(name)
  samples[name] = playdate.getCurrentTimeMilliseconds()
end

function module.endSample(name)
  local endTime = playdate.getCurrentTimeMilliseconds()
  local startTime = samples[name]
  print(name.."="..(endTime - startTime).."ms")
end

function module.beginFrameSample(name)
!if DEBUG then
  if frameSamples[name] == nil then
    frameSamples[name] = {
      startTime = 0,
      lastDuration = 0
    }
  end
  frameSamples[name].startTime = playbit.time.getTime()
!end
end

function module.endFrameSample(name)
!if DEBUG then
  local endTime = playbit.time.getTime()
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

  return playbit.util.round(time, 3)
!else
    return "0.000"
!end
end

-- returns average FPS
function module.getFps()
!if LOVE2D then
  return love.timer.getFPS()
!elseif PLAYDATE then
  return math.floor(1.0 / playbit.time.avgDeltaTime())
!end
end

function module.getMemory()
  return collectgarbage("count"), 2
end
