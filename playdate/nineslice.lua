-- docs: https://sdk.play.date/3.0.2/Inside%20Playdate.html#C-graphics.nineSlice

local module = {}
playdate.graphics.nineSlice = module

local meta = {}
meta.__index = meta
module.__index = meta

function module.new(imagePath, innerX, innerY, innerWidth, innerHeight)
  --playdate.graphics.nineSlice.new(imagePath, innerX, innerY, innerWidth, innerHeight)
  local nineSlice = setmetatable({}, meta)
  nineSlice._image = playdate.graphics.image.new(imagePath)
  local width, height = nineSlice._image:getSize()
  nineSlice._rightSize = width - innerWidth - innerX
  nineSlice._bottomSize = height - innerHeight - innerY
  nineSlice._innerWidth = innerWidth
  nineSlice._innerHeight = innerHeight
  nineSlice._leftSize = innerX
  nineSlice._topSize = innerY

  nineSlice._imageSections = {}

  nineSlice._imageSectionQuad = {}

  return nineSlice
end
function meta:getMinSize()
  return self._rightSize + self._leftSize ,self._topSize + self._bottomSize
end
function meta:getSize()
  return self._image:getSize()
end
function meta:drawInRect(x, y, width, height)
  -- Implement image.drawTiled and use that:
  if width < self._rightSize + self._leftSize then width = self._rightSize + self._leftSize end
  if height < self._topSize + self._bottomSize then height = self._topSize + self._bottomSize end
  if y == nil then
    error("[ERR] playdate.nineSlice draw with RECT is not yet implemented.")
  end
  if self._imageSectionImages == nil then
    self._imageSectionImages = {}
    local sliceX = {0,self._leftSize,self._leftSize+self._innerWidth}
    local sliceY = {0,self._topSize,self._topSize+self._innerHeight}
    local sliceWidth = {self._leftSize,self._innerWidth,self._rightSize}
    local sliceHeight = {self._topSize,self._innerHeight,self._bottomSize}
    for i = 1, 3, 1 do
      -- TL , TM , TR , ML, MM, MR , BL , BM , BR
      for j = 1,3,1 do
        if sliceWidth[i] > 0 and sliceHeight[j] > 0 then
          self._imageSectionImages[i+(j-1)*3] = playdate.graphics.image.new(sliceWidth[i], sliceHeight[j])
          playdate.graphics.pushContext(self._imageSectionImages[i+(j-1)*3])
          playdate.graphics.clear(2)
          self._image:draw(-sliceX[i],-sliceY[j])
          playdate.graphics.popContext()
        end
      end
    end
  end
  
  if self._drawImage == nil then
    self._drawImage= playdate.graphics.image.new(width,height)
  end
  local drawImageWidth, drawImageHeight = self._drawImage:getSize()
  if drawImageHeight ~= height or drawImageWidth ~= width then
    self._drawImage= playdate.graphics.image.new(width,height)
  end
  local drawPosX = {0,self._leftSize,width-self._rightSize}
  local drawPosY = {0,self._topSize,height-self._bottomSize}
  local drawWidth = {self._leftSize,width-self._rightSize-self._leftSize,self._rightSize}
  local drawHeight = {self._topSize,height-self._bottomSize-self._topSize,self._bottomSize}
  playdate.graphics.pushContext(self._drawImage)
  playdate.graphics.clear(2)
  for i = 1, 3, 1 do
    -- TL , TM , TR , ML, MM, MR , BL , BM , BR
    for j = 1,3,1 do
      if drawWidth[i] > 0 and drawHeight[j] > 0 then
        self._imageSectionImages[i+(j-1)*3]:drawTiled(drawPosX[i],drawPosY[j],drawWidth[i],drawHeight[j])
      end
    end
  end
  playdate.graphics.popContext()
  self._drawImage:draw(x,y)
end
