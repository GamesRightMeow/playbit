-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#M-sound

local module = {}
playdate.sound = module

function module.getSampleRate()
  return 44100.0 -- hardcoded by Playdate hardware
end

function module.playingSources()
  error("[ERR] playdate.sound.playingSources() is not yet implemented.")
end

function module.addEffect(effect)
  error("[ERR] playdate.sound.addEffect() is not yet implemented.")
end

function module.removeEffect(effect)
  error("[ERR] playdate.sound.removeEffect() is not yet implemented.")
end

function module.getHeadphoneState(changeCallback)
  error("[ERR] playdate.sound.getHeadphoneState() is not yet implemented.")
end

function module.setOutputsActive(headphones, speaker)
  error("[ERR] playdate.sound.setOutputsActive() is not yet implemented.")
end

function module.getCurrentTime()
  error("[ERR] playdate.sound.getCurrentTime() is not yet implemented.")
end

function module.resetTime()
  error("[ERR] playdate.sound.resetTime() is not yet implemented.")
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

local bitcrusher = {}
playdate.sound.bitcrusher = bitcrusher
bitcrusher.meta = {}
bitcrusher.meta.__index = bitcrusher.meta

function bitcrusher.new()
  error("[ERR] playdate.sound.bitcrusher.new() is not yet implemented.")
end

function bitcrusher.meta:setMix(level)
  error("[ERR] playdate.sound.bitcrusher:setMix() is not yet implemented.")
end

function bitcrusher.meta:setMixMod(signal)
  error("[ERR] playdate.sound.bitcrusher:setMixMod() is not yet implemented.")
end

function bitcrusher.meta:setAmount(amount)
  error("[ERR] playdate.sound.bitcrusher:setAmount() is not yet implemented.")
end

function bitcrusher.meta:setAmountMod(signal)
  error("[ERR] playdate.sound.bitcrusher:setAmountMod() is not yet implemented.")
end

function bitcrusher.meta:setUndersampling(amount)
  error("[ERR] playdate.sound.bitcrusher:setUndersampling() is not yet implemented.")
end

function bitcrusher.meta:setUndersamplingMod(signal)
  error("[ERR] playdate.sound.bitcrusher:setUndersamplingMod() is not yet implemented.")
end

local ringmod = {}
playdate.sound.ringmod = ringmod
ringmod.meta = {}
ringmod.meta.__index = ringmod.meta

function ringmod.new()
  error("[ERR] playdate.sound.ringmod.new() is not yet implemented.")
end

function ringmod.meta:setMix(level)
  error("[ERR] playdate.sound.ringmod:setMix() is not yet implemented.")
end

function ringmod.meta:setMixMod(signal)
  error("[ERR] playdate.sound.ringmod:setMixMod() is not yet implemented.")
end

function ringmod.meta:setFrequency(frequency)
  error("[ERR] playdate.sound.ringmod:setFrequency() is not yet implemented.")
end

function ringmod.meta:setFrequencyMod(signal)
  error("[ERR] playdate.sound.ringmod:setFrequencyMod() is not yet implemented.")
end

local onepolefilter = {}
playdate.sound.onepolefilter = onepolefilter
onepolefilter.meta = {}
onepolefilter.meta.__index = onepolefilter.meta

function onepolefilter.new()
  error("[ERR] playdate.sound.onepolefilter.new() is not yet implemented.")
end

function onepolefilter.meta:setMix(level)
  error("[ERR] playdate.sound.onepolefilter:setMix() is not yet implemented.")
end

function onepolefilter.meta:setMixMod(signal)
  error("[ERR] playdate.sound.onepolefilter:setMixMod() is not yet implemented.")
end

function onepolefilter.meta:setParameter(parameter)
  error("[ERR] playdate.sound.onepolefilter:setParameter() is not yet implemented.")
end

function onepolefilter.meta:setParameterMod(signal)
  error("[ERR] playdate.sound.onepolefilter:setParameterMod() is not yet implemented.")
end

