local module = {}
playdate.graphics = module

-- #b0aea7
local COLOR_WHITE = { r = 176 / 255, g = 174 / 255, b = 167 / 255 }
-- #312f28
local COLOR_BLACK = { r = 49 / 255, g = 47 / 255, b = 40 / 255 }

module._shader = love.graphics.newShader("playdate/shader")
module._drawOffset = { x = 0, y = 0}
module._drawColor = COLOR_WHITE
module._backgroundColor = COLOR_BLACK
module._activeFont = {}
module._drawMode = "copy"
module._canvas = love.graphics.newCanvas()
module._contextStack = {}
-- shared quad to reduce gc
module._quad = love.graphics.newQuad(0, 0, 1, 1, 1, 1)
module._lastClearColor = COLOR_WHITE
module._screenScale = 1
module._newScreenScale = 1

module.kDrawModeCopy = 0
module.kDrawModeWhiteTransparent = 1
module.kDrawModeBlackTransparent = 2
module.kDrawModeFillWhite = 3
module.kDrawModeFillBlack = 4
module.kDrawModeXOR = 5
module.kDrawModeNXOR = 6
module.kDrawModeInverted = 7

kTextAlignment = {
	left = 0,
	right = 1,
	center = 2,
}

function module.setDrawOffset(x, y)
  module._drawOffset.x = x
  module._drawOffset.y = y
  love.graphics.pop()
  love.graphics.push()
  love.graphics.translate(x, y)
end

function module.getDrawOffset()
  return module._drawOffset.x, module._drawOffset.y
end

function module.setBackgroundColor(color)
  @@ASSERT(color == 1 or color == 0, "Only values of 0 (black) or 1 (white) are supported.")
  if color == 1 then
    module._backgroundColor = COLOR_WHITE
  else
    module._backgroundColor = COLOR_BLACK
  end
  -- don't actually set love's bg color here since doing so immediately sets the color, and this is not consistent with PD
end

function module.setColor(color)
  @@ASSERT(color == 1 or color == 0, "Only values of 0 (black) or 1 (white) are supported.")
  -- when drawing without a pattern, we must flip the pattern mask for white/black because of the way the shader draws patterns
  if color == 1 then
    module._drawColor = COLOR_WHITE
    -- reset pattern, as per PD behavior
    module.setPattern({0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff})
    love.graphics.setColor(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b, 1)
  else
    module._drawColor = COLOR_BLACK
    -- reset pattern, as per PD behavior
    module.setPattern({0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00})
    love.graphics.setColor(COLOR_BLACK.r, COLOR_BLACK.g, COLOR_BLACK.b, 1)
  end
end

function module.setPattern(pattern)
  module._drawPattern = pattern

  -- bitshifting does not work in shaders, so do it here in Lua
  local pixels = {}
  for i = 1, 8 do
    for j = 7, 0, -1 do
      local b = bit.lshift(1, j)
      if bit.band(pattern[i], b) == b then
        table.insert(pixels, 1)
      else
        table.insert(pixels, 0)
      end
    end
  end
  
  module._shader:send("pattern", unpack(pixels))
end

function module.clear(color)
  if not color then
    local c = module._backgroundColor
    love.graphics.clear(c.r, c.g, c.b, 1)
    module._lastClearColor = c
  else
    @@ASSERT(color == 1 or color == 0, "Only values of 0 (black) or 1 (white) are supported.")
    if color == 1 then
      love.graphics.clear(COLOR_WHITE.r, COLOR_WHITE.g, COLOR_WHITE.b, 1)
      module._lastClearColor = COLOR_WHITE
    else
      love.graphics.clear(COLOR_BLACK.r, COLOR_BLACK.g, COLOR_BLACK.b, 1)
      module._lastClearColor = COLOR_BLACK
    end
  end
  module._updateContext()
end

-- "copy", "inverted", "XOR", "NXOR", "whiteTransparent", "blackTransparent", "fillWhite", or "fillBlack".
function module.setImageDrawMode(mode)
  module._drawMode = mode
  if mode == module.kDrawModeCopy or mode == "copy" then
    module._shader:send("mode", 0)
  elseif mode == module.kDrawModeFillWhite or mode == "fillWhite" then
    module._shader:send("mode", 1)
  elseif mode == module.kDrawModeFillBlack or mode == "fillBlack" then
    module._shader:send("mode", 2)
  else
    error("Draw mode '"..mode.."' not implemented.")
  end
