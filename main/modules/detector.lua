-- Detector Module
local detector = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local detectionRange = 0.02 -- Detection range for the twitch movement
local detectionInterval = 0.1 -- Interval to check for twitch movements
local lastPositions = {}
local detectionEnabled = false
local detectionConnection
local detectLocalPlayer = false

local notificationCallback

local function detectTwitch()
    if not detectionEnabled then return end

    for _, player in pairs(Players:GetPlayers()) do
        if (player ~= LocalPlayer or detectLocalPlayer) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local currentPos = player.Character.HumanoidRootPart.Position
            local lastPos = lastPositions[player.UserId]

            if lastPos then
                local delta = (currentPos - lastPos).Magnitude
                if delta > detectionRange then
                    if notificationCallback then
                        notificationCallback(player.Name)
                    end
                    print("[Debug] Detected twitch in:", player.Name, "Delta:", delta)
                end
            end

            lastPositions[player.UserId] = currentPos
        end
    end
end

function detector.start()
    if detectionConnection then return end
    detectionEnabled = true
    detectionConnection = RunService.Heartbeat:Connect(detectTwitch)
    print("[Debug] Detector module started.")
end

function detector.stop()
    if detectionConnection then
        detectionConnection:Disconnect()
        detectionConnection = nil
        print("[Debug] Detector module stopped.")
    end
    detectionEnabled = false
end

function detector.setNotificationCallback(callback)
    notificationCallback = callback
end

function detector.setDetectLocalPlayer(value)
    detectLocalPlayer = value
    print("[Debug] Detect local player set to:", value)
end

return detector