local twopolefilter = {}
playdate.sound.twopolefilter = twopolefilter
twopolefilter.meta = {}
twopolefilter.meta.__index = twopolefilter.meta

function twopolefilter.new(type)
  error("[ERR] playdate.sound.twopolefilter.new() is not yet implemented.")
end

function twopolefilter.meta:setMix(level)
  error("[ERR] playdate.sound.twopolefilter:setMix() is not yet implemented.")
end

function twopolefilter.meta:setMixMod(signal)
  error("[ERR] playdate.sound.twopolefilter:setMixMod() is not yet implemented.")
end

function twopolefilter.meta:setFrequency(frequency)
  error("[ERR] playdate.sound.twopolefilter:setFrequency() is not yet implemented.")
end

function twopolefilter.meta:setFrequencyMod(signal)
  error("[ERR] playdate.sound.twopolefilter:setFrequencyMod() is not yet implemented.")
end

function twopolefilter.meta:setResonance(resonance)
  error("[ERR] playdate.sound.twopolefilter:setResonance() is not yet implemented.")
end

function twopolefilter.meta:setResonanceMod(signal)
  error("[ERR] playdate.sound.twopolefilter:setResonanceMod() is not yet implemented.")
end

function twopolefilter.meta:setGain(gain)
  error("[ERR] playdate.sound.twopolefilter:setGain() is not yet implemented.")
end

function twopolefilter.meta:setType(type)
  error("[ERR] playdate.sound.twopolefilter:setType() is not yet implemented.")
end

local overdrive = {}
playdate.sound.overdrive = overdrive
overdrive.meta = {}
overdrive.meta.__index = overdrive.meta

function overdrive.new(type)
  error("[ERR] playdate.sound.overdrive.new() is not yet implemented.")
end

function overdrive.meta:setMix(level)
  error("[ERR] playdate.sound.overdrive:setMix() is not yet implemented.")
end

function overdrive.meta:setMixMod(signal)
  error("[ERR] playdate.sound.overdrive:setMixMod() is not yet implemented.")
end

function overdrive.meta:setGain(level)
  error("[ERR] playdate.sound.overdrive:setGain() is not yet implemented.")
end

function overdrive.meta:setLimit(level)
  error("[ERR] playdate.sound.overdrive:setLimit() is not yet implemented.")
end

function overdrive.meta:setLimitMod(signal)
  error("[ERR] playdate.sound.overdrive:setLimitMod() is not yet implemented.")
end

function overdrive.meta:setOffset(level)
  error("[ERR] playdate.sound.overdrive:setOffset() is not yet implemented.")
end

function overdrive.meta:setOffsetMod(signal)
  error("[ERR] playdate.sound.overdrive:setOffsetMod() is not yet implemented.")
end

local delayline = {}
playdate.sound.delayline = delayline
delayline.meta = {}
delayline.meta.__index = delayline.meta

function delayline.new(type)
  error("[ERR] playdate.sound.delayline.new() is not yet implemented.")
end

function delayline.meta:setMix(level)
  error("[ERR] playdate.sound.delayline:setMix() is not yet implemented.")
end

function delayline.meta:setMixMod(signal)
  error("[ERR] playdate.sound.delayline:setMixMod() is not yet implemented.")
end

function delayline.meta:addTap(delay)
  error("[ERR] playdate.sound.delayline:addTap() is not yet implemented.")
end

function delayline.meta:setFeedback(level)
  error("[ERR] playdate.sound.delayline:setFeedback() is not yet implemented.")
end

local delaylinetap = {}
playdate.sound.delaylinetap = delaylinetap
delaylinetap.meta = {}
delaylinetap.meta.__index = delaylinetap.meta

function delaylinetap.meta:setDelay(time)
  error("[ERR] playdate.sound.delaylinetap:setDelay() is not yet implemented.")
end

function delaylinetap.meta:setDelayMod(signal)
  error("[ERR] playdate.sound.delaylinetap:setDelayMod() is not yet implemented.")
end

