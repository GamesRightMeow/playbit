local module = {}
playdate = module

require("playbit.geometry")

function module.getCurrentTimeMilliseconds()
  return love.timer.getTime() * 1000
end

-- ██╗███╗   ██╗██████╗ ██╗   ██╗████████╗
-- ██║████╗  ██║██╔══██╗██║   ██║╚══██╔══╝
-- ██║██╔██╗ ██║██████╔╝██║   ██║   ██║   
-- ██║██║╚██╗██║██╔═══╝ ██║   ██║   ██║   
-- ██║██║ ╚████║██║     ╚██████╔╝   ██║   
-- ╚═╝╚═╝  ╚═══╝╚═╝      ╚═════╝    ╚═╝   
  
local lastActiveJoystick = nil
local isCrankDocked = false
local crankPos = 0
local lastCrankPos = 0

module._buttonToKey = {
  up = "kb_up",
  down = "kb_down",
  left = "kb_left",
  right = "kb_right",
  a = "kb_s",
  b = "kb_a",
}

local NONE = 0
local JUST_PRESSED = 1
local PRESSED = 2
local JUST_RELEASED = 3

local inputStates = {}

function module.buttonIsPressed(button)
  local key = module._buttonToKey[button]
  if not inputStates[key] then
    -- no entry, assume no input
    return false
  end

  return inputStates[key] == JUST_PRESSED or inputStates[key] == PRESSED
end

function module.buttonJustPressed(button)
  local key = module._buttonToKey[button]
  if not inputStates[key] then
    -- no entry, assume no input
    return false
  end

  return inputStates[key] == JUST_PRESSED
end

function module.buttonJustReleased(button)
  local key = module._buttonToKey[button]
  if not inputStates[key] then
    -- no entry, assume no input
    return false
  end

  return inputStates[key] == JUST_RELEASED
end

function module.isCrankDocked()
  if not lastActiveJoystick then
    return isCrankDocked
  end

  -- TODO: is basing dock state on if stick is non-zero a bad assumption here?
  -- will other games want a dedicated dock/undock button?
  local x = math.abs(lastActiveJoystick:getAxis(3))
  local y = math.abs(lastActiveJoystick:getAxis(4))
  local len = math.sqrt(x * x + y * y)
  -- TODO: deadzone sensitivity?
  if len < 0.1 then
    return true
  end

  return false
end

function module.getCrankChange()
    local change = playbit.geometry.angleDiff(lastCrankPos, crankPos)
    -- TODO: how does the playdate accelerate this?
    local acceleratedChange = change 
    return change, acceleratedChange
end

function module.getCrankPosition()
  if module.isCrankDocked() then
    return 0
  end

  if not lastActiveJoystick then
    return crankPos
  end

  local x = lastActiveJoystick:getAxis(3)
  local y = lastActiveJoystick:getAxis(4)

  local degrees = math.deg(math.atan2(-y, x))
  if degrees < 0 then
    return degrees + 360
  end
  return degrees
end

function love.joystickadded(joystick)
  -- always take most recently added joystick as active joystick
  lastActiveJoystick = joystick
end

function love.joystickremoved(joystick)
  if lastActiveJoystick == nil then
    return
  end

  if joystick:getID() == lastActiveJoystick:getID() then
    lastActiveJoystick = nil
  end
end

function love.gamepadpressed(joystick, gamepadButton)
  lastActiveJoystick = joystick
  inputStates["js_"..gamepadButton] = JUST_PRESSED
end

function love.gamepadreleased(joystick, gamepadButton)
  lastActiveJoystick = joystick
  inputStates["js_"..gamepadButton] = JUST_RELEASED
end

function love.mousepressed(x, y, button, istouch, presses)
  if button ~= 3 then
    return
  end

  isCrankDocked = not isCrankDocked
  crankPos = 0
end

function love.wheelmoved(x, y)
  if isCrankDocked then
    return
  end

  -- TODO: emulate PD crank acceleration?
  -- TODO: configure scroll sensitivity?
  crankPos = crankPos + -y * 6
  
  if crankPos < 0 then
    crankPos = 359
  elseif crankPos > 359 then
    crankPos = 0
  end
end

function love.keypressed(key)
  inputStates["kb_"..key] = JUST_PRESSED
end

function love.keyreleased(key)  
  inputStates["kb_"..key] = JUST_RELEASED
end

function module.updateInput()
  -- only update keys that are mapped
  for k,v in pairs(module._buttonToKey) do
    if inputStates[v] == JUST_PRESSED then
      inputStates[v] = PRESSED
    elseif inputStates[v] == JUST_RELEASED then
      inputStates[v] = NONE
    end
  end
  lastCrankPos = crankPos
end

-- ██╗     ██╗   ██╗ █████╗ 
-- ██║     ██║   ██║██╔══██╗
-- ██║     ██║   ██║███████║
-- ██║     ██║   ██║██╔══██║
-- ███████╗╚██████╔╝██║  ██║
-- ╚══════╝ ╚═════╝ ╚═╝  ╚═╝
                         
function table.indexOfElement(table, element)
  for i = 1, #table do
    if table[i] == element then
      return i
    end
  end
  return nil
end

-- printTable(...) is just like print but formats tables
local insert = table.insert
local sort   = table.sort
local concat = table.concat
local function repeatString(s,t)
	local chars = {}
	for i=1,t do
		chars[i] = s
	end
	return concat(chars)
end

-- based on compareAnyTypes from http://lua-users.org/wiki/SortedIteration
local function sortAny(val1, val2)
    local type1,type2 = type(val1), type(val2)
    local num1,num2  = tonumber(val1), tonumber(val2)
    
    if num1 and num2 then
        return num1 < num2
    elseif type1 ~= type2 then
        return type1 < type2
    elseif type1 == 'string'  then
        return val1 < val2
    elseif type1 == 'boolean' then
        return val1
    else
        return tostring(val1) < tostring(val2)
    end
end

-- from https://www.lua.org/pil/19.3.html
local function pairsByKey(t, f)
	local a = {}
	for n in pairs(t) do insert(a, n) end
	sort(a, f or sortAny)
	local i = 0 -- iterator variable
	local iter = function() -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]] end
	end
	return iter
end

local encounteredTables = nil -- {}
local function tableToString(o,path,t)
	path = path or '/'
	if encounteredTables[o] then
		return 'reference: '..encounteredTables[o]
	end
	encounteredTables[o] = path
	
	t = t or 1
	local lines = {'{'}
	local tabs = repeatString('\t', t)
	t = t + 1
	
	local line = #lines + 1
	for k,v in pairsByKey(o) do
		local ktype = type(k)
		local vtype = type(v)
		
		local key = ''
		if ktype ~= 'number' then
			key = '['..tostring(k)..'] = '
		end
		
		local value
		if vtype == 'table' then
			value = tableToString(v, path..k..'/', t)
		else
			value = tostring(v)
		end
		lines[line] = tabs..key..value..','
		
		line = line + 1
	end
	lines[line] = repeatString('\t', t-2)..'}'
	return concat(lines, '\n')
end

function printTable(...)
	encounteredTables = {}
	local args = {...}
	for i=1,#args do
		local a = args[i]
		if type(a) == 'table' then
			-- encounteredTables[a] = '/'..i
			args[i] = tableToString(a)
		end
	end
	print(unpack(args))
	encounteredTables = nil
end