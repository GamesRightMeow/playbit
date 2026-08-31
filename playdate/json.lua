-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#M-json

local module = {}
json = module

local jsonParser = require("json.json")

function module.decode(json)
  local ok, resultOrError = pcall(function () return jsonParser.decode(json) end)
  if ok then
    return resultOrError
  else
    return nil, resultOrError
  end
end

-- TODO: handle overloaded signature (file) - where `file` is a playdate.file.file
function module.decodeFile(path)
  local contents, sizeOrError = love.filesystem.read(path)
  if not contents then
    return nil, sizeOrError
  end
  return module.decode(contents)
end

function module.encode(table)
  error("[ERR] json.encode() is not yet implemented.")
end

function module.encodePretty(table)
  error("[ERR] json.encodePretty() is not yet implemented.")
end

-- TODO: handle overloaded signature (file, pretty, table) - where `file` is a playdate.file.file
function module.encodeToFile(path, pretty, table)
  error("[ERR] json.encodeToFile() is not yet implemented.")
end
