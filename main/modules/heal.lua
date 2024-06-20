-- Heal Module
local heal = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character
local healAmount = 10
local healDelay = 0.5
local healConnection
local active = false

local function debugPrint(...)
    -- Debug printing enabled only for internal checks
    print(...)
end

local function healPlayer()
    if not character or not active then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local newHealth = math.min(humanoid.Health + healAmount, humanoid.MaxHealth)
        humanoid.Health = newHealth
        debugPrint("[Debug] Healed player to:", newHealth)
    end
end

local function onCharacterAdded(newCharacter)
    character = newCharacter
    newCharacter:WaitForChild("Humanoid")
    debugPrint("[Debug] New character added:", newCharacter:GetFullName())
end

function heal.start()
    if healConnection then return end
    player.CharacterAdded:Connect(onCharacterAdded)
    character = player.Character or player.CharacterAdded:Wait()
    healConnection = RunService.Stepped:Connect(function()
        healPlayer()
        task.wait(healDelay)
    end)
    active = true
    debugPrint("[Debug] Heal module started.")
end

function heal.stop()
    if healConnection then
        healConnection:Disconnect()
        healConnection = nil
    end
    active = false
    debugPrint("[Debug] Heal module stopped.")
end

function heal.updateAmount(value)
    healAmount = tonumber(value) or 10
    debugPrint("[Debug] Heal amount updated to:", healAmount)
end

function heal.updateDelay(value)
    healDelay = tonumber(value) or 0.5
    debugPrint("[Debug] Heal delay updated to:", healDelay)
end

return heal
