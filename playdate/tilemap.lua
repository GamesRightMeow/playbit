local module = {}
playdate.graphics.tilemap = module

local meta = {}
meta.__index = meta
module.__index = meta

function module.new()
  local tilemap = setmetatable({}, meta)
  return tilemap
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
  for x = 1, self._width, 1 do
    local column = {}
    for y = 1, self._height, 1 do
      column[y] = 0
    end
    self._tiles[x] = column
  end
end

function meta:setTileAtPosition(x, y, tile)
  self._tiles[x][y] = tile
end

function meta:getTileAtPosition(x, y)
  return self._tiles[x][y]
end

function meta:draw(x, y)
  -- always render pure white so its not tinted
  local r, g, b = love.graphics.getColor()
  love.graphics.setColor(1, 1, 1, 1)

  local w = self._imagetable._width
  local h = self._imagetable._height
  local frameWidth = self._imagetable._frameWidth
  local frameHeight = self._imagetable._frameHeight
  local imageRows = self._imagetable._rows

  for tx = 1, self._width, 1 do
    for ty = 1, self._height, 1 do
      local index = self._tiles[tx][ty]
      local dx = x + ((tx - 1) * frameWidth)
      local dy = y + ((ty - 1) * frameHeight)
      local qx = math.floor((index - 1) % imageRows) * frameHeight
      local qy = math.floor((index - 1) / imageRows) * frameWidth
      playdate.graphics._quad:setViewport(qx, qy, frameWidth, frameHeight, w, h)
      love.graphics.draw(self._imagetable._images[index].data, dx, dy)
    end
  end

  love.graphics.setColor(r, g, b, 1)
  playdate.graphics._updateContext()
end