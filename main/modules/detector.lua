-- Detector Module
local detector = {}

local player = game.Players.LocalPlayer
local others = game.Players:GetPlayers()
local active = false
local detectConnection

local twitchDistance = 0.05 -- Should match the twitch module
local detectThreshold = 0.01 -- Threshold to account for minor discrepancies

local function isTwitching(targetPosition, originalPosition)
    return (targetPosition - originalPosition).Magnitude <= (twitchDistance + detectThreshold)
end

local function startDetecting()
    if detectConnection then return end
    detectConnection = game:GetService("RunService").Stepped:Connect(function()
        for _, otherPlayer in pairs(others) do
            if otherPlayer ~= player then
                local character = otherPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local humanoidRootPart = character.HumanoidRootPart
                    local originalPosition = humanoidRootPart.Position
                    task.wait(0.1)
                    local newPosition = humanoidRootPart.Position
                    if isTwitching(newPosition, originalPosition) then
                        -- Detected another user running the script
                        warn("[Detector] Another user running the script detected: ", otherPlayer.Name)
                        -- Optionally, you can kick the other player
                        -- otherPlayer:Kick("Detected running unauthorized script.")
                    end
                end
            end
        end
    end)
end

local function stopDetecting()
    if detectConnection then
        detectConnection:Disconnect()
        detectConnection = nil
    end
end

function detector.start()
    active = true
    startDetecting()
end

function detector.stop()
    active = false
    stopDetecting()
end

return detector
