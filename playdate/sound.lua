-- Love2d implementation heavily based on https://github.com/superzazu/denver.lua

local sampleplayer = {}
playdate.sound = {}
playdate.sound.sampleplayer = sampleplayer

sampleplayer.meta = {}
sampleplayer.meta.__index = sampleplayer.meta

function sampleplayer.new(path)
  local sample = setmetatable({}, sampleplayer.meta)
  sample.data = love.audio.newSource(path..".wav", "static")
  return sample
end

function sampleplayer.meta:play(repeatCount, rate)
  -- TODO: repeat count
  self.data:setPitch(rate)
  self.data:play()
end

function sampleplayer.meta:stop()
  self.data:stop()
end

function sampleplayer.meta:isPlaying()
  return self.data:isPlaying()
end

function sampleplayer.meta:setVolume(value)
  self.data:setVolume(value)
end

-- TODO: fileplayer
-- TODO: synth