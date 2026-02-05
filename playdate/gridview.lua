-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#C-ui.gridview
import 'CoreLibs/timer'
import 'CoreLibs/easing'

playdate.ui = playdate.ui or {}

local module = {}
playdate.ui.gridview = module

local meta = {}
meta.__index = meta
module.__index = meta

module.needsDisplay = false

function module.new(cellWidth, cellHeight)
    local gridview = setmetatable({}, meta)
    gridview._drawImage = playdate.graphics.image.new(cellWidth,cellHeight)
    gridview._selectedRow = 1
    gridview._selectedColumn = 1
    gridview._selectedSection = 1
    gridview._cellWidth = cellWidth
    gridview._cellHeight = cellHeight
    gridview.backgroundImage = nil
    gridview.isScrolling = false
    gridview.scrollEasingFunction = playdate.easingFunctions.outCubic
    gridview.easingAmplitude = nil
    gridview.easingPeriod = nil
    gridview._numSections = 1
    gridview._numRows = {1}
    gridview._sectionStartY = {0}
    gridview._numColumns = 1
    gridview._cellPadding = {0,0,0,0}  -- left, right, top , bottom 
    gridview._contentInset = {0,0,0,0} -- left, right, top , bottom 
    gridview._sectionHeaderHeight = 0
    gridview._sectionHeaderPadding = {0,0,0,0} -- left, right, top , bottom 
    gridview._horizontalDividerHeight = cellHeight / 2
    gridview._horizontalDivider = {}
    gridview._scrollDuration = 250
    gridview._scrollPositionX = 0
    gridview._scrollPositionY = 0
    gridview._scrollToPositionX = 0
    gridview._scrollToPositionY = 0
    gridview._scrollToStartPositionX = 0
    gridview._scrollToStartPositionY = 0
    gridview._maxX = cellWidth
    gridview._maxY = cellHeight
    gridview._drawRectWidth = nil
    gridview._drawRectHeight = nil
    gridview._drawInsetWidth = cellWidth
    gridview._drawInsetHeight = cellHeight
    gridview._scrollTimer = playdate.timer.new(250,0,1,gridview.scrollEasingFunction)
    gridview.scrollCellsToCenter = true
    gridview.changeRowOnColumnWrap = true
    local gridViewLocal = gridview
    gridview._scrollTimer.updateCallback = function(timer)
        gridViewLocal._scrollPositionX = gridViewLocal._scrollToStartPositionX + timer.value * (gridViewLocal._scrollToPositionX-gridViewLocal._scrollToStartPositionX)
        gridViewLocal._scrollPositionY = gridViewLocal._scrollToStartPositionY + timer.value * (gridViewLocal._scrollToPositionY-gridViewLocal._scrollToStartPositionY)
    end
    gridview._scrollTimer.timerEndedCallback = function(timer)
        gridViewLocal._scrollPositionX = gridViewLocal._scrollToPositionX
        gridViewLocal._scrollPositionY = gridViewLocal._scrollToPositionY
        gridViewLocal.isScrolling = false
    end
    gridview._needToRecalculateSectionStartY = true
    gridview:_calculateSectionStartY()
    
    return gridview
end
function meta:_scrollGridview(x,y)
    --NOTE: Need to change originalValues to deal with timer reseting easing Function
    self._scrollTimer.originalValues.easingFunction = self.scrollEasingFunction
    self._scrollToStartPositionX = self._scrollPositionX
    self._scrollToStartPositionY = self._scrollPositionY
    self._scrollToPositionX = x
    self._scrollToPositionY = y
    self._scrollTimer:reset()
    self._scrollTimer:start()
end
function meta:_calculateSectionStartY()
    local curHeight = 0
    self._sectionStartY = {}
    for sectionIndex = 1, self._numSections, 1 do
        self._sectionStartY[sectionIndex] = curHeight
        curHeight = curHeight + self._numRows[sectionIndex] * (self._cellHeight + self._cellPadding[3] + self._cellPadding[4])
        if self._sectionHeaderHeight > 0 then
            curHeight = curHeight + self._sectionHeaderHeight + self._sectionHeaderPadding[3] + self._sectionHeaderPadding[4]
        end
        if self._horizontalDivider[sectionIndex] ~= nil then
            for hdRow = 1, self._numRows[sectionIndex], 1 do
                if self._horizontalDivider[sectionIndex][hdRow] then
                    curHeight = curHeight + self._horizontalDividerHeight
                end
            end
        end
    end
    self._maxY = curHeight
    self._maxX = self._numColumns * (self._cellWidth +self._cellPadding[1] + self._cellPadding[2])
    self._needToRecalculateSectionStartY = false
