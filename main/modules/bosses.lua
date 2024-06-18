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
local active = false
local connection
local debugEnabled = true

local function debugPrint(...)
    if debugEnabled then
        print(...)
    end
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

return bosses
