-- entry point into the playbit engine

local namespace = {}

namespace.app = require("playbit.app");
namespace.scene = require("playbit.scene");
namespace.graphics = require("playbit.graphics");
namespace.perf = require("playbit.perf");
namespace.input = require("playbit.input");
namespace.util = require("playbit.util");
namespace.components = require("playbit.components");
namespace.bitfield = require("playbit.bitfield");
namespace.vector = require("playbit.vector");
namespace.ease = require("playbit.ease");
namespace.steering = require("playbit.steering");

namespace.systems = {}
namespace.systems.collisionDetector = require("playbit.systems.collision-detector")
namespace.systems.graphicRenderer = require("playbit.systems.graphic-renderer")
namespace.systems.parentManager = require("playbit.systems.parent-manager")
namespace.systems.particleSystem = require("playbit.systems.particle-system")
namespace.systems.physics = require("playbit.systems.physics")

function namespace.assert(value, message)
  --! if ASSERT then
  assert(value, message)
  --! end
end

return namespace