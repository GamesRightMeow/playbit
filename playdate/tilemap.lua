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
  tilemap.length = 0
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
  for i = 1, self.length, 1 do
    self.tiles[i] = 0
  end
end

function meta:setTileAtPosition(x, y, tile)
  local index = self.width * (x - 1) + y
  self.tiles[index] = tile
end

function meta:getTileAtPosition(x, y)
  local index = self.width * (x - 1) + y
  return self.tiles[index]
end

function meta:draw(x, y)
  for i = 1, self.length, 1 do
    local tx = x + math.floor((i - 1) / self.width) * self.imagetable.frameWidth
    local ty = y + math.floor((i - 1) % self.width) * self.imagetable.frameHeight
    self.imagetable:drawImage(self.tiles[i], tx, ty)
  end
end