local Perf = {}

local sampleStart = 0
local frameSamples = {}

function Perf.beginSample()
  sampleStart = os.clock()
end

function Perf.endSample()
  local endTime = os.clock()
  print((endTime - sampleStart) .. "ms")
end

function Perf.beginFrameSample(name)
  --! if DEBUG then
  if frameSamples[name] == nil then
    frameSamples[name] = {
      startTime = 0,
      lastDuration = 0
    }
  end

  frameSamples[name].startTime = os.clock()
  --! end
end

function Perf.endFrameSample(name)
  --! if DEBUG then
  local endTime = os.clock()
  local startTime = frameSamples[name].startTime
  frameSamples[name].lastDuration = endTime - startTime
  --! end
end

function Perf.getFrameSample(name)
  --! if DEBUG then
  if not frameSamples[name] then
    return "--"
  end

  local time = frameSamples[name].lastDuration
  if time == 0 then
    -- fixes round not working on 0
    return "0.000"
  end

  return pb.util.round(time, 3)
  --! else
    return "0.000"
  --! end
end

function Perf.getFps()
  --! if LOVE2D then
  return love.timer.getFPS()
  --! elseif PLAYDATE then
  -- TODO: calcualte FPS on playdate
  return 0
  --! end
end

function Perf.getMemory()
  return collectgarbage("count"), 2
end

return Perf;