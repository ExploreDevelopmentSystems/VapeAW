-- Detector Module
local detector = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local detectionRange = 0.02 -- Detection range for the twitch movement
local patternTolerance = 0.02 -- Tolerance for pattern matching
local detectionEnabled = false
local detectionConnection
local detectLocalPlayer = false

local pattern = {
    Vector3.new(-detectionRange, 0, 0), -- left
    Vector3.new(0, detectionRange, 0), -- up
    Vector3.new(detectionRange, 0, 0), -- right
    Vector3.new(0, -detectionRange, 0) -- down
}
local patternIndex = 1
local recentMovements = {}
local notificationCallback

local function detectTwitch()
    if not detectionEnabled then return end

    for _, player in pairs(Players:GetPlayers()) do
        if (player ~= LocalPlayer or detectLocalPlayer) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local currentPos = player.Character.HumanoidRootPart.Position
            local lastPos = recentMovements[player.UserId]

            if lastPos then
                local delta = currentPos - lastPos
                if delta:FuzzyEq(pattern[patternIndex], patternTolerance) then
                    patternIndex = patternIndex + 1
                    if patternIndex > #pattern then
                        if notificationCallback then
                            notificationCallback(player.Name)
                        end
                        print("[Debug] Detected unique twitch pattern in:", player.Name)
                        patternIndex = 1 -- Reset after detection
                    end
                else
                    patternIndex = 1 -- Reset if pattern doesn't match
                end
            end

            recentMovements[player.UserId] = currentPos
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
