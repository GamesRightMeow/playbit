local module = {}
playdate.graphics.video = module

local meta = {}
meta.__index = meta
module.__index = meta

require("playbit.util")

local function loadFrameData(vid, number)
  @@ASSERT(number > 0 and number <= vid.frameCount, "Invalid frame number: " .. number)
  
  local bufferCompressed = vid.imageBuffers[number]
  local bufferRaw = love.data.decompress("string", "zlib", bufferCompressed)
  
  local imageData = love.image.newImageData(vid.width, vid.height)
  local fillColorWhite = playdate.graphics.getLoveColor(1)
  local fillColorBlack = playdate.graphics.getLoveColor(0)
  
  local charWidth = vid.width / 8
  local bufferSize = charWidth * vid.height
  for y = 0, vid.height - 1 do
    for xchar = 0, charWidth - 1 do
	  -- Ready 8 pixels at once
	  local chunkIndex = y * charWidth + (charWidth - xchar - 1)
	  local chunk = playbit.util.readUInt8(bufferRaw, bufferSize, chunkIndex)
	  for shift = 0, 7 do
	    x = vid.width - (xchar * 8 + shift) - 1
		local isWhite = (bit.band(bit.rshift(chunk, shift), 0x1) == 0x1)
		if isWhite then
	      imageData:setPixel(x, y, fillColorWhite.r, fillColorWhite.g, fillColorWhite.b, 1)
		else
	      imageData:setPixel(x, y, fillColorBlack.r, fillColorBlack.g, fillColorBlack.b, 1)
		end
      end
	end
  end
  vid.images[number] = playdate.graphics.image.newFromData(imageData)
end

function module.new(path)
  local data, dataSize = love.filesystem.read(path)
  @@ASSERT(data, "Failed to load video data.")
  
  -- Read header
  local headerStr = playbit.util.readChars(data, dataSize, 0, 12)
  @@ASSERT(headerStr == "Playdate VID", "Invalid video data header: " .. headerStr)
  
  local reserved1 = playbit.util.readUInt32(data, dataSize, 12)
  @@ASSERT(reserved1 == 0, "Expected 0 for reserved value: " .. reserved1)
  
  -- Read main info
  local frameCount = playbit.util.readInt16(data, dataSize, 16)
  @@ASSERT(frameCount > 0, "Invalid video frame count: " .. frameCount)
  
  local reserved2 = playbit.util.readInt16(data, dataSize, 18)
  @@ASSERT(reserved2 == 0, "Expected 0 for reserved value: " .. reserved2)
  
  local frameRate = playbit.util.readFloat32(data, dataSize, 20)
  @@ASSERT(frameRate > 0, "Invalid video frame rate: " .. frameRate)
  
  local width = playbit.util.readInt16(data, dataSize, 24)
  @@ASSERT(width == 400, "Invalid video width: " .. width)
  
  local height = playbit.util.readInt16(data, dataSize, 26)
  @@ASSERT(height == 240, "Invalid video height: " .. height)
  
  local vid = setmetatable({}, meta)
  vid.width = width
  vid.height = height
  vid.frameCount = frameCount
  vid.frameRate = frameRate
  vid.imageBuffers = {}
  vid.images = {}
  vid.context = nil
  
  -- Read frame table
  local tableTypes = {}
  local tableOffsets = {}
  local baseOffset = 28 + (frameCount + 1) * 4
  for i = 0, frameCount do
    local v = playbit.util.readUInt32(data, dataSize, 28 + i * 4)
    local type = bit.band(v, 0x3)
    local offset = bit.rshift(v, 2)
	@@ASSERT(type == 1 or type == 0, "Unsupported frame type: " .. type)
	@@ASSERT(type ~= 0 or i == frameCount, "Invalid null frame before end-of-file")
	@@ASSERT(offset + baseOffset <= dataSize, "Invalid frame offset: " .. offset)
    tableTypes[i + 1] = type
    tableOffsets[i + 1] = offset + baseOffset
  end
  @@ASSERT(tableTypes[frameCount + 1] == 0, "Invalid end-of-file offset type: " .. tableTypes[frameCount + 1])
  @@ASSERT(tableOffsets[frameCount + 1] == dataSize, "Invalid end-of-file offset: " .. tableOffsets[frameCount + 1])
  
  -- TODO: add support for P-frame (type 2) and combined frame (type 3)
  
  -- Read frame data
  for f = 1, frameCount do
    local startOffset = tableOffsets[f]
    local endOffset = tableOffsets[f + 1]
    
	local bufferSizeCompressed = endOffset - startOffset
	local bufferCompressed = playbit.util.readChars(data, dataSize, startOffset, bufferSizeCompressed)
	@@ASSERT(bufferCompressed, "Invalid frame data for frame: " .. f)
	
    vid.imageBuffers[f] = playbit.util.readChars(data, dataSize, startOffset, bufferSizeCompressed)
  end
  
  return vid
end

function meta:getSize()
  return self.width, self.height
end

function meta:getFrameCount()
  return self.frameCount
end

function meta:getFrameRate()
  return self.frameRate
end

function meta:setContext(image)
  self.context = image
end

function meta:getContext()
  -- create image context if it doesn't exist
  if self.context == nil then
    self.context = playdate.graphics.image.new(self.width, self.height)
  end
  
  return self.context
end

function meta:useScreenContext()
  -- reset image context if it exists
  self.context = nil
end

function meta:renderFrame(number)
  @@ASSERT(number > 0 and number <= self.frameCount, "Invalid frame number: " .. number)
  
  -- load frame data if needed
  if self.images[number] == nil then
    loadFrameData(self, number)
  end
  
  if self.context then
    -- render into image context
	playdate.graphics.pushContext(self.context)
    self.images[number]:draw(0, 0)
	playdate.graphics.popContext()
  else
    -- directly render frame
    self.images[number]:draw(0, 0)
  end
  
  -- reset frame data
  self.images[number] = nil
  
  -- Force releasing image data to avoid memory leaks
  collectgarbage('collect')
end
