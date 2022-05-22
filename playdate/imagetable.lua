local module = {}
playdate.graphics.imagetable = module

local meta = {}
meta.__index = meta
module.__index = meta

function module.new(path)
  local imagetable = setmetatable({}, meta)

  -- FIXME: what if no folder?
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

  local image = playdate.graphics.image.new(actualPath)
  local w, h = image:getSize()
  imagetable.image = image
  imagetable.rows = w / frameWidth
  imagetable.columns = h / frameHeight
  imagetable.length = imagetable.rows * imagetable.columns
  imagetable.frameWidth = frameWidth
  imagetable.frameHeight = frameHeight

  return imagetable
end

function meta:drawImage(n, x, y, flip)
  -- TODO: cache index calculation
  local qx = math.floor((n - 1) % self.rows) * self.frameHeight
  local qy = math.floor((n - 1) / self.rows) * self.frameWidth
  self.image:draw(x, y, flip, qx, qy, self.frameWidth, self.frameHeight)
end

function meta:getLength()
  return self.length
end