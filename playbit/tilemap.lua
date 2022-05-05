local module = {}

local meta = {}
meta.__index = meta
module.__index = meta

-- TODO: is drawing with a nested array vs 1d array is faster on playdate?
-- TODO: is the native playdate tilemap faster?

function module.new(spritesheet, rows, columns)
  local tilemap = { 
    spritesheet = spritesheet,
    rows = rows, 
    length = rows * columns,
    tiles = {},
  }
  setmetatable(tilemap, meta)
  
  for i = 1, tilemap.length, 1 do
    tilemap.tiles[i] = 1
  end

  return tilemap
end

function meta:setTile(row, col, tile)
  local index = self.rows * (row - 1) + col
  self.tiles[index] = tile
end

function meta:getTile(row, col)
  local index = self.rows * (row - 1) + col
  return self.tiles[index]
end

function meta:draw(x, y)
  for i = 1, self.length, 1 do
    local tx = math.floor((i - 1) / self.rows) * self.spritesheet.spriteWidth
    local ty = math.floor((i - 1) % self.rows) * self.spritesheet.spriteHeight
    self.spritesheet:draw(self.tiles[i], tx, ty)
  end
end

return module