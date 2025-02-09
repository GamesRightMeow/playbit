-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#M-ui

playdate.ui = playdate.ui or {}

local module = {}
playdate.ui.crankIndicator = module

local meta = {}
meta.__index = meta
module.__index = meta

module.clockwise = true

function meta:draw(xOffset, yOffset)
    error("[ERR] playdate.ui.crankIndicator:draw() is not yet implemented.")
end

function meta:resetAnimation()
    error("[ERR] playdate.ui.crankIndicator:resetAnimation() is not yet implemented.")
end

function meta:getBounds()
    error("[ERR] playdate.ui.crankIndicator:getBounds() is not yet implemented.")
end