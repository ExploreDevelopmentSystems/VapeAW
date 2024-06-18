-- Reach Module
local reach = {}

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local headSize = 20
local visualizerEnabled = false
local angleCheckEnabled = false
local lastVisualizedPlayer
local reachConnection

local function revertReachChanges(player)
    local rootPart = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.Size = Vector3.new(2, 2, 1)
        rootPart.Transparency = 1
        rootPart.BrickColor = BrickColor.new("Medium stone grey")
        rootPart.Material = Enum.Material.Plastic
        rootPart.CanCollide = true
    end
end

local function getClosestPlayer()
    local closestPlayer
    local shortestDistance = math.huge
    local localRootPart = character:FindFirstChild("HumanoidRootPart")

    if not localRootPart then return nil end

    for _, v in ipairs(game.Players:GetPlayers()) do
        local targetRootPart = v.Character and v.Character:FindFirstChild("HumanoidRootPart")
        if v ~= player and targetRootPart then
            local distance = (localRootPart.Position - targetRootPart.Position).Magnitude
            if distance < shortestDistance then
                if angleCheckEnabled then
                    local direction = (targetRootPart.Position - localRootPart.Position).Unit
                    local forward = localRootPart.CFrame.LookVector
                    if forward:Dot(direction) > 0 then
                        closestPlayer = v
                        shortestDistance = distance
                    end
                else
                    closestPlayer = v
                    shortestDistance = distance
                end
            end
        end
    end

    return closestPlayer
end

function reach.start()
    if reachConnection then return end
    reachConnection = game:GetService("RunService").Stepped:Connect(function()
        local closestPlayer = getClosestPlayer()

        if lastVisualizedPlayer and lastVisualizedPlayer ~= closestPlayer then
            revertReachChanges(lastVisualizedPlayer)
        end

        local localRootPart = character:FindFirstChild("HumanoidRootPart")
        local targetRootPart = closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart")

        if localRootPart and targetRootPart then
            targetRootPart.Size = Vector3.new(headSize, headSize, headSize)
            targetRootPart.Transparency = visualizerEnabled and 0.5 or 1
            targetRootPart.BrickColor = BrickColor.new("Medium stone grey")
            targetRootPart.Material = Enum.Material.ForceField
            targetRootPart.CanCollide = false

            lastVisualizedPlayer = closestPlayer
        end
    end)
end

function reach.stop()
    if reachConnection then
        reachConnection:Disconnect()
        reachConnection = nil
        if lastVisualizedPlayer then
            revertReachChanges(lastVisualizedPlayer)
            lastVisualizedPlayer = nil
        end
    end
end

function reach.update(value)
    local reachValue = tonumber(value)
    if reachValue then
        headSize = reachValue
    end
end

function reach.toggleVisualizer(callback)
    visualizerEnabled = callback
    if not callback and lastVisualizedPlayer then
        revertReachChanges(lastVisualizedPlayer)
        lastVisualizedPlayer = nil
    end
end

function reach.toggleAngleCheck(callback)
    angleCheckEnabled = callback
end

function reach.getHeadSize()
    return headSize
end

return reach
