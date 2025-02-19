-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#M-sound

local module = {}
playdate.sound = module

function module.getSampleRate()
  return 44100.0 -- hardcoded by Playdate hardware
end

function module.playingSources()
  error("[ERR] playdate.sound.playingSources() is not yet implemented.")
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

local channel = {}
playdate.sound.channel = channel
channel.meta = {}
channel.meta.__index = channel.meta

function channel.new()
  error("[ERR] playdate.sound.channel.new() is not yet implemented.")
end

function channel.meta:remove()
  error("[ERR] playdate.sound.channel:remove() is not yet implemented.")
end

function channel.meta:addEffect(effect)
  error("[ERR] playdate.sound.channel:addEffect() is not yet implemented.")
end

function channel.meta:removeEffect(effect)
  error("[ERR] playdate.sound.channel:removeEffect() is not yet implemented.")
end

function channel.meta:addSource(source)
  error("[ERR] playdate.sound.channel:addSource() is not yet implemented.")
end

function channel.meta:removeSource(source)
  error("[ERR] playdate.sound.channel:removeSource() is not yet implemented.")
end

function channel.meta:setVolume(volume)
  error("[ERR] playdate.sound.channel:setVolume() is not yet implemented.")
end

function channel.meta:getVolume()
  error("[ERR] playdate.sound.channel:getVolume() is not yet implemented.")
end

function channel.meta:setPan(pan)
  error("[ERR] playdate.sound.channel:setPan() is not yet implemented.")
end

function channel.meta:setPanMod(signal)
  error("[ERR] playdate.sound.channel:setPanMod() is not yet implemented.")
end

function channel.meta:setVolumeMod(signal)
  error("[ERR] playdate.sound.channel:setVolumeMod() is not yet implemented.")
end

function channel.meta:getDryLevelSignal()
  error("[ERR] playdate.sound.channel:getDryLevelSignal() is not yet implemented.")
end

function channel.meta:getWetLevelSignal()
  error("[ERR] playdate.sound.channel:getWetLevelSignal() is not yet implemented.")
end

local synth = {}
playdate.sound.synth = synth
synth.meta = {}
synth.meta.__index = synth.meta

-- TODO: handle overloaded signature (sample, sustainStart, sustainEnd)
function synth.new(waveform)
  error("[ERR] playdate.sound.synth.new() is not yet implemented.")
end

function synth.meta:copy()
  error("[ERR] playdate.sound.synth:copy() is not yet implemented.")
end

function synth.meta:playNote(pitch, volume, length, when)
  error("[ERR] playdate.sound.synth:playNote() is not yet implemented.")
end

function synth.meta:playMIDINote(note, volume, length, when)
  error("[ERR] playdate.sound.synth:playMIDINote() is not yet implemented.")
end

function synth.meta:noteOff()
  error("[ERR] playdate.sound.synth:noteOff() is not yet implemented.")
end

function synth.meta:stop()
  error("[ERR] playdate.sound.synth:stop() is not yet implemented.")
end

function synth.meta:isPlaying()
  error("[ERR] playdate.sound.synth:isPlaying() is not yet implemented.")
end

function synth.meta:setAmplitudeMod(signal)
  error("[ERR] playdate.sound.synth:setAmplitudeMod() is not yet implemented.")
end

function synth.meta:setADSR(attack, decay, sustain, release)
  error("[ERR] playdate.sound.synth:setADSR() is not yet implemented.")
end

function synth.meta:setAttack(time)
  error("[ERR] playdate.sound.synth:setAttack() is not yet implemented.")
end

function synth.meta:setDecay(time)
  error("[ERR] playdate.sound.synth:setDecay() is not yet implemented.")
end

function synth.meta:setSustain(level)
  error("[ERR] playdate.sound.synth:setSustain() is not yet implemented.")
end

function synth.meta:setRelease(time)
  error("[ERR] playdate.sound.synth:setRelease() is not yet implemented.")
end

function synth.meta:clearEnvelope()
  error("[ERR] playdate.sound.synth:clearEnvelope() is not yet implemented.")
end

function synth.meta:setEnvelopeCurvature(amount)
  error("[ERR] playdate.sound.synth:setEnvelopeCurvature() is not yet implemented.")
end

function synth.meta:getEnvelope()
  error("[ERR] playdate.sound.synth:getEnvelope() is not yet implemented.")
end

function synth.meta:setFinishCallback(func)
  error("[ERR] playdate.sound.synth:setFinishCallback() is not yet implemented.")
end

function synth.meta:setFrequencyMod(signal)
  error("[ERR] playdate.sound.synth:setFrequencyMod() is not yet implemented.")
end

function synth.meta:setLegato(flag)
  error("[ERR] playdate.sound.synth:setLegato() is not yet implemented.")
end

function synth.meta:setVolume(left, right)
  error("[ERR] playdate.sound.synth:setVolume() is not yet implemented.")
end

function synth.meta:getVolume()
  error("[ERR] playdate.sound.synth:getVolume() is not yet implemented.")
