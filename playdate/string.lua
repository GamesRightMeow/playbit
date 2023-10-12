local module = {}
playdate.string = module

function module.UUID(length)
  local str = ""
  for i = 1, length do 
    str = str..string.char(math.random(65, 90)) 
  end
  return str
end

function module.getTextSize(str)
  return playdate.graphics.getTextSize(str)
end

-- trim7() from http://lua-users.org/wiki/StringTrim
local match = string.match
function module.trimWhitespace(str)
  return match(str, '^()%s*$') and '' or match(str, '^%s*(.*%S)')
end

function module.trimLeadingWhitespace(str)
  return match(str, '^%s*(.+)')
end

function module.trimTrailingWhitespace(str)
  return match(str, '(.-)%s*$')
end
