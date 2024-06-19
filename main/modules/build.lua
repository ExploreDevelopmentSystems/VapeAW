-- Build Module
local build = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local character
local buildFolder = Workspace:FindFirstChild("Engineer Builds") and Workspace["Engineer Builds"]:FindFirstChild("Build Model")
local punchEvent = ReplicatedStorage:FindFirstChild("Remote Events") and ReplicatedStorage["Remote Events"]:FindFirstChild("Punch")
local buildDelay = 0.5
local active = false
local connection
local debugEnabled = true

local function debugPrint(...)
    if debugEnabled then
        print(...)
    end
end

local function punchBuilds()
    if not active or not character or not character:FindFirstChild("HumanoidRootPart") then return end
    if not buildFolder then
        debugPrint("[Debug] Build folder not found in Workspace.")
        return
    end

    for _, build in ipairs(buildFolder:GetChildren()) do
        if build:IsA("Model") then
            local impactPosition = build:GetModelCFrame().p
            if punchEvent then
                debugPrint("[Debug] Punching build model:", build.Name)
                punchEvent:FireServer(build, impactPosition)
                task.wait(buildDelay) -- Wait for the configured delay
            else
                warn("[Debug] Punch event not found.")
            end
        else
            debugPrint("[Debug] Non-model found in build folder:", build.Name)
        end
    end
end

local function onCharacterAdded(newCharacter)
    character = newCharacter
    if active then
        punchBuilds()
    end
end

function build.start()
    if connection then return end
    player.CharacterAdded:Connect(onCharacterAdded)
    character = player.Character or player.CharacterAdded:Wait()
    connection = game:GetService("RunService").Stepped:Connect(function()
        punchBuilds()
        task.wait(buildDelay) -- Wait for the configured delay
    end)
    active = true
    debugPrint("[Debug] Build module started.")
end

function build.stop()
    if connection then
        connection:Disconnect()
        connection = nil
        debugPrint("[Debug] Build module connection stopped.")
    end
    active = false
end

function build.updateDelay(value)
    buildDelay = tonumber(value) or 0.5
    debugPrint("[Debug] Build delay updated to:", buildDelay)
end

return build
