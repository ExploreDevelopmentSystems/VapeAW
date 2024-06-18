-- Bosses Module
local bosses = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local bossesFolder = ReplicatedStorage:WaitForChild("Bosses")
local punchEvent = ReplicatedStorage:FindFirstChild("Remote Events") and ReplicatedStorage["Remote Events"]:FindFirstChild("Punch")
local punchDelay = 0.5
local falseifyEnabled = false
local active = false
local connection
local debugEnabled = true
local detectionRange = 20

local function debugPrint(...)
    if debugEnabled then
        print(...)
    end
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
    if not active then return end

    local localRootPart = character:FindFirstChild("HumanoidRootPart")
    if not localRootPart then
        debugPrint("[Debug] Local player does not have HumanoidRootPart.")
        return
    end

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
                            return -- Skip punching if not enough players around
                        end
                    end

                    local impactPosition = humanoidRootPart.Position
                    if punchEvent then
                        debugPrint("[Debug] Punching boss:", bossInWorkspace.Name)
                        punchEvent:FireServer(bossInWorkspace, impactPosition)
                    else
                        warn("[Debug] Punch event not found.")
                    end
                else
                    debugPrint("[Debug] No HumanoidRootPart for boss:", bossInWorkspace.Name)
                end
            end
        end
    end
end

function bosses.start()
    if connection then return end
    active = true
    connection = game:GetService("RunService").Stepped:Connect(function()
        punchBosses()
        task.wait(punchDelay) -- Wait for the configured punch delay
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
