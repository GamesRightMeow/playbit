-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#C-graphics.animation.loop

playdate.graphics.animation = playdate.graphics.animation or {}

local module = {}
playdate.graphics.animation.loop = module

local meta = {}
meta.__index = meta
module.__index = meta

function module.new(delay, imageTable, shouldLoop)
  local animation = setmetatable({}, meta)
  
  animation.startFrame = 1
  animation.endFrame = 1
  animation.frame = 1
  animation.step = 1
  animation.pause = false
  animation._startTime = playdate.getCurrentTimeMilliseconds()

  animation.delay = delay or 100
  animation._imageTable = imageTable
  animation.shouldLoop = shouldLoop

  if imageTable then
    animation.endFrame = imageTable:getLength()
  end

  return animation
end

function meta:image()
  return self._imageTable:getImage(self.frame)
end

function meta:setImageTable(it)
  self._imageTable = it
end

function meta:isValid()
  if self.shouldLoop then
    return true
  end

  if self.frame > self.endFrame then
    return false
  end

  return true
end

function meta:draw(x, y, flip)
  if not self.pause then
    local elapsedTime = playdate.getCurrentTimeMilliseconds() - self._startTime
    self.frame = self.startFrame + math.floor(elapsedTime / self.delay) * self.step

    if self.frame > self.endFrame then
      if self.shouldLoop then
        self.frame = self.startFrame
        self._startTime = playdate.getCurrentTimeMilliseconds()
      else
        self.frame = self.endFrame
      end
    end
  end

  self._imageTable:drawImage(self.frame, x, y, flip)
end

local blinkers = {}
local blinkersToRemove = {}

-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#C-graphics.animation.blinker
local blinkerModule = {}
playdate.graphics.animation.blinker = blinkerModule

local blinkerMeta = {}
blinkerMeta.__index = blinkerMeta
blinkerModule.__index = blinkerMeta

local function setBlinkerSettings(inblinker,onDuration, offDuration, loop, cycles, default)
  if (type(onDuration) == "table") then
    onDuration = onDuration.onDuration
		offDuration = onDuration.offDuration
		loop = onDuration.loop
		cycles = onDuration.cycles
		default = onDuration.default
  end
  inblinker.onDuration = onDuration or 200
  inblinker.offDuration = offDuration or 200
  inblinker.loop = loop or false
  inblinker.cycles = cycles or 6
  inblinker._default = default or true
  
  inblinker.counter = 0
  inblinker.running = false
  inblinker.valid = true
  inblinker.on = inblinker._default
end

function blinkerModule.new(onDuration, offDuration, loop, cycles, default)
  local blinker = setmetatable({}, blinkerMeta)
  setBlinkerSettings(blinker,onDuration, offDuration, loop, cycles, default)
  blinker.t = 0
  blinker.counter = 0
  blinker.running = false
  blinker.valid = true
  blinker.on = blinker._default
  blinker._toRemove = false
  table.insert(blinkers, blinker)
  return blinker
  --error("[ERR] playdate.graphics.animation.blinker.new() is not yet implemented.")
end

function blinkerModule.updateAll()
  for key, value in pairs(blinkers) do
    value:update()
  end
  for i = #blinkers, 1 , -1 do
    if blinkers[i]._toRemove then
      table.remove(blinkers,i)
    end
  end
  --error("[ERR] playdate.graphics.animation.blinker.updateAll() is not yet implemented.")
end
function blinkerMeta:update()
  if not self.running then return end
  local elapsedTime = playdate.getCurrentTimeMilliseconds()
  local durationTime
  if self.on then
    durationTime = self.onDuration
  else
    durationTime = self.offDuration
  end
  if self.counter > 0 and elapsedTime-self.t > durationTime then
    self.on = not self.on
    self.t = elapsedTime
    self.counter = self.counter - 1
  elseif self.counter == 0 then
    self.on = self._default
    self.running = false
    if self.loop then self:startLoop() end
  end
  --error("[ERR] playdate.graphics.animation.blinker:update() is not yet implemented.")
end

function blinkerMeta:start(onDuration, offDuration, loop, cycles, default)
  setBlinkerSettings(self,onDuration, offDuration, loop, cycles, default)
  self.running = true
  self.counter = self.cycles
end

function blinkerMeta:startLoop()
  self:start(nil,nil,true)
end

function blinkerMeta:stop()
  self.running = false
  self.counter = 0
  self.on = self._default
end

function blinkerModule.stopAll()
  for key, value in pairs(blinkers) do
    value:stop()
  end
end

function blinkerMeta:remove()
  self._toRemove = true
end