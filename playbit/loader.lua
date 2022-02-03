local Loader = {}

local cache = {}

function Loader.image(path)
  local cachedImage = cache[path]
  if cachedImage then
    -- pull from cache if exists
    return cachedImage
  end

  -- otherwise generate new image and cache it
  local img = pb.image.new(path)
  cache[path] = img
  return img
end

-- TODO: load and cache other assets

return Loader