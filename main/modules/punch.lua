-- Punch Module
local punch = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local Random = Random.new()
local player = Players.LocalPlayer
local character
local punchRange = 20
local maxDetectionRange = 25
local punchVisualizerEnabled = false
local punchAngleCheckEnabled = false
local includeNPCs = true
local punchParticleEnabled = false
local wallCheckEnabled = false
local mouseConnection
local visualizerPart
local active = false

local function debugPrint(...)
    -- Debug printing enabled only for internal checks
    print(...)
end

local function getTargetLimbs(targetModel)
    local limbs = {}
    for _, partName in ipairs({"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}) do
        local limb = targetModel:FindFirstChild(partName)
        if limb then
            table.insert(limbs, limb)
        end
    end
    return limbs
end

local function getRandomLimb(targetModel)
    local limbs = getTargetLimbs(targetModel)
    if #limbs > 0 then
        return limbs[Random:NextInteger(1, #limbs)]
    end
    return nil
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
    local localRootPart = character and character:FindFirstChild("HumanoidRootPart")

    if not localRootPart then
        debugPrint("[Debug] Local player does not have HumanoidRootPart.")
        return nil
    end

    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model ~= character then
            local humanoidRootPart = model:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                if includeNPCs or Players:GetPlayerFromCharacter(model) then
                    local distance = (humanoidRootPart.Position - localRootPart.Position).Magnitude
                    if distance <= maxDetectionRange and (not punchAngleCheckEnabled or isInFrontAndVisible(localRootPart.Position, localRootPart.CFrame.LookVector, humanoidRootPart.Position, model)) then
                        if distance < shortestDistance then
                            closestEntity = model
                            shortestDistance = distance
                            debugPrint("[Debug] Nearest entity found:", model.Name, "Distance:", distance)
                        end
                    end
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

    local rightHand = character and character:FindFirstChild("RightHand")
    if not rightHand then return humanoidRootPart.Position end

    -- Raycast from the local player's right hand to the target's torso (or other random limb)
    local targetLimb = getRandomLimb(targetModel) or humanoidRootPart
    local directionToTarget = (targetLimb.Position - rightHand.Position).Unit
    local distance = (targetLimb.Position - rightHand.Position).Magnitude
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {character}

    local ray = Workspace:Raycast(rightHand.Position, directionToTarget * distance, rayParams)
    local impactPosition

    if ray then
        impactPosition = ray.Position
    else
        impactPosition = targetLimb.Position
    end

    return impactPosition
end

local function createVisualizerPart(targetModel)
    local humanoidRootPart = targetModel:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        debugPrint("[Debug] createVisualizerPart: No HumanoidRootPart for target model:", targetModel.Name)
        return
    end

    if visualizerPart then
        visualizerPart:Destroy()
    end

    visualizerPart = Instance.new("Part")
    visualizerPart.Name = "Visualizer"
    visualizerPart.Size = Vector3.new(4, 6, 4)
    visualizerPart.Transparency = 0.5
    visualizerPart.Anchored = true
    visualizerPart.CanCollide = false
    visualizerPart.Color = Color3.new(1, 0, 0)
    visualizerPart.Material = Enum.Material.ForceField
    visualizerPart.CFrame = humanoidRootPart.CFrame
    visualizerPart.Parent = Workspace

    debugPrint("[Debug] Visualizer created for model:", targetModel.Name)

    Debris:AddItem(visualizerPart, 1)
end

local function removeVisualizerPart()
    if visualizerPart then
        visualizerPart:Destroy()
        visualizerPart = nil
        debugPrint("[Debug] Visualizer part removed.")
    end
end

local function punchNearestEntity()
    if not active then return end

    local nearestEntity = findNearestEntity()
    if nearestEntity then
        local humanoidRootPart = nearestEntity:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            if wallCheckEnabled then
                local localRootPart = character and character:FindFirstChild("HumanoidRootPart")
                if localRootPart then
                    local directionToTarget = (humanoidRootPart.Position - localRootPart.Position).Unit
                    local rayParams = RaycastParams.new()
                    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                    rayParams.FilterDescendantsInstances = {character}

                    local ray = Workspace:Raycast(localRootPart.Position, directionToTarget * punchRange, rayParams)
                    if ray and ray.Instance and not ray.Instance:IsDescendantOf(nearestEntity) then
                        debugPrint("[Debug] Wall check failed: Ray hit", ray.Instance.Name)
                        return
                    end
                end
            end

            local punchEvent = ReplicatedStorage:FindFirstChild("Remote Events") and ReplicatedStorage["Remote Events"]:FindFirstChild("Punch")
            if punchEvent then
                if punchParticleEnabled then
                    local impactPosition = computeImpactPosition(nearestEntity)
                    debugPrint("[Debug] Firing punch event. Target:", nearestEntity:GetFullName(), "Position:", impactPosition)
                    punchEvent:FireServer(nearestEntity, impactPosition)
                else
                    debugPrint("[Debug] Firing punch event without position. Target:", nearestEntity:GetFullName())
                    punchEvent:FireServer(nearestEntity)
                end
                debugPrint("[Debug] Punch event fired.")
                if punchVisualizerEnabled then
                    createVisualizerPart(nearestEntity)
                end
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

local function onCharacterAdded(newCharacter)
    character = newCharacter
end

function punch.start()
    if mouseConnection then return end
    player.CharacterAdded:Connect(onCharacterAdded)
    character = player.Character or player.CharacterAdded:Wait()
    mouseConnection = player:GetMouse().Button1Down:Connect(function()
        debugPrint("[Debug] Mouse button clicked.")
        punchNearestEntity()
    end)
    active = true
    debugPrint("[Debug] Punch module started.")
end

function punch.stop()
    if mouseConnection then
        mouseConnection:Disconnect()
        mouseConnection = nil
        debugPrint("[Debug] Mouse connection stopped.")
    end
    removeVisualizerPart()
    active = false
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
