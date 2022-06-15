local input = {
  "w	10",
  "© 12",
  "�		12",
  "¥		8",
  "ag		0",
  "©¥         0",
  "©a         0",
}

function isWhitespace(char)
  local start = string.find(char, "%s")
  return start ~= nil
end

function splitLine(line)
  local a = ""
  local b = ""
  local reachedSpace = false
  for i = 1, #line, 1 do
    local char = line:sub(i, i)
    if isWhitespace(char) then
      reachedSpace = true
    else
      if reachedSpace then
        b = b..char
      else
        a = a..char
      end
    end
  end
  return a, b
end


for i = 1, #input, 1 do
  local line = input[i]
  local a, b = splitLine(line)
  print(a.."|"..b)
  -- https://stackoverflow.com/questions/24190608/lua-string-byte-for-non-ascii-characters
  for c in a:gmatch("[\x80-\xBF]*") do
    print(c:byte(1, -1))
  end
end
