-- Kick Module
local kick = {}

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local chatConnection
local debugEnabled = true

local function debugPrint(...)
    if debugEnabled then
        print(...)
    end
end

local function onPlayerChatted(message, sender)
    if sender ~= player and message:lower():find("kick") then
        local targetPlayerName = message:match("^kick%s+(%S+)$")
        if targetPlayerName then
            for _, targetPlayer in ipairs(Players:GetPlayers()) do
                if targetPlayer.Name:lower() == targetPlayerName:lower() then
                    debugPrint("[Debug] Kick command detected for:", targetPlayer.Name, "Message:", message)
                    targetPlayer:Kick("You have been kicked from the game.")
                    return
                end
            end
        end
    end
end

function kick.start()
    if chatConnection then return end
    chatConnection = Players.PlayerChatted:Connect(function(sender, message)
        onPlayerChatted(message, sender)
    end)
    debugPrint("[Debug] Kick module started.")
end

function kick.stop()
    if chatConnection then
        chatConnection:Disconnect()
        chatConnection = nil
        debugPrint("[Debug] Kick module stopped.")
    end
end

return kick
