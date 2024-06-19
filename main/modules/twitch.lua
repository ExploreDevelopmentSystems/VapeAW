-- Twitch Module
local twitch = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera
local twitchEnabled = false
local twitchConnection

local function counterCameraMovement(originalPosition)
    -- Calculate the counter movement
    local delta = originalPosition - LocalPlayer.Character.HumanoidRootPart.Position
    Camera.CFrame = Camera.CFrame * CFrame.new(delta.X, delta.Y, delta.Z)
end

local function applyTwitch()
    if not twitchEnabled then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    -- Save the original camera position
    local originalPosition = Camera.CFrame.Position

    -- Apply the twitch effect
    LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0.02, 0, 0)
    task.wait(0.02)
    LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(-0.02, 0, 0)

    -- Apply counter camera movement
    counterCameraMovement(originalPosition)
end

function twitch.start()
    if twitchConnection then return end
    twitchEnabled = true
    twitchConnection = RunService.Heartbeat:Connect(applyTwitch)
    print("[Debug] Twitch module started.")
end

function twitch.stop()
    if twitchConnection then
        twitchConnection:Disconnect()
        twitchConnection = nil
        print("[Debug] Twitch module stopped.")
    end
    twitchEnabled = false
end

return twitch
