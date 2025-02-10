-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#C-graphics.font

local module = {}
playdate.graphics.font = module

local meta = {}
meta.__index = meta
module.__index = meta

function module.new(path)
  local font = setmetatable({}, meta)
  font.data = love.graphics.newFont(path..".fnt")
  font.data:setLineHeight(0)
  return font
end

function module.newFamily(fontPaths)
  error("[ERR] playdate.graphics.font.newFamily() is not yet implemented.")
end

function module.setFont(font, variant)
  error("[ERR] playdate.graphics.font.setFont() is not yet implemented.")
end

function module.getFont(variant)
  error("[ERR] playdate.graphics.font.getFont() is not yet implemented.")
end

function module.setFontFamily(fontFamily)
  error("[ERR] playdate.graphics.font.setFontFamily() is not yet implemented.")
end

function module.setFontTracking(pixels)
  error("[ERR] playdate.graphics.font.setFontTracking() is not yet implemented.")
end

function module.getSystemFont(variant)
  error("[ERR] playdate.graphics.font.getSystemFont() is not yet implemented.")
end

function meta:getTextWidth(str)
  --[[ 
    NOTE: width returned will not be the same as on Playdate
    if a tracking value is set in the font (.fnt)
    https://github.com/GamesRightMeow/playbit/issues/12
  ]]--
  return self.data:getWidth(str)
end

function meta:getHeight()
  return self.data:getHeight()
end

function meta:setTracking(pixels)
  error("[ERR] playdate.graphics.font:setTracking() is not yet implemented.")
end

function meta:getTracking()
  error("[ERR] playdate.graphics.font:getTracking() is not yet implemented.")
end

function meta:getLeading()
  return self.data:getLineHeight()
end

function meta:setLeading(pixels)
  return self.data:setLineHeight(pixels)
end

function meta:getGlyph(character)
  error("[ERR] playdate.graphics.font:getGlyph() is not yet implemented.")
end

-- TODO: handle the overloaded signature (text, rect, leadingAdjustment, wrapMode, alignment)
function meta:drawText(str, x, y, width, height, leadingAdjustment, wrapMode, alignment)
  @@ASSERT(width == nil, "[ERR] Parameter width is not yet implemented.")
  @@ASSERT(height == nil, "[ERR] Parameter height is not yet implemented.")
  @@ASSERT(leadingAdjustment == nil, "[ERR] Parameter leadingAdjustment is not yet implemented.")
  @@ASSERT(wrapMode == nil, "[ERR] Parameter wrapMode is not yet implemented.")
  @@ASSERT(alignment == nil, "[ERR] Parameter alignment is not yet implemented.")
  local currentFont = love.graphics.getFont()
  love.graphics.setFont(self.data)
  love.graphics.print(str, x, y)
  love.graphics.setFont(currentFont)
  playdate.graphics._updateContext()
end

-- 0=left 1=right 2=center
function meta:drawTextAligned(str, x, y, alignment, leadingAdjustment)
  @@ASSERT(leadingAdjustment == nil, "[ERR] Parameter leadingAdjustment is not yet implemented.")
  local width = self:getTextWidth(str)
  if alignment == 1 then
    -- right
    x = x - width
  elseif alignment == 2 then
    -- center
    x = x - width * 0.5  
  end
  -- left, draw normally
  
  local currentFont = love.graphics.getFont()
  love.graphics.setFont(self.data)
  love.graphics.print(str, x, y)
  love.graphics.setFont(currentFont)
  playdate.graphics._updateContext()
end

function meta:_drawTextInRect(text, x, y, width, height, leadingAdjustment, truncationString, textAlignment)
  y = y - 1
  
  local lineHeight = self:getHeight() + self:getLeading() + leadingAdjustment
  
  if lineHeight > height then
    -- even one line won't fit
    return 0, 0, false
  end

  local line = ""
  local lineCount = 0
  local largestLineWidth = 0
  local truncated = false

  for w in string.gmatch(text, "%S+") do
    -- append words to line until it doesn't fit
    local l = line..w
    if self:getTextWidth(l) <= width then
      line = l.." "
      goto continue
    end

    -- trimm trailing space
    line = string.sub(line, 1, #line - 1)

    if lineHeight * (lineCount + 1) > height 
    or lineHeight * (lineCount + 2) > height then
      -- this line or the next line surpasses specified max height
      line = line..truncationString
      local lineWidth = self:getTextWidth(line)
      if lineWidth > largestLineWidth then
        largestLineWidth = lineWidth
      end

      self:drawTextAligned(line, x, y + lineHeight * lineCount, textAlignment)
      line = nil
      lineCount = lineCount + 1
      truncated = true
      break
    end

    local lineWidth = self:getTextWidth(line)
    if lineWidth > largestLineWidth then
      largestLineWidth = lineWidth
    end

    self:drawTextAligned(line, x, y + lineHeight * lineCount, textAlignment)
    line = w.." "
    lineCount = lineCount + 1

    ::continue::
  end

  if line then
    -- print last line if shorter than specified width
    self:drawTextAligned(line, x, y + lineHeight * lineCount, textAlignment)
    lineCount = lineCount + 1

    local lineWidth = self:getTextWidth(line)
    if lineWidth > largestLineWidth then
      largestLineWidth = lineWidth
    end
  end
  
  return largestLineWidth, (lineHeight * lineCount) - leadingAdjustment, truncated
end