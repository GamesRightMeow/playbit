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

function meta:getTextWidth(str)
  return self.data:getWidth(str)
end

function meta:getHeight()
  return self.data:getHeight()
end

function meta:getLeading()
  return self.data:getLineHeight()
end

function meta:setLeading(pixels)
  return self.data:setLineHeight(pixels)
end

function meta:drawText(str, x, y)
  local currentFont = love.graphics.getFont()
  love.graphics.setFont(self.data)
  love.graphics.print(str, x, y)
  love.graphics.setFont(currentFont)
  playdate.graphics._updateContext()
end

-- 0=left 1=right 2=center
function meta:drawTextAligned(str, x, y, alignment)
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