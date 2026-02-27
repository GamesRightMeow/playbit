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
  t._tiles = {}
  t._tileWidth = 0
  t._tileHeight = 0
  return t
end

function meta:indexFromPosition(x,y)
  return x + (y-1) * self._width
end

function meta:setImageTable(table)
  self._imagetable = table
  self._tileWidth , self._tileHeight = table:getImage(1):getSize()
end

function meta:setSize(width, height)
  self._width = width
  self._height = height
  self._length = width * height

  -- TODO: this will clear the tilemap if set later, what does PD do?
  self._tiles = {}
end

function meta:setTileAtPosition(x, y, tile)
  local index = self:indexFromPosition(x,y)
  if index > #self._tiles or index < 1 then
    return 0
  end
  self._tiles[index] = tile
end

function meta:getTileAtPosition(x, y)
  local index = self:indexFromPosition(x,y)
  if index > #self._tiles or index < 1 then
    return 0
  end
  return self._tiles[index]
end

function meta:draw(x, y)
  -- always render pure white so its not tinted

  local frameWidth = self._imagetable._frameWidth
  local frameHeight = self._imagetable._frameHeight
  for i = 1 , self._width do
    for j = 1, self._height do
      local tileIndex = self:indexFromPosition(i,j)
      local xPos = x + (i-1)*self._tileWidth
      local yPos = y + (j-1)*self._tileHeight
      
      self._imagetable:drawImage(self._tiles[tileIndex],xPos,yPos)
    end
  end
  -- for i = 1, self._length do
  --   local j = i - 1
  --   local tile = self._tiles[i]
  --   local x = math.floor(j % self._width) * frameHeight
  --   local y = math.floor(j / self._width) * frameWidth
  --   love.graphics.draw(self._imagetable._images[tile].data, x, y)
  -- end
end

function meta:setTiles(data, width)
  self._width = width
  self._length = #data
  self._height = #data/width
  self._tiles = data
end

function meta:getTileSize()
  return self._imagetable._frameWidth, self._imagetable._frameHeight
end