end
function meta:_calculateCellPosition(section,row,column)
    local cellX, cellY = 0 , 0
    cellY = cellY + self._sectionStartY[section]
    cellY = cellY + self._sectionHeaderHeight + self._sectionHeaderPadding[3] + self._sectionHeaderPadding[4]
    cellY = cellY + (self._cellPadding[3]) * row + (row-1)*(self._cellHeight + self._cellPadding[4])
    if self._horizontalDivider[section] ~= nil then
        for hdRow = 1, row, 1 do
            if self._horizontalDivider[section][hdRow] then
                cellY = cellY + self._horizontalDividerHeight
            end
        end
    end
    cellX = cellX + (self._cellPadding[1]) * column + (column-1)*(self._cellWidth + self._cellPadding[2])
    return cellX,cellY
end
-- drawing: https://sdk.play.date/2.6.2/Inside%20Playdate.html#_drawing_3
function meta:drawCell(section, row, column, selected, x, y, width, height)
    playdate.graphics.setColor(0)
	playdate.graphics.drawRect(x, y, width, height)
	if selected then
		playdate.graphics.fillRect(x + 2, y + 2, width - 4, height - 4)
	end
end

function meta:drawSectionHeader(section, x, y, width, height)
    playdate.graphics.setColor(0)
	playdate.graphics.fillRect(x, y, width, height)
end

function meta:drawHorizontalDivider(x, y, width, height)
    playdate.graphics.setColor(0)
	playdate.graphics.fillRect(x+2, y+(height-1)/2, width-4, 2)
