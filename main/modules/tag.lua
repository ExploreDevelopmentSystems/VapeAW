-- Tag Module
local tag = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local tagDistance = 50
local priorityEnabled = false
local deleteOGEnabled = false
local displayEnabled = false
local abilityEnabled = false
local tagConnection

local function debugPrint(...)
    print(...)
end

local function createNametag(targetPlayer)
    local character = targetPlayer.Character
    if not character then return end

    local head = character:FindFirstChild("Head")
    if not head then return end

    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "CustomNametag"
    billboardGui.Size = UDim2.new(1, 0, 1, 0)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.AlwaysOnTop = priorityEnabled

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextStrokeTransparency = 0
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.Text = displayEnabled and targetPlayer.DisplayName or targetPlayer.Name
    textLabel.TextScaled = true
    textLabel.Parent = billboardGui

    if abilityEnabled then
        local ability = targetPlayer:FindFirstChild("leaderstats") and targetPlayer.leaderstats:FindFirstChild("Ability")
        if ability then
            textLabel.Text = textLabel.Text .. "\nAbility: " .. ability.Value
        end
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
                    createNametag(targetPlayer)
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
    tagConnection = RunService.Stepped:Connect(updateNametags)
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

return tag
