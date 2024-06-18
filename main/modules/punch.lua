-- Punch Module
local punch = {}

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local punchRange = 10
local maxDetectionRange = 25
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
        print("[Debug] Raycast hit:", ray.Instance.Name, "Not clear path.")
        return false
    end

    print("[Debug] Path is clear, target in front:", isInFront)
    return isInFront
end

local function findNearestEntity()
    local closestEntity
    local shortestDistance = math.huge
    local localRootPart = character:FindFirstChild("HumanoidRootPart")

    if not localRootPart then
        print("[Debug] Local player does not have HumanoidRootPart.")
        return nil
    end

    local candidates = includeNPCs and Workspace:GetDescendants() or game.Players:GetPlayers()

    for _, model in ipairs(candidates) do
        local humanoidRootPart = model:IsA("Model") and model:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart and model ~= player.Character then
            if includeNPCs or model:IsA("Player") then
                local distance = (humanoidRootPart.Position - localRootPart.Position).Magnitude
                if distance <= maxDetectionRange and (not punchAngleCheckEnabled or isInFrontAndVisible(localRootPart.Position, localRootPart.CFrame.LookVector, humanoidRootPart.Position)) then
                    closestEntity = model
                    shortestDistance = distance
                    print("[Debug] Nearest entity found:", model.Name, "Distance:", distance)
                end
            end
        end
    end

    if not closestEntity then
        print("[Debug] No entity found within range.")
    end

    return closestEntity
end

local function punchNearestEntity()
    local nearestEntity = findNearestEntity()
    if nearestEntity then
        local humanoidRootPart = nearestEntity:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local impactPosition = punchParticleEnabled and humanoidRootPart.Position + (humanoidRootPart.CFrame.LookVector * 1) or Vector3.new(1e4, 1e4, 1e4)

            local punchEvent = ReplicatedStorage:FindFirstChild("Remote Events") and ReplicatedStorage["Remote Events"]:FindFirstChild("Punch")
            if punchEvent then
                punchEvent:FireServer(nearestEntity, impactPosition)
                print("[Debug] Punch event fired on:", nearestEntity:GetFullName(), "at position:", impactPosition)
            else
                warn("[Debug] Punch event not found.")
            end
        end
    else
        print("[Debug] No nearest entity to punch.")
    end
end

local function createVisualizerPart(model)
    if not model then
        print("[Debug] No model provided for visualizer.")
        return
    end
    local part = Instance.new("Part")
    part.Size = Vector3.new(4, 6, 4)
    part.Transparency = 1
    part.Anchored = false
    part.CanCollide = false
    part.Parent = model
    part.CFrame = model.HumanoidRootPart.CFrame

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = part
    weld.Part1 = model.HumanoidRootPart
    weld.Parent = part

    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Adornee = part
    selectionBox.Parent = model

    print("[Debug] Visualizer created for model:", model.Name)
    return part
end

local function removeVisualizerPart(model)
    if model then
        local visualPart = model:FindFirstChildWhichIsA("Part", true)
        if visualPart then
            visualPart:Destroy()
            print("[Debug] Visualizer part removed from model:", model.Name)
        end
        local selectionBox = model:FindFirstChildWhichIsA("SelectionBox", true)
        if selectionBox then
            selectionBox:Destroy()
            print("[Debug] SelectionBox removed from model:", model.Name)
        end
    end
end

function punch.start()
    if mouseConnection then return end
    mouseConnection = player:GetMouse().Button1Down:Connect(function()
        print("[Debug] Mouse button clicked.")
        punchNearestEntity()
    end)
end

function punch.stop()
    if mouseConnection then
        mouseConnection:Disconnect()
        mouseConnection = nil
        print("[Debug] Mouse connection stopped.")
    end
end

function punch.updateRange(value)
    local rangeValue = tonumber(value)
    if rangeValue then
        punchRange = rangeValue
        print("[Debug] Punch range updated to:", punchRange)
    end
end

function punch.toggleVisualizer(callback)
    punchVisualizerEnabled = callback
    print("[Debug] Visualizer toggled:", callback)
    local nearestEntity = findNearestEntity()
    if punchVisualizerEnabled and nearestEntity then
        createVisualizerPart(nearestEntity)
    else
        removeVisualizerPart(nearestEntity)
    end
end

function punch.toggleAngleCheck(callback)
    punchAngleCheckEnabled = callback
    print("[Debug] Angle check toggled:", callback)
end

function punch.toggleIncludeNPCs(callback)
    includeNPCs = callback
    print("[Debug] Include NPCs toggled:", callback)
end

function punch.toggleParticle(callback)
    punchParticleEnabled = callback
    print("[Debug] Particle effect toggled:", callback)
end

function punch.getRange()
    return punchRange
end

return punch
