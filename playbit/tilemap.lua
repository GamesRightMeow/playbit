local module = {}

local meta = {}
meta.__index = meta
module.__index = meta

-- TODO: is drawing with a nested array vs 1d array is faster on playdate?
-- TODO: is the native playdate tilemap faster?

function module.new(spritesheet, sizeX, sizeY)
  local tilemap = setmetatable({}, meta)
!if LOVE2D then
  tilemap.spritesheet = spritesheet
  tilemap.sizeX = sizeY
  tilemap.length = sizeX * sizeY
  tilemap.tiles = {}
  for i = 1, tilemap.length, 1 do
    tilemap.tiles[i] = 0
  end
!elseif PLAYDATE then
  local tm = playdate.graphics.tilemap.new()
  tm:setImageTable(spritesheet.imagetable)
  tm:setSize(sizeX, sizeY)
  tilemap.tilemap = tm
!end
  return tilemap
end

function meta:setTile(x, y, tile)
!if LOVE2D then
  local index = self.sizeX * (x - 1) + y
  self.tiles[index] = tile
!elseif PLAYDATE then
  self.tilemap:setTileAtPosition(x, y, tile)
!end
end

function meta:getTile(x, y)
!if LOVE2D then
  local index = self.sizeX * (x - 1) + y
  return self.tiles[index]
!elseif PLAYDATE then
  return self.tilemap:getTileAtPosition(x, y)
!end
end

function meta:draw(x, y)
!if LOVE2D then
  for i = 1, self.length, 1 do
    local tx = math.floor((i - 1) / self.sizeX) * self.spritesheet.spriteWidth
    local ty = math.floor((i - 1) % self.sizeX) * self.spritesheet.spriteHeight
    self.spritesheet:draw(self.tiles[i], tx, ty)
  end
!elseif PLAYDATE then
  self.tilemap:draw(x, y)
!end
end

return module