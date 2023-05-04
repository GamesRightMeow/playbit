playbit = playbit or {}

!if LOVE2D then
--- Sets the scale of the screen.
---@param scale number
function playbit.setScreenScale(scale)
  playdate.graphics._newScreenScale = scale
end

---Returns the current scale of the screen.
---@return number
function playbit.getScreenScale()
    return playdate.graphics._screenScale
end
!end