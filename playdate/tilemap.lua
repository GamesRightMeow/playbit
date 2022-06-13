local module = {}
playdate.graphics.tilemap = module

local meta = {}
meta.__index = meta
module.__index = meta

function module.new(imagetable, width, height)
  local tilemap = setmetatable({}, meta)
  tilemap.imagetable = nil
  tilemap.width = 0
  tilemap.height = 0
  tilemap.tiles = {}
  return tilemap
end

function meta:setImageTable(table)
  self.imagetable = table
end

function meta:setSize(width, height)
  self.width = width
  self.height = height
  self.length = width * height

  -- TODO: this will clear the tilemap if set later, what does PD do?
  self.tiles = {}
  for x = 1, self.width, 1 do
    local column = {}
    for y = 1, self.height, 1 do
      column[y] = 0
    end
    self.tiles[x] = column
  end
end

function meta:setTileAtPosition(x, y, tile)
  self.tiles[x][y] = tile
end

function meta:getTileAtPosition(x, y)
  return self.tiles[x][y]
end

function meta:draw(x, y)
  for tx = 1, self.width, 1 do
    for ty = 1, self.height, 1 do
      local index = self.tiles[tx][ty]
      local dx = x + ((tx - 1) * self.imagetable.frameWidth)
      local dy = y + ((ty - 1) * self.imagetable.frameHeight)
      self.imagetable:drawImage(index, dx, dy)
    end
  end
end