-- Twitch Module
local twitch = {}

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local active = false
local movementOffset = 0.1 -- Small movement offset
local interval = 0.02 -- Time between movements
local camera = game.Workspace.CurrentCamera
local twitchConnection

local sequence = {
    Vector3.new(-movementOffset, 0, 0), -- left
    Vector3.new(movementOffset, 0, 0), -- right
    Vector3.new(0, movementOffset, 0), -- up
    Vector3.new(0, -movementOffset, 0) -- down
}
local sequenceIndex = 1

local function performTwitch()
    if not active then return end

    local offset = sequence[sequenceIndex]
    humanoidRootPart.CFrame = humanoidRootPart.CFrame + offset

    -- Counter camera movement to minimize visual shake
    camera.CFrame = camera.CFrame - offset

    sequenceIndex = (sequenceIndex % #sequence) + 1

    -- Stop twitching after completing the sequence
    if sequenceIndex == 1 then
        twitch.stop()
    end
end

function twitch.start()
    if twitchConnection then return end
    active = true
    twitchConnection = RunService.Heartbeat:Connect(function()
        performTwitch()
        wait(interval)
    end)
    print("[Debug] Twitch module started.")
end

function twitch.stop()
    if twitchConnection then
        twitchConnection:Disconnect()
        twitchConnection = nil
        print("[Debug] Twitch module stopped.")
    end
    active = false
end

return twitch