function delaylinetap.meta:setVolume(level)
  error("[ERR] playdate.sound.delaylinetap:setVolume() is not yet implemented.")
end

function delaylinetap.meta:getVolume()
  error("[ERR] playdate.sound.delaylinetap:getVolume() is not yet implemented.")
end

function delaylinetap.meta:setFlipChannels(flag)
  error("[ERR] playdate.sound.delaylinetap:setFlipChannels() is not yet implemented.")
end

local sequence = {}
playdate.sound.sequence = sequence
sequence.meta = {}
sequence.meta.__index = sequence.meta

function sequence.new(midiPath)
  error("[ERR] playdate.sound.sequence.new() is not yet implemented.")
end

function sequence.meta:play(finishCallback)
  error("[ERR] playdate.sound.sequence:play() is not yet implemented.")
end

function sequence.meta:stop()
  error("[ERR] playdate.sound.sequence:stop() is not yet implemented.")
end

function sequence.meta:isPlaying()
  error("[ERR] playdate.sound.sequence:isPlaying() is not yet implemented.")
end

function sequence.meta:getLength()
  error("[ERR] playdate.sound.sequence:getLength() is not yet implemented.")
end

function sequence.meta:goToStep(step, play)
  error("[ERR] playdate.sound.sequence:goToStep() is not yet implemented.")
end

function sequence.meta:getCurrentStep()
  error("[ERR] playdate.sound.sequence:getCurrentStep() is not yet implemented.")
end

function sequence.meta:setTempo(stepsPerSecond)
  error("[ERR] playdate.sound.sequence:setTempo() is not yet implemented.")
end

function sequence.meta:getTempo()
  error("[ERR] playdate.sound.sequence:getTempo() is not yet implemented.")
end

-- TODO: handle overloaded signature (loopCount)
function sequence.meta:setLoops(startSteps, endStep, loopCount)
  error("[ERR] playdate.sound.sequence:setLoops() is not yet implemented.")
end

function sequence.meta:getTrackCount()
  error("[ERR] playdate.sound.sequence:getTrackCount() is not yet implemented.")
end

function sequence.meta:addTrack(track)
  error("[ERR] playdate.sound.sequence:addTrack() is not yet implemented.")
end

function sequence.meta:setTrackAtIndex(n, track)
  error("[ERR] playdate.sound.sequence:setTrackAtIndex() is not yet implemented.")
end

function sequence.meta:getTrackAtIndex(n)
  error("[ERR] playdate.sound.sequence:getTrackAtIndex() is not yet implemented.")
end

function sequence.meta:allNotesOff()
  error("[ERR] playdate.sound.sequence:allNotesOff() is not yet implemented.")
end

local track = {}
playdate.sound.track = track
track.meta = {}
track.meta.__index = track.meta

function track.new()
  error("[ERR] playdate.sound.track.new() is not yet implemented.")
end

-- TODO: handle overloaded signature (table)
function track.meta:addNote(step, note, length, velocity)
  error("[ERR] playdate.sound.track:addNote() is not yet implemented.")
end

function track.meta:setNotes(list)
  error("[ERR] playdate.sound.track:setNotes() is not yet implemented.")
end

function track.meta:getNotes(step, endStep)
  error("[ERR] playdate.sound.track:getNotes() is not yet implemented.")
end

function track.meta:removeNote(step, note)
  error("[ERR] playdate.sound.track:removeNote() is not yet implemented.")
end

function track.meta:clearNotes()
  error("[ERR] playdate.sound.track:clearNotes() is not yet implemented.")
end

function track.meta:getLength()
  error("[ERR] playdate.sound.track:getLength() is not yet implemented.")
end

function track.meta:getNotesActive()
  error("[ERR] playdate.sound.track:getNotesActive() is not yet implemented.")
end

function track.meta:getPolyphony()
  error("[ERR] playdate.sound.track:getPolyphony() is not yet implemented.")
end

function track.meta:setInstrument(instrument)
  error("[ERR] playdate.sound.track:setInstrument() is not yet implemented.")
