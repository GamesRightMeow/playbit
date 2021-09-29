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

return namespace