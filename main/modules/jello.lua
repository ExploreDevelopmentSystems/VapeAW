-- Jello Module
local jello = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character
local heartbeatConnection

local detectionRadius = 35
local abilityName = "Jello"
local checkCastle = false
local checkMushroom = false

local modelsToCheck = {
    {Name = "Jello Castle", PartName = "Hitbox", Enabled = function() return checkCastle end},
    {Name = "Jello Mushroom", PartName = "Main", Enabled = function() return checkMushroom end}
}

local function debugPrint(...)
    -- Debug printing enabled only for internal checks
    print(...)
end

local function destroyTouchInterest(part)
    if part then
        local touchInterest = part:FindFirstChildOfClass("TouchTransmitter")
        if touchInterest then
            touchInterest:Destroy()
            debugPrint("[Debug] Destroyed TouchInterest in part:", part:GetFullName())
        end
    end
end

local function checkAndDestroy(model)
    for _, check in ipairs(modelsToCheck) do
        if check.Enabled() and model.Name == check.Name then
            local part = model:FindFirstChild(check.PartName)
            if part then
                destroyTouchInterest(part)
            end
        end
    end
end

local function onHeartbeat()
    local localRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not localRootPart then return end

    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            local targetRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRootPart then
                local distance = (localRootPart.Position - targetRootPart.Position).Magnitude
                if distance <= detectionRadius then
                    local ability = targetPlayer:FindFirstChild("leaderstats") and targetPlayer.leaderstats:FindFirstChild("Ability")
                    if ability and ability.Value == abilityName then
                        for _, model in ipairs(Workspace:GetDescendants()) do
                            if model:IsA("Model") then
                                checkAndDestroy(model)
                            end
                        end
                    end
                end
            end
        end
    end
end

function jello.start()
    if heartbeatConnection then return end
    character = player.Character or player.CharacterAdded:Wait()
    player.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
    end)
    heartbeatConnection = RunService.Heartbeat:Connect(onHeartbeat)
    debugPrint("[Debug] Jello module started.")
end

function jello.stop()
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
        debugPrint("[Debug] Jello module stopped.")
    end
end

function jello.toggleCastle(callback)
    checkCastle = callback
    debugPrint("[Debug] Castle check toggled:", callback)
end

function jello.toggleMushroom(callback)
    checkMushroom = callback
    debugPrint("[Debug] Mushroom check toggled:", callback)
end

return jello
