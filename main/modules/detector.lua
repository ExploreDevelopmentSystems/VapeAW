-- Detector Module
local detector = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local detectionRange = 0.1
local patternTolerance = 0.02 
local detectionEnabled = false
local detectionConnection
local detectLocalPlayer = false

local pattern = {
    Vector3.new(-detectionRange, 0, 0), -- left
    Vector3.new(detectionRange, 0, 0), -- right
    Vector3.new(0, detectionRange, 0), -- up
    Vector3.new(0, -detectionRange, 0) -- down
}
local patternIndex = 1
local recentMovements = {}
local movementTimestamps = {}
local movementTimeout = 0.1
local notificationCallback

local function resetPattern(player)
    patternIndex = 1
    recentMovements[player.UserId] = nil
    movementTimestamps[player.UserId] = nil
end

local function detectTwitch()
    if not detectionEnabled then return end

    for _, player in pairs(Players:GetPlayers()) do
        if (player ~= LocalPlayer or detectLocalPlayer) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local currentPos = player.Character.HumanoidRootPart.Position
            local lastPos = recentMovements[player.UserId]
            local lastTimestamp = movementTimestamps[player.UserId]
            local currentTime = tick()

            if lastPos then
                local delta = currentPos - lastPos
                local expectedMovement = pattern[patternIndex]

                if delta:FuzzyEq(expectedMovement, patternTolerance) then
                    patternIndex = patternIndex + 1
                    if patternIndex > #pattern then
                        if notificationCallback then
                            notificationCallback(player.Name)
                        end
                        print("[Debug] Detected unique twitch pattern in:", player.Name)
                        resetPattern(player) -- Reset after detection
                    else
                        movementTimestamps[player.UserId] = currentTime
                    end
                else
                    resetPattern(player) -- Reset if pattern doesn't match
                end
            end

            if not lastTimestamp or currentTime - lastTimestamp > movementTimeout then
                resetPattern(player) -- Reset if movement is too slow
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
