-- Love2d implementation heavily based on https://github.com/superzazu/denver.lua

local module = {}

module.sampleplayer = {}
module.sampleplayer.meta = {}
module.sampleplayer.meta.__index = module.sampleplayer.meta

function module.sampleplayer.new(path)
  local sample = setmetatable({}, module.sampleplayer.meta)
!if LOVE2D then

!elseif PLAYDATE then
  sample.data = playdate.sound.sampleplayer.new(path)
!end
  return sample
end

function module.sampleplayer.meta:play(repeatCount, rate)
!if LOVE2D then

!elseif PLAYDATE then
  self.data:play(repeatCount or 1, rate or 1)
!end
end

function module.sampleplayer.meta:stop()
!if LOVE2D then

!elseif PLAYDATE then
  self.data:stop()
!end
end

function module.sampleplayer.meta:isPlaying()
!if LOVE2D then

!elseif PLAYDATE then
  return self.data:isPlaying()
!end
end

function module.sampleplayer.meta:setVolume(value)
!if LOVE2D then

!elseif PLAYDATE then
  self.data:setVolume(value)
!end
end

-- TODO: file player

-- TODO: this doesn't match what's loaded in pulp
function module.loadPulpSequence(path)
!if LOVE2D then

!elseif PLAYDATE then
  local json = pb.json.decodeFile(path)
  -- note array = pairs of 3:note,octave,hold
  -- ticks = number of notes (length of notes array *can* have some extra data at end?)
  -- type = synth (but doesn't map directly to wave form)

  -- TODO: load other sounds from json
  local soundJson = json[1]
  local a = 0.005
  local d = 0.1
  local s = 0.5
  local r = 0.1

  if soundJson.envelope then
    if soundJson.envelope.attack then
      a = soundJson.envelope.attack
    end

    if soundJson.envelope.decay then
      d = soundJson.envelope.decay
    end

    if soundJson.envelope.sustain then
      s = soundJson.envelope.sustain
    end

    if soundJson.envelope.release then
      r = soundJson.envelope.release
    end
  end

  -- why...don't these match up with pulp?!
  local waveform = playdate.sound.kWaveSine
  if soundJson.type == 0 then
    waveform = playdate.sound.kWaveSine
  elseif soundJson.type == 1 then
    waveform = playdate.sound.kWaveSquare
  elseif soundJson.type == 2 then
    waveform = playdate.sound.kWaveSawtooth
  elseif soundJson.type == 3 then
    waveform = playdate.sound.kWaveTriangle
  elseif soundJson.type == 4 then
    waveform = playdate.sound.kWaveNoise
  end

  local synth = module.synth.new(waveform)
  synth:setADSR(a, d, s, r)
  local instrument = module.instrument.new(synth)
  local track = module.track.new(synth)
  track:setInstrument(instrument)
  local step = 0
  for i = 1, soundJson.ticks, 3 do
    step = step + 1
    if soundJson.notes[i] == 0 then
      -- a zero (0) is a lack of a note
      goto continue
    end

    local baseNote = soundJson.notes[i] + 1
    local octave = soundJson.notes[i + 1]
    local length = soundJson.notes[i + 2]
    local note = baseNote + ((octave + 1) * 12)
    track:addNote(i, note, length, 1)
    ::continue::
  end
  local sequence = module.sequence.new()
  sequence:addTrack(track)
  sequence:setTempo(soundJson.bpm / 6)
  sequence:setLoops(0, sequence:getLength(), 0)

  -- TODO: probably should return list of these?
  return sequence
!end
end

module.synth = {}
module.synth.meta = {}
module.synth.meta.__index = module.synth.meta

--[[
  0 = playdate.sound.kWaveSquare
  1 = playdate.sound.kWaveTriangle
  2 = playdate.sound.kWaveSine
  3 = playdate.sound.kWaveNoise
  4 = playdate.sound.kWaveSawtooth
--]]
function module.synth.new(waveform)
  local synth = setmetatable({}, module.synth.meta)
!if LOVE2D then

!elseif PLAYDATE then
  synth.data = playdate.sound.synth.new(waveform)
!end
  return synth
end

function module.synth.meta:playNote(pitch, volume, length)
!if LOVE2D then

!elseif PLAYDATE then
  self.data:playNote(pitch, volume, length)
!end
end

function module.synth.meta:playMIDINote(note, volume, length)
!if LOVE2D then

!elseif PLAYDATE then
  self.data:playMIDINote(note, volume, length)
!end
end

function module.synth.meta:setADSR(attack, decay, sustain, release)
!if LOVE2D then

!elseif PLAYDATE then
  self.data:setADSR(attack, decay, sustain, release)
!end
end

module.sequence = {}
module.sequence.meta = {}
module.sequence.meta.__index = module.sequence.meta

function module.sequence.new()
  local sequence = setmetatable({}, module.sequence.meta)
!if LOVE2D then

!elseif PLAYDATE then
  sequence.data = playdate.sound.sequence.new()
!end
  return sequence
end

function module.sequence.meta:setTempo(stepsPerSecond)
!if LOVE2D then

!elseif PLAYDATE then
  self.data:setTempo(stepsPerSecond)
!end
end

function module.sequence.meta:play()
!if LOVE2D then

!elseif PLAYDATE then
  self.data:play()
!end
end

function module.sequence.meta:stop()
!if LOVE2D then

!elseif PLAYDATE then
  self.data:stop()
!end
end

function module.sequence.meta:addTrack(track)
!if LOVE2D then

!elseif PLAYDATE then
  self.data:addTrack(track.data)
!end
end

function module.sequence.meta:getLength()
!if LOVE2D then

!elseif PLAYDATE then
  return self.data:getLength()
!end
end

function module.sequence.meta:setLoops(startStep, endStep, loopCount)
!if LOVE2D then

!elseif PLAYDATE then
  return self.data:setLoops(startStep, endStep, loopCount)
!end
end

module.track = {}
module.track.meta = {}
module.track.meta.__index = module.track.meta

function module.track.new()
  local track = setmetatable({}, module.track.meta)
!if LOVE2D then

!elseif PLAYDATE then
  track.data = playdate.sound.track.new()
!end
  return track
end

function module.track.meta:addNote(step, note, length, velocity)
!if LOVE2D then

!elseif PLAYDATE then
  self.data:addNote(step, note, length, velocity)
!end
end

function module.track.meta:setInstrument(inst)
!if LOVE2D then

!elseif PLAYDATE then
  self.data:setInstrument(inst.data)
!end
end

module.instrument = {}
module.instrument.meta = {}
module.instrument.meta.__index = module.instrument.meta

function module.instrument.new(synth)
  local instrument = setmetatable({}, module.instrument.meta)
!if LOVE2D then

!elseif PLAYDATE then
  instrument.data = playdate.sound.instrument.new(synth.data)
!end
  return instrument
end

function module.instrument.meta:playNote(frequency, vel, length)
!if LOVE2D then

!elseif PLAYDATE then
  self.data:playNote(frequency, vel, length)
!end
end

return module