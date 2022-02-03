-- entry point into the playbit engine

pb = {}

pb.app = require("playbit.app")
pb.scene = require("playbit.scene")
pb.graphics = require("playbit.graphics")
pb.image = require("playbit.image")
pb.perf = require("playbit.perf")
pb.input = require("playbit.input")
pb.util = require("playbit.util")
pb.components = require("playbit.components")
pb.componentArray = require("playbit.component-array")
pb.entityArray = require("playbit.entity-array")
pb.bitfield = require("playbit.bitfield")
pb.vector = require("playbit.vector")
pb.ease = require("playbit.ease")
pb.steering = require("playbit.steering")
pb.loader = require("playbit.loader")
pb.debug = require("playbit.debug")

pb.systems = {}
pb.systems.nameAllocator = require("playbit.systems.name-allocator")
pb.systems.collisionDetector = require("playbit.systems.collision-detector")
pb.systems.graphicRenderer = require("playbit.systems.graphic-renderer")
pb.systems.parentManager = require("playbit.systems.parent-manager")
pb.systems.particleSystem = require("playbit.systems.particle-system")
pb.systems.physics = require("playbit.systems.physics")
pb.systems.offscreenDetector = require("playbit.systems.offscreen-detector")