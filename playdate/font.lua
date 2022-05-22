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

function meta:drawTextAligned(str, x, y, alignment)
  error("drawTextAligned() not implemented")
  --   local width = module.getTextSize(str)
  --   if align == "center" then
  --     x = x - width * 0.5  
  --   elseif align == "right" then
  --     x = x - width
  --   end
end