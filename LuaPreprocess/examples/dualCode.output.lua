--[[============================================================
--=
--=  LuaPreprocess example: Dual code.
--=
--=  Here we have some constants that are used in both the
--=  metaprogram and in the final program.
--=
--============================================================]]

-- Assignments starting with !! will appear in both the metaprogram and the final output.
local TEXT_HEIGHT    = 30
local BUTTON_PADDING = 15
local BUTTON_BORDER  = 2
local BUTTON_WIDTH   = 400
local BUTTON_HEIGHT  = 64

function drawImage(imagePath, x, y, scale)    print("Drawing image with scale "..scale)  end
function drawBackground(x, y, width, height)  print("Drawing background")                end
function drawBorder(x, y, width, height)      print("Drawing border")                    end
function drawLabel(x, y, label)               print("Drawing label: "..label)            end

function drawButton(label, x, y)
	drawImage("button_background.png", x, y, 0.25)

	drawBorder(x, y, BUTTON_WIDTH, BUTTON_HEIGHT)
	drawLabel(x, y, label)
end

function drawContextMenu(x, y, menuItemLabels)
	local menuWidth  = BUTTON_WIDTH
	local menuHeight = #menuItemLabels * BUTTON_HEIGHT

	drawBackground(x, y, menuWidth, menuHeight)

	for i, label in ipairs(menuItemLabels) do
		drawButton(label, x, y)
		y = y+BUTTON_HEIGHT
	end
end

drawContextMenu(20, 50, {"Copy","Cut","Paste"})
