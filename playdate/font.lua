local module = {}
playdate.graphics.font = module

local meta = {}
meta.__index = meta
module.__index = meta

function module.new(path)
  local font = setmetatable({}, meta)
  font.data = love.graphics.newFont(path..".fnt")
  return font
end

function meta:getWidth(str)
  return self.data:getWidth(str)
end

function meta:getHeight()
  return self.data:getHeight()
end

function meta:drawText(str, x, y)
  love.graphics.print(str, x, y)
end

-- 0=left 1=right 2=center
function meta:drawTextAligned(str, x, y, alignment)
  local width = self:getWidth(str)
  if alignment == 1 then
    -- right
    x = x - width
  elseif alignment == 2 then
    -- center
    x = x - width * 0.5  
  end
  -- left, draw normally
  
  love.graphics.print(str, x, y)
end