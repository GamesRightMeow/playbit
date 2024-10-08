--[[ 
Lua script that converts a Playdate Caps .fnt to a BMFont .fnt for usage in Love2d.

Usage: 
  `lua caps-to-bmfont.lua <input_caps_font_path> <input_caps_image_path> <output_bmf_font_path>`
  `lua caps-to-bmfont.lua Roobert-11-Bold.fnt Roobert-11-Bold-table-22-22.png Roobert-BMFont.fnt`

Designed around these specs:
  * https://sdk.play.date/1.9.3/Inside%20Playdate.html#_supported_characters
  * https://sdk.play.date/1.9.3/Inside%20Playdate.html#_text
  * https://www.angelcode.com/products/bmfont/doc/file_format.html

Limitations:
  * does not support non-ascii chars
--]]
local folderOfThisFile = (...):match("(.-)[^%.]+$")
local fs = require(folderOfThisFile..".filesystem")

function isWhitespace(char)
  local start = string.find(char, "%s")
  return start ~= nil
end

function isAscii(char)
  local code = string.byte(char)
  if #char == 0 then
    error("function was given a nil char")
  end

  -- space to tilde
  if (code >= 32 and code <= 126) then
    return true
  end
  
  return false
end

function parseLine(line, inputData, lineNum)
  local start, ends = string.find(line, "%-%-")
  if (start and ends) then
    -- ignore comments
    return
  end
  
  local start, ends = string.find(line, "playbit_width=")
  if (start and ends) then
    inputData.texWidth = tonumber(string.sub(line, ends+1))
    return
  end

  local start, ends = string.find(line, "playbit_height=")
  if (start and ends) then
    inputData.texHeight = tonumber(string.sub(line, ends+1))
    return
  end

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

  if #char1 == 0 or #char2 == 0 then
    -- ignore empty line
    return
  end

  if isWhitespace(char2) then  
    -- if second char is whitespace, we can assume this line is a glyph
    if isAscii(char1) then
      local glyph = {
        string.byte(char1),
        tonumber(string.sub(line, 2))
      }
      table.insert(inputData.glyphs, glyph)
    else
      print("Glyph on line "..lineNum.." in font '"..inputData.name.."' is a non-ASCII character and was skipped because they are not currently supported by Playbit: https://github.com/GamesRightMeow/playbit/issues/2")
      table.insert(inputData.glyphs, {nil})
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
    else
      print("Glyph on line "..lineNum.." in font '"..inputData.name.."' is a non-ASCII character and was skipped because they are not currently supported by Playbit: https://github.com/GamesRightMeow/playbit/issues/2")
      table.insert(inputData.glyphs, {nil})
    end
  end
end

function tableToStr(table)
  local result = ""
  if table[1] then
    -- table is an array, don't prepend key name
    for key, value in pairs(table) do
      result = result..value..","
    end
    result = string.sub(result, 1, #result - 1)
  else
    -- otherwise prepend key name
    for key, value in pairs(table) do
      if type(value) == "table" then
        result = result.." "..key.."="..tableToStr(value)
      elseif type(value) == "string" then
        result = result.." "..key.."=\""..value.."\""
      else
        result = result.." "..key.."="..value
      end
    end
  end
  return result
end

function getGlyphSize(path)
  local start1, ends1 = string.find(path, "%-table%-")
  local start2, ends2 = string.find(path, ".png")
  local sizeStr = string.sub(path, ends1 + 1, start2 - 1)
  local start, ends = string.find(sizeStr, "-")
  local width = tonumber(string.sub(sizeStr, 1, start-1))
  local height = tonumber(string.sub(sizeStr, ends+1))
  return width, height
end

function getAtlasPath(input)
  local platform = fs.getPlatform()
  if platform == fs.WINDOWS then
    local inputNoExt = string.sub(input, 1, #input - 4)
    local command = io.popen("dir /a-d /s /b \""..inputNoExt.."-table-*.png\"")
    return command:read("*a"):match("(.-)\n")
  else
    local inputNoExt = string.sub(input, 1, #input - 4)
    local command = io.popen("find "..inputNoExt.."-table-*.png")
    return command:read("*a"):match("(.-)\n")
  end
end

function convert(inputFntPath, outputFntPath)
  local input = {
    tracking = 0,
    tileWidth = 0,
    tileHeight = 0,
    atlasPath = "",
    glyphs = {},
    kerning = {},
    name = "",
    texWidth = 0,
    texHeight = 0
  }

  -- find atlas based on .fnt path
  input.atlasPath = getAtlasPath(inputFntPath)

  -- determine name based on file
  input.name = fs.getFileName(inputFntPath)

  -- set glyph size based on .png path
  input.tileWidth, input.tileHeight = getGlyphSize(input.atlasPath)

  -- parse Caps .fnt file
  local inputFile = io.open(inputFntPath, "r")
  io.input(inputFile)
  local line = io.read()
  local lineNum = 1
  while line ~= nil do
    parseLine(line, input, lineNum)
    line = io.read()
    lineNum = lineNum + 1
  end

  -- Lua does not have any native way to read image size, so instead playbit requires font files to add custom keys to specify the font texture dimensions
  if input.texWidth == 0 then
    error("Font '"..input.name..".fnt' does not contain the playbit_width key!")
  end

  if input.texHeight == 0 then
    error("Font '"..input.name..".fnt' does not contain the playbit_height key!")
  end

  if input.texWidth % input.tileWidth ~= 0 then
    error("Font '"..input.name..".fnt' does not have a texture width that is evenly divisible by tile width. Is the playbit_width key set to the correct value?")
  end

  if input.tileHeight % input.tileHeight ~= 0 then
    error("Font '"..input.name..".fnt' does not have a texture height that is evenly divisible by tile height. Is the playbit_height key set to the correct value?")
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
    padding = { 0, 0, 0, 0 },
    spacing = { 0, 0 },
    outline = 0
  }
  io.write("info"..tableToStr(info))

  local common = {
    lineHeight = input.tileHeight,
    base = input.tileHeight,
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
    file = fs.getFileName(input.atlasPath)..".png",
  }
  io.write("\npage"..tableToStr(page))

  -- glyphs
  local glyphsPerRow = input.texWidth / input.tileWidth
  io.write("\nchars count="..#input.glyphs)
  for i = 1, #input.glyphs, 1 do
    local index = i - 1
    local id = input.glyphs[i][1]
    local leading = input.glyphs[i][2]

    if id == nil then
      --[[ Skip nil glyphs. These characters are unsupported by playbit
      but we still need to count other wise glyph position will be off. ]]--
      goto continue
    end

    local glyph = {
      id = id,
      x = (index % glyphsPerRow) * input.tileWidth,
      y = math.floor(index / glyphsPerRow) * input.tileHeight,
      width = input.tileWidth,
      height = input.tileHeight,
      xoffset = 0,
      yoffset = 0,
      xadvance = leading + input.tracking,
      page = 0,
      chnl = 15,
    }
    io.write("\nchar"..tableToStr(glyph))
    ::continue::
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

return convert
