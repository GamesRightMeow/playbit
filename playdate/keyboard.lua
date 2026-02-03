-- docs: https://sdk.play.date/3.0.2/Inside%20Playdate.html#M-keyboard

local module = {}
playdate.keyboard = module

local meta = {}
meta.__index = meta
module.__index = meta
module.keyBoardImage = playdate.graphics.image.new("playdate/Keyboard_temp")
module.sprite = playdate.graphics.sprite.new(module.keyBoardImage)
module.sprite:setZIndex(32767)
module._visible = false
module.text = ''
module.x = 0
module.textChangedCallback = nil
module.keyboardDidShowCallback = nil
module.keyboardDidHideCallback = nil
module.keyboardWillHideCallback = nil
module.keyboardAnimatingCallback = nil
function module.hide()
  module._visible = false
  playdate.inputHandlers.pop()
  module.sprite:remove()
end
function module.show(_text)
  playdate.inputHandlers.push({}, true)
  module._visible = true
  if type(_text) == "string" then
    module.text = _text
  else
    module.text = ''
  end
  module.sprite:add()
  module.sprite:moveTo(338,120)
  module.sprite:setIgnoresDrawOffset(true)
end
function module.isVisible()
  return module._visible
end
function module.left()
  return module.x
end
function module.width()
  return module.x
end
function module.setCapitalizationBehavior(behavior)
  error("[ERR] playdate.keyboard.show() is not yet implemented.")
end
function module._backspace()
  module.text = module.text:sub(1,-2)
  if module.textChangedCallback ~= nil then
    module.textChangedCallback()
  end
end
function module._closeOk()
  module.hide()
  if module.keyboardDidHideCallback ~= nil then
    module.keyboardDidHideCallback(true)
  end
end
function module._closeCancel()
  module.hide()
  if module.keyboardDidHideCallback ~= nil then
    module.keyboardDidHideCallback(true)
  end
end