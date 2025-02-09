local module = {}
playdate.graphics.sprite = module

local meta = {}
meta.__index = meta
module.__index = meta

local allSprites = {}

function module.new(imageOrTilemap)
    local self = setmetatable({}, module)

    if imageOrTilemap then
        self:setImage(imageOrTilemap)
    end

    self.x, self.y = 0, 0
    self.visible = true
    self.zIndex = 0
    self.collideRect = nil
    self.animator = nil

    table.insert(allSprites, self)
    return self
end

function module.performOnallSprites(func)
    for i = 1, #allSprites do
        func(allSprites[i])
    end
end

function module.spriteWithText(text, maxWidth, maxHeight, backgroundColor, leadingAdjustment, truncationString, alignment, font)
	error("spriteWithText not implemented!")
end

function module:setImage(image)
    self.image = image
    self.width = image:getWidth()
    self.height = image:getHeight()
end

function module:getImage()
    return self.image
end

function module:moveTo(x, y)
    self.x, self.y = x, y
end

function module:getPosition()
    return self.x, self.y
end

function module:moveBy(x, y)
    self:moveTo(self.x + x, self.y + y)
end

function module:add()
    if not self.added then
        table.insert(allSprites, self)
        self.added = true
        table.sort(allSprites, function(a, b) return a.zIndex < b.zIndex end)
    end
end

function module:remove()
    for i, sprite in ipairs(allSprites) do
        if sprite == self then
            table.remove(allSprites, i)
            self.added = false
            return
        end
    end
end

function module:setZIndex(index)
    self.zIndex = index
    table.sort(allSprites, function(a, b) return a.zIndex < b.zIndex end)
end

function module:getZIndex()
    return self.zIndex
end

function module:setCollideRect(x, y, w, h)
    self.collideRect = { x = x, y = y, width = w, height = h }
end

function module:getCollideRect()
    return self.collideRect
end

function module:getCollideBounds()
end

function module:setCollisionResponse(response)
    self.collisionResponse = response
end

local function checkAABBCollision(self, other)
    if not self.collideRect or not other.collideRect then return false end
    return self.x + self.collideRect.x < other.x + other.collideRect.x + other.collideRect.width and
            self.x + self.collideRect.x + self.collideRect.width > other.x + other.collideRect.x and
            self.y + self.collideRect.y < other.y + other.collideRect.y + other.collideRect.height and
            self.y + self.collideRect.y + self.collideRect.height > other.y + other.collideRect.y
end


-- Swept AABB Collision Detection to Calculate `ti`
-- sweptAABB() – Swept Axis-Aligned Bounding Box Collision Detection
-- The Swept AABB algorithm is used to detect collisions along a movement path
-- and calculate the exact time (ti) at which a collision occurs.
local function sweptAABB(self, other, startX, startY, endX, endY)
    local dx, dy = endX - startX, endY - startY
    local ti = 1  -- Default: full movement allowed
    local normalX, normalY = 0, 0

    local function entryExit(t0, t1, ds, sMin, sMax, oMin, oMax)
        if ds == 0 then
            if sMin >= oMax or sMax <= oMin then return nil, nil end
            return 0, 1
        end
        local tEntry = (oMin - sMax) / ds
        local tExit = (oMax - sMin) / ds
        if tEntry > tExit then tEntry, tExit = tExit, tEntry end
        return math.max(t0, tEntry), math.min(t1, tExit)
    end

    for _, axis in ipairs({ { "x", dx }, { "y", dy } }) do
        local key, ds = axis[1], axis[2]
        local sMin, sMax = startX + self.collideRect.x, startX + self.collideRect.x + self.collideRect.width
        local oMin, oMax = other.x + other.collideRect.x, other.x + other.collideRect.x + other.collideRect.width
        if key == "y" then
            sMin, sMax = startY + self.collideRect.y, startY + self.collideRect.y + self.collideRect.height
            oMin, oMax = other.y + other.collideRect.y, other.y + other.collideRect.y + other.collideRect.height
        end

        local tEntry, tExit = entryExit(0, 1, ds, sMin, sMax, oMin, oMax)
        if not tEntry or tEntry > tExit or tExit < 0 or tEntry > 1 then return nil, 0, 0 end
        if tEntry < ti then
            ti = tEntry
            if key == "x" then
                normalX = (dx > 0) and -1 or 1
            else
                normalY = (dy > 0) and -1 or 1
            end
        end
    end

    return ti, normalX, normalY
end

function module:checkCollisions(goalX, goalY)
    local collisions = {}
    local moveX, moveY = goalX - self.x, goalY - self.y
    local ti = 1
    local normalX, normalY = 0, 0
    local overlaps = false

    -- 1️⃣ Check if already overlapping another sprite
    for _, other in ipairs(allSprites) do
        if other ~= self and checkAABBCollision(self, other) then
            overlaps = true
            break
        end
    end

    -- 2️⃣ Check for future collisions
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

function module:moveWithCollisions(goalX, goalY)
    local actualX, actualY, collisions, count = self:checkCollisions(goalX, goalY)
    
    -- Move only if there were no collisions
    if count == 0 or self.collisionResponse == "overlap" then
        self:moveTo(actualX, actualY)
    end

    return actualX, actualY, collisions, count
end

function module:draw()
    if self.visible and self.image then
        love.graphics.draw(self.image, self.x, self.y)
    end
end

function module.updateAll()
    for _, module in ipairs(allSprites) do
        if module.animator then
            local p = module.animator:currentValue()
            module:moveTo(p.x, p.y)
            if module.animator:ended() then
                module.animator = nil
            end
        end
    end
end

function module.drawAll()
    for _, module in ipairs(allSprites) do
        module:draw()
    end
end

function module.setBackgroundDrawingCallback(callback)
    module.backgroundCallback = callback
end

function module.drawBackground()
    if module.backgroundCallback then
        module.backgroundCallback()
    end
end

return module
