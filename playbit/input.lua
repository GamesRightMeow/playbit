local module = {}
playbit = playbit or {}
playbit.input = module

!if LOVE2D then
--- Sets how Love2D inputs are mapped to Playdate's buttons. Both keyboard and joystick are supported.  
--- Prepend keyboard inputs with "kb_" and refer to Love2D's input list: https://love2d.org/wiki/KeyConstant  
--- Prepend joystick inputs with "js_" and refer to Love2D's input list:  https://love2d.org/wiki/GamepadButton.
---@param up string
---@param down string
---@param left string
---@param right string
---@param a string
---@param b string
function module.setKeyMap(up, down, left, right, a, b)
    @@ASSERT(string.find(up, "^kb_") or string.find(up, "^js_"), "Missing device prefix!")
    @@ASSERT(string.find(down, "^kb_") or string.find(down, "^js_"), "Missing device prefix!")
    @@ASSERT(string.find(left, "^kb_") or string.find(left, "^js_"), "Missing device prefix!")
    @@ASSERT(string.find(right, "^kb_") or string.find(right, "^js_"), "Missing device prefix!")
    @@ASSERT(string.find(a, "^kb_") or string.find(a, "^js_"), "Missing device prefix!")
    @@ASSERT(string.find(b, "^kb_") or string.find(b, "^js_"), "Missing device prefix!")
    playdate._buttonToKey.up = up
    playdate._buttonToKey.down = down
    playdate._buttonToKey.left = left
    playdate._buttonToKey.right = right
    playdate._buttonToKey.a = a
    playdate._buttonToKey.b = b
end
!end