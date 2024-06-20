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
local includeNPCs = false
local tags = {}
local tagScale = 1
local tagHeight = 2
local updateInterval = 0.5 -- Default update interval
local lastUpdate = 0

local function debugPrint(...)
    -- Debug printing enabled only for internal checks
    print(...)
end

local function getPlayerDistance(targetPlayer)
    local localRootPart = character and character:FindFirstChild("HumanoidRootPart")
    local targetRootPart = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if localRootPart and targetRootPart then
        return (localRootPart.Position - targetRootPart.Position).Magnitude
    end
    return math.huge -- Return a large value if the distance can't be calculated
end

local function createTagForEntity(targetModel)
    if targetModel == player.Character then return end -- Exclude local player

    local head = targetModel:FindFirstChild("Head") or targetModel:FindFirstChild("HumanoidRootPart")

    if head then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "CustomNameTag"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 100 * tagScale, 0, 30 * tagScale)
        billboard.StudsOffset = Vector3.new(0, tagHeight, 0)
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
        label.TextScaled = true
        label.TextSize = 14
        label.Parent = billboard

        tags[targetModel] = {
            billboard = billboard,
            label = label,
            originalTextLabel = head:FindFirstChild("Name Tag") and head["Name Tag"]:FindFirstChild("TextLabel")
        }

        if deleteOGEnabled and tags[targetModel].originalTextLabel then
            tags[targetModel].originalTextLabel.TextTransparency = 1
        end
    end
end

local function updateTagForEntity(targetModel)
    if targetModel == player.Character then return end -- Exclude local player

    local head = targetModel:FindFirstChild("Head") or targetModel:FindFirstChild("HumanoidRootPart")

    if head and tags[targetModel] then
        local label = tags[targetModel].label
        local targetPlayer = Players:GetPlayerFromCharacter(targetModel)
        local name = targetPlayer and (displayEnabled and targetPlayer.DisplayName or targetPlayer.Name) or "NPC"
        local ability = targetPlayer and targetPlayer:FindFirstChild("leaderstats") and targetPlayer.leaderstats:FindFirstChild("Ability") and targetPlayer.leaderstats.Ability.Value or "N/A"
        local distance = distanceEnabled and ("Distance: " .. math.floor(getPlayerDistance(targetPlayer or targetModel))) or ""

        label.Text = name .. (abilityEnabled and ("\nAbility: " .. ability) or "") .. (distanceEnabled and ("\n" .. distance) or "")
    end
end

local function removeTagForEntity(targetModel)
    if tags[targetModel] then
        local head = targetModel:FindFirstChild("Head") or targetModel:FindFirstChild("HumanoidRootPart")
        if head and tags[targetModel].originalTextLabel then
            tags[targetModel].originalTextLabel.TextTransparency = 0
        end
        tags[targetModel].billboard:Destroy()
        tags[targetModel] = nil
    end
end

local function onCharacterAdded(targetPlayer)
    local targetModel = targetPlayer.Character or targetPlayer.CharacterAdded:Wait()
    createTagForEntity(targetModel)
    updateTagForEntity(targetModel)
end

local function onModelAdded(targetModel)
    if targetModel:IsA("Model") and targetModel:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(targetModel) then
        createTagForEntity(targetModel)
        updateTagForEntity(targetModel)
    end
end

local function onPlayerAdded(targetPlayer)
    targetPlayer.CharacterAdded:Connect(function()
        onCharacterAdded(targetPlayer)
    end)
    if targetPlayer.Character then
        onCharacterAdded(targetPlayer)
    end
end

local function onPlayerRemoving(targetPlayer)
    if targetPlayer.Character then
        removeTagForEntity(targetPlayer.Character)
    end
end

local function onDescendantAdded(descendant)
    if includeNPCs and descendant:IsA("Model") then
        onModelAdded(descendant)
    end
end

local function onDescendantRemoving(descendant)
    if includeNPCs and descendant:IsA("Model") then
        removeTagForEntity(descendant)
    end
end

function tag.start()
    if tagConnection then return end
    character = player.Character or player.CharacterAdded:Wait()
    player.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
    end)
    tagConnection = RunService.Stepped:Connect(function(time, deltaTime)
        if tick() - lastUpdate >= updateInterval then
            lastUpdate = tick()
            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if targetPlayer ~= player then
                    updateTagForEntity(targetPlayer.Character)
                end
            end
            if includeNPCs then
                for _, targetModel in ipairs(Workspace:GetDescendants()) do
                    if targetModel:IsA("Model") and targetModel:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(targetModel) then
                        updateTagForEntity(targetModel)
                    end
                end
            end
        end
    end)
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        onPlayerAdded(targetPlayer)
    end
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
    if includeNPCs then
        Workspace.DescendantAdded:Connect(onDescendantAdded)
        Workspace.DescendantRemoving:Connect(onDescendantRemoving)
    end
    debugPrint("[Debug] Tag module started.")
end

function tag.stop()
    if tagConnection then
        tagConnection:Disconnect()
        tagConnection = nil
    end
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer.Character then
            removeTagForEntity(targetPlayer.Character)
        end
    end
    if includeNPCs then
        for _, targetModel in pairs(Workspace:GetDescendants()) do
            if not Players:GetPlayerFromCharacter(targetModel) then
                removeTagForEntity(targetModel)
            end
        end
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
        if targetPlayer ~= player and targetPlayer.Character then -- Exclude local player
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

function tag.toggleIncludeNPCs(callback)
    includeNPCs = callback
    debugPrint("[Debug] Include NPCs toggled:", callback)
end

function tag.updateScale(value)
    tagScale = tonumber(value)
    for _, data in pairs(tags) do
        data.billboard.Size = UDim2.new(0, 100 * tagScale, 0, 30 * tagScale)
    end
    debugPrint("[Debug] Tag scale updated to:", tagScale)
end

function tag.updateHeight(value)
    tagHeight = tonumber(value)
    for _, data in pairs(tags) do
        data.billboard.StudsOffset = Vector3.new(0, tagHeight, 0)
    end
    debugPrint("[Debug] Tag height updated to:", tagHeight)
end

function tag.updateInterval(value)
    updateInterval = tonumber(value)
    debugPrint("[Debug] Update interval set to:", updateInterval)
end

return tag
