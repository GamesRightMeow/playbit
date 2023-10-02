-- taken from the playdate sdk

playdate.string = {}

function playdate.string.UUID(length)
  str = ""
  for i=1, length do str = str..string.char(math.random(65, 90)) end
  return str
end

function playdate.string.getTextSize(str)
  return playdate.graphics.getTextSize(str)
end

-- trim7() from http://lua-users.org/wiki/StringTrim
local match = string.match
function playdate.string.trimWhitespace(str)
   return match(str,'^()%s*$') and '' or match(str,'^%s*(.*%S)')
end

function playdate.string.trimLeadingWhitespace(str)
   return match(str,'^%s*(.+)')
end

function playdate.string.trimTrailingWhitespace(str)
   return match(str,'(.-)%s*$')
end
