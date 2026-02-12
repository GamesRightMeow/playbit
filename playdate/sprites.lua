require("playdate.object")
local bit = require("bit") -- LuaJIT's bitwise operations

local module = {}

module.kCollisionTypeSlide = "slide"
module.kCollisionTypeFreeze = "freeze"
module.kCollisionTypeOverlap = "overlap"
module.kCollisionTypeBounce = "bounce"

playdate.graphics.sprite = module

local meta = {}
meta.__index = meta
module.__index = meta


local allSprites = {}

function module.new(imageOrTilemap)
  local sprite = setmetatable({}, meta)

  if imageOrTilemap then
    sprite:setImage(imageOrTilemap)
  end

  sprite.x, sprite.y = 0, 0
  sprite.visible = true
  sprite.zIndex = 0
  sprite.collideRect = nil
  sprite.animator = nil

  sprite._updatesEnabled = true
  sprite._collisionsEnabled = true

  sprite:setCenter(0.5, 0.5)

  sprite:resetGroupMask()
  sprite:resetCollidesWithGroupsMask()

  return sprite
end

function module.getAllSprites(func)
  return { unpack(allSprites) }
end

function module.performOnAllSprites(func)
  for i = 1, #allSprites do
    func(allSprites[i])
  end
end

function module.spriteCount(func)
  return #allSprites
end

function module.removeAll()
  for _, spr in ipairs(allSprites) do
    spr.added = false
  end

  allSprites = {}
end

function module.removeSprites(spritesArray)
  if spritesArray then
    for _, spr in ipairs(spritesArray) do
      spr:remove()
    end
  end
end

function module.spriteWithText(text, maxWidth, maxHeight, backgroundColor, leadingAdjustment, truncationString, alignment, font)
  error("[ERR] playdate.graphics.sprite.spriteWithText() is not yet implemented.")
end

function module.addSprite(sprite)
  sprite:add()
end

function module.removeSprite(sprite)
  sprite:remove()
end

function module.setAlwaysRedraw(flag)
  error("[ERR] playdate.graphics.sprite.setAlwaysRedraw() is not yet implemented.")
end

function module.getAlwaysRedraw()
  error("[ERR] playdate.graphics.sprite.getAlwaysRedraw() is not yet implemented.")
end

function meta:copy()
  error("[ERR] playdate.graphics.sprite.copy() is not yet implemented.")
end

function meta:setImage(image)
  self.image = image
  if image then
    self.width, self.height = image:getSize()
  end
end

function meta:getImage()
  return self.image
end

function meta:setSize(w, h)
  self.width, self.height = w, h
end

function meta:getSize()
  return self.width, self.height
end

function meta:moveTo(x, y)
  self.x, self.y = x, y
end

function meta:getPosition()
  return self.x, self.y
end

function meta:moveBy(x, y)
  self:moveTo(self.x + x, self.y + y)
end

function meta:add()
  if not self.added then
    table.insert(allSprites, self)
    self.added = true
    table.sort(allSprites, function(a, b) return a.zIndex < b.zIndex end)
  end
end

function meta:remove()
  for i, sprite in ipairs(allSprites) do
    if sprite == self then
      table.remove(allSprites, i)
      self.added = false
      return
    end
  end
end

function meta:setZIndex(index)
  self.zIndex = index
  table.sort(allSprites, function(a, b) return a.zIndex < b.zIndex end)
end

function meta:getZIndex()
  return self.zIndex
end

function meta:setCollideRect(x, y, w, h)
  self.collideRect = { x = x, y = y, width = w, height = h }
end

function meta:getCollideRect()
  return self.collideRect
end

function meta:getCollideBounds()
  error("[ERR] playdate.graphics.sprite.getCollideBounds() is not yet implemented.")
end

function meta:clearCollideRect()
  self.collideRect = nil
end

function meta:setCollisionResponse(response)
  self.collisionResponse = response
end

function module.allOverlappingSprites()
  error("[ERR] playdate.graphics.sprite.allOverlappingSprites() is not yet implemented.")
end

function meta:alphaCollision(anotherSprite)
  error("[ERR] playdate.graphics.sprite.alphaCollision() is not yet implemented.")
end

function meta:setCollisionsEnabled(flag)
  self._collisionsEnabled = flag
end

function meta:collisionsEnabled()
  return self._collisionsEnabled
end

function meta:setGroups(groups)
  self.groupMask = 0x00000000

  for _, group in ipairs(groups) do
    if group >= 1 and group <= 32 then
      self.groupMask = bit.bor(self.groupMask, bit.lshift(1, group - 1))
    end
  end
end

function meta:setCollidesWithGroups(groups)
  self.collidesWithGroupsMask = 0x00000000
  for _, group in ipairs(groups) do
    if group >= 1 and group <= 32 then
      self.collidesWithGroupsMask = bit.bor(self.collidesWithGroupsMask, bit.lshift(1, group - 1))
    end
  end
end

