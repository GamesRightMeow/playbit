local pd = playdate
local gfx = pd.graphics
local bit = require("bit")

class('Sprite').extends()

Sprite.kCollisionTypeSlide = "slide"
Sprite.kCollisionTypeFreeze = "freeze"
Sprite.kCollisionTypeOverlap = "overlap"
Sprite.kCollisionTypeBounce = "bounce"

gfx.sprite = Sprite
local allSprites = {}
local clearImageData = love.image.newImageData(1, 1)
clearImageData:setPixel(0,0,playbit.graphics.colorWhite[1],playbit.graphics.colorWhite[2],playbit.graphics.colorWhite[3],playbit.graphics.colorWhite[4])
local love2DImage = love.graphics.newImage(clearImageData)
function Sprite.new(arg1,arg2)
    local sprite
    if arg2 ~= nil then
        sprite = Sprite(arg2)
    else
        sprite = Sprite(arg1)
    end
	return sprite
end
function Sprite:init(imageOrTilemap)
    self:initVariables()
	if imageOrTilemap ~= nil then
		if getmetatable(imageOrTilemap) == playdate.graphics.image.__index then
			self:setImage(imageOrTilemap)
		elseif getmetatable(imageOrTilemap) == playdate.graphics.tilemap.__index then
			self:setTilemap(imageOrTilemap)
		end
	end
end
function Sprite.initVariables(self)
    self.x, self.y = 0, 0
    self.visible = true
    self.zIndex = 0
    self.width, self.height = 0 , 0
    if self.centerX == nil then self:setCenter(0.5,0.5) end
    self.drawClipOffsetX = 0
    self.drawClipOffsetY = 0

    self._drawFlipped = nil
    self._drawImage = nil
    self.collideRect = nil
    self.animator = nil
    self._ignoresDrawOffset = false

end
function Sprite.performOnallSprites(func)
    for i = 1, #allSprites do
        func(allSprites[i])
    end
end

function Sprite:setIgnoresDrawOffset(flag)
  self._ignoresDrawOffset = flag
end
function Sprite:setTilemap(tilemap)
    self.image=tilemap
end
function Sprite:setImage(image, flip, scale, yscale)
    if image == nil then
        image = playdate.graphics.image.new(self.width,self.height)
    end
    self._drawFlipped = flip
    self._drawImage = nil
    self.image = image
    self.width, self.height = image:getSize()
    if self.centerX == nil then self:setCenter(0.5,0.5) end
end

function Sprite:getImage()
    return self.image
end

function Sprite:setSize(w, h)
    if self.image ~= nil then
        return
    end
    self.width, self.height = w, h
    self._drawImage = playdate.graphics.image.new(w,h)
end

function Sprite:getSize()
    return self.width, self.height
end

function Sprite:moveTo(x, y)
    self.x, self.y = x, y
end

function Sprite:getPosition()
    return self.x, self.y
end

function Sprite:moveBy(x, y)
    self:moveTo(self.x + x, self.y + y)
end

function Sprite:add()
    if self.visible == nil then
        self.visible = true
    end
    if self.zIndex == nil then
        self.zIndex = 0
    end
    if not self.added then
        table.insert(allSprites, self)
        self.added = true
        table.sort(allSprites, function(a, b) return a.zIndex < b.zIndex end)
    end
end
function Sprite:remove()
    if not self.added then
        return
    end
    for i, sprite in ipairs(allSprites) do
        if sprite == self then
            table.remove(allSprites, i)
            self.added = false
            return
        end
    end
    -- wasn't found so shouldn't be added.
    print('Should never get here', self.added)
    assert(false)
    self.added = false
end
function Sprite:markDirty()
    --Not needed for love2D
end
function Sprite:removeAll()
    for i, sprite in ipairs(allSprites) do
        sprite.added = false
    end
    allSprites = {}
end
function Sprite:setZIndex(index)
    self.zIndex = index
    table.sort(allSprites, function(a, b) return a.zIndex < b.zIndex end)
end

function Sprite:getZIndex()
    return self.zIndex
end

function Sprite:setCollideRect(x, y, w, h)
    self.collideRect = { x = x, y = y, width = w, height = h }
end

function Sprite:getCollideRect()
    return self.collideRect
end

function Sprite:getCollideBounds()
end

