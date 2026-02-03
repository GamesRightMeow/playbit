-- docs: https://sdk.play.date/3.0.2/Inside%20Playdate.html#M-keyboard
import("CoreLibs/ui/gridview")

local module = {}
playdate.menu = module

local meta = {}
meta.__index = meta
module.__index = meta

local moduleitem = {}
playdate.menu.item = moduleitem

local metaitem = {}
metaitem.__index = metaitem
moduleitem.__index = metaitem

module.menuitems = {}
module.isVisible = false
module.savedUpdate = nil
module.menuGridView = nil
module.menuPosition = 400
module.menuOpenPosition = 200
module.menuClosedPosition = 400
module.menuClosing = false
module.menuOpening = false
module.font = SYSTEM_FONT
function playdate.openSystemMenu()
  --TODO take background screen shot
  module.isVisible = true
  module.savedUpdate = playdate.update
  playdate.update = playdate.systemMenuUpdate
  module.menuGridView = playdate.ui.gridview.new(186,25)
  local bg = playdate.graphics.nineSlice.new('playdate/systemmenu',7,7,17,18)
  module.menuGridView.backgroundImage = bg
  module.menuGridView:setNumberOfRows(3)
  module.menuGridView:setNumberOfColumns(1)
  module.menuGridView:setCellPadding(2,2,2,2)
  module.menuGridView:setContentInset(7,7,7,7)
  module.menuOpening = true
  module.menuGridView.drawCell = systemdrawCell
  module.runCallback = {}
  for i = 1, #module.menuitems, 1 do
    module.runCallback[i] = false
  end
end
function playdate.closedSystemMenu()
  module.isVisible = false
  for i = 1, #module.menuitems, 1 do
    if module.runCallback[i] then
      module.menuitems[i].callback(module.menuitems[i].value)
    end
  end
  playdate.update = module.savedUpdate
end
function playdate.closeSystemMenu()
  module.menuClosing = true
end
function playdate.systemMenuUpdate()
  if module.menuOpening then
    module.menuPosition = module.menuPosition - 10
    if module.menuPosition <= module.menuOpenPosition then
      module.menuOpening = false
    end
  elseif module.menuClosing then
    module.menuPosition = module.menuPosition + 10
    if module.menuPosition >= module.menuClosedPosition then
      module.menuClosing = false
      playdate.closedSystemMenu()
    end
  end
  module.menuGridView:drawInRect(module.menuPosition,0,200,240)
  if module.menuClosing or module.menuOpening then
    return
  end
  if playdate.buttonJustPressed(playdate.kButtonDown) then
    module.menuGridView:selectNextRow(false)
  elseif playdate.buttonJustPressed(playdate.kButtonUp) then
    module.menuGridView:selectPreviousRow(false)
  elseif playdate.buttonJustPressed(playdate.kButtonRight) or playdate.buttonJustPressed(playdate.kButtonA) then
    -- change option or tick box or run callback
    local selectedRow = module.menuGridView:getSelectedRow()
    module.runCallback[selectedRow] = true
    if module.menuitems[selectedRow].options ~= nil then
      module.menuitems[selectedRow].index = module.menuitems[selectedRow].index + 1
      if module.menuitems[selectedRow].index > #module.menuitems[selectedRow].options then
        module.menuitems[selectedRow].index = 1
      end
      module.menuitems[selectedRow].value = module.menuitems[selectedRow].options[module.menuitems[selectedRow].index]
    elseif module.menuitems[selectedRow].value ~= nil then
      module.menuitems[selectedRow].value =  not module.menuitems[selectedRow].value
    else
      -- Close menu and call menuitem's callback (and any callbacks already queued)
      -- setting a non - nil value means it will be called
      playdate.closeSystemMenu()
    end
  elseif playdate.buttonJustPressed(playdate.kButtonLeft) then
    -- change option or tick box
    local selectedRow = module.menuGridView:getSelectedRow()
    module.runCallback[selectedRow] = true
    if module.menuitems[selectedRow].options ~= nil then
      module.menuitems[selectedRow].index = module.menuitems[selectedRow].index - 1
      if module.menuitems[selectedRow].index < 1 then
        module.menuitems[selectedRow].index = #module.menuitems[selectedRow].options
      end
      module.menuitems[selectedRow].value = module.menuitems[selectedRow].options[module.menuitems[selectedRow].index]
    elseif module.menuitems[selectedRow].value ~= nil then
      module.menuitems[selectedRow].value =  not module.menuitems[selectedRow].value
    end
  elseif playdate.buttonJustPressed(playdate.kButtonB) then
    playdate.closeSystemMenu()
  end
