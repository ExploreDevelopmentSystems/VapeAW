-- Tag Module
local tag = {}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character
local tagConnection
local priorityEnabled = false
local deleteOGEnabled = false
local showBGEnabled = true
local displayEnabled = false
local distanceEnabled = false
local abilityEnabled = false
local tags = {}

local function debugPrint(...)
    -- Debug printing enabled only for internal checks
    print(...)
end

local function createTagForPlayer(targetPlayer)
    if targetPlayer == player then return end  -- Exclude local player

    local targetCharacter = targetPlayer.Character
    local head = targetCharacter and targetCharacter:FindFirstChild("Head")

    if head then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "CustomNameTag"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 100, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = priorityEnabled
        billboard.Parent = head

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = showBGEnabled and 0.5 or 1
        label.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        label.Text = ""
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.SourceSans
        label.TextSize = 14
        label.Parent = billboard

        tags[targetPlayer] = {
            billboard = billboard,
            label = label,
            originalTextLabel = head:FindFirstChild("Name Tag") and head["Name Tag"]:FindFirstChild("TextLabel")
        }

        if deleteOGEnabled and tags[targetPlayer].originalTextLabel then
            tags[targetPlayer].originalTextLabel.TextTransparency = 1
        end
    end
end

local function updateTagForPlayer(targetPlayer)
    if targetPlayer == player then return end  -- Exclude local player

    local targetCharacter = targetPlayer.Character
    local head = targetCharacter and targetCharacter:FindFirstChild("Head")

    if head and tags[targetPlayer] then
        local label = tags[targetPlayer].label
        local name = displayEnabled and targetPlayer.DisplayName or targetPlayer.Name
        local ability = targetPlayer:FindFirstChild("leaderstats") and targetPlayer.leaderstats:FindFirstChild("Ability") and targetPlayer.leaderstats.Ability.Value or "N/A"
        local distance = distanceEnabled and (" | Distance: " .. math.floor((player:FindFirstChild("HumanoidRootPart").Position - head.Position).Magnitude)) or ""

        label.Text = name .. (abilityEnabled and ("\nAbility: " .. ability) or "") .. (distanceEnabled and ("\n" .. distance) or "")
    end
end

local function removeTagForPlayer(targetPlayer)
    if tags[targetPlayer] then
        local head = targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head")
        if head and tags[targetPlayer].originalTextLabel then
            tags[targetPlayer].originalTextLabel.TextTransparency = 0
        end
        tags[targetPlayer].billboard:Destroy()
        tags[targetPlayer] = nil
    end
end

local function onPlayerAdded(targetPlayer)
    targetPlayer.CharacterAdded:Connect(function()
        createTagForPlayer(targetPlayer)
        updateTagForPlayer(targetPlayer)
    end)
    if targetPlayer.Character then
        createTagForPlayer(targetPlayer)
        updateTagForPlayer(targetPlayer)
    end
end

local function onPlayerRemoving(targetPlayer)
    removeTagForPlayer(targetPlayer)
end

function tag.start()
    if tagConnection then return end
    tagConnection = RunService.Stepped:Connect(function()
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player then
                updateTagForPlayer(targetPlayer)
            end
        end
    end)
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        onPlayerAdded(targetPlayer)
    end
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
    debugPrint("[Debug] Tag module started.")
end

function tag.stop()
    if tagConnection then
        tagConnection:Disconnect()
        tagConnection = nil
    end
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        removeTagForPlayer(targetPlayer)
    end
    debugPrint("[Debug] Tag module stopped.")
end

function tag.togglePriority(callback)
    priorityEnabled = callback
    for _, data in pairs(tags) do
        data.billboard.AlwaysOnTop = priorityEnabled
    end
    debugPrint("[Debug] Priority toggled:", callback)
end

function tag.toggleDeleteOG(callback)
    deleteOGEnabled = callback
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer.Character then
            local head = targetPlayer.Character:FindFirstChild("Head")
            if head then
                local originalTextLabel = head:FindFirstChild("Name Tag") and head["Name Tag"]:FindFirstChild("TextLabel")
                if originalTextLabel then
                    originalTextLabel.TextTransparency = callback and 1 or 0
                end
            end
        end
    end
    debugPrint("[Debug] Delete OG toggled:", callback)
end

function tag.toggleShowBG(callback)
    showBGEnabled = callback
    for _, data in pairs(tags) do
        data.label.BackgroundTransparency = showBGEnabled and 0.5 or 1
    end
    debugPrint("[Debug] Show BG toggled:", callback)
end

function tag.toggleDisplay(callback)
    displayEnabled = callback
    debugPrint("[Debug] Display toggled:", callback)
end

function tag.toggleDistance(callback)
    distanceEnabled = callback
    debugPrint("[Debug] Distance toggled:", callback)
end

function tag.toggleAbility(callback)
    abilityEnabled = callback
    debugPrint("[Debug] Ability toggled:", callback)
end

return tag
