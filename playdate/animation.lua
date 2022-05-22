-- NOTE: this is almost the exact animation implementation copied from the Playdate SDK
-- with minor modifications and optimizations

-- Playdate CoreLibs: Animation addons
-- Copyright (C) 2014 Panic, Inc.

playdate.graphics.animation = playdate.graphics.animation or {}

--! **** Animation Loops ****
playdate.graphics.animation.loop = {}

local loopAnimation = playdate.graphics.animation.loop
loopAnimation.__index = loopAnimation

local floor = math.floor

local function updateLoopAnimation(loop, force)
	if loop.paused == true and force ~= true then
		return
	end

	local startTime = loop.t
	local elapsedTime = playdate.getCurrentTimeMilliseconds() - startTime
	local frame = loop.startFrame + floor(elapsedTime / loop.delay) * loop.step

	if loop.loop or frame <= loop.endFrame then
		local startFrame = loop.startFrame
		local numFrames = loop.endFrame + 1 - startFrame
		loop.currentFrame = ((frame-startFrame) % numFrames) + startFrame
	else
		loop.currentFrame = loop.endFrame
		loop.valid = false
	end
end

loopAnimation.__index = function(table, key)
	if key == "frame" then
		updateLoopAnimation(table)
		return table.currentFrame
	elseif key == "paused" then
		return table._paused
	else
		return rawget(loopAnimation, key)
	end
end

loopAnimation.__newindex = function(table, key, value)
	if key == "frame" then
		local newFrame = math.floor(tonumber(value))
		@@ASSERT(newFrame ~= nil, "playdate.graphics.animation.loop.frame must be an number")
		local newFrame = math.min(table.endFrame, math.max(table.startFrame, value))
		local frameOffset = newFrame - table.startFrame
		table.t = playdate.getCurrentTimeMilliseconds() - (frameOffset * table.delay)
		table.valid = true
		updateLoopAnimation(table, true)
	elseif key == "paused" then
		@@ASSERT(value == true or value == false, "playdate.graphics.animation.loop.paused can only be set to true or false")

		if value == true and table._paused == false then
			table.pauseTime = playdate.getCurrentTimeMilliseconds()
		elseif value == false and table._paused == true then
			local elapsedPauseTime = table.pauseTime - playdate.getCurrentTimeMilliseconds()
			table.pauseTime = nil
			table.t = table.t - elapsedPauseTime -- offset the original pause time so unpausing carries on at the same frame as when the loop was paused
		end

		table._paused = value
	elseif key == "shouldLoop" then
		@@ASSERT(value == true or value == false, "playdate.graphics.animation.loop.loop can only be set to true or false")

		if table.valid == false and value == true then
			-- restart the loop if necessary
			table.valid = true
			table.t = playdate.getCurrentTimeMilliseconds()
		end
		
		if value == false then
			-- adjust the start time of the loop so that it's what it would have been if the loop started at the beginning of this cycle
			local currentTime = playdate.getCurrentTimeMilliseconds()
			local oneLoopDuration = table.delay * (table.endFrame - table.startFrame + 1)
			table.t = table.t + (floor((currentTime - table.t) / oneLoopDuration) * oneLoopDuration)			
		end
		
		table.loop = value
	else
		rawset(table, key, value)
	end
end

function loopAnimation.new(delay, imageTable, shouldLoop)
	local o = {}

	o.delay = delay or 100
	o.startFrame = 1
	o.currentFrame = 1
	o.endFrame = 1
	o.step = 1
	o.loop = shouldLoop ~= false
	o._paused = false
	o.valid = true
	o.t = playdate.getCurrentTimeMilliseconds()

	if imageTable ~= nil then
		o.imageTable = imageTable
		o.endFrame = imageTable:getLength()
	else
		imageTable = nil
	end

	setmetatable(o, loopAnimation)
	return o
end

function loopAnimation:setImageTable(it)
	self.imageTable = it
	if it ~= nil then
		self.endFrame = it:getLength()
	end
end

function loopAnimation:isValid()
	return self.valid
end

function loopAnimation:draw(x, y, flip)
  self.imageTable:drawImage(self.frame, x, y, flip)
end