function meta:setGroupMask(mask)
  self.groupMask = mask
end

function meta:getGroupMask()
  return self.groupMask
end

function meta:setCollidesWithGroupsMask(mask)
  self.collidesWithGroupsMask = mask
end

function meta:getCollidesWithGroupsMask()
  return self.collidesWithGroupsMask
end

function meta:resetGroupMask()
  self.groupMask = 0x00000000
end

function meta:resetCollidesWithGroupsMask()
  self.collidesWithGroupsMask = 0x00000000
end

function meta:canCollideWith(other)
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
    return 0, 1     -- Overlapping, collision lasts full movement range
  end

  -- Compute time when movement **enters** and **exits** collision on this axis
  local tEntry = (oMin - sMax) / ds   -- Entry time (when first touching)
  local tExit = (oMax - sMin) / ds    -- Exit time (when leaving)

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
  local ti = 1                    -- Time of impact (1 = full movement allowed, 0 = instant collision)
  local normalX, normalY = 0, 0   -- Collision normal

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
      return nil, 0, 0       -- No collision
    end

    -- **Track the earliest collision (smallest `ti`)**
    if tEntry < ti then
      ti = tEntry       -- Update the earliest collision time

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


function meta:checkCollisions(goalX, goalY)
  local collisions = {}
  local moveX, moveY = goalX - self.x, goalY - self.y
  local ti = 1
  local normalX, normalY = 0, 0
  local overlaps = false

  if not self._collisionsEnabled then
    return goalX, goalY, collisions, #collisions
  end

  -- already overlapping another sprite?
  for _, other in ipairs(allSprites) do
    if other ~= self and other._collisionsEnabled and other.collideRect and checkAABBCollision(self, other) then
      overlaps = true
      break
    end
  end

  -- Check for possible future collisions
  for _, other in ipairs(allSprites) do
    if other ~= self and other._collisionsEnabled and other.collideRect then
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

-- function meta:moveWithCollisions(goalX, goalY)
--     local actualX, actualY, collisions, count = self:checkCollisions(goalX, goalY)

--     -- Move only if there were no collisions
--     if count == 0 or self.collisionResponse == "overlap" then
--         self:moveTo(actualX, actualY)
--     end

--     return actualX, actualY, collisions, count
-- end

function meta:moveWithCollisions(goalX, goalY)
  local actualX, actualY, collisions, count = self:checkCollisions(goalX, goalY)

  if count == 0 then
    self:moveTo(goalX, goalY)
    return actualX, actualY, collisions, count
  end

  -- Iterate through each collision
  for _, col in ipairs(collisions) do
    local other = col.other
    local response = "freeze"     -- Default collision behavior

    -- **Check if `collisionResponse` is a function or string**
    if type(self.collisionResponse) == "function" then
      response = self:collisionResponse(other) or "freeze"       -- Call function with `other`
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
      actualX, actualY = self.x, self.y       -- Reset to original position
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

function module.querySpritesAtPoint(x, y)
  error("[ERR] playdate.graphics.sprite.querySpritesAtPoint() is not yet implemented.")
end

function module.querySpritesInRect(x, y, width, height)
  error("[ERR] playdate.graphics.sprite.querySpritesInRect() is not yet implemented.")
end

function module.querySpritesAlongLine(x1, y1, x2, y2)
  error("[ERR] playdate.graphics.sprite.querySpritesAlongLine() is not yet implemented.")
end

function module.querySpriteInfoAlongLine(x1, y1, x2, y2)
  error("[ERR] playdate.graphics.sprite.querySpriteInfoAlongLine() is not yet implemented.")
end

function module.addEmptyCollisionSprite(x, y, w, h)
  error("[ERR] playdate.graphics.sprite.addEmptyCollisionSprite() is not yet implemented.")
end

function module.addWallSprites(tilemap, emptyIDs, xOffset, yOffset)
  error("[ERR] playdate.graphics.sprite.addWallSprites() is not yet implemented.")
end

function meta:setScale(scale, yScale)
  self.scaleX = scale
  self.scaleY = yScale or scale
end

function meta:getScale()
  return self.scaleX, self.scaleY
end

function meta:setRotation(angle, scale, yScale)
  self.angle = angle

  if (scale) then
    self:setScale(scale, yScale)
  end
end

function meta:getRotation()
  return self.angle
end

function meta:setUpdatesEnabled(flag)
  self._updatesEnabled = false
end

function meta:updatesEnabled()
  return self._updatesEnabled
end

function meta:setTag(tag)
  error("[ERR] playdate.graphics.sprite.setTag() is not yet implemented.")
end

function meta:getTag()
  error("[ERR] playdate.graphics.sprite.getTag() is not yet implemented.")
end

function meta:setImageDrawMode(mode)
  error("[ERR] playdate.graphics.sprite.setImageDrawMode() is not yet implemented.")
end

function meta:setImageFlip(flip, flipCollideRect)
  error("[ERR] playdate.graphics.sprite.setImageFlip() is not yet implemented.")