end
function module.drawInRect(inGridview,x,y,width,height)
    if inGridview == nil then return end
    if inGridview._needToRecalculateSectionStartY then
        inGridview:_calculateSectionStartY()
    end
    local changedSize = false
    if inGridview._drawRectWidth ~= width then
        inGridview._drawRectWidth = width
        changedSize = true
    end
    if inGridview._drawInsetWidth ~= width - inGridview._contentInset[1] - inGridview._contentInset[2] then
        inGridview._drawInsetWidth = width - inGridview._contentInset[1] - inGridview._contentInset[2]
        changedSize = true
    end
    if inGridview._drawRectHeight ~= height then
        inGridview._drawRectHeight = height
        changedSize = true
    end
    if inGridview._drawInsetHeight ~= height - inGridview._contentInset[3] - inGridview._contentInset[4] then
        inGridview._drawInsetHeight = height - inGridview._contentInset[3] - inGridview._contentInset[4]
        changedSize = true
    end
    if changedSize or inGridview._drawImage == nil then
        inGridview._drawImage = playdate.graphics.image.new(inGridview._drawRectWidth,inGridview._drawRectHeight)
        inGridview._drawInsetImage = playdate.graphics.image.new(inGridview._drawInsetWidth,inGridview._drawInsetHeight)
    end
    playdate.graphics.pushContext(inGridview._drawImage)
    playdate.graphics.clear(2)
    -- draw background
    
    if inGridview.backgroundImage ~= nil then
        if inGridview.backgroundImage._imageSections ~= nil then
            inGridview.backgroundImage:drawInRect(0,0,width,height)
        else
            inGridview.backgroundImage:drawTiled(0, 0, width, height)
        end
    end
    playdate.graphics.pushContext(inGridview._drawInsetImage)
    playdate.graphics.clear(2)

    local drawWidth = inGridview._drawInsetWidth
    local drawHeight = inGridview._drawInsetHeight
    -- Draw all cells



    local cellWidth,cellHeight = inGridview._cellWidth,inGridview._cellHeight

    for curSection = 1 , inGridview._numSections do
        if inGridview._sectionStartY[curSection+1] == nil or inGridview._sectionStartY[curSection+1] >= inGridview._scrollPositionY then
            -- if start of next section is after scroll position then this section 
            -- needs to be drawn or we would have stopped already
            if inGridview._sectionHeaderHeight ~= 0 then
                local xPos = inGridview._sectionHeaderPadding[1]+x
                local yPos = inGridview._sectionHeaderPadding[3]+y + inGridview._sectionStartY[curSection]- inGridview._scrollPositionY
                inGridview:drawSectionHeader(curSection,xPos,yPos,drawWidth,inGridview._sectionHeaderHeight)
            end
            local horizontalDividerCounter = 0
            for curRow = 1, inGridview._numRows[curSection] do
                local rowY = - inGridview._scrollPositionY +horizontalDividerCounter * inGridview._horizontalDividerHeight + inGridview._sectionStartY[curSection]+inGridview._sectionHeaderHeight+inGridview._sectionHeaderPadding[3]+inGridview._sectionHeaderPadding[4] + inGridview._cellPadding[3] + (curRow-1)* (cellHeight+inGridview._cellPadding[3]+inGridview._cellPadding[4])                
                if inGridview._horizontalDivider[curSection] ~= nil then
                    if inGridview._horizontalDivider[curSection][curRow] then
                        horizontalDividerCounter = horizontalDividerCounter + 1
                        inGridview:drawHorizontalDivider(0,rowY,drawWidth,inGridview._horizontalDividerHeight)
                    end
                end
                rowY = - inGridview._scrollPositionY + horizontalDividerCounter * inGridview._horizontalDividerHeight + inGridview._sectionStartY[curSection]+inGridview._sectionHeaderHeight+inGridview._sectionHeaderPadding[3]+inGridview._sectionHeaderPadding[4] + inGridview._cellPadding[3] + (curRow-1)* (cellHeight+inGridview._cellPadding[3]+inGridview._cellPadding[4])
                
                for curColumn = 1, inGridview._numColumns do
                    local isSelected,cellX,cellY
                    isSelected = false
                    if inGridview._selectedSection == curSection and inGridview._selectedRow == curRow and inGridview._selectedColumn == curColumn then
                        isSelected = true
                    end                    
                    cellX = - inGridview._scrollPositionX + (inGridview._cellPadding[1]) * curColumn + (curColumn-1)*(inGridview._cellWidth + inGridview._cellPadding[2])
                    cellY = rowY + inGridview._cellPadding[3]
                    inGridview:drawCell(curSection,curRow,curColumn,isSelected,cellX,cellY,cellWidth,cellHeight)
                end
            end
        end
    end
    playdate.graphics.popContext()
    inGridview._drawInsetImage:draw(inGridview._contentInset[1],inGridview._contentInset[3])
    playdate.graphics.popContext()
    inGridview._drawImage:draw(x,y)
