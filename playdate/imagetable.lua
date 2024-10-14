local module = {}
playdate.graphics.imagetable = module

local meta = {}
meta.__index = meta
module.__index = meta

function module.new(path)
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

  imagetable.images = {}
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
      table.insert(imagetable.images, image)
    end
  end
  
  imagetable.length = rows * columns
  imagetable.frameWidth = frameWidth
  imagetable.frameHeight = frameHeight

  return imagetable
end

function meta:drawImage(n, x, y, flip)
  self.images[n]:draw(x, y, flip)
end

function meta:getImage(n)
  return self.images[n]
end

function meta:getLength()
  return self.length
end