end

function module.drawCircleAtPoint(x, y, radius)
  module._shader:send("mode", 8)

  love.graphics.circle("line", x, y, radius)
  module._updateContext()

  module.setImageDrawMode(module._drawMode)
end

function module.fillCircleAtPoint(x, y, radius)
  module._shader:send("mode", 8)

  love.graphics.circle("fill", x, y, radius)
  module._updateContext()

  module.setImageDrawMode(module._drawMode)
end

function module.setLineWidth(width)
  love.graphics.setLineWidth(width)
end

function module.drawRect(x, y, width, height)
  module._shader:send("mode", 8)

  love.graphics.rectangle("line", x, y, width, height)
  module._updateContext()

  module.setImageDrawMode(module._drawMode)
end

function module.fillRect(x, y, width, height)
  module._shader:send("mode", 8)

  love.graphics.rectangle("fill", x, y, width, height)
  module._updateContext()

  module.setImageDrawMode(module._drawMode)
end

function module.drawLine(x1, y1, x2, y2)
  module._shader:send("mode", 8)

  love.graphics.line(x1, y1, x2, y2)
  module._updateContext()

  module.setImageDrawMode(module._drawMode)
end

function module.drawArc(x, y, radius, startAngle, endAngle)
  module._shader:send("mode", 8)

  -- 0 degrees is 270 when drawing an arc on PD...
  startAngle = startAngle - 90
  endAngle = endAngle - 90

  if startAngle == endAngle then
    -- if startAngle and endAngle are the same, PD draws a full circle
    love.graphics.arc("line", "open", x, y, radius, math.rad(startAngle), math.rad(endAngle + 360), 16)
  elseif startAngle > endAngle then
    -- love2d adjusts for when the startAngle is larger, but PD does not, so we need to compensate
    love.graphics.arc("line", "open", x, y, radius, math.rad(startAngle), math.rad(endAngle + 360), 16)
  else
    love.graphics.arc("line", "open", x, y, radius, math.rad(endAngle), math.rad(startAngle), 16)
  end
  module._updateContext()

  module.setImageDrawMode(module._drawMode)
end

function module.drawPixel(x, y)
  module._shader:send("mode", 8)

  love.graphics.points(x, y)
  module._updateContext()

  module.setImageDrawMode(module._drawMode)
end

function module.setFont(font)
  module._activeFont = font
  love.graphics.setFont(font.data)
end

function module.getFont()
  return module._activeFont
end

function module.getTextSize(str)
  local font = module._activeFont
  return font:getWidth(str), font:getHeight()
end

local function _styleCharacterForNewline(line)
	local _, boldCount = string.gsub(line, "*", "*")
	if ( boldCount % 2 ~= 0 ) then
		return "*"
	end
	
	local _, italicCount = string.gsub(line, "_", "_")
	if ( italicCount % 2 ~= 0 ) then
		return "_"
	end

	return ""
end

local function _addStyleToLine(style, line)
	if #style == 0 then
		return line
	elseif line:sub(1,1) == style then
		return line:sub(2,-1)
	else
		return style .. line
	end
end

