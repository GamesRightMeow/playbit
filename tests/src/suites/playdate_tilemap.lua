local tests = {}

function tests.IsCreated()
  local tilemap = playdate.graphics.tilemap.new()
  pbAssert.IsNotNil(tilemap)
end

function tests.CanGetTileSize()
  local tilemap = playdate.graphics.tilemap.new()
  local imagetable = playdate.graphics.imagetable.new("images/pie-fill")
  tilemap:setImageTable(imagetable)
  local width, height = tilemap:getTileSize()
  pbAssert.IsNotNil(width)
  pbAssert.IsNotNil(height)
end

function tests.CanSetTiles()
  local tilemap = playdate.graphics.tilemap.new()
  local imagetable = playdate.graphics.imagetable.new("images/pie-fill")
  tilemap:setImageTable(imagetable)
  tilemap:setTiles({1, 1, 2, 3, 3, 1}, 3)
  pbAssert.AreEqual(tilemap:getTileAtPosition(1, 1), 1)
end

function tests.CanSetTile()
  local tilemap = playdate.graphics.tilemap.new()
  local imagetable = playdate.graphics.imagetable.new("images/pie-fill")
  tilemap:setImageTable(imagetable)
  tilemap:setTiles({1, 1, 2, 3, 3, 1}, 3)
  tilemap:setTileAtPosition(1, 1, 2)
  pbAssert.AreEqual(tilemap:getTileAtPosition(1, 1), 2)
end

-- sdk quirk
function tests.CantSetTileBeforeSetTiles()
  local tilemap = playdate.graphics.tilemap.new()
  local imagetable = playdate.graphics.imagetable.new("images/pie-fill")
  tilemap:setImageTable(imagetable)
  tilemap:setTileAtPosition(1, 1, 2)
  pbAssert.IsNil(tilemap:getTileAtPosition(1, 1))
end

function tests.CanDraw()
  local tilemap = playdate.graphics.tilemap.new()
  local imagetable = playdate.graphics.imagetable.new("images/pie-fill")
  tilemap:setImageTable(imagetable)
  tilemap:setSize(2, 2)
  tilemap:setTiles({1, 2, 1, 2}, 2)
  tilemap:draw(0, 0)
  pbAssert.IsImageSimilar()
end

return tests
