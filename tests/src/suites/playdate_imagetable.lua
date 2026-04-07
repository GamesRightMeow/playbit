local tests = {}

function tests.IsLoaded()
  local img = playdate.graphics.imagetable.new("images/pie-fill")
  pbAssert.IsNotNil(img)
end

function tests.GetSize_ReturnsSize()
  local img = playdate.graphics.imagetable.new("images/pie-fill")
  local rows, cols = img:getSize()
  pbAssert.AreEqual(rows, 9)
  pbAssert.AreEqual(cols, 1)
end

function tests.GetLength_ReturnsLength()
  local img = playdate.graphics.imagetable.new("images/pie-fill")
  local len = img:getLength()
  pbAssert.AreEqual(len, 9)
end

function tests.GetImage_ImageIsReturned()
  local imgtable = playdate.graphics.imagetable.new("images/pie-fill")
  local len = imgtable:getLength()
  local img = imgtable:getImage(len)
  pbAssert.IsNotNil(img)
end

function tests.IsDrawn()
  local img = playdate.graphics.imagetable.new("images/pie-fill")
  local width, height = img:getImage(1):getSize()
  local len = img:getLength()
  for i=1, len do
    img:drawImage(i, (i-1)*width, 0)
  end
  pbAssert.IsImageSimilar()
end

function tests.IsDrawn_Flipped()
  local img = playdate.graphics.imagetable.new("images/pie-fill")
  local width, height = img:getImage(1):getSize()
  local len = img:getLength()
  for i=1, len do
    img:drawImage(i, (i-1)*width, 0, playdate.graphics.kImageFlippedXY)
  end
  pbAssert.IsImageSimilar()
end

return tests