-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#C-graphics.animator
import "CoreLibs/easing.lua"

playdate.graphics = playdate.graphics or {}

local module = {}
playdate.graphics.animator = module

local meta = {}
meta.__index = meta
module.__index = meta

-- note: this function has 5 overloaded definitions as of 2.6.2. 
-- the parameters will first need to be interpreted, then passed off to an appropriate local function for processing.
function module.new(a, b, c, d, e)
    error("[ERR] playdate.graphics.animator.new() is not yet implemented.")
end

function meta:currentValue()
    error("[ERR] playdate.graphics.animator:currentValue() is not yet implemented.")
end

function meta:valueAtTime(time)
    error("[ERR] playdate.graphics.animator:valueAtTime() is not yet implemented.")
end

function meta:progress()
    error("[ERR] playdate.graphics.animator:progress() is not yet implemented.")
end

function meta:reset(duration)
    error("[ERR] playdate.graphics.animator:reset() is not yet implemented.")
end

function meta:ended()
    error("[ERR] playdate.graphics.animator:ended() is not yet implemented.")
end

module.easingAmplitude = nil
module.easingPeriod = nil
module.repeatCount = nil
module.reverses = nil