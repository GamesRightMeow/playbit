playdate.pathfinder = playdate.pathfinder or {}
local module = {}
playdate.pathfinder.node = module

local meta = {}
meta.__index = meta
module.__index = meta

function module.new(id,x,y)
      local node = setmetatable({}, meta)
      node.x = x
      node.y = y
      node.id = id
      node.connections = {}
      node.graph = nil
      return node
end
function meta:_setGraph(inGraph)
      self.graph = inGraph
end
--playdate.pathfinder.node:addConnection(node, weight, addReciprocalConnection)
function meta:addConnection(node,weight, addReciprocalConnection)
      self.connections[node.id] = {node = node, nodeid = node.id,weight = weight}
      if addReciprocalConnection then
            node.connections[self.id] = {node = node, nodeid = self.id,weight = weight}
      end
end
function meta:removeAllConnections(removeIncoming)
      self.graph:removeAllConnectionsFromNodeWithID(self.id,removeIncoming)
end
function meta:removeConnection(node, removeReciprocal)
      self.connections[node.id] = nil
      if removeReciprocal then
            node.connections[self.id] = nil
      end
end
function meta:connectedNodes()
      local nodeList = {}
      for key, value in pairs(self.connections) do
            nodeList[#nodeList+1] = value.node
      end
      return nodeList
end