local module = {}

local meta = {}
meta.__index = meta
module.__index = meta

-- TODO: is drawing with a nested array vs 1d array is faster on playdate?
-- TODO: is the native playdate tilemap faster?

function module.new(spritesheet, rows, columns)
  local tilemap = setmetatable({}, meta)
  --! if LOVE2D then
  tilemap.spritesheet = spritesheet
  tilemap.rows = rows
  tilemap.length = rows * columns
  tilemap.tiles = {}
  for i = 1, tilemap.length, 1 do
    tilemap.tiles[i] = 1
  end
  --! elseif PLAYDATE then
  local tm = playdate.graphics.tilemap.new()
  tm:setImageTable(spritesheet.imagetable)
  tm:setSize(rows, columns)
  tilemap.tilemap = tm
  --! end
  return tilemap
end

function meta:setTile(row, col, tile)
  --! if LOVE2D then
  local index = self.rows * (row - 1) + col
  self.tiles[index] = tile
  --! elseif PLAYDATE then
  self.tilemap:setTileAtPosition(row, col, tile)
  --! end
end

function meta:getTile(row, col)
  --! if LOVE2D then
  local index = self.rows * (row - 1) + col
  return self.tiles[index]
  --! elseif PLAYDATE then
  return self.tilemap:getTileAtPosition(row, col)
  --! end
end

function meta:draw(x, y)
  --! if LOVE2D then
  for i = 1, self.length, 1 do
    local tx = math.floor((i - 1) / self.rows) * self.spritesheet.spriteWidth
    local ty = math.floor((i - 1) % self.rows) * self.spritesheet.spriteHeight
    self.spritesheet:draw(self.tiles[i], tx, ty)
  end
  --! elseif PLAYDATE then
  self.tilemap:draw(x, y)
  --! end
end

return module