end

function meta:getImageFlip()
  error("[ERR] playdate.graphics.sprite.getImageFlip() is not yet implemented.")
end

function meta:setIgnoresDrawOffset(flag)
  error("[ERR] playdate.graphics.sprite.setIgnoresDrawOffset() is not yet implemented.")
end

function meta:setBounds(x, y, width, height)
  if y == nil then
    self.x, self.y, self.width, self.height = x:unpack()
  else
    self.x, self.y, self.width, self.height = x, y, width, height
  end
end

function meta:getBounds()
  return self.x, self.y, self.width, self.height
end

function meta:getBoundsRect()
  return playdate.geometry.rect.new(self.x, self.y, self.width, self.height)
end

function meta:setOpaque(flag)
  error("[ERR] playdate.graphics.sprite.setOpaque() is not yet implemented.")
end

function meta:isOpaque()
  error("[ERR] playdate.graphics.sprite.isOpaque() is not yet implemented.")
end

function meta:setVisible(flag)
  self.visible = flage
end

function meta:isVisible()
  return self.visible
end

function meta:setCenter(x, y)
  self.centerX = x
  self.centerY = y
end

function meta:getCenter()
  return self.centerX, self.centerY
end

function meta:getCenterPoint()
  return self.x - self.width * self.centerX, self.y - self.height * self.centerY
end

function meta:setTilemap(tilemap)
  error("[ERR] playdate.graphics.sprite.setTilemap() is not yet implemented.")
end

function meta:setAnimator(animator, moveWithCollisions, removeOnCollision)
  -- assert(moveWithCollisions == nil, "[ERR] moveWithCollisions is not yet supported")
  -- assert(removeOnCollision == nil, "[ERR] removeOnCollision is not yet supported")
  self.animator = animator
end

function meta:removeAnimator()
  self.animator = nil
end

function meta:setClipRect(x, y, width, height)
  error("[ERR] playdate.graphics.sprite.setClipRect() is not yet implemented.")
end

function meta:clearClipRect()
  error("[ERR] playdate.graphics.sprite.clearClipRect() is not yet implemented.")
end

function module.setClipRectsInRange(x, y, width, height, startz, endz)
  error("[ERR] playdate.graphics.sprite.setClipRectsInRange() is not yet implemented.")
end

function module.clearClipRectsInRange(startz, endz)
  error("[ERR] playdate.graphics.sprite.clearClipRectsInRange() is not yet implemented.")
end

function meta:setStencilImage(stencil, tile)
  error("[ERR] playdate.graphics.sprite.setStencilImage() is not yet implemented.")
end

function meta:setStencilPattern(level, ditherType)
  error("[ERR] playdate.graphics.sprite.setStencilPattern() is not yet implemented.")
end

function meta:clearStencil()
  error("[ERR] playdate.graphics.sprite.clearStencil() is not yet implemented.")
end

function meta:markDirty()
  -- do nothing.
end

function module.addDirtyRect(x, y, width, height)
  -- do nothing.
end

function meta:setRedrawsOnImageChange(flag)
  error("[ERR] playdate.graphics.sprite.setRedrawsOnImageChange() is not yet implemented.")
end

local function updateAll()
  for _, spr in ipairs(allSprites) do
    if spr.animator then
      local p = spr.animator:currentValue()
      spr:moveTo(p.x, p.y)
      if spr.animator:ended() then
        spr.animator = nil
      end
    end

    -- call sprite:update() implementation
    if spr._updatesEnabled and spr.update ~= module.update then
        spr:update()
    end
  end
end

local function drawAll()
  for _, spr in ipairs(allSprites) do
    if spr.visible then
      if spr.image then
        playbit.graphics.setDrawMode("image")
        love.graphics.draw(spr.image.data,
            spr.x, spr.y,
            spr.angle,
            spr.scaleX, spr.scaleY,
            spr.width * spr.centerX, spr.height * spr.centerY)

      elseif spr.draw then
        love.graphics.push()
        love.graphics.translate(spr.x, spr.y)
        spr:draw(0, 0, spr.width, spr.height)
        love.graphics.pop()
      end
    end
  end
end

function module.update()
  updateAll()
  drawAll()
end

function module.setBackgroundDrawingCallback(callback)
  local backgroundSprite = module.new()
  backgroundSprite:setSize(playdate.display.getSize())
  backgroundSprite:setCenter(0, 0)
  backgroundSprite:setZIndex(-32768)
  backgroundSprite:setIgnoresDrawOffset(true)
  backgroundSprite:setUpdatesEnabled(false)
  backgroundSprite.draw = function(self, x, y, w, h)
    callback(x, y, w, h)
  end
  backgroundSprite:add()
  return backgroundSprite
end

function module.redrawBackground()
end

-- allow sprite to be inheritable
module.className = "Sprite"
module.super = Object
module.baseObject = module.new
setmetatable(module, meta)
setmetatable(meta, Object)

return module