end
function meta:drawInRect(x, y, width, height)
    playdate.ui.gridview.drawInRect(self,x,y,width,height)
    -- if self._needToRecalculateSectionStartY then
    --     self:_calculateSectionStartY()
    -- end
    -- local changedSize = false
    -- if self._drawRectWidth ~= width then
    --     self._drawRectWidth = width
    --     changedSize = true
    -- end
    -- if self._drawInsetWidth ~= width - self._contentInset[1] - self._contentInset[2] then
    --     self._drawInsetWidth = width - self._contentInset[1] - self._contentInset[2]
    --     changedSize = true
    -- end
    -- if self._drawRectHeight ~= height then
    --     self._drawRectHeight = height
    --     changedSize = true
    -- end
    -- if self._drawInsetHeight ~= height - self._contentInset[3] - self._contentInset[4] then
    --     self._drawInsetHeight = height - self._contentInset[3] - self._contentInset[4]
    --     changedSize = true
    -- end
    -- if changedSize or self._drawImage == nil then
    --     self._drawImage = playdate.graphics.image.new(self._drawRectWidth,self._drawRectHeight)
    --     self._drawInsetImage = playdate.graphics.image.new(self._drawInsetWidth,self._drawInsetHeight)
    -- end
    -- playdate.graphics.pushContext(self._drawImage)
    -- playdate.graphics.clear(2)
    -- -- draw background
    -- if self.backgroundImage ~= nil then
    --     if self.backgroundImage._imageSections ~= nil then
    --         self.backgroundImage:drawInRect(0,0,width,height)
    --     else
    --         self.backgroundImage:drawTiled(0, 0, width, height)
    --     end
    -- end

    -- playdate.graphics.pushContext(self._drawInsetImage)
    -- playdate.graphics.clear(2)

    -- local drawWidth = self._drawInsetWidth
    -- local drawHeight = self._drawInsetHeight
    -- -- Draw all cells
    -- local cellWidth,cellHeight = self._cellWidth,self._cellHeight
    -- for curSection = 1 , self._numSections do
    --     if self._sectionStartY[curSection+1] == nil or self._sectionStartY[curSection+1] >= self._scrollPositionY then
    --         -- if start of next section is after scroll position then this section 
    --         -- needs to be drawn or we would have stopped already
    --         if self._sectionHeaderHeight ~= 0 then
    --             self:drawSectionHeader(curSection,self._sectionHeaderPadding[1]+x,self._sectionHeaderPadding[3]+y,drawWidth,self._sectionHeaderHeight)
    --         end
    --         local horizontalDividerCounter = 0
    --         for curRow = 1, self._numRows[curSection] do
    --             local rowY = - self._scrollPositionY +horizontalDividerCounter * self._horizontalDividerHeight + self._sectionStartY[curSection]+self._sectionHeaderHeight+self._sectionHeaderPadding[3]+self._sectionHeaderPadding[4] + self._cellPadding[3] + (curRow-1)* (cellHeight+self._cellPadding[3]+self._cellPadding[4])                
    --             if self._horizontalDivider[curSection] ~= nil then
    --                 if self._horizontalDivider[curSection][curRow] then
    --                     horizontalDividerCounter = horizontalDividerCounter + 1
    --                     self:drawHorizontalDivider(0,rowY,drawWidth,self._horizontalDividerHeight)
    --                 end
    --             end
    --             rowY = - self._scrollPositionY + horizontalDividerCounter * self._horizontalDividerHeight + self._sectionStartY[curSection]+self._sectionHeaderHeight+self._sectionHeaderPadding[3]+self._sectionHeaderPadding[4] + self._cellPadding[3] + (curRow-1)* (cellHeight+self._cellPadding[3]+self._cellPadding[4])
                
    --             for curColumn = 1, self._numColumns do
    --                 local isSelected,cellX,cellY
    --                 isSelected = false
    --                 if self._selectedSection == curSection and self._selectedRow == curRow and self._selectedColumn == curColumn then
    --                     isSelected = true
    --                 end                    
    --                 cellX = - self._scrollPositionX + (self._cellPadding[1]) * curColumn + (curColumn-1)*(self._cellWidth + self._cellPadding[2])
    --                 cellY = rowY + self._cellPadding[3]
    --                 self:drawCell(curSection,curRow,curColumn,isSelected,cellX,cellY,cellWidth,cellHeight)
    --             end
    --         end
    --     end
    -- end
    -- playdate.graphics.popContext()
    -- self._drawInsetImage:draw(self._contentInset[1],self._contentInset[3])
    -- playdate.graphics.popContext()
    -- self._drawImage:draw(x,y)
end

-- configuration: https://sdk.play.date/2.6.2/Inside%20Playdate.html#_configuration
function meta:setNumberOfSections(num)
    if num > 0 then
        if num > self._numSections then
            for i = self._numSections+1, num, 1 do
                self._numRows[i] = 1
            end
        elseif num < self._numSections then
            for i = num+1, self._numSections, 1 do
                self._numRows[i] = nil
            end
        end
        self._numSections = num
        self._needToRecalculateSectionStartY = true
    end
end

function meta:getNumberOfSections()
    return self._numSections
end

function meta:setNumberOfRowsInSection(section, num)
    if num > 0 then
        self._numRows[section] = num
        self._needToRecalculateSectionStartY = true
    end
end

function meta:getNumberOfRowsInSection(section)
    return self._numRows[section]
end

function meta:setNumberOfColumns(num)
    if num > 0 then
        self._numColumns = num
        self._needToRecalculateSectionStartY = true
    end
end

function meta:getNumberOfColumns()
    return self._numColumns
end

function meta:setNumberOfRows(...)
    local numSections = select ('#', ...)
    if numSections > self._numSections then
        self:setNumberOfSections(numSections)
    end
    for i = 1, numSections, 1 do
        self:setNumberOfRowsInSection(i,select (i, ...))
    end
end

function meta:setCellSize(cellWidth, cellHeight)
    if cellWidth > 0 then
        self._cellWidth = cellWidth
        self._needToRecalculateSectionStartY = true
    end
    if cellHeight > 0 then
        self._cellHeight = cellHeight
        self._needToRecalculateSectionStartY = true
    end