end
function playdate.getSystemMenu()
  return module
end
function playdate.setMenuImage(image, xOffset)
end
function module:addMenuItem(title, callback)
  local menuitem = moduleitem.new(title,callback)
  table.insert(module.menuitems,menuitem)
end
function module:addCheckmarkMenuItem(_text,value,callback)
  local menuitem = moduleitem.new(_text,callback)
  if value ~= true then
    menuitem.value = false
  else
    menuitem.value = true
  end
  table.insert(module.menuitems,menuitem)
end
function module:addOptionsMenuItem(title, options, initalValue, callback)
  local menuitem = moduleitem.new(title,callback)
  menuitem.options = options
  menuitem.index = 1
  for i = 1, #options, 1 do
    if initalValue == options[i] then
      menuitem.index = i
    end
  end
  menuitem.value = menuitem.options[menuitem.index]
  table.insert(module.menuitems,menuitem)
end
function module:getMenuItems()
  return module.menuitems
end
function module:removeMenuItem(menuItem)
  for i = #module.menuitems, 1, -1 do
    if module.menuitems[i] == menuItem then
      table.remove(module.menuitems,i)
      return
    end
  end
end
function module:removeAllMenuItems()
  module.menuitems = {}
end

function moduleitem.new(title,callback)
  local menuitem = setmetatable({}, metaitem)
  menuitem.title = title
  menuitem.callback = callback
  return menuitem
end
function metaitem:setCallback(callback)
  self.callback = callback
end
function metaitem:setTitle(newTitle)
  self.title = newTitle
end
function metaitem:getTitle()
  return self.title
end
function metaitem:setValue(newValue)
  self.value = newValue
end
function metaitem:getValue()
  return self.value
end

function systemdrawCell(gridview, section, row, column, selected, x, y, width, height)
  
	playdate.graphics.drawRect(x, y, width, height)
  if selected then
    playdate.graphics.setColor(0)
    playdate.graphics.fillRect(x,y,width,height)
    playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
  else
    playdate.graphics.setColor(0)
	  playdate.graphics.drawRect(x, y, width, height)
  end
  if module.menuitems[row] ~= nil then
    if module.menuitems[row].title ~= nil then
      font = SYSTEM_FONT
      playdate.graphics.drawTextInRect(module.menuitems[row].title,x,y+2,width,height,nil,nil,nil,font)
    end
    if module.menuitems[row].value == nil then
      -- nothing to add
    elseif module.menuitems[row].options ~= nil then
      -- add text for selected option
      local optionText = module.menuitems[row].value
      playdate.graphics.drawTextInRect(optionText,x,y+3,width,height,nil,nil,1,font)
    else
      -- Add tick box
      if module.menuitems[row].value == true then
        -- Ticked (checked)
        if selected then
          playdate.graphics.setColor(1)
        else
          playdate.graphics.setColor(0)
        end
        playdate.graphics.setLineWidth(3) 
        playdate.graphics.fillRoundRect(x+width-30,y+2,20,20,2)
        if selected then
          playdate.graphics.setColor(0)
        else
          playdate.graphics.setColor(1)
        end
        playdate.graphics.drawLine(x+width-28,y+12,x+width-20,y+20)
        playdate.graphics.drawLine(x+width-21,y+20,x+width-13,y+5)
        playdate.graphics.setColor(0)
        playdate.graphics.setLineWidth(1)
      else
        -- unticked (not checked)
        if selected then
          playdate.graphics.setColor(1)
        else
          playdate.graphics.setColor(0)
        end
        playdate.graphics.setLineWidth(2)
        playdate.graphics.drawRoundRect(x+width-30,y+2,20,20,2)
        playdate.graphics.setLineWidth(1)
        playdate.graphics.setColor(0)
      end
    end
  end
  playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
  playdate.graphics.setColor(0)
end