-- docs: https://sdk.play.date/2.7.1/#C-graphics.tilemap
local module = {}
playdate.graphics.tilemap = module

local meta = {}
meta.__index = meta
module.__index = meta

function module.new()
  local t = setmetatable({}, meta)
  t._width = 0
  t._height = 0
  t._length = 0
  t._tiles = {} -- a table of integer indexes (1-based) that index into the tilemap's imagetable
  t._imagetable = nil
  return t
end

function meta:setImageTable(table)
  self._imagetable = table
end

function meta:setSize(width, height)
  self._width = width
  self._height = height
  self._length = width * height

  -- TODO: this will clear the tilemap if set later, what does PD do?
  self._tiles = {}
end

function meta:setTileAtPosition(x, y, index)
  self._tiles[x][y] = index -- index into the tilemap's imagetable
end

function meta:getTileAtPosition(x, y)
  local index = x * y
  if index > #self._tiles then
    return 0
  end
  return self._tiles[index]
end

function meta:draw(x, y, sourceRect)
  @@ASSERT(x == nil, "[ERR] Parameter x is not yet implemented.")
  @@ASSERT(y == nil, "[ERR] Parameter y is not yet implemented.")
  @@ASSERT(sourceRect == nil, "[ERR] Parameter sourceRect is not yet implemented.")

  -- always render pure white so its not tinted
  local r, g, b = love.graphics.getColor()
  love.graphics.setColor(1, 1, 1, 1)

  local frameWidth = self._imagetable._frameWidth
  local frameHeight = self._imagetable._frameHeight

  for i = 1, self._length do
    local j = i - 1
    local tile = self._tiles[i]
    -- TODO: fix - overwriting the parameter values x, y
    local x = math.floor(j % self._width) * frameHeight
    local y = math.floor(j / self._width) * frameWidth
    love.graphics.draw(self._imagetable._images[tile].data, x, y)
  end

  love.graphics.setColor(r, g, b, 1)
  playbit.graphics.updateContext()
end

function meta:getTiles()
  error("[ERR] playdate.graphics.tilemap:getTiles() is not yet implemented.")
end

function meta:setTiles(data, width)
  self._width = width
  self._length = width * self._height
  self._tiles = data
end

function meta:getTileSize()
  return self._imagetable._frameWidth, self._imagetable._frameHeight
end

function meta:drawIgnoringOffset(x, y, sourceRect)
  error("[ERR] playdate.graphics.tilemap:drawIgnoringOffset() is not yet implemented.")
end

function meta:getSize()
  error("[ERR] playdate.graphics.tilemap:getSize() is not yet implemented.")
end

function meta:getPixelSize()
  error("[ERR] playdate.graphics.tilemap:getPixelSize() is not yet implemented.")
end

function meta:getCollisionRects(emptyIDs)
  error("[ERR] playdate.graphics.tilemap:getCollisionRects() is not yet implemented.")
end