end

function meta:setCellPadding(left, right, top, bottom)
    self._cellPadding = {left,right,top,bottom}
end

function meta:setContentInset(left, right, top, bottom)
    self._contentInset = {left,right,top,bottom}
    if self._drawRectHeight ~= nil then
        self._drawInsetWidth = self._drawRectWidth - left - right
        self._drawInsetHeight = self._drawRectHeight - top - bottom
    end
end

function meta:getCellBounds(section, row, column, gridWidth)
    -- playdate seems to give x and y relative to top left not top right as mentioned in the documentation
    local cellX,cellY = self:_calculateCellPosition(section,row,column)
    local x = cellX - self._scrollPositionX + self._contentInset[1]
    local y = cellY - self._scrollPositionY + self._contentInset[3]
    if self._cellWidth > 0 then
        return x,y,self._cellWidth,self._cellHeight
    else
        assert(gridWidth ~= nil, 'if cell width is 0 or nil gridWidth must be given')
        return x,y,gridWidth - self._contentInset[1] - self._contentInset[2]
    end
end

function meta:setSectionHeaderHeight(height)
    if height ~= nil then
        self._sectionHeaderHeight = height
    end
    self._needToRecalculateSectionStartY = true
end

function meta:getSectionHeaderHeight()
    return self._sectionHeaderHeight
end

function meta:setSectionHeaderPadding(left, right, top, bottom)
    self._sectionHeaderPadding = {left,right,top,bottom}
    if self._sectionHeaderHeight ~= 0 then
        self._needToRecalculateSectionStartY = true
    end
end

function meta:setHorizontalDividerHeight(height)
    if height ~= nil then
        self._horizontalDividerHeight = height
        self._needToRecalculateSectionStartY = true
    end
end

function meta:addHorizontalDividerAbove(section, row)
    local dividerData = {}
    if self._horizontalDivider[section] == nil then
        self._horizontalDivider[section] = {}
    end
    self._horizontalDivider[section][row] = true
    self._needToRecalculateSectionStartY = true
end

function meta:removeHorizontalDividers()
    self._horizontalDivider = {}
    self._needToRecalculateSectionStartY = true
end

-- scrolling: https://sdk.play.date/2.6.2/Inside%20Playdate.html#_scrolling_2
function meta:setScrollDuration(ms)
    ms = math.max(0,ms)
    self._scrollDuration = ms
end

function meta:setScrollPosition(x, y, animated)
    if y > self._maxY - self._drawInsetHeight then y = self._maxY - self._drawInsetHeight end
    if x > self._maxX - self._drawInsetWidth then x = self._maxX - self._drawInsetWidth end
    if x < 0 then x = 0 end
    if y < 0 then y = 0 end
    if animated ~= false then
        self:_scrollGridview(x,y)
    else
        self._scrollPositionX = x
        self._scrollPositionY = y
    end
end

function meta:getScrollPosition()
    return self._scrollPositionX ,  self._scrollPositionY
end

function meta:scrollToCell(section, row, column, animated)
    if self.scrollCellsToCenter then
        self:scrollCellToCenter(section, row, column, animated)
        return
    end
    cellX,cellY = self:_calculateCellPosition(section,row,column)
    local toXPos,toYPos = self._scrollPositionX , self._scrollPositionY
    if self._scrollPositionX > cellX - self._cellPadding[1] then
        toXPos = cellX - self._cellPadding[1]
    elseif self._scrollPositionX + self._drawInsetWidth < cellX + self._cellWidth + self._cellPadding[2] then
        toXPos = cellX + self._cellPadding[2] + self._cellWidth - self._drawInsetWidth 
    end
    if self._scrollPositionY > cellY - self._cellPadding[3] then
        toYPos = cellY - self._cellPadding[3]
    elseif self._scrollPositionY + self._drawInsetHeight < cellY+ self._cellHeight + self._cellPadding[4] then
        toYPos = cellY + self._cellPadding[4] + self._cellHeight - self._drawInsetHeight 
    end
    self:setScrollPosition(toXPos,toYPos,animated)
end

