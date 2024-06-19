-- Twitch Module
local twitch = {}

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local active = false
local twitchConnection

local twitchDistance = 0.05
local twitchInterval = 0.1

local function startTwitching()
    if twitchConnection then return end
    twitchConnection = game:GetService("RunService").Stepped:Connect(function()
        if active then
            local originalPosition = humanoidRootPart.Position
            humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(twitchDistance, 0, 0)
            task.wait(twitchInterval)
            humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(-twitchDistance, 0, 0)
        end
    end)
end

local function stopTwitching()
    if twitchConnection then
        twitchConnection:Disconnect()
        twitchConnection = nil
    end
end

function twitch.start()
    active = true
    startTwitching()
end

function twitch.stop()
    active = false
    stopTwitching()
end

function twitch.isActive()
    return active
end

return twitch
