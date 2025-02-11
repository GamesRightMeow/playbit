-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#M-sound

local module = {}
playdate.sound = module

function module.getSampleRate()
  return 44100.0 -- hardcoded by Playdate hardware
end

local sampleplayer = {}
playdate.sound.sampleplayer = sampleplayer
sampleplayer.meta = {}
sampleplayer.meta.__index = sampleplayer.meta

-- TODO: handle overloaded signature (sample) - sample is a playdate.sound.sample
function sampleplayer.new(path)
  local sample = setmetatable({}, sampleplayer.meta)
  sample.data = love.audio.newSource(path..".wav", "static")
  -- TODO: should we force a sample rate of 44100.0 since Playdate's hardware does this?
  return sample
end

function sampleplayer.meta:copy()
  local sample = setmetatable({}, sampleplayer.meta)
  sample.data = self.data:clone()
  return sample
end

function sampleplayer.meta:play(repeatCount, rate)
  -- TODO: repeat count
  if rate then
    self.data:setPitch(rate)
  end

  if repeatCount then
    -- TODO: specific repeat count
    if repeatCount == 0 then
      -- loop endlessly
      self.data:setLooping(true)
    end
  end

  self.data:play()
end

function sampleplayer.meta:playAt(when, vol, rightvol, rate)
  error("[ERR] playdate.sound.sampleplayer:playAt() is not yet implemented.")
end

function sampleplayer.meta:stop()
  self.data:stop()
end

function sampleplayer.meta:isPlaying()
  return self.data:isPlaying()
end

function sampleplayer.meta:setVolume(left, right)
  @@ASSERT(right == nil, "[ERR] Parameter right is not yet implemented.")
  self.data:setVolume(left)
end

function sampleplayer.meta:getVolume()
  return self.data:getVolume()
end

function sampleplayer.meta:setLoopCallback(callback, arg)
  error("[ERR] playdate.sound.sampleplayer:setLoopCallback() is not yet implemented.")
end

function sampleplayer.meta:setPlayRange(startframe, endframe)
  error("[ERR] playdate.sound.sampleplayer:setPlayRange() is not yet implemented.")
end

function sampleplayer.meta:setFinishCallback(callback, arg)
  error("[ERR] playdate.sound.sampleplayer:setFinishCallback() is not yet implemented.")
end

function sampleplayer.meta:setSample(sample)
  error("[ERR] playdate.sound.sampleplayer:setSample() is not yet implemented.")
end

function sampleplayer.meta:getSample()
  error("[ERR] playdate.sound.sampleplayer:getSample() is not yet implemented.")
end

function sampleplayer.meta:getLength()
  error("[ERR] playdate.sound.sampleplayer:getLength() is not yet implemented.")
end

function sampleplayer.meta:setOffset(value)
  self.data:seek(value)
end

function sampleplayer.meta:getOffset()
  return self.data:tell()
end

function sampleplayer.meta:setRate(rate)
  self.data:setPitch(rate)
end

function sampleplayer.meta:getRate()
  self.data:getPitch()
end

function sampleplayer.meta:setRateMod(signal)
  error("[ERR] playdate.sound.sampleplayer:setRateMod() is not yet implemented.")
end

local fileplayer = {}
playdate.sound.fileplayer = fileplayer
fileplayer.meta = {}
fileplayer.meta.__index = fileplayer.meta

-- TODO: handle overloaded function signature (bufferSize)
function fileplayer.new(path, bufferSize)
  -- TODO: is there a way to use bufferSize to control Love2D chunks?
  local sample = setmetatable({}, fileplayer.meta)
  sample.data = love.audio.newSource(path..".wav", "stream")
  return sample
end

function fileplayer.meta:load(path)
  error("[ERR] playdate.sound.fileplayer:load() is not yet implemented.")
end

function fileplayer.meta:play(repeatCount)
  if repeatCount then
    -- TODO: specific repeat count
    if repeatCount == 0 then
      -- loop endlessly
      self.data:setLooping(true)
    end
  end

  self.data:play()
