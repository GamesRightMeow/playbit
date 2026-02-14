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

function meta:setTileAtPosition(x, y, tile)
  if x >= 1 and x <= self._width and y >= 1 and y <= self._height then
    local index = (y - 1) * self._width + x
    self._tiles[index] = tile -- index into the tilemap's imagetable
  end
end

function meta:getTileAtPosition(x, y)
  if x < 1 or x > self._width or y < 1 or y > self._height then
    return nil
  end
  local index = (y - 1) * self._width + x
  if index > #self._tiles then
    return 0
  end
  return self._tiles[index]
end

function meta:draw(x, y, sourceRect)
  @@ASSERT(sourceRect == nil, "[ERR] Parameter sourceRect is not yet implemented.")

  local frameWidth = self._imagetable._frameWidth
  local frameHeight = self._imagetable._frameHeight

  local draw = love.graphics.draw
  local images = self._imagetable._images
  local imagesCount = #images
  local tiles = self._tiles
  local index = 1
  local sy = y

  playbit.graphics.setDrawMode("image")

  for j = 1, self._height do
    local sx = x
    for i = 1, self._width do
      local tile = tiles[index]
      if tile and tile > 0 and tile <= imagesCount then
        draw(images[tile].data, sx, sy)
      end
      sx = sx + frameWidth
      index = index + 1
    end
    sy = sy + frameHeight
  end

  playbit.graphics.updateContext()
end

function meta:getTiles()
  error("[ERR] playdate.graphics.tilemap:getTiles() is not yet implemented.")
end

function meta:setTiles(data, width)
  self._width = width
  self._height = math.floor(#data / width)
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
  return self._width, self._height
end

function meta:getPixelSize()
  return self._width * self._imagetable._frameWidth, self._height * self._imagetable._frameHeight
end

function meta:getCollisionRects(emptyIDs)
  error("[ERR] playdate.graphics.tilemap:getCollisionRects() is not yet implemented.")
end