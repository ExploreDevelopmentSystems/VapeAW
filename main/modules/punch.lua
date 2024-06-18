-- Punch Module
local punch = {}

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local punchRange = 20 -- The effective range for punching
local maxDetectionRange = 25 -- The range to detect entities
local punchVisualizerEnabled = false
local punchAngleCheckEnabled = false
local includeNPCs = true
local punchParticleEnabled = false
local wallCheckEnabled = false
local mouseConnection
local debugEnabled = true -- Set this to false to disable debug messages

local function debugPrint(...)
    if debugEnabled then
        print(...)
    end
end

local function isInFrontAndVisible(localPosition, localLookVector, targetPosition, targetModel)
    local directionToTarget = (targetPosition - localPosition).Unit
    local dotProduct = localLookVector:Dot(directionToTarget)
    local isInFront = dotProduct > 0.3

    if wallCheckEnabled then
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.FilterDescendantsInstances = {character}

        local ray = Workspace:Raycast(localPosition, directionToTarget * punchRange, rayParams)
        if ray and ray.Instance and not ray.Instance:IsDescendantOf(targetModel) then
            debugPrint("[Debug] Raycast hit:", ray.Instance.Name, "Not clear path.")
            return false
        end
    end

    return isInFront
end

local function findNearestEntity()
    local closestEntity
    local shortestDistance = math.huge
    local localRootPart = character:FindFirstChild("HumanoidRootPart")

    if not localRootPart then
        debugPrint("[Debug] Local player does not have HumanoidRootPart.")
        return nil
    end

    local function isValidCandidate(model)
        local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            debugPrint("[Debug] Model does not have HumanoidRootPart:", model.Name)
            return false
        end
        if not includeNPCs and not game.Players:GetPlayerFromCharacter(model) then
            debugPrint("[Debug] Model is not a player:", model.Name)
            return false
        end
        return true
    end

    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model ~= player.Character and isValidCandidate(model) then
            local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local distance = (humanoidRootPart.Position - localRootPart.Position).Magnitude
                if distance <= maxDetectionRange and (not punchAngleCheckEnabled or isInFrontAndVisible(localRootPart.Position, localRootPart.CFrame.LookVector, humanoidRootPart.Position, model)) then
                    closestEntity = model
                    shortestDistance = distance
                    debugPrint("[Debug] Nearest entity found:", model.Name, "Distance:", distance)
                end
            end
        end
    end

    if not closestEntity then
        debugPrint("[Debug] No entity found within range.")
    end

    return closestEntity
end

local function computeImpactPosition(targetModel)
    local humanoidRootPart = targetModel:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        debugPrint("[Debug] computeImpactPosition: No HumanoidRootPart for target model:", targetModel.Name)
        return Vector3.new(0, 0, 0)
    end

    local rightHand = character:FindFirstChild("RightHand")
    if not rightHand then return humanoidRootPart.Position end

    local directionToTarget = (humanoidRootPart.Position - rightHand.Position).Unit
    local distance = (humanoidRootPart.Position - rightHand.Position).Magnitude
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {character}

    local ray = Workspace:Raycast(rightHand.Position, directionToTarget * distance, rayParams)

    local impactPosition
    if ray then
        impactPosition = ray.Position + directionToTarget * 1
    else
        impactPosition = humanoidRootPart.Position
    end

    return impactPosition
end

local function punchNearestEntity()
    local nearestEntity = findNearestEntity()
    if nearestEntity then
        local humanoidRootPart = nearestEntity:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local impactPosition = punchParticleEnabled and computeImpactPosition(nearestEntity) or Vector3.new(1e4, 1e4, 1e4)
            local punchEvent = ReplicatedStorage:FindFirstChild("Remote Events") and ReplicatedStorage["Remote Events"]:FindFirstChild("Punch")

            if punchEvent then
                debugPrint("[Debug] Firing punch event. Target:", nearestEntity:GetFullName(), "Position:", impactPosition)
                punchEvent:FireServer(nearestEntity, impactPosition)
                debugPrint("[Debug] Punch event fired.")
            else
                warn("[Debug] Punch event not found.")
            end
        else
            debugPrint("[Debug] No HumanoidRootPart for the nearest entity:", nearestEntity.Name)
        end
    else
        debugPrint("[Debug] No nearest entity to punch.")
    end
end

local function createVisualizerPart(model)
    if not model then
        debugPrint("[Debug] No model provided for visualizer.")
        return
    end

    local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        debugPrint("[Debug] No HumanoidRootPart found for model in visualizer:", model.Name)
        return
    end

    local part = Instance.new("Part")
    part.Size = Vector3.new(4, 6, 4)
    part.Transparency = 0.5
    part.Anchored = false
    part.CanCollide = false
    part.Color = Color3.new(1, 0, 0)
    part.Material = Enum.Material.SmoothPlastic
    part.Parent = model
    part.CFrame = humanoidRootPart.CFrame

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = part
    weld.Part1 = humanoidRootPart
    weld.Parent = part

    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Adornee = part
    selectionBox.Parent = model

    debugPrint("[Debug] Visualizer created for model:", model.Name)
    return part
end

local function removeVisualizerPart(model)
    if model then
        local visualPart = model:FindFirstChild("Serv")
        if visualPart then
            visualPart:Destroy()
            debugPrint("[Debug] Visualizer part removed from model:", model.Name)
        end
        local selectionBox = model:FindFirstChildWhichIsA("SelectionBox", true)
        if selectionBox then
            selectionBox:Destroy()
            debugPrint("[Debug] SelectionBox removed from model:", model.Name)
        end
    end
end

function punch.start()
    if mouseConnection then return end
    mouseConnection = player:GetMouse().Button1Down:Connect(function()
        debugPrint("[Debug] Mouse button clicked.")
        punchNearestEntity()
    end)
    debugPrint("[Debug] Punch module started.")
end

function punch.stop()
    if mouseConnection then
        mouseConnection:Disconnect()
        mouseConnection = nil
        debugPrint("[Debug] Mouse connection stopped.")
    end
end

function punch.updateRange(value)
    local rangeValue = tonumber(value)
    if rangeValue then
        punchRange = rangeValue
        debugPrint("[Debug] Punch range updated to:", punchRange)
    end
end

function punch.toggleVisualizer(callback)
    punchVisualizerEnabled = callback
    debugPrint("[Debug] Visualizer toggled:", callback)
    local nearestEntity = findNearestEntity()
    if punchVisualizerEnabled and nearestEntity then
        createVisualizerPart(nearestEntity)
    else
        removeVisualizerPart(nearestEntity)
    end
end

function punch.toggleAngleCheck(callback)
    punchAngleCheckEnabled = callback
    debugPrint("[Debug] Angle check toggled:", callback)
end

function punch.toggleIncludeNPCs(callback)
    includeNPCs = callback
    debugPrint("[Debug] Include NPCs toggled:", callback)
end

function punch.toggleParticle(callback)
    punchParticleEnabled = callback
    debugPrint("[Debug] Particle effect toggled:", callback)
end

function punch.toggleWallCheck(callback)
    wallCheckEnabled = callback
    debugPrint("[Debug] Wall check toggled:", callback)
end

function punch.getRange()
    return punchRange
end

return punch
