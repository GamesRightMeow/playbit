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

-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#C-graphics.animation.blinker
local blinkerModule = {}
playdate.graphics.animation.blinker = blinkerModule

local blinkerMeta = {}
blinkerMeta.__index = blinkerMeta
blinkerModule.__index = blinkerMeta

function blinkerModule.new(onDuration, offDuration, loop, cycles, default)
  error("[ERR] playdate.graphics.animation.blinker.new() is not yet implemented.")
end

function blinkerModule.updateAll()
  error("[ERR] playdate.graphics.animation.blinker.updateAll() is not yet implemented.")
end

function blinkerMeta:update()
  error("[ERR] playdate.graphics.animation.blinker:update() is not yet implemented.")
end

function blinkerMeta:start(onDuration, offDuration, loop, cycles, default)
  error("[ERR] playdate.graphics.animation.blinker:start() is not yet implemented.")
end

function blinkerMeta:startLoop()
  error("[ERR] playdate.graphics.animation.blinker:startLoop() is not yet implemented.")
end

function blinkerMeta:stop()
  error("[ERR] playdate.graphics.animation.blinker:stop() is not yet implemented.")
end

function blinkerModule.stopAll()
  error("[ERR] playdate.graphics.animation.blinker.stopAll() is not yet implemented.")
end

function blinkerMeta:remove()
  error("[ERR] playdate.graphics.animation.blinker:remove() is not yet implemented.")
end