-- Detector Module
local detector = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("StarterGui")
local detectionPattern = {0.05, 0, -0.05, 0, 0.05, 0, -0.05, 0} -- Simplified detection pattern
local localDetectionEnabled = false
local detectLocalPlayer = false -- Change this to true for local player detection testing

local function notify(message)
    CoreGui:SetCore("SendNotification", {
        Title = "Script Detection",
        Text = message,
        Duration = 5
    })
end

local function detectTwitchingPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer or detectLocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local rootPart = character.HumanoidRootPart
                local movementPattern = {}
                for _, move in ipairs(detectionPattern) do
                    table.insert(movementPattern, rootPart.Position + Vector3.new(0, 0, move))
                end

                -- Check if the player's movement matches the pattern
                for i = 1, #movementPattern - 1 do
                    local currentPos = movementPattern[i]
                    local nextPos = movementPattern[i + 1]
                    if (currentPos - nextPos).Magnitude < 0.01 then
                        notify(player.Name .. " is using the script.")
                        break
                    end
                end
            end
        end
    end
end

function detector.start()
    RunService.Stepped:Connect(detectTwitchingPlayers)
end

function detector.enableLocalDetection()
    detectLocalPlayer = true
end

function detector.disableLocalDetection()
    detectLocalPlayer = false
end

return detector
