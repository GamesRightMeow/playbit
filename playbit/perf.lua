local util = require("playbit.util")

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
  if frameSamples[name] == nil then
    frameSamples[name] = {
      startTime = 0,
      lastDuration = 0
    }
  end

  frameSamples[name].startTime = os.clock()
end

function Perf.endFrameSample(name)
  local endTime = os.clock()
  local startTime = frameSamples[name].startTime
  frameSamples[name].lastDuration = endTime - startTime
end

function Perf.getFrameSample(name)
  local time = frameSamples[name].lastDuration
  if time == 0 then
    -- fixes round not working on 0
    return "0.000"
  end

  return util.round(time, 3)
end

function Perf.getFps()
  return love.timer.getFPS()
end

return Perf;