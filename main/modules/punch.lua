-- Punch Module
local punch = {}

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local punchRange = 10
local punchVisualizerEnabled = false
local punchAngleCheckEnabled = false
local includeNPCs = true
local punchParticleEnabled = false
local mouseConnection

local function isInFrontAndVisible(localPosition, localLookVector, targetPosition)
    local directionToTarget = (targetPosition - localPosition).Unit
    local dotProduct = localLookVector:Dot(directionToTarget)
    local isInFront = dotProduct > 0.3

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {character}

    local ray = Workspace:Raycast(localPosition, directionToTarget * punchRange, rayParams)
    if ray and ray.Instance and not ray.Instance:IsDescendantOf(character) then
        return false
    end

    return isInFront
end

local function findNearestEntity()
    local closestEntity
    local shortestDistance = math.huge
    local localRootPart = character:FindFirstChild("HumanoidRootPart")

    if not localRootPart then return nil end

    local candidates = includeNPCs and Workspace:GetDescendants() or game.Players:GetPlayers()

    for _, model in ipairs(candidates) do
        local humanoidRootPart = model:IsA("Model") and model:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart and model ~= player.Character then
            if includeNPCs or model:IsA("Player") then
                local distance = (humanoidRootPart.Position - localRootPart.Position).Magnitude
                if distance <= punchRange and (not punchAngleCheckEnabled or isInFrontAndVisible(localRootPart.Position, localRootPart.CFrame.LookVector, humanoidRootPart.Position)) then
                    closestEntity = model
                    shortestDistance = distance
                end
            end
        end
    end

    return closestEntity
end

local function punchNearestEntity()
    local nearestEntity = findNearestEntity()
    if nearestEntity then
        local humanoidRootPart = nearestEntity:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local impactPosition = punchParticleEnabled and humanoidRootPart.Position or Vector3.new(1e4, 1e4, 1e4)

            local punchEvent = ReplicatedStorage:FindFirstChild("Remote Events") and ReplicatedStorage["Remote Events"]:FindFirstChild("Punch")
            if punchEvent then
                punchEvent:FireServer(nearestEntity, impactPosition)
                print("Punch fired at model:", nearestEntity:GetFullName(), "at position:", impactPosition)
            else
                warn("Punch event not found.")
            end
        end
    end
end

function punch.start()
    if mouseConnection then return end
    mouseConnection = player:GetMouse().Button1Down:Connect(punchNearestEntity)
end

function punch.stop()
    if mouseConnection then
        mouseConnection:Disconnect()
        mouseConnection = nil
    end
end

function punch.updateRange(value)
    local rangeValue = tonumber(value)
    if rangeValue then
        punchRange = rangeValue
    end
end

function punch.toggleVisualizer(callback)
    punchVisualizerEnabled = callback
end

function punch.toggleAngleCheck(callback)
    punchAngleCheckEnabled = callback
end

function punch.toggleIncludeNPCs(callback)
    includeNPCs = callback
end

function punch.toggleParticle(callback)
    punchParticleEnabled = callback
end

function punch.getRange()
    return punchRange
end

return punch
