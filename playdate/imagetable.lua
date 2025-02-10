-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#C-graphics.imagetable

local module = {}
playdate.graphics.imagetable = module

local meta = {}
meta.__index = meta
module.__index = meta

-- TODO: overload the `[]` array index operator to return an image
-- TODO: overload the `#` length operator to return the number of images

-- TODO: handle overloaded signature (count, cellsWide, cellSize)
function module.new(path, cellsWide, cellsSize)
  @@ASSERT(cellsWide == nil, "[ERR] Parameter cellsWide is not yet implemented.")
  @@ASSERT(cellsSize == nil, "[ERR] Parameter cellsSize is not yet implemented.")

  local imagetable = setmetatable({}, meta)
  local folder = ""
  local pattern = path.."-table-"

  -- no findLast() so reverse string first
  local start, ends = string.find(string.reverse(path), "/")
  if start and ends then
    folder = string.sub(path, 1, #path - ends)
    pattern = string.sub(path, #path - ends + 2).."-table-"
  end

  -- escape dashes
  pattern = string.gsub(pattern, "%-", "%%%-")
  -- TODO: escape other magic chars?

  -- TODO: support about a sequence of files (image1.png, image2.png, etc)
  local actualFilename = ""
  local files = love.filesystem.getDirectoryItems(folder)
  for i = 1, #files, 1 do
    local f = files[i]
    local s, e = string.find(f, pattern)
    if s and e then
      -- file found, remove extension
      actualFilename = string.sub(f, 1, #f - 4)
      break
    end
  end

  -- parse frame width and height out of filename
  local matches = string.gmatch(actualFilename, "%-(%d+)")
  local frameWidth = tonumber(matches())
  local frameHeight = tonumber(matches())
  local actualPath = folder.."/"..actualFilename

  -- load atlas
  local atlas = love.image.newImageData(actualPath..".png")
  
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
    return self._rows, self._columns
end
