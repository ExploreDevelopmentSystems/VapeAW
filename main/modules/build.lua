-- Build Module
local build = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local character
local punchEvent = ReplicatedStorage:FindFirstChild("Remote Events") and ReplicatedStorage["Remote Events"]:FindFirstChild("Punch")
local buildDelay = 0.5
local active = false
local connection
local debugEnabled = true

local validModelNames = {
    ["Floor"] = true,
    ["Wall"] = true,
    ["Wheel"] = true,
    ["Seat"] = true,
    ["Driver's Seat"] = true,
    ["Teleporter"] = true,
    ["Tree"] = true,
    ["Fan"] = true,
    ["Dispenser"] = true,
    ["Ballon"] = true
}

local function debugPrint(...)
    if debugEnabled then
        print(...)
    end
end

local function punchBuilds()
    if not active or not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local buildFolder = Workspace:FindFirstChild("Engineer Builds")
    if not buildFolder then
        return -- Exit if Engineer Builds folder does not exist
    end

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
    player.CharacterAdded:Connect(onCharacterAdded)
    character = player.Character or player.CharacterAdded:Wait()
    connection = game:GetService("RunService").Stepped:Connect(function()
        punchBuilds()
        task.wait(buildDelay) -- Wait for the configured delay
    end)
    active = true
end

function build.stop()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    active = false
end

function build.updateDelay(value)
    buildDelay = tonumber(value) or 0.5
end

return build
