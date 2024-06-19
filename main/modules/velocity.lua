-- Tag Module
local tag = {}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local active = false
local nametagFolder = Instance.new("Folder", Workspace)
nametagFolder.Name = "Nametags"
local updateInterval = 0.5
local scale = 1
local height = 2
local includeNPCs = false
local priorityRendering = false
local deleteOG = false
local showBG = true
local display = false
local showDistance = false
local showAbility = false
local activeTags = {}

-- Helper Functions
local function createBillboard(playerOrNPC, name, character)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Nametag"
    billboard.Adornee = character.Head
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, height, 0)
    billboard.AlwaysOnTop = priorityRendering

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "TagLabel"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = showBG and 0.5 or 1
    textLabel.TextStrokeTransparency = 0
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextScaled = true
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.Parent = billboard

    if playerOrNPC:IsA("Player") then
        local leaderstats = playerOrNPC:FindFirstChild("leaderstats")
        local ability = leaderstats and leaderstats:FindFirstChild("Ability")
        local tagText = display and playerOrNPC.DisplayName or playerOrNPC.Name
        if showAbility and ability then
            tagText = tagText .. "\nAbility: " .. ability.Value
        end
        textLabel.Text = tagText
    else
        textLabel.Text = "NPC"
    end

    billboard.Parent = nametagFolder
    return billboard
end

local function updateNametags()
    for _, target in pairs(activeTags) do
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local billboard = target.Tag
            local humanoidRootPart = target.Character.HumanoidRootPart

            billboard.Adornee = humanoidRootPart
            billboard.StudsOffset = Vector3.new(0, height, 0)

            local textLabel = billboard:FindFirstChild("TagLabel")
            if textLabel then
                local tagText = display and target.Player.DisplayName or target.Player.Name
                if showAbility then
                    local ability = target.Player:FindFirstChild("leaderstats") and target.Player.leaderstats:FindFirstChild("Ability")
                    if ability then
                        tagText = tagText .. "\nAbility: " .. ability.Value
                    end
                end
                if showDistance then
                    local distance = (humanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    tagText = tagText .. "\nDistance: " .. math.floor(distance) .. " studs"
                end
                textLabel.Text = tagText
            end
        end
    end
end

local function addNametag(playerOrNPC, character)
    local existingTag = activeTags[playerOrNPC.Name]
    if existingTag then
        existingTag.Tag:Destroy()
        activeTags[playerOrNPC.Name] = nil
    end

    local nametag = createBillboard(playerOrNPC, playerOrNPC.Name, character)
    activeTags[playerOrNPC.Name] = {
        Player = playerOrNPC,
        Tag = nametag,
        Character = character
    }
end

local function removeNametag(playerOrNPC)
    if activeTags[playerOrNPC.Name] then
        activeTags[playerOrNPC.Name].Tag:Destroy()
        activeTags[playerOrNPC.Name] = nil
    end
end

local function trackPlayer(player)
    local function onCharacterAdded(character)
        if deleteOG then
            local head = character:FindFirstChild("Head")
            if head then
                local nameTag = head:FindFirstChild("Name Tag")
                if nameTag and nameTag:IsA("BillboardGui") then
                    nameTag.TextLabel.TextTransparency = 1
                end
            end
        end
        addNametag(player, character)
    end

    player.CharacterAdded:Connect(onCharacterAdded)

    if player.Character then
        onCharacterAdded(player.Character)
    end
end

local function trackNPC(npc)
    if npc:FindFirstChild("HumanoidRootPart") then
        addNametag(npc, npc)
    end
end

local function startTracking()
    -- Track players
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player then
            trackPlayer(targetPlayer)
        end
    end

    Players.PlayerAdded:Connect(trackPlayer)
    Players.PlayerRemoving:Connect(removeNametag)

    -- Track NPCs
    for _, descendant in pairs(Workspace:GetDescendants()) do
        if descendant:IsA("Model") and descendant:FindFirstChild("HumanoidRootPart") and descendant ~= player.Character then
            if includeNPCs or Players:GetPlayerFromCharacter(descendant) then
                trackNPC(descendant)
            end
        end
    end

    Workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Model") and descendant:FindFirstChild("HumanoidRootPart") then
            if includeNPCs or Players:GetPlayerFromCharacter(descendant) then
                trackNPC(descendant)
            end
        end
    end)
end

local function clearAllNametags()
    for _, tagData in pairs(activeTags) do
        if tagData.Tag then
            tagData.Tag:Destroy()
        end
    end
    activeTags = {}
end

function tag.start()
    if active then return end
    active = true
    clearAllNametags()
    startTracking()
    RunService.Heartbeat:Connect(function()
        updateNametags()
    end)
    print("[Debug] Tag module started.")
end

function tag.stop()
    active = false
    clearAllNametags()
    print("[Debug] Tag module stopped.")
end

function tag.togglePriority(callback)
    priorityRendering = callback
    for _, tagData in pairs(activeTags) do
        if tagData.Tag then
            tagData.Tag.AlwaysOnTop = priorityRendering
        end
    end
    print("[Debug] Priority rendering toggled:", callback)
end

function tag.toggleDeleteOG(callback)
    deleteOG = callback
    if deleteOG then
        for _, target in pairs(Players:GetPlayers()) do
            if target ~= player and target.Character then
                local head = target.Character:FindFirstChild("Head")
                if head then
                    local nameTag = head:FindFirstChild("Name Tag")
                    if nameTag and nameTag:IsA("BillboardGui") then
                        nameTag.TextLabel.TextTransparency = 1
                    end
                end
            end
        end
    else
        for _, target in pairs(Players:GetPlayers()) do
            if target ~= player and target.Character then
                local head = target.Character:FindFirstChild("Head")
                if head then
                    local nameTag = head:FindFirstChild("Name Tag")
                    if nameTag and nameTag:IsA("BillboardGui") then
                        nameTag.TextLabel.TextTransparency = 0
                    end
                end
            end
        end
    end
    print("[Debug] Delete original nametag toggled:", callback)
end

function tag.toggleShowBG(callback)
    showBG = callback
    for _, tagData in pairs(activeTags) do
        if tagData.Tag then
            tagData.Tag.TagLabel.BackgroundTransparency = showBG and 0.5 or 1
        end
    end
    print("[Debug] Show background toggled:", callback)
end

function tag.toggleDisplay(callback)
    display = callback
    print("[Debug] Display toggled:", callback)
end

function tag.toggleDistance(callback)
    showDistance = callback
    print("[Debug] Show distance toggled:", callback)
end

function tag.toggleAbility(callback)
    showAbility = callback
    print("[Debug] Show ability toggled:", callback)
end

function tag.toggleIncludeNPCs(callback)
    includeNPCs = callback
    clearAllNametags()
    startTracking()
    print("[Debug] Include NPCs toggled:", callback)
end

function tag.updateScale(value)
    scale = tonumber(value)
    for _, tagData in pairs(activeTags) do
        if tagData.Tag then
            tagData.Tag.Size = UDim2.new(0, 200 * scale, 0, 50 * scale)
        end
    end
    print("[Debug] Tag scale updated to:", scale)
end

function tag.updateHeight(value)
    height = tonumber(value)
    for _, tagData in pairs(activeTags) do
        if tagData.Tag then
            tagData.Tag.StudsOffset = Vector3.new(0, height, 0)
        end
    end
    print("[Debug] Tag height updated to:", height)
end

function tag.updateInterval(value)
    updateInterval = tonumber(value)
    print("[Debug] Update interval set to:", updateInterval)
end

return tag