end

function synth.meta:setWaveform(waveform)
  error("[ERR] playdate.sound.synth:setWaveform() is not yet implemented.")
end

function synth.meta:setWavetable(sample, samplesize, xsize, ysize)
  error("[ERR] playdate.sound.synth:setWavetable() is not yet implemented.")
end

function synth.meta:setParameter(parameter, value)
  error("[ERR] playdate.sound.synth:setParameter() is not yet implemented.")
end

function synth.meta:setParameterMod(parameter, signal)
  error("[ERR] playdate.sound.synth:setParameterMod() is not yet implemented.")
end

local signal = {}
playdate.sound.signal = signal
signal.meta = {}
signal.meta.__index = signal.meta

function signal.meta:setOffset(offset)
  error("[ERR] playdate.sound.signal:setOffset() is not yet implemented.")
end

function signal.meta:setScale(scale)
  error("[ERR] playdate.sound.signal:setScale() is not yet implemented.")
end

function signal.meta:getValue()
  error("[ERR] playdate.sound.signal:getValue() is not yet implemented.")
end

local lfo = {}
playdate.sound.lfo = lfo
lfo.meta = {}
lfo.meta.__index = lfo.meta

function lfo.new(type)
  error("[ERR] playdate.sound.lfo.new() is not yet implemented.")
end

function lfo.meta:setType(type)
  error("[ERR] playdate.sound.lfo:setType() is not yet implemented.")
end

function lfo.meta:setArpeggio(note1, ...)
  error("[ERR] playdate.sound.lfo:setArpeggio() is not yet implemented.")
end

function lfo.meta:setCenter(center)
  error("[ERR] playdate.sound.lfo:setCenter() is not yet implemented.")
end

function lfo.meta:setDepth(depth)
  error("[ERR] playdate.sound.lfo:setDepth() is not yet implemented.")
end

function lfo.meta:setRate(rate)
  error("[ERR] playdate.sound.lfo:setRate() is not yet implemented.")
end

function lfo.meta:setPhase(phase)
  error("[ERR] playdate.sound.lfo:setPhase() is not yet implemented.")
end

function lfo.meta:setStartPhase(phase)
  error("[ERR] playdate.sound.lfo:setStartPhase() is not yet implemented.")
end

function lfo.meta:setGlobal(flag)
  error("[ERR] playdate.sound.lfo:setGlobal() is not yet implemented.")
end

function lfo.meta:setRetrigger(flag)
  error("[ERR] playdate.sound.lfo:setRetrigger() is not yet implemented.")
end

function lfo.meta:setDelay(holdoff, ramp)
  error("[ERR] playdate.sound.lfo:setDelay() is not yet implemented.")
end

function lfo.meta:getValue()
  error("[ERR] playdate.sound.lfo:getValue() is not yet implemented.")
end

local envelope = {}
playdate.sound.envelope = envelope
envelope.meta = {}
envelope.meta.__index = envelope.meta

function envelope.new(attack, decay, sustain, release)
  error("[ERR] playdate.sound.envelope.new() is not yet implemented.")
end

function envelope.meta:setAttack(attack)
  error("[ERR] playdate.sound.envelope:setAttack() is not yet implemented.")
end

function envelope.meta:setDecay(decay)
  error("[ERR] playdate.sound.envelope:setDecay() is not yet implemented.")
end

function envelope.meta:setSustain(sustain)
  error("[ERR] playdate.sound.envelope:setSustain() is not yet implemented.")
end

function envelope.meta:setRelease(release)
  error("[ERR] playdate.sound.envelope:setRelease() is not yet implemented.")
end

function envelope.meta:setCurvature(amount)
  error("[ERR] playdate.sound.envelope:setCurvature() is not yet implemented.")
end

function envelope.meta:setVelocitySensitivity(scaling, start, finish)
  error("[ERR] playdate.sound.envelope:setVelocitySensitivity() is not yet implemented.")
end

function envelope.meta:setRateScaling(scaling, start, finish)
  error("[ERR] playdate.sound.envelope:setRateScaling() is not yet implemented.")
end

function envelope.meta:setScale(scale)
  error("[ERR] playdate.sound.envelope:setScale() is not yet implemented.")
end

function envelope.meta:setOffset(offset)
  error("[ERR] playdate.sound.envelope:setOffset() is not yet implemented.")
end

function envelope.meta:setLegato(flag)
  error("[ERR] playdate.sound.envelope:setLegato() is not yet implemented.")
end

function envelope.meta:setRetrigger(flag)
  error("[ERR] playdate.sound.envelope:setRetrigger() is not yet implemented.")
end

function envelope.meta:setGlobal(flag)
  error("[ERR] playdate.sound.envelope:setGlobal() is not yet implemented.")
end

function envelope.meta:getValue()
  error("[ERR] playdate.sound.envelope:getValue() is not yet implemented.")
end

-- https://sdk.play.date/2.6.2/Inside%20Playdate.html#C-sound.effect
-- TODO: effects, bitcrusher, ring modulator.....