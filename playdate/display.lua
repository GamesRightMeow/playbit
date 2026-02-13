local module = {}
playdate.display = module

local inverted = false

function module.setRefreshRate(rate)
  error("[ERR] playdate.display.setRefreshRate() is not yet implemented.")
end

function module.getRefreshRate()
  error("[ERR] playdate.display.getRefreshRate() is not yet implemented.")
end

function module.flush()
  error("[ERR] playdate.display.flush() is not yet implemented.")
end

function module.getHeight()
  local w, h = module.getSize()
  return h
end

function module.getWidth()
  local w, h = module.getSize()
  return w
end

function module.getSize()
  return playbit.graphics.getCanvasSize()
end

function module.getRect()
  local w, h = playbit.graphics.getCanvasSize()
  return playdate.geometry.rect.new(0, 0, w, h)
end

function module.setScale(scale)
  assert(scale == 1 or scale == 2 or scale == 4 or scale == 8)
  playbit.graphics.setCanvasScale(scale)
  playbit.graphics.setCanvasSize(
    math.floor(playbit.graphics.SCR_WIDTH / scale),
    math.floor(playbit.graphics.SCR_HEIGHT / scale))
end

function module.getScale()
    return displayScale
end

function module.setInverted(flag)
  inverted = flag
  playbit.graphics.shaders.final:send("inverted", flag and 1 or 0)
end

function module.getInverted()
  return inverted
end

function module.setMosaic(x, y)
  error("[ERR] playdate.display.setMosaic() is not yet implemented.")
end

function module.getMosaic()
  error("[ERR] playdate.display.getMosaic() is not yet implemented.")
end

function module.setOffset(x, y)
  playbit.graphics.setCanvasPosition(x, y)
end

function module.getOffset()
  return playbit.graphics.getCanvasPosition()
end

function module.setFlipped(x, y)
  playbit.graphics.shaders.final:send("flip", { x and 1 or 0, y and 1 or 0 })
end

function module.loadImage(path)
  error("[ERR] playdate.display.loadImage() is not yet implemented.")
end