local function _layoutTextInRect(shouldDrawText, str, x, ...)
	if str == nil then 
		return 0, 0, false, nil 
	end
	
	-- returnStringInfo is used to return a table of line information for later drawing into an image
	local y, width, height, lineHeightAdjustment, truncator, textAlignment, singleFont, returnStringInfo
	if (type(x) == "userdata") then		-- check if x is a playdate.geometry.rect object
		x, y, width, height = x.x, x.y, x.width, x.height
		lineHeightAdjustment, truncator, textAlignment, singleFont, returnStringInfo = select(1, ...)
	else
		y, width, height, lineHeightAdjustment, truncator, textAlignment, singleFont, returnStringInfo = select(1, ...)
	end
	
	local stringInfo = nil
	if returnStringInfo == true then
		stringInfo = {}
		stringInfo.textAlignment = textAlignment
		stringInfo.singleFont = singleFont
	end
	
	if width < 0 or height < 0 then
		return 0, 0, false, nil
	end
	
	local font = nil
	if singleFont == nil then 
		font = playdate.graphics.getFont()
		if font == nil then print('error: no font set!') 
			return 0, 0, false, nil 
		end
	end
	
	y = math.floor(y)
	x = math.floor(x)
	lineHeightAdjustment = math.floor(lineHeightAdjustment or 0)
	if truncator == nil then truncator = "" end
	
	local top = y
	local bottom = y + height
	local currentLine = ""
	local lineWidth = 0
	local firstWord = true

	local lineHeight
	local fontLeading
	local fontHeight
	if singleFont == nil then 
		fontLeading = font:getLeading()
		fontHeight = font:getHeight()
		lineHeight = fontHeight + fontLeading
	else
		fontLeading = singleFont:getLeading()
		fontHeight = singleFont:getHeight()
		lineHeight = fontHeight + fontLeading
	end
	-- local unmodifiedLineHeight = lineHeight
	
	local maxLineWidth = 0
	
	if height < fontHeight then
		return 0, 0, false	-- if the rect is shorter than the text, don't draw anything
	else
		lineHeight = lineHeight + lineHeightAdjustment
	end
	
	local function getLineWidth(text)
		if singleFont == nil then
			return playdate.graphics.getTextSize(text)		
		else
			return singleFont:getTextWidth(text)
		end
	end
	
	local function drawAlignedText(t, twidth)
		
		if twidth > maxLineWidth then
			maxLineWidth = twidth
		end
		
		if stringInfo ~= nil then
			stringInfo[#stringInfo+1] = {
				text = t,
				width = twidth,
				y = y
			}
		end
		
		if shouldDrawText == false then
			return
		end
		
		local alignedX = x
		if textAlignment == kTextAlignment.right then
			alignedX = x + width - twidth
		elseif textAlignment == kTextAlignment.center then
			alignedX = x + ((width - twidth) / 2)
		end
		if singleFont == nil then
			playdate.graphics.drawText(t, alignedX, y)
		else
			singleFont:drawText(t, alignedX, y)
		end
	end
	
	
	local function drawTruncatedWord(wordLine)
		lineWidth = getLineWidth(wordLine)
		local truncatedWord = wordLine
		local stylePrefix = _styleCharacterForNewline(truncatedWord)
		
		while lineWidth > width and #truncatedWord > 1 do	-- shorten word until truncator fits
			truncatedWord = truncatedWord:sub(1, -2)		-- remove last character, and try again
			lineWidth = getLineWidth(truncatedWord)
		end

		drawAlignedText(truncatedWord, lineWidth)
	
		local remainingWord = _addStyleToLine(stylePrefix, wordLine:sub(#truncatedWord+1, -1))
		lineWidth = getLineWidth(remainingWord)
		firstWord = true
		return remainingWord
	end
	
	
	local function drawTruncatedLine()
		currentLine = trimTrailingWhitespace(currentLine)	-- trim whitespace at the end of the line
		lineWidth = getLineWidth(currentLine .. truncator)
		
		while lineWidth > width and getLineWidth(currentLine) > 0 do	-- shorten line until truncator fits
			currentLine = currentLine:sub(1, -2)	-- remove last character, and try again
			lineWidth = getLineWidth(currentLine .. truncator)
		end
		
		currentLine = currentLine .. truncator
		lineWidth = getLineWidth(currentLine)
		firstWord = true

		drawAlignedText(currentLine, lineWidth)
		
		local textBlockHeight = y - top + fontHeight
		return maxLineWidth, textBlockHeight, true, stringInfo
	end
	
	
	local function drawLineAndMoveToNext(firstWordOfNextLine)

		firstWordOfNextLine = _addStyleToLine(_styleCharacterForNewline(currentLine), firstWordOfNextLine)
		
		drawAlignedText(currentLine, lineWidth)
		y = y + lineHeight
		currentLine = firstWordOfNextLine
		lineWidth = getLineWidth(firstWordOfNextLine)
		firstWord = true
	end
	
	
	local lines = {}
	local i = 1
	for line in str:gmatch("[^\r\n]*") do		-- split into hard-coded lines
		lines[i] = line
		i = i + 1
	end
	
	local line
		
	for i = 1, #lines do
		line  = lines[i]
		
		local firstWordInLine = true
		local leadingWhiteSpace = ""
		
		for word in line:gmatch("%S+ *") do	-- split into words
			
			-- preserve leading space on lines
			if firstWordInLine == true then
				local leadingSpace = line:match("^%s+")
				if leadingSpace ~= nil then
					leadingWhiteSpace = leadingSpace
				end
				firstWordInLine = false
			else
				leadingWhiteSpace = ""
			end

			-- split individual words into pieces if they're too wide
			if firstWord then
				if #currentLine > 0 then
					while getLineWidth(leadingWhiteSpace..currentLine) > width do
						currentLine = drawTruncatedWord(leadingWhiteSpace..currentLine)
						y = y + lineHeight
					end
				else
					word = leadingWhiteSpace .. word
					while getLineWidth(word) > width do
						if y + fontHeight <= bottom then
							if y + lineHeight + fontHeight <= bottom then
								word = drawTruncatedWord(leadingWhiteSpace .. word)
							else 	-- a line after this one will not fit
								currentLine = word
								return drawTruncatedLine() -- no room for another line
							end
							leadingWhiteSpace = ""
						end
						y = y + lineHeight
					end
				end
				firstWord = false
			end
			
			if getLineWidth(currentLine .. leadingWhiteSpace .. playdate.string.trimWhitespace(word)) <= width then
				currentLine = currentLine .. leadingWhiteSpace .. word
			else 
				if y + lineHeight + fontHeight <= bottom then
					currentLine = leadingWhiteSpace .. playdate.string.trimTrailingWhitespace(currentLine)	-- trim whitespace at the end of the line
					lineWidth = getLineWidth(currentLine)
					drawLineAndMoveToNext(leadingWhiteSpace .. word)
				else
					-- the next line is lower than the boundary, so we need to truncate and stop drawing
					currentLine = leadingWhiteSpace ..currentLine .. word
					if y + fontHeight <= bottom then
						return drawTruncatedLine()
					end
					local textBlockHeight = y - top + fontHeight
					return maxLineWidth, textBlockHeight, true, stringInfo
				end
			end
			
		end
		
		if (lines[i+1] == nil) or (y + lineHeight + fontHeight <= bottom) then
			
			if #currentLine > 0 then
				while getLineWidth(currentLine) > width do
					currentLine = drawTruncatedWord(currentLine)
					y = y + lineHeight
				end
			end
			
			lineWidth = getLineWidth(currentLine)
			drawLineAndMoveToNext('')
		else
			return drawTruncatedLine()
		end
	end
	
	local textBlockHeight = y - top - lineHeight + fontHeight
	return maxLineWidth, textBlockHeight, false, stringInfo
end

-- playdate.graphics.drawTextInRect(str, x, y, width, height, [leadingAdjustment, [truncationString, [alignment, [font]]]]) 
-- playdate.graphics.drawTextInRect(str, rect, [leadingAdjustment, [truncationString, [alignment, [font]]]]) 
function module.drawTextInRect(text, x, ...)
  local font = module._activeFont
  -- font:drawText(text, x, y, fontFamily, leadingAdjustment)
  local w, h = _layoutTextInRect(true, text, x, ...)
  module._updateContext()
  return w, h
end

function module.drawText(text, x, y, fontFamily, leadingAdjustment)
  @@ASSERT(text ~= nil, "Text is nil")
  local font = module._activeFont
  font:drawText(text, x, y, fontFamily, leadingAdjustment)
  module._updateContext()
end

function module:_updateContext()
  if #module._contextStack == 0 then
    return
  end

  local activeContext = module._contextStack[#module._contextStack]

  -- love2d doesn't allow calling newImageData() when canvas is active
  love.graphics.setCanvas()
  local imageData = activeContext._canvas:newImageData()
  love.graphics.setCanvas(activeContext._canvas)

  -- update image
  activeContext.data:replacePixels(imageData)
end

function module.pushContext(image)
  -- TODO: PD docs say image is optional, but not passing an image just results in drawing to last context?
  @@ASSERT(image, "Missing image parameter.")

  -- create canvas if it doesn't exist
  if not image._canvas then
    image._canvas = love.graphics.newCanvas(image:getSize())
  end
  
  -- push context
  table.insert(module._contextStack, image)

  -- update current render target
  love.graphics.setCanvas(image._canvas)
end

function module.popContext()
  @@ASSERT(#module._contextStack > 0, "No pushed context.")

  -- pop context
  table.remove(module._contextStack)
  -- update current render target
  if #module._contextStack == 0 then
    love.graphics.setCanvas(module._canvas)
  else
    local activeContext = module._contextStack[#module._contextStack]
    love.graphics.setCanvas(activeContext._canvas)
  end
end