-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#C-ui.gridview

playdate.ui = playdate.ui or {}

local module = {}
playdate.ui.gridview = module

local meta = {}
meta.__index = meta
module.__index = meta

module.needsDisplay = false

function module.new(cellWidth, cellHeight)
    error("[ERR] playdate.ui.gridview.new() is not yet implemented.")
end

-- drawing: https://sdk.play.date/2.6.2/Inside%20Playdate.html#_drawing_3
function meta:drawCell(section, row, column, selected, x, y, width, height)
    error("[ERR] playdate.ui.gridview:drawCell() is not yet implemented.")
end

function meta:drawSectionHeader(section, x, y, width, height)
    error("[ERR] playdate.ui.gridview:drawSectionHeader() is not yet implemented.")
end

function meta:drawHorizontalDivider(x, y, width, height)
    error("[ERR] playdate.ui.gridview:drawHorizontalDivider() is not yet implemented.")
end

function meta:drawInRect(x, y, width, height)
    error("[ERR] playdate.ui.gridview:drawInRect() is not yet implemented.")
end

-- configuration: https://sdk.play.date/2.6.2/Inside%20Playdate.html#_configuration
function meta:setNumberOfSections(num)
    error("[ERR] playdate.ui.gridview:setNumberOfSections() is not yet implemented.")
end

function meta:getNumberOfSections()
    error("[ERR] playdate.ui.gridview:getNumberOfSections() is not yet implemented.")
end

function meta:setNumberOfRowsInSection(section, num)
    error("[ERR] playdate.ui.gridview:setNumberOfRowsInSection() is not yet implemented.")
end

function meta:getNumberOfRowsInSection(section)
    error("[ERR] playdate.ui.gridview:getNumberOfRowsInSection() is not yet implemented.")
end

function meta:setNumberOfColumns(num)
    error("[ERR] playdate.ui.gridview:setNumberOfColumns() is not yet implemented.")
end

function meta:getNumberOfColumns()
    error("[ERR] playdate.ui.gridview:getNumberOfColumns() is not yet implemented.")
end

function meta:setNumberOfRows(...)
    error("[ERR] playdate.ui.gridview:setNumberOfRows() is not yet implemented.")
end

function meta:setCellSize(cellWidth, cellHeight)
    error("[ERR] playdate.ui.gridview:setCellSize() is not yet implemented.")
end

function meta:setCellPadding(left, right, top, bottom)
    error("[ERR] playdate.ui.gridview:setCellPadding() is not yet implemented.")
end

function meta:setContentInset(left, right, top, bottom)
    error("[ERR] playdate.ui.gridview:setContentInset() is not yet implemented.")
end

function meta:getCellBounds(section, row, column, gridWidth)
    error("[ERR] playdate.ui.gridview:getCellBounds() is not yet implemented.")
end

function meta:setSectionHeaderHeight(height)
    error("[ERR] playdate.ui.gridview:setSectionHeaderHeight() is not yet implemented.")
end

function meta:getSectionHeaderHeight()
    error("[ERR] playdate.ui.gridview:getSectionHeaderHeight() is not yet implemented.")
end

function meta:setSectionHeaderPadding(left, right, top, bottom)
    error("[ERR] playdate.ui.gridview:setSectionHeaderPadding() is not yet implemented.")
end

function meta:setHorizontalDividerHeight(height)
    error("[ERR] playdate.ui.gridview:setHorizontalDividerHeight() is not yet implemented.")
end

function meta:addHorizontalDividerAbove(section, row)
    error("[ERR] playdate.ui.gridview:addHorizontalDividerAbove() is not yet implemented.")
end

function meta:removeHorizontalDividers()
    error("[ERR] playdate.ui.gridview:removeHorizontalDividers() is not yet implemented.")
end

-- scrolling: https://sdk.play.date/2.6.2/Inside%20Playdate.html#_scrolling_2
function meta:setScrollDuration(ms)
    error("[ERR] playdate.ui.gridview:setScrollDuration() is not yet implemented.")
end

function meta:setScrollPosition(x, y, animated)
    error("[ERR] playdate.ui.gridview:setScrollPosition() is not yet implemented.")
end

function meta:getScrollPosition()
    error("[ERR] playdate.ui.gridview:getScrollPosition() is not yet implemented.")
end

function meta:scrollToCell(section, row, column, animated)
    error("[ERR] playdate.ui.gridview:scrollToCell() is not yet implemented.")
end

function meta:scrollCellToCenter(section, row, column, animated)
    error("[ERR] playdate.ui.gridview:scrollCellToCenter() is not yet implemented.")
end

function meta:scrollToRow(row, animated)
    error("[ERR] playdate.ui.gridview:scrollToRow() is not yet implemented.")
end

function meta:scrollToTop(animated)
    error("[ERR] playdate.ui.gridview:scrollToTop() is not yet implemented.")
end

-- selection: https://sdk.play.date/2.6.2/Inside%20Playdate.html#_selection
function meta:setSelection(section, row, column)
    error("[ERR] playdate.ui.gridview:setSelection() is not yet implemented.")
end

function meta:getSelection()
    error("[ERR] playdate.ui.gridview:getSelection() is not yet implemented.")
end

function meta:setSelectedRow()
    error("[ERR] playdate.ui.gridview:setSelectedRow() is not yet implemented.")
end

function meta:getSelectedRow()
    error("[ERR] playdate.ui.gridview:getSelectedRow() is not yet implemented.")
end

function meta:selectNextRow(wrapSelection, scrollToSelection, animate)
    error("[ERR] playdate.ui.gridview:selectNextRow() is not yet implemented.")
end

function meta:selectPreviousRow(wrapSelection, scrollToSelection, animate)
    error("[ERR] playdate.ui.gridview:selectPreviousRow() is not yet implemented.")
end

function meta:selectNextColumn(wrapSelection, scrollToSelection, animate)
    error("[ERR] playdate.ui.gridview:selectNextColumn() is not yet implemented.")
end

function meta:selectPreviousColumn(wrapSelection, scrollToSelection, animate)
    error("[ERR] playdate.ui.gridview:selectPreviousColumn() is not yet implemented.")
end

-- properties: https://sdk.play.date/2.6.2/Inside%20Playdate.html#_properties
module.backgroundImage = nil
module.isScrolling = nil
module.scrollEasingFunction = nil
module.easingAmplitude = nil
module.easingPeriod = nil
module.changeRowOnColumnWrap = nil
module.scrollCellsToCenter = nil