-- Bosses Module
local bosses = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local punchDelay = 0.5
local falseifyEnabled = false
local active = false
local connection
local character
local detectionRange = 20

local function debugPrint(...)
    -- Debug printing enabled only for internal checks
    print(...)
end

local function countNearbyPlayers(position, range)
    local count = 0
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (otherPlayer.Character.HumanoidRootPart.Position - position).Magnitude
            if distance <= range then
                count = count + 1
            end
        end
    end
    return count
end

local function punchBosses()
    if not active or not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local localRootPart = character.HumanoidRootPart

    local bossesFolder = ReplicatedStorage:FindFirstChild("Bosses")
    local punchEvent = ReplicatedStorage:FindFirstChild("Remote Events") and ReplicatedStorage["Remote Events"]:FindFirstChild("Punch")

    if bossesFolder and punchEvent then
        for _, boss in ipairs(bossesFolder:GetChildren()) do
            if boss:IsA("Model") then
                local bossInWorkspace = Workspace:FindFirstChild(boss.Name)
                if bossInWorkspace then
                    local humanoidRootPart = bossInWorkspace:FindFirstChild("HumanoidRootPart")
                    if humanoidRootPart then
                        if falseifyEnabled then
                            local nearbyPlayers = countNearbyPlayers(humanoidRootPart.Position, detectionRange)
                            if nearbyPlayers < 2 then
                                debugPrint("[Debug] Not enough players around the boss:", bossInWorkspace.Name)
                                return
                            end
                        end

                        local impactPosition = humanoidRootPart.Position
                        debugPrint("[Debug] Punching boss:", bossInWorkspace.Name)
                        punchEvent:FireServer(bossInWorkspace, impactPosition)
                    else
                        debugPrint("[Debug] No HumanoidRootPart for boss:", bossInWorkspace.Name)
                    end
                end
            end
        end
    else
        debugPrint("[Debug] Bosses folder or punch event not found.")
    end
end

local function onCharacterAdded(newCharacter)
    character = newCharacter
end

function bosses.start()
    if connection then return end
    active = true
    player.CharacterAdded:Connect(onCharacterAdded)
    character = player.Character or player.CharacterAdded:Wait()
    connection = game:GetService("RunService").Stepped:Connect(function()
        punchBosses()
        task.wait(punchDelay)
    end)
    debugPrint("[Debug] Bosses module started.")
end

function bosses.stop()
    if connection then
        connection:Disconnect()
        connection = nil
        debugPrint("[Debug] Bosses connection stopped.")
    end
    active = false
end

function bosses.updateDelay(value)
    punchDelay = tonumber(value) or 0.5
    debugPrint("[Debug] Punch delay updated to:", punchDelay)
end

function bosses.toggleFalseify(callback)
    falseifyEnabled = callback
    debugPrint("[Debug] Falseify toggled:", callback)
end

return bosses