function meta:scrollCellToCenter(section, row, column, animated)
    local cellX,cellY = self:_calculateCellPosition(section,row,column)
    -- top left of cell (relative to top left of gridview)
    local cellXCenter, cellYCenter = cellX +self._cellWidth/2 , cellY+self._cellHeight/2
    local gridviewCenterX, gridviewCenterY = self._drawInsetWidth/2 , self._drawInsetHeight / 2
    self:setScrollPosition(cellXCenter-gridviewCenterX,cellYCenter-gridviewCenterY,animated)
    --self:setScrollPosition(cellX+self._cellWidth/2-self._drawInsetWidth/2,cellY+self._cellHeight/2-self._drawInsetHeight/2,animated)
end

function meta:scrollToRow(row, animated)
    self:scrollToCell(self._selectedSection,row,self._selectedColumn,animated)
end

function meta:scrollToTop(animated)
    self:setScrollPosition(self._scrollPositionX,0,animated)
end

-- selection: https://sdk.play.date/2.6.2/Inside%20Playdate.html#_selection
function meta:setSelection(section, row, column)
    self._selectedSection, self._selectedRow, self._selectedColumn = section, row, column
end

function meta:getSelection()
    return self._selectedSection, self._selectedRow, self._selectedColumn
end

function meta:setSelectedRow()
    self._selectedRow = 1
end

function meta:getSelectedRow()
    return self._selectedRow
end

function meta:selectNextRow(wrapSelection, scrollToSelection, animate)
    local didChange = false
    if self._selectedRow < self._numRows[self._selectedSection] then
        self._selectedRow = self._selectedRow + 1
        didChange = true
    else
        if self._selectedSection == self._numSections and wrapSelection == true then
            self._selectedSection = 1 
            self._selectedRow = 1
            didChange = true
        elseif self._selectedSection < self._numSections then
            self._selectedSection = self._selectedSection + 1
            self._selectedRow = 1
            didChange = true
        end
    end
    if didChange and scrollToSelection ~= false then
        self:scrollToCell(self._selectedSection,self._selectedRow,self._selectedColumn,animate)
    end
end

function meta:selectPreviousRow(wrapSelection, scrollToSelection, animate)
    local didChange = false
    if self._selectedRow > 1 then
        self._selectedRow = self._selectedRow - 1
        didChange = true
    else
        if self._selectedSection == 1 and wrapSelection == true then
            self._selectedSection = self._numSections 
            self._selectedRow = self._numRows[self._selectedSection]
            didChange = true
        elseif self._selectedSection > 1 then
            self._selectedSection = self._selectedSection - 1
            self._selectedRow = self._numRows[self._selectedSection]
            didChange = true
        end
    end
    if didChange and scrollToSelection ~= false then
        self:scrollToCell(self._selectedSection,self._selectedRow,self._selectedColumn,animate)
    end
end

function meta:selectNextColumn(wrapSelection, scrollToSelection, animate)
    local didChange = false
    --TODO: test : if self.changeRowOnColumnWrap 
    if self._selectedColumn < self._numColumns then
        self._selectedColumn = self._selectedColumn + 1
        didChange = true
    elseif self._selectedColumn == self._selectedColumn and self._numColumns > 1 and wrapSelection then
        self._selectedColumn = 1
        didChange = true
        if self.changeRowOnColumnWrap then
            self:selectNextRow(wrapSelection,scrollToSelection,animate)
            didChange = false
        end
        
    end
    if didChange and scrollToSelection ~= false then
        self:scrollToCell(self._selectedSection,self._selectedRow,self._selectedColumn,animate)
    end
end

function meta:selectPreviousColumn(wrapSelection, scrollToSelection, animate)
    local didChange = false
    --TODO: test : if self.changeRowOnColumnWrap
    if self._selectedColumn > 1 then
        self._selectedColumn = self._selectedColumn - 1
        didChange = true
    elseif self._selectedColumn == 1 and self._numColumns > 1 and wrapSelection then
        self._selectedColumn = self._numColumns
        didChange = true
        if self.changeRowOnColumnWrap then
            self:selectPreviousRow(wrapSelection,scrollToSelection,animate)
            didChange = false
        end
    end
    if didChange and scrollToSelection ~= false then
        self:scrollToCell(self._selectedSection,self._selectedRow,self._selectedColumn,animate)
    end
end

-- properties: https://sdk.play.date/2.6.2/Inside%20Playdate.html#_properties


