-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#M-datastore

local module = {}
playdate.datastore = module

local jsonParser = require("json.json")

function module.write(table, filename, prettyPrint)
  filename = filename or "data"
  filename = filename..".json"
  prettyPrint = prettyPrint or false
  -- TODO: json lib doesn't support pretty printing
  @@ASSERT(not prettyPrint, "[ERR] prettyPrint parameter is not yet implemented.")
  local str = jsonParser.encode(table)
  love.filesystem.write(filename, str)
end

function module.read(filename)
  filename = filename or "data"
  filename = filename..".json"
  
  local str, size = love.filesystem.read(filename)
  if str == nil then
    return nil
  end

  local table = jsonParser.decode(str)
  return table
end

function module.delete(filename)
  filename = filename or "data"
  filename = filename..".json"
  love.filesystem.remove(filename)
end

function module.writeImage(image, path)
  error("[ERR] playdate.datastore.writeImage() is not yet implemented.")
end

function module.readImage(path)
  error("[ERR] playdate.datastore.readImage() is not yet implemented.")
end