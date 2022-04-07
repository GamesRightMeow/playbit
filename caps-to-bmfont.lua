-- does not support non-ascii chars

local inputPath = arg[1]
local outputPath = arg[2]

local glyphs = {}

function isWhitespace(char)
  local start = string.find(char, "%s")
  return start ~= nil
end

-- https://sdk.play.date/1.9.3/Inside%20Playdate.html#_supported_characters
function isAscii(char)
  local code = string.byte(char)

  -- space to tilde
  if (code >= 32 and code <= 126) then
    return true
  end
  
  return false
end

function parseLine(line)
  local start, ends = string.find(line, "tracking=")
  if (start and ends) then
    -- TODO: extract value
    print("tracking: "..start..ends)
    return
  end

  local start, ends = string.find(line, "space")
  if (start and ends) then
    -- TODO: extract value
    print("space: "..start..ends)
    return
  end

  local char1 = string.sub(line, 1, 1)
  local char2 = string.sub(line, 2, 2)

  if isWhitespace(char2) then  
    -- if second char is whitespace, we can assume this line is a glyph
    if isAscii(char1) then
      -- TODO: extract value
      print("glyph: "..char1.."="..string.byte(char1))
      -- table.insert(glyphs, { char1, width })
    end
  else
    -- otherwise assume is a kerning pair
    if isAscii(char1) then
      -- TODO: extract value
      -- if the first char is supported, assume this is a kerning pair  
      print("kerning: "..char1..char2)
    end
  end
end

-- https://sdk.play.date/1.9.3/Inside%20Playdate.html#_text
local inputFile = io.open(inputPath, "r")
io.input(inputFile)
local line = io.read()
while line ~= nil do
  parseLine(line)
  line = io.read()
end

-- TODO: convert to BMFont file
-- https://www.angelcode.com/products/bmfont/doc/file_format.html
-- local outputFile = io.open(outputPath, "w+")
-- io.output(outputFile)
-- io.write(io.read())
-- io.close(outputFile)