end

function track.meta:getInstrument()
  error("[ERR] playdate.sound.track:getInstrument() is not yet implemented.")
end

function track.meta:setMuted(flag)
  error("[ERR] playdate.sound.track:setMuted() is not yet implemented.")
end

function track.meta:addControlSignal(signal)
  error("[ERR] playdate.sound.track:addControlSignal() is not yet implemented.")
end

function track.meta:getControlSignals()
  error("[ERR] playdate.sound.track:getControlSignals() is not yet implemented.")
end

local instrument = {}
playdate.sound.instrument = instrument
instrument.meta = {}
instrument.meta.__index = instrument.meta

function instrument.new(synth)
  error("[ERR] playdate.sound.instrument.new() is not yet implemented.")
end

function instrument.meta:addVoice(v, note, rangeend, transpose)
  error("[ERR] playdate.sound.instrument:addVoice() is not yet implemented.")
end

function instrument.meta:setPitchBend(amount)
  error("[ERR] playdate.sound.instrument:setPitchBend() is not yet implemented.")
end

function instrument.meta:setPitchBendRange(halfsteps)
  error("[ERR] playdate.sound.instrument:setPitchBendRange() is not yet implemented.")
end

function instrument.meta:setTranspose(halfsteps)
  error("[ERR] playdate.sound.instrument:setTranspose() is not yet implemented.")
end

function instrument.meta:playNote(frequency, velocity, length, when)
  error("[ERR] playdate.sound.instrument:playNote() is not yet implemented.")
end

function instrument.meta:playMIDINote(note, velocity, length, when)
  error("[ERR] playdate.sound.instrument:playMIDINote() is not yet implemented.")
end

function instrument.meta:noteOff(note, when)
  error("[ERR] playdate.sound.instrument:noteOff() is not yet implemented.")
end

function instrument.meta:allNotesOff()
  error("[ERR] playdate.sound.instrument:allNotesOff() is not yet implemented.")
end

function instrument.meta:setVolume(left, right)
  error("[ERR] playdate.sound.instrument:setVolume() is not yet implemented.")
end

function instrument.meta:getVolume()
  error("[ERR] playdate.sound.instrument:getVolume() is not yet implemented.")
end

local controlsignal = {}
playdate.sound.controlsignal = controlsignal
controlsignal.meta = {}
controlsignal.meta.__index = controlsignal.meta

controlsignal.events = nil

-- TODO: handle overloaded signature (event)
function controlsignal.meta:addEvent(step, value, interpolate)
  error("[ERR] playdate.sound.controlsignal:addEvent() is not yet implemented.")
end

function controlsignal.meta:clearEvents()
  error("[ERR] playdate.sound.controlsignal:clearEvents() is not yet implemented.")
end

function controlsignal.meta:setControllerType(number)
  error("[ERR] playdate.sound.controlsignal:setControllerType() is not yet implemented.")
end

function controlsignal.meta:getControllerType()
  error("[ERR] playdate.sound.controlsignal:getControllerType() is not yet implemented.")
end

function controlsignal.meta:getValue()
  error("[ERR] playdate.sound.controlsignal:getValue() is not yet implemented.")
end

local micinput = {}
playdate.sound.micinput = micinput

function micinput.recordToSample(buffer, completionCallback)
  error("[ERR] playdate.sound.micinput.recordToSample() is not yet implemented.")
end

function micinput.stopRecording()
  error("[ERR] playdate.sound.micinput.stopRecording() is not yet implemented.")
end

function micinput.startListening(source)
  error("[ERR] playdate.sound.micinput.startListening() is not yet implemented.")
end

function micinput.stopListening()
  error("[ERR] playdate.sound.micinput.stopListening() is not yet implemented.")
end

function micinput.getLevel()
  error("[ERR] playdate.sound.micinput.getLevel() is not yet implemented.")
end

function micinput.getSource()
  error("[ERR] playdate.sound.micinput.getSource() is not yet implemented.")
end