-- entry point into the playbit engine

-- set globally
pb = {}

pb.import = function(path)
!if LOVE2D then
  return require(string.gsub(path, "/", "."))
!else
  return playdate.file.run(path)
!end
end

pb.util = pb.import("playbit/util")
pb.time = pb.import("playbit/time")
pb.app = pb.import("playbit/app")
pb.io = pb.import("playbit/io")
pb.graphics = pb.import("playbit/graphics")
pb.image = pb.import("playbit/image")
pb.imagetable = pb.import("playbit/imagetable")
pb.tilemap = pb.import("playbit/tilemap")
pb.animation = pb.import("playbit/animation")
pb.perf = pb.import("playbit/perf")
pb.input = pb.import("playbit/input")
pb.random = pb.import("playbit/random")
pb.geometry = pb.import("playbit/geometry")
pb.vector = pb.import("playbit/vector")
pb.ease = pb.import("playbit/ease")
pb.debug = pb.import("playbit/debug")