end

function fileplayer.meta:stop()
  self.data:stop()
end

function fileplayer.meta:pause()
  self.data:pause()
end

function fileplayer.meta:isPlaying()
  return self.data:isPlaying()
end

function fileplayer.meta:setVolume(left, right, fadeSeconds, fadeCallback, arg)
  @@ASSERT(right == nil, "[ERR] Parameter right is not yet implemented.")
  @@ASSERT(fadeSeconds == nil, "[ERR] Parameter fadeSeconds is not yet implemented.")
  @@ASSERT(fadeCallback == nil, "[ERR] Parameter fadeCallback is not yet implemented.")
  @@ASSERT(arg == nil, "[ERR] Parameter arg is not yet implemented.")

  self.data:setVolume(left)
end

function fileplayer.meta:getVolume()
  -- TODO: should have two return values; left, right
  return self.data:getVolume(), self.data:getVolume()
end

function fileplayer.meta:setRate(rate)
  self.data:setPitch(rate)
end

function fileplayer.meta:getRate(rate)
  self.data:getPitch()
end

function fileplayer.meta:setRateMod(signal)
  error("[ERR] playdate.sound.fileplayer:setRateMod() is not yet implemented.")
end


function fileplayer.meta:setOffset(seconds)
  self.data:seek(seconds)
end

function fileplayer.meta:getOffset()
  return self.data:tell()
end

function fileplayer.meta:getLength()
  return self.data:getDuration("seconds")
end

function fileplayer.meta:setFinishCallback(callback, arg)
  error("[ERR] playdate.sound.fileplayer:setFinishCallback() is not yet implemented.")
end

function fileplayer.meta:didUnderrun()
  error("[ERR] playdate.sound.fileplayer:didUnderrun() is not yet implemented.")
end

function fileplayer.meta:setStopOnUnderrun(flag)
  error("[ERR] playdate.sound.fileplayer:setStopOnUnderrun() is not yet implemented.")
end

function fileplayer.meta:setLoopRange(startframe, endframe, loopCallback, arg)
  error("[ERR] playdate.sound.fileplayer:setLoopRange() is not yet implemented.")
end

function fileplayer.meta:setLoopCallback(callback, arg)
  error("[ERR] playdate.sound.fileplayer:setLoopCallback() is not yet implemented.")
end

function fileplayer.meta:setBufferSize(seconds)
  error("[ERR] playdate.sound.fileplayer:setBufferSize() is not yet implemented.")
end

local sample = {}
playdate.sound.sample = sample
sample.meta = {}
sample.meta.__index = sample.meta

-- TODO: handle overloaded signature (seconds, format)
function sample.new(path)
  error("[ERR] playdate.sound.sample.new() is not yet implemented.")
end

function sample.meta:getSubSample(startOffset, endOffset)
  error("[ERR] playdate.sound.sample:getSubSample() is not yet implemented.")
end

function sample.meta:load(path)
  error("[ERR] playdate.sound.sample:load() is not yet implemented.")
end

function sample.meta:decompress()
  error("[ERR] playdate.sound.sample:decompress() is not yet implemented.")
end

function sample.meta:getSampleRate()
  error("[ERR] playdate.sound.sample:getSampleRate() is not yet implemented.")
end

function sample.meta:getFormat()
  error("[ERR] playdate.sound.sample:getFormat() is not yet implemented.")
end

function sample.meta:getLength()
  error("[ERR] playdate.sound.sample:getLength() is not yet implemented.")
end

function sample.meta:play(repeatCount, rate)
  error("[ERR] playdate.sound.sample:play() is not yet implemented.")
end

function sample.meta:playAt(when, vol, rightvol, rate)
  error("[ERR] playdate.sound.sample:playAt() is not yet implemented.")
end

function sample.meta:save(filename)
  error("[ERR] playdate.sound.sample:save() is not yet implemented.")
end

-- TODO: synth, channel, source, signnal, LFO, envelope, effects, bitcrusher, ring modulator.....