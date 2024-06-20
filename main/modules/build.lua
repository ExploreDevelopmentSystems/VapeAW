-- Build Module
local build = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character
local punchEvent = ReplicatedStorage:FindFirstChild("Remote Events") and ReplicatedStorage["Remote Events"]:FindFirstChild("Punch")
local buildDelay = 0.5
local active = false
local connection
local validModelNames = {}

local function debugPrint(...)
    -- Debug printing enabled only for internal checks
    print(...)
end

local function fetchEngineerAssets()
    local engineerFolder = ReplicatedStorage:FindFirstChild("Ability Assets") and ReplicatedStorage["Ability Assets"]:FindFirstChild("Engineer")
    if not engineerFolder then
        warn("[Debug] Engineer assets folder not found.")
        return
    end

    for _, model in ipairs(engineerFolder:GetChildren()) do
        if model:IsA("Model") then
            validModelNames[model.Name] = true
        end
    end

    debugPrint("[Debug] Valid models updated:", validModelNames)
end

local function punchBuilds()
    if not active or not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local buildFolder = Workspace:FindFirstChild("Engineer Builds")
    if not buildFolder then return end

    for _, build in ipairs(buildFolder:GetDescendants()) do
        if build:IsA("Model") and validModelNames[build.Name] then
            for _, part in ipairs(build:GetDescendants()) do
                if part:IsA("BasePart") then
                    local impactPosition = part.Position
                    if punchEvent then
                        punchEvent:FireServer(build, impactPosition)
                        task.wait(buildDelay)
                    end
                end
            end
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
    fetchEngineerAssets()
    player.CharacterAdded:Connect(onCharacterAdded)
    character = player.Character or player.CharacterAdded:Wait()
    connection = RunService.Stepped:Connect(function()
        punchBuilds()
        task.wait(buildDelay)
    end)
    active = true
    debugPrint("[Debug] Build module started.")
end

function build.stop()
    if connection then
        connection:Disconnect()
        connection = nil
        debugPrint("[Debug] Build connection stopped.")
    end
    active = false
end

function build.updateDelay(value)
    buildDelay = tonumber(value) or 0.5
    debugPrint("[Debug] Build delay updated to:", buildDelay)
end

return build
