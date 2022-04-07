local inputPath = arg[1]
local outputPath = arg[2]

local glyphs = {}

function parseKerning(line)

end

function parseGlyph(line)
  local char = string.sub(line, 1, 1)
  local ascii = string.byte(char)
  local start, ends = string.find(line, ".%s")
  if not start then
    start = "nil"
  end
  -- FIXME: how to detect a special char? They don't seem to be a single char?
  -- maybe read line until whitespace, then use those chars to convert to ascii
  print(char..":"..ascii..":"..start)
  if (ascii >= 32 and ascii <= 126) then
    -- print("glyph: "..ascii)
    -- table.insert(glyphs, { char, width })
    return true
  end
  return false
end

function parseTracking(line)
  local start, ends = string.find(line, "tracking=")
  if (start and ends) then
    print("tracking: "..start..ends)
    return true
  end
  return false
end

-- https://sdk.play.date/1.9.3/Inside%20Playdate.html#_text
local inputFile = io.open(inputPath, "r")
io.input(inputFile)
local line = io.read()
while line ~= nil do
  if (parseTracking(line)) then
  else
    parseGlyph(line)
  end

  line = io.read()
end



-- TODO: use to convert chars to ASCII code
-- string.byte(" ")

-- https://www.angelcode.com/products/bmfont/doc/file_format.html
-- local outputFile = io.open(outputPath, "w+")
-- io.output(outputFile)
-- io.write(io.read())
-- io.close(outputFile)