function Sprite:setCollisionResponse(response)
    self.collisionResponse = response
end

function Sprite:setGroups(groups)
    self.groupMask = 0x00000000

    for _, group in ipairs(groups) do
        if group >= 1 and group <= 32 then
            self.groupMask = bit.bor(self.groupMask, bit.lshift(1, group - 1))
        end
    end
end

function Sprite:setCollidesWithGroups(groups)
    self.collidesWithGroupsMask = 0x00000000
    for _, group in ipairs(groups) do
        if group >= 1 and group <= 32 then
            self.collidesWithGroupsMask = bit.bor(self.collidesWithGroupsMask, bit.lshift(1, group - 1))
        end
    end
end
function Sprite:setClipRect(x,y,width,height)
    if self.width == nil then return end
    local maxWidth = math.min(width,self.width-x)
    local maxHeight = math.min(height,self.height-y)
    self.drawClipOffsetX = x
    self.drawClipOffsetY = y
    self.quad = love.graphics.newQuad(x,y, width,height, self.width,self.height)
end
function Sprite:clearClipRect()
    self.quad = nil
    self.drawClipOffsetX = 0
    self.drawClipOffsetY = 0
end
function Sprite:setGroupMask(mask)
    self.groupMask = mask
end

function Sprite:getGroupMask()
    return self.groupMask
end

function Sprite:setCollidesWithGroupsMask(mask)
    self.collidesWithGroupsMask = mask
end

function Sprite:getCollidesWithGroupsMask()
    return self.collidesWithGroupsMask
end

function Sprite:resetGroupMask()
    self.groupMask = 0x00000000
end

function Sprite:resetCollidesWithGroupsMask()
    self.collidesWithGroupsMask = 0x00000000
end

function Sprite:canCollideWith(other)
    return bit.band(self.collidesWithGroupsMask, other.groupMask) ~= 0
end


local function checkAABBCollision(self, other)
    if not self:canCollideWith(other) then return false end
    if not self.collideRect or not other.collideRect then return false end
    return self.x + self.collideRect.x < other.x + other.collideRect.x + other.collideRect.width and
            self.x + self.collideRect.x + self.collideRect.width > other.x + other.collideRect.x and
            self.y + self.collideRect.y < other.y + other.collideRect.y + other.collideRect.height and
            self.y + self.collideRect.y + self.collideRect.height > other.y + other.collideRect.y
end


-- **Entry and Exit Calculation**
-- Finds when the moving sprite **enters** and **exits** collision on an axis.
local function entryExit(t0, t1, ds, sMin, sMax, oMin, oMax)
    -- If no movement along this axis, check for overlap (static collision case)
    if ds == 0 then
        if sMin >= oMax or sMax <= oMin then return nil, nil end
        return 0, 1  -- Overlapping, collision lasts full movement range
    end

    -- Compute time when movement **enters** and **exits** collision on this axis
    local tEntry = (oMin - sMax) / ds  -- Entry time (when first touching)
    local tExit = (oMax - sMin) / ds  -- Exit time (when leaving)

    -- Ensure proper ordering (entry should always be before exit)
    if tEntry > tExit then tEntry, tExit = tExit, tEntry end

    -- Return max entry time and min exit time (valid range for collision)
    return math.max(t0, tEntry), math.min(t1, tExit)
end

