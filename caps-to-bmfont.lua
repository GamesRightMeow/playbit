--[[ 

Designed around these specs:
  * https://sdk.play.date/1.9.3/Inside%20Playdate.html#_supported_characters
  * https://sdk.play.date/1.9.3/Inside%20Playdate.html#_text
  * https://www.angelcode.com/products/bmfont/doc/file_format.html

Limitations:
  * does not support non-ascii chars
  * cannot determine texture width/height - must be provided

Usage: 
  `lua caps-to-bmfont.lua Roobert-11-Bold.fnt Roobert-11-Bold-table-22-32.png output.fnt 352 176`

--]]

function isWhitespace(char)
  local start = string.find(char, "%s")
  return start ~= nil
end

function isAscii(char)
  local code = string.byte(char)

  -- space to tilde
  if (code >= 32 and code <= 126) then
    return true
  end
  
  return false
end

function parseLine(line, inputData)
  local start, ends = string.find(line, "tracking=")
  if (start and ends) then
    inputData.tracking = string.sub(line, ends+1)
    return
  end

  local start, ends = string.find(line, "space")
  if (start and ends) then
    local glyph = {
      32,
      tonumber(string.sub(line, ends+1))
    }
    table.insert(inputData.glyphs, glyph)
    return
  end

  local char1 = string.sub(line, 1, 1)
  local char2 = string.sub(line, 2, 2)

  if isWhitespace(char2) then  
    -- if second char is whitespace, we can assume this line is a glyph
    if isAscii(char1) then
      local glyph = {
        string.byte(char1),
        tonumber(string.sub(line, 2))
      }
      table.insert(inputData.glyphs, glyph)
    end
  else
    -- otherwise assume is a kerning pair
    if isAscii(char1) then
      -- TODO: extract value
      -- if the first char is supported, assume this is a kerning pair  
      -- print("kerning: "..char1..char2)
      local pair = {
        string.byte(char1),
        string.byte(char2),
        tonumber(string.sub(line, 3))
      }
      table.insert(inputData.kerning, pair)
    end
  end
end

function tableToStr(table)
  local result = ""
  for key, value in pairs(table) do
    result = result.." "..key.."="..value
  end
  return result
end

function getGlyphSize(path)
  local start1, ends1 = string.find(path, "%-table%-")
  local start2, ends2 = string.find(path, ".png")
  local sizeStr = string.sub(path, ends1 + 1, start2 - 1)
  local start, ends = string.find(sizeStr, "-")
  local width = string.sub(sizeStr, 1, start-1)
  local height = string.sub(sizeStr, ends+1)
  return width, height
end

function getName(path)
  local name = path
  local nameReversed = string.reverse(name)
  local lastSlash = #name - string.find(nameReversed, "/")
  name = string.sub(name, lastSlash + 2)
  name = string.gsub(name, ".fnt", "")
  return name
end

function convert(inputFntPath, inputImgPath, outputFntPath, inputImgWidth, inputImgHeight)
  local input = {
    tracking = 0,
    glyphWidth = 0,
    glyphHeight = 0,
    glyphs = {},
    kerning = {},
    name = "",
    texWidth = inputImgWidth,
    textHeight = inputImgHeight
  }

  -- determine name based on file
  input.name = getName(inputFntPath)

  -- set glyph size based on .png path
  input.glyphWidth, input.glyphHeight = getGlyphSize(inputImgPath)

  -- parse Caps .fnt file
  local inputFile = io.open(inputFntPath, "r")
  io.input(inputFile)
  local line = io.read()
  while line ~= nil do
    parseLine(line, input)
    line = io.read()
  end

  -- convert to BMFont .fnt file
  local outputFile = io.open(outputFntPath, "w+")
  io.output(outputFile)

  -- metadata
  local info = {
    face = input.name,
    size = 32,
    bold = 0,
    italic = 0,
    charset = "",
    unicode = 1,
    stretchH = 100,
    smooth = 0,
    aa = 0,
    padding = "0,0,0,0",
    spacing = input.tracking..",0",
    outline = 0
  }
  io.write("info"..tableToStr(info))

  local common = {
    lineHeight = input.glyphHeight,
    base = input.glyphHeight,
    scaleW = input.texWidth, 
    scaleH = input.texHeight,
    pages = 1,
    packed = 0,
    alphaChnl = 0,
    redChnl = 0,
    greenChnl = 0,
    blueChnl = 0
  }
  io.write("\ncommon"..tableToStr(common))

  local page = {
    id = 0,
    file = inputImgPath,
  }
  io.write("\npage"..tableToStr(page))

  -- glyphs
  local glyphsPerRow = input.texWidth / input.glyphWidth
  io.write("\nchars count="..#input.glyphs)
  for i = 1, #input.glyphs, 1 do
    local glyph = {
      id = input.glyphs[i][1],
      x = (i % glyphsPerRow) * input.glyphWidth,
      y = math.floor(i / glyphsPerRow) * input.glyphHeight,
      width = input.glyphWidth,
      height = input.glyphHeight,
      xoffset = 0,
      yoffset = 0,
      xadvance = 0,
      page = 0,
      chnl = 15,
    }
    io.write("\nchar"..tableToStr(glyph))
  end

  -- kerning
  io.write("\nkernings count="..#input.kerning)
  for i = 1, #input.kerning, 1 do
    local kerning = {
      first = input.kerning[i][1],
      second = input.kerning[i][2],
      amount = input.kerning[i][3],
    }
    io.write("\nkerning"..tableToStr(kerning))
  end
  
  io.close(outputFile)
end

local inputFntPath = arg[1]
if not inputFntPath then
  error("Input Caps .fnt file not specified!")
end

local inputImgPath = arg[2]
if not inputImgPath then
  error("Input Caps .png file not specified!")
end

local outputFntPath = arg[3]
if not outputFntPath then
  error("Output BMFont .fnt path not specified!")
end

-- optional
local inputImgWidth = arg[4]
local inputImgHeight = arg[5]

convert(inputFntPath, inputImgPath, outputFntPath, inputImgWidth, inputImgHeight)