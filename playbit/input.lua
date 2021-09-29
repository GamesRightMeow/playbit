local Input = {}

local keyToButton = {}
keyToButton["up"] = "up"
keyToButton["down"] = "down"
keyToButton["left"] = "left"
keyToButton["right"] = "right"
keyToButton["z"] = "a"
keyToButton["x"] = "b"
keyToButton["`"] = "debug_stats"

local buttonStates = {}
for k,v in pairs(keyToButton) do
  buttonStates[v] = 0
end

function Input.update()
  for k,v in pairs(buttonStates) do
    if buttonStates[k] == 1 then
      buttonStates[k] = 2
    end
  end
end

function Input.handleKeyPressed(key)
  local button = keyToButton[key]
  if button == nil then
    return
  end

  if buttonStates[button] == nil then
    return
  end

  buttonStates[button] = 1
end

function Input.handleKeyReleased(key)
  local button = keyToButton[key]
  if button == nil then
    return
  end

  if buttonStates[button] == nil then
    return
  end

  buttonStates[button] = 0
end

-- returns true when the specified button is held down
function Input.getButton(button)
  return buttonStates[button] > 0
end

-- returns true when the specified button was pressed in the last frame
function Input.getButtonDown(button)
  return buttonStates[button] == 1
end

return Input