-- **Swept AABB Collision Detection**
-- This function calculates the **time of impact (ti)** for a moving sprite
-- and determines the **collision normal** (direction of impact).
-- It prevents tunneling by checking **when** the collision happens (0-1 scale).
local function sweptAABB(self, other, startX, startY, endX, endY)
    -- Compute movement vector
    local dx, dy = endX - startX, endY - startY

    -- Default values:
    local ti = 1  -- Time of impact (1 = full movement allowed, 0 = instant collision)
    local normalX, normalY = 0, 0  -- Collision normal

    -- **Check Collisions on X and Y Axis Separately**
    -- Loop through **X and Y axes**, applying `entryExit()` to both
    for _, axis in ipairs({ { "x", dx }, { "y", dy } }) do
        local key, ds = axis[1], axis[2]

        -- Get bounds of moving sprite
        local sMin, sMax = startX + self.collideRect.x, startX + self.collideRect.x + self.collideRect.width
        -- Get bounds of colliding object
        local oMin, oMax = other.x + other.collideRect.x, other.x + other.collideRect.x + other.collideRect.width

        -- Adjust values for Y axis if needed
        if key == "y" then
            sMin, sMax = startY + self.collideRect.y, startY + self.collideRect.y + self.collideRect.height
            oMin, oMax = other.y + other.collideRect.y, other.y + other.collideRect.y + other.collideRect.height
        end

        -- **Get the earliest and latest possible collision times for this axis**
        local tEntry, tExit = entryExit(0, 1, ds, sMin, sMax, oMin, oMax)

        -- **Check if collision is valid**
        -- If there is **no collision** (entry after exit), return no impact
        if not tEntry or tEntry > tExit or tExit < 0 or tEntry > 1 then
            return nil, 0, 0  -- No collision
        end

        -- **Track the earliest collision (smallest `ti`)**
        if tEntry < ti then
            ti = tEntry  -- Update the earliest collision time

            -- Set collision normal:
            -- - If movement is in positive direction, normal is `-1`
            -- - If movement is in negative direction, normal is `1`
            if key == "x" then
                normalX = (dx > 0) and -1 or 1
            else
                normalY = (dy > 0) and -1 or 1
            end
        end
    end

    return ti, normalX, normalY
end


function Sprite:checkCollisions(goalX, goalY)
    local collisions = {}
    local moveX, moveY = goalX - self.x, goalY - self.y
    local ti = 1
    local normalX, normalY = 0, 0
    local overlaps = false

    -- already overlapping another sprite?
    for _, other in ipairs(allSprites) do
        if other ~= self and checkAABBCollision(self, other) then
            overlaps = true
            break
        end
    end

    -- Check for possible future collisions
    for _, other in ipairs(allSprites) do
        if other ~= self then

            local tImpact, nx, ny = sweptAABB(self, other, self.x, self.y, goalX, goalY)

            if tImpact then
                ti = math.min(ti, tImpact)
                normalX, normalY = nx, ny
                table.insert(collisions, {
                    sprite = self,
                    other = other,
                    type = self.collisionResponse,
                    overlaps = overlaps,
                    ti = tImpact,
                    move = { x = moveX * ti, y = moveY * ti },
                    normal = { x = normalX, y = normalY },
                    touch = { x = self.x + moveX * ti, y = self.y + moveY * ti },
                    spriteRect = self.collideRect,
                    otherRect = other.collideRect
                })
            end
        end
    end

    return goalX, goalY, collisions, #collisions
end

-- function Sprite:moveWithCollisions(goalX, goalY)
--     local actualX, actualY, collisions, count = self:checkCollisions(goalX, goalY)
    
--     -- Move only if there were no collisions
--     if count == 0 or self.collisionResponse == "overlap" then
--         self:moveTo(actualX, actualY)
--     end

--     return actualX, actualY, collisions, count
-- end

function Sprite:moveWithCollisions(goalX, goalY)
    local actualX, actualY, collisions, count = self:checkCollisions(goalX, goalY)

    if count == 0 then
        self:moveTo(goalX, goalY)
        return actualX, actualY, collisions, count
    end

    -- Iterate through each collision
    for _, col in ipairs(collisions) do
        local other = col.other
        local response = "freeze"  -- Default collision behavior

        -- **Check if `collisionResponse` is a function or string**
        if type(self.collisionResponse) == "function" then
            response = self:collisionResponse(other) or "freeze"  -- Call function with `other`
        elseif type(self.collisionResponse) == "string" then
            response = self.collisionResponse
        end

        -- **Handle Different Collision Types**
        if response == "slide" then
            -- **Slide:** Stop movement in the direction of collision
            if col.normal.x ~= 0 then actualX = col.touch.x end
            if col.normal.y ~= 0 then actualY = col.touch.y end

        elseif response == "freeze" then
            -- **Freeze:** Stop movement completely
            actualX, actualY = self.x, self.y  -- Reset to original position

        elseif response == "overlap" then
            -- **Overlap:** Ignore collision, allow full movement
            actualX, actualY = goalX, goalY

        elseif response == "bounce" then
            -- **Bounce:** Reflect movement based on collision normal
            local bounceX = (goalX - self.x) * (1 - math.abs(col.normal.x) * 2)
            local bounceY = (goalY - self.y) * (1 - math.abs(col.normal.y) * 2)
            actualX = self.x + bounceX
            actualY = self.y + bounceY
        end
    end

    -- Move sprite to final position based on response
    self:moveTo(actualX, actualY)
    return actualX, actualY, collisions, count
