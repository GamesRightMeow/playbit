-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#C-graphics.imagetable

local module = {}
playdate.graphics.imagetable = module

local meta = {}
meta.__index = meta
module.__index = meta

-- TODO: overload the `[]` array index operator to return an image
-- TODO: overload the `#` length operator to return the number of images

local function splitPath(path)
  path = path:gsub("[/\\]+$", "")

  local dir, tail = path:match("^(.*[/\\])([^/\\]+)$")
  if not dir then
    dir, tail = "", path
  end

  local name, ext = tail:match("^(.*)%.([^%.]+)$")
  if name and name ~= "" and tail:sub(1,1) ~= "." then
    -- ok: "file.png" -> name="file", ext="png"
    -- ok: "file.tar.gz" -> name="file.tar", ext="gz"
  else
    name, ext = tail, nil
  end

  return dir, name, ext
end

-- returns actualPath, frameWidth, frameHeight
local function resolveImagePath(path)
  local folder, name, ext = splitPath(path)
  folder = folder or ""
  ext = ext or ""

  -- if this is partial name then scan the folder
  if not string.find(name, "-table-", nil, true) then
    local pattern = name.."-table-"
    name = nil
    local files = love.filesystem.getDirectoryItems(folder)
    for i = 1, #files do
      local f = files[i]
      if string.find(f, pattern, nil, true) then
        local fd, fn, fe = splitPath(f)
        if fe == "png" then
          name = fn
          break
        end
      end
    end

    if not name then return end
  end

  -- parse frame width and height out of filename
  local matches = string.gmatch(name, "%-(%d+)")
  local frameWidth = tonumber(matches())
  local frameHeight = tonumber(matches())

  return folder .. name .. ".png", frameWidth, frameHeight
end

-- TODO: handle overloaded signature (count, cellsWide, cellSize)
function module.new(path, cellsWide, cellsSize)
  @@ASSERT(cellsWide == nil, "[ERR] Parameter cellsWide is not yet implemented.")
  @@ASSERT(cellsSize == nil, "[ERR] Parameter cellsSize is not yet implemented.")

  local actualPath, frameWidth, frameHeight = resolveImagePath(path)
  if not actualPath then
    return nil -- todo: error?
  end

  local imagetable = setmetatable({}, meta)

  -- load atlas
  local atlas = love.image.newImageData(actualPath)

  -- create a separate image for each frame
  local w = atlas:getWidth()
  local h = atlas:getHeight()
  local rows = h / frameHeight
  local columns = w / frameWidth

  local images = {}
  for r = 0, rows - 1, 1 do
    for c = 0, columns - 1, 1 do
      
      local imageData = love.image.newImageData(frameWidth, frameHeight)
      for x = 0, frameWidth - 1, 1 do
        for y = 0, frameHeight - 1, 1 do
          local r, g, b, a = atlas:getPixel(x + (c * frameWidth), y + (r * frameHeight))
          imageData:setPixel(x, y, r, g, b, a)
        end
      end

      local image = playdate.graphics.image.new(frameWidth, frameHeight)
      image.data:replacePixels(imageData)
      table.insert(images, image)
    end
  end
  
  imagetable.length = rows * columns

  imagetable._images = images
  imagetable._width = w
  imagetable._height = h
  imagetable._rows = rows
  imagetable._columns = columns
  imagetable._frameWidth = frameWidth
  imagetable._frameHeight = frameHeight

  return imagetable
end

function meta:drawImage(n, x, y, flip)
  self._images[n]:draw(x, y, flip)
end

-- TODO: handle overloaded signature (x, y)
function meta:getImage(n)
  return self._images[n]
end

function meta:setImage(n, image)
  error("[ERR] playdate.graphics.imagetable:setImage() is not yet implemented.")
end

function meta:load(path)
  error("[ERR] playdate.graphics.imagetable:load() is not yet implemented.")
end

function meta:getLength()
  return self.length
end

function meta:getSize()
    return self._columns, self._rows
end
