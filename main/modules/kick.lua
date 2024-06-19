-- Kick Module
local kick = {}

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local kickConnection
local debugEnabled = true

local function debugPrint(...)
    if debugEnabled then
        print(...)
    end
end

local function onPlayerChatted(message, sender)
    if sender ~= player and message:lower():find("kick " .. player.UserId) then
        debugPrint("[Debug] Kick command detected from:", sender.Name, "Message:", message)
        player:Kick("You have been kicked by an admin.")
    end
end

function kick.start()
    if kickConnection then return end
    kickConnection = Players.PlayerChatted:Connect(function(sender, message)
        onPlayerChatted(message, sender)
    end)
    debugPrint("[Debug] Kick module started.")
end

function kick.stop()
    if kickConnection then
        kickConnection:Disconnect()
        kickConnection = nil
        debugPrint("[Debug] Kick module stopped.")
    end
end

return kick