end

function Sprite:setScale(scale, yScale)
    self.scaleX = scale
    self.scaleY = yScale or scale
end

function Sprite:getScale()
    return self.scaleX, self.scaleY
end

function Sprite:setRotation(angle, scale, yScale)
    self.angle = angle

    if (scale) then
        self:setScale(scale, yScale)
    end
end

function Sprite:getRotation()
    return self.angle
end

function Sprite:setVisible(flag)
    self.visible = flag
end

function Sprite:isVisible()
    return self.visible
end

function Sprite:setCenter(x, y)
    self.centerX = x
    self.centerY = y
end

function Sprite:getCenter()
    return self.centerX, self.centerY
end

function Sprite:getCenterPoint()
    error("[ERR] Sprite:getCenterPoint() is not yet implemented. need geometry point")
end

function Sprite:draw()
  local imageToDraw = self.image or self._drawImage
  if self.centerX == nil then
    --print('No centreX to draw, imageToDraw=',imageToDraw,self.className)
    return
   end
  if imageToDraw == nil then
    --print('No image to draw')
    return
  end
  local dx,dy = 0,0
  local cpx,cpy = -self.centerX *self.width , -self.centerY*self.height
  
  if self._ignoresDrawOffset then
    dx, dy = playdate.graphics.getDrawOffset()
  end
  local curDrawMode = playbit.graphics.drawMode
  playdate.graphics.setImageDrawMode(self._imageDrawMode)
  local yOffset = cpy-dy+self.drawClipOffsetY
  local xOffset = cpx-dx+self.drawClipOffsetX
  if self.visible ~= false then
    if self.scaleX then
        imageToDraw:drawScaled(self.x+xOffset, self.y+yOffset, self.scaleX, self.scaleY)
    elseif self.angle then
        imageToDraw:drawRotated(self.x+xOffset, self.y+yOffset, self.angle)
    else --Image:draw(x, y, flip, qx, qy, qw, qh)
        if self.quad == nil then
            imageToDraw:draw(self.x+xOffset, self.y+yOffset,self._drawFlipped)
        else
            imageToDraw:draw(self.x+xOffset, self.y+yOffset,self._drawFlipped,self.quad)
        end
    end
    --playdate.graphics.drawRect(self.x-dx+cpx, self.y-dy+cpy, self.width, self.height)
  end
  playdate.graphics.setImageDrawMode(curDrawMode)
end

function Sprite:setImageDrawMode(mode)
    self._imageDrawMode = mode
end
function Sprite.updateAll()
    for _, spr in ipairs(allSprites) do
        if spr.animator then
            local p = spr.animator:currentValue()
            spr:moveTo(p.x, p.y)
            if spr.animator:ended() then
                spr.animator = nil
            end
        end
    end
end
function Sprite.update(self)
  if self == nil then
    local dx, dy = playdate.graphics.getDrawOffset()
    local r, g, b = love.graphics.getColor()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(love2DImage,-dx,-dy,0,400,240)
    love.graphics.setColor(r,g,b,1)
    if #allSprites > 0 then
      local startTime = love.timer.getTime()
        for _, spr in ipairs(allSprites) do
            local updateTime = love.timer.getTime()
            spr:update()
            local updateTimeEnd = love.timer.getTime()
            -- print(string.format('Update %s took %3f ms',spr.className,(updateTimeEnd - updateTime)*1000))
        end
      local midTime = love.timer.getTime()
        for _, spr in ipairs(allSprites) do
            spr:draw()
        end
      local endTime = love.timer.getTime()
    --   print(string.format('Update took %3f ms',(midTime - startTime)*1000))
    --   print(string.format('draw took %3f ms',(endTime - midTime)*1000))
    end
  end
end
function Sprite.drawAll()
    for _, spr in ipairs(allSprites) do
        spr:draw()
    end
end

function Sprite.setBackgroundDrawingCallback(callback)
    Sprite.backgroundCallback = callback
end

function Sprite.drawBackground()
    if Sprite.backgroundCallback then
        Sprite.backgroundCallback()
    end
end

