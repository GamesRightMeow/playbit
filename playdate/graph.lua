require("playdate.node")

local module = {}
playdate.pathfinder.graph = module

local meta = {}
meta.__index = meta
module.__index = meta

function module.new(nodeCount, coordinates)
    local graph = setmetatable({}, meta)
    @@ASSERT(false, "new graph (without 2d grid) not implemented")
    return graph
end
function module.new2DGrid(width, height, allowDiagonals, includedNodes)
    @@ASSERT(includedNodes == nil, "included nodes not implemented")
    local graph = setmetatable({}, meta)
    graph.width = width
    graph.height = height
    graph.maxWeight = 14
    graph.nodes = {}
    for x = 1, width, 1 do
        graph.nodes[x] = {}
        for y = 1, height,1 do
            graph.nodes[x][y] = playdate.pathfinder.node.new(x+((y-1)*width),x,y)
            graph.nodes[x][y]:_setGraph(graph)
        end
    end
    for y = 2, height-1, 1 do
        for x = 2, width-1, 1 do
            local curNode = graph.nodes[x][y]
            local dxarray = {1,0,1}
            local dyarray = {0,1,1}
            local pathWeightArray = {10,10,14}
            for deltaIndex = 1,3,1 do
                if deltaIndex < 3 or allowDiagonals then
                    local dx = dxarray[deltaIndex]
                    local dy = dyarray[deltaIndex]
                    local connectedNode = graph.nodes[x+dx][y+dy]
                    local pathWeight = pathWeightArray[deltaIndex]
                    curNode:addConnection(connectedNode,pathWeight,true)
                end
            end
        end
    end
    return graph
end
function meta:removeAllConnectionsFromNodeWithID(id,removeIncoming)
    local curNode = self:nodeWithID(id)
    if removeIncoming then
        for x = 1, self.width, 1 do
            for y = 1, self.height,1 do
                graph.nodes[x][y]:removeConnection(curNode,false)
            end
        end
    end
    curNode.connections = {}
end
function meta:removeAllConnections()
    for x = 1, self.width, 1 do
        for y = 1, self.height,1 do
            self.nodes[x][y].connections = {}
        end
    end
end
function meta:nodeWithID(id)
    if id <= 0 then return nil end
    local x,y = self:XYfromIndex(id)
    return self:nodeWithXY(x,y)
end
function meta:nodeWithXY(x, y)
    return self.nodes[x][y]
end
function meta:indexFromXY(x,y)
    return x+(y-1)*self.width
end
function meta:XYfromIndex(index)
    y = math.floor((index-1)/self.width)+1
    x = index - (y-1)*self.width
    return x,y
end
function meta:setMaxWeight(inMaxWeight)
    if inMaxWeight > self.maxWeight then
        self.maxWeight = inMaxWeight
    end
end

--playdate.pathfinder.graph:findPath(startNode, goalNode, [heuristicFunction, [findPathToGoalAdjacentNodes]])
function meta:findPath(startNode, goalNode,heuristicFunction,findPathToGoalAdjacentNodes)
    @@ASSERT(heuristicFunction == nil, "heuristicFunction not implemented")
    @@ASSERT(findPathToGoalAdjacentNodes == nil, "findPathToGoalAdjacentNodes not implemented")

    if startNode == goalNode then return {startNode} end

    -- Initialize nodeData for path
    local nodeCost = {}
    local nodeDone = {}
    local nodePreviousID = {}
    local maxCost = self.maxWeight * self.width * self.height 
    for x = 1, self.width, 1 do
        nodeCost[x] = {}
        nodeDone[x] = {}
        nodePreviousID[x] = {}
        for y = 1, self.height,1 do
            nodeCost[x][y] = maxCost
            nodeDone[x][y] = 0
            nodePreviousID[x][y] = 0
        end
    end

    local startX,startY = startNode.x,startNode.y
    local finishX,finishY = goalNode.x,goalNode.y
    local notFinished = true
    nodeCost[startX][startY] = 0
    nodeDone[startX][startY] = 1
    nodePreviousID[startX][startY] = -1
    local curNode
    -- path finding
    local curPathCost = nodeCost[finishX][finishY]
    local optimumPathNotFound = true
    local openPaths = {startNode}
    local nodecounter = 0
    local loopCounter = 0
    while optimumPathNotFound do
        loopCounter = loopCounter + 1
        local distToGoal = self.width+self.height
        local nextNode = nil
        if curNode == nil then
            curNode = table.remove(openPaths)
        end
        local curX,curY = curNode.x,curNode.y
        local curNodeCost = nodeCost[curX][curY]
        nodeDone[curX][curY] = 1
        nodecounter = nodecounter + 1
        for key, value in pairs(curNode.connections) do
            local adjNodeX,adjNodeY = self:XYfromIndex(value.nodeid)
            local adjGoalDistance = math.abs(adjNodeX-finishX) + math.abs(adjNodeY-finishY)
            local adjWeight = value.weight
            if adjWeight + curNodeCost < nodeCost[adjNodeX][adjNodeY] then
                local adjNodeCost = adjWeight + curNodeCost
                nodeCost[adjNodeX][adjNodeY] = adjNodeCost
                nodeDone[adjNodeX][adjNodeY] = 0
                nodePreviousID[adjNodeX][adjNodeY] = curNode.id
                if adjNodeCost < curPathCost then
                    if adjNodeX == finishX and adjNodeY == finishY then
                        curPathCost = adjNodeCost
                    else
                        table.insert(openPaths,self.nodes[adjNodeX][adjNodeY])
                        if adjGoalDistance < distToGoal then
                            distToGoal = adjGoalDistance
                            nextNode = self.nodes[adjNodeX][adjNodeY]
                        end
                    end
                end
            end
        end
        curNode = nextNode
        -- check all undone paths and see if there is a better way to go, compare to curPathCost to decide when to stop with node
        if #openPaths == 0 then
            optimumPathNotFound = false
        end
    end
    if nodePreviousID[finishX][finishY] == 0 then
        return nil
    else
        curNode = goalNode
        local nodeListRev = {}
        local nodeCount = 0
        while curNode ~= nil do
            nodeCount = nodeCount + 1
            local curX,curY = curNode.x,curNode.y
            nodeListRev[nodeCount] = curNode
            curNode = self:nodeWithID(nodePreviousID[curX][curY])
        end
        local nodeListFwd = {}
        for i = 1, nodeCount, 1 do
            nodeListFwd[i] = nodeListRev[nodeCount+1-i]
        end
        return nodeListFwd
    end
end


    -- while notFinished do
    --     local curX,curY = curNode.x,curNode.y
    --     local curNodeCost = nodeCost[curX][curY]
    --     nodeDone[curX][curY] = 1
    --     for key, value in pairs(curNode.connections) do
    --         local adjNodeX,adjNodeY = self:XYfromIndex(value.nodeid)
    --         local adjWeight = value.weight
    --         if adjWeight + curNode < nodeCost[adjNodeX][adjNodeY] then
    --             nodeCost[adjNodeX][adjNodeY] = adjWeight + curNodeCost
    --             nodeDone[adjNodeX][adjNodeY] = 0
    --         end
    --     end
    --     if curX < finishX then
    --         curX = curX + 1
    --     elseif curX > finishX then
    --         curX = curX - 1
    --     elseif curY < finishY then
    --         curY = curY + 1 
    --     elseif curY > finishY then
    --         curY = curY - 1
    --     else
    --         notFinished = false
    --     end
    -- end