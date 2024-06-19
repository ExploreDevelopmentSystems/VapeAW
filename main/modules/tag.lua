-- Tag Module
local tag = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local player = Players.LocalPlayer
local tagDistance = 50
local priorityEnabled = false
local deleteOGEnabled = false
local displayEnabled = false
local abilityEnabled = false
local backgroundColor = Color3.new(0, 0, 0)
local tagConnection

local function debugPrint(...)
    print(...)
end

local function createNametagFrame(targetPlayer)
    local character = targetPlayer.Character
    if not character then return end

    local head = character:FindFirstChild("Head")
    if not head then return end

    -- Remove old custom nametag if it exists
    local existingTag = head:FindFirstChild("CustomNametag")
    if existingTag then
        existingTag:Destroy()
    end

    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "CustomNametag"
    billboardGui.Size = UDim2.new(4, 0, 1, 0)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.AlwaysOnTop = priorityEnabled

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 0.5
    frame.BackgroundColor3 = backgroundColor
    frame.Parent = billboardGui

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.Text = displayEnabled and targetPlayer.DisplayName or targetPlayer.Name
    nameLabel.TextScaled = true
    nameLabel.Parent = frame

    if abilityEnabled then
        local ability = targetPlayer:FindFirstChild("leaderstats") and targetPlayer.leaderstats:FindFirstChild("Ability")
        local abilityLabel = Instance.new("TextLabel")
        abilityLabel.Size = UDim2.new(1, 0, 0.5, 0)
        abilityLabel.Position = UDim2.new(0, 0, 0.5, 0)
        abilityLabel.BackgroundTransparency = 1
        abilityLabel.TextStrokeTransparency = 0
        abilityLabel.TextColor3 = Color3.new(1, 1, 1)
        abilityLabel.Text = "Ability: " .. (ability and ability.Value or "N/A")
        abilityLabel.TextScaled = true
        abilityLabel.Parent = frame
    end

    if deleteOGEnabled then
        local originalNametag = character:FindFirstChild("Name Tag", true)
        if originalNametag then
            originalNametag:Destroy()
        end
    end

    billboardGui.Parent = head
end

local function updateNametags()
    local localCharacter = player.Character
    local localRootPart = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")

    if not localRootPart then return end

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            local targetRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRootPart then
                local distance = (localRootPart.Position - targetRootPart.Position).Magnitude
                if distance <= tagDistance then
                    createNametagFrame(targetPlayer)
                else
                    local head = targetPlayer.Character:FindFirstChild("Head")
                    if head then
                        local existingTag = head:FindFirstChild("CustomNametag")
                        if existingTag then
                            existingTag:Destroy()
                        end
                    end
                end
            end
        end
    end
end

function tag.start()
    if tagConnection then return end
    tagConnection = RunService.Heartbeat:Connect(function()
        updateNametags()
        wait(1)  -- Update every second
    end)
    debugPrint("[Debug] Tag module started.")
end

function tag.stop()
    if tagConnection then
        tagConnection:Disconnect()
        tagConnection = nil
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            local head = targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head")
            if head then
                local existingTag = head:FindFirstChild("CustomNametag")
                if existingTag then
                    existingTag:Destroy()
                end
            end
        end
        debugPrint("[Debug] Tag module stopped.")
    end
end

function tag.updateDistance(value)
    tagDistance = tonumber(value) or 50
    debugPrint("[Debug] Tag distance updated to:", tagDistance)
end

function tag.togglePriority(callback)
    priorityEnabled = callback
    debugPrint("[Debug] Priority rendering toggled:", callback)
end

function tag.toggleDeleteOG(callback)
    deleteOGEnabled = callback
    debugPrint("[Debug] Delete original nametag toggled:", callback)
end

function tag.toggleDisplay(callback)
    displayEnabled = callback
    debugPrint("[Debug] Display name toggled:", callback)
end

function tag.toggleAbility(callback)
    abilityEnabled = callback
    debugPrint("[Debug] Ability display toggled:", callback)
end

function tag.updateBackground(color)
    backgroundColor = color
    debugPrint("[Debug] Background color updated:", backgroundColor)
end

return tag
