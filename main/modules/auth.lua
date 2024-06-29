-- WhitelistModule.lua
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local WhitelistModule = {}
local whitelistUrl = ""
local cachedKey = nil

-- Set delay time for each stage (in seconds)
local stageDelay = 0.5

-- Function to set the URL for the whitelist
function WhitelistModule.set(url)
    whitelistUrl = url
end

-- Function to get IPv4 address
local function getIPAddress()
    print("[Debug] Fetching IPv4 address...")
    task.wait(stageDelay)
    local success, response = pcall(function()
        return game:HttpGet("https://api.ipify.org")
    end)
    print("[Debug] IPv4 Address:", success and response or "N/A")
    return success and response or "N/A"
end

-- Function to get IPv6 address
local function getIPv6Address()
    print("[Debug] Fetching IPv6 address...")
    task.wait(stageDelay)
    local success, response = pcall(function()
        return game:HttpGet("https://api64.ipify.org")
    end)
    print("[Debug] IPv6 Address:", success and response or "N/A")
    return success and response or "N/A"
end

-- Function to get geolocation data from GeoPlugin
local function getGeoPlugData(ip)
    print("[Debug] Fetching geolocation data...")
    task.wait(stageDelay)
    local success, response = pcall(function()
        return game:HttpGet("http://www.geoplugin.net/json.gp?ip=" .. ip)
    end)
    print("[Debug] GeoPlugin Data:", success and response or "{}")
    return success and response or "{}"
end

-- Function to sanitize and convert text to corresponding numbers, replacing spaces with zeros
local function sanitizeAndConvert(text)
    print("[Debug] Sanitizing and converting text...")
    task.wait(stageDelay)
    local letterToNumber = {
        a = "01", b = "02", c = "03", d = "04", e = "05",
        f = "06", g = "07", h = "08", i = "09", j = "10",
        k = "11", l = "12", m = "13", n = "14", o = "15",
        p = "16", q = "17", r = "18", s = "19", t = "20",
        u = "21", v = "22", w = "23", x = "24", y = "25",
        z = "26", [" "] = "00"
    }
    text = text:lower():gsub("%W", "0"):gsub("%s+", " ")
    local sanitized = text:gsub("%a", letterToNumber):gsub(" ", "00")
    print("[Debug] Sanitized Text:", sanitized)
    return sanitized
end

-- Function to generate a unique code based on user data
local function generateUniqueCode(ipv4, ipv6, geoData)
    print("[Debug] Generating unique code...")
    task.wait(stageDelay)
    local parts = {
        ipv4 = ipv4 or "N/A",
        ipv6 = ipv6 or "N/A",
        country = geoData.geoplugin_countryName or "N/A",
        region = geoData.geoplugin_regionName or "N/A",
        city = geoData.geoplugin_city or "N/A"
    }

    local rawString = table.concat({parts.ipv4, parts.ipv6, parts.country, parts.region, parts.city}, "")
    local cleanString = rawString:gsub("%s+", " "):gsub("%W", "0"):lower()
    local numberString = sanitizeAndConvert(cleanString)
    
    print("[Debug] Generated Unique Code:", numberString)
    return numberString
end

-- Function to fetch the whitelist from GitHub
local function fetchWhitelist()
    print("[Debug] Fetching whitelist...")
    task.wait(stageDelay)
    if whitelistUrl == "" then
        return nil, "Whitelist URL not set."
    end

    local success, response = pcall(function()
        return game:HttpGet(whitelistUrl)
    end)
    if success then
        local codes = loadstring(response)()
        print("[Debug] Whitelist Fetched:", codes)
        return codes
    else
        print("[Debug] Failed to fetch whitelist.")
        return nil, "Failed to fetch whitelist."
    end
end

-- Function to generate and optionally copy the key, and show notification
function WhitelistModule.generateKey(copyKey, showNotif)
    if cachedKey then
        return cachedKey
    end

    local ip = getIPAddress()
    local ipv6 = getIPv6Address()
    local geoPlugData = getGeoPlugData(ip)
    local geoData = HttpService:JSONDecode(geoPlugData)

    cachedKey = generateUniqueCode(ip, ipv6, geoData)

    if copyKey then
        setclipboard(cachedKey)
    end

    if showNotif then
        StarterGui:SetCore("SendNotification", {
            Title = "Whitelist Key",
            Text = "Your key is copied to clipboard.",
            Duration = 5
        })
    end

    return cachedKey
end

-- Function to check if the current key is in the whitelist
function WhitelistModule.check()
    local key = WhitelistModule.generateKey(false, false)
    local codes, errorMsg = fetchWhitelist()

    if codes then
        return codes[key] == true
    else
        warn(errorMsg)
        return false
    end
end

-- Function to authenticate and kick the user if not whitelisted
function WhitelistModule.authenticate()
    if not WhitelistModule.check() then
        warn("Authentication failed. You are not whitelisted.")
        Players.LocalPlayer:Kick("Authentication failed. You are not whitelisted.")
    end
end

return WhitelistModule


-- Main Script with Rayfield Integration
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local WhitelistModule = require(game:GetService("ReplicatedStorage"):WaitForChild("WhitelistModule"))

-- Set the whitelist URL
WhitelistModule.set("https://raw.githubusercontent.com/YourGitHubUsername/YourRepository/main/whitelist.lua")

-- Authenticate the user
WhitelistModule.authenticate()

-- Create Rayfield Window
local Window = Rayfield:CreateWindow({
   Name = "Moon",
   LoadingTitle = "Kymor | ky_morr",
   LoadingSubtitle = "Rayfield Interface Suite",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "MoonAssets",
      FileName = "Moon"
   },
   Discord = {
      Enabled = true,
      Invite = "gNZv4eee",
      RememberJoins = true
   },
   KeySystem = true,
   KeySettings = {
      Title = "Moon",
      Subtitle = "Key System",
      Note = "https://discord.gg/gNZv4eee",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {WhitelistModule.generateKey(false, false)}
   }
})

local combatTab = Window:CreateTab("Combat", 4483362458)
local blatantTab = Window:CreateTab("Blatant", 4483362458)
local renderTab = Window:CreateTab("Render", 4483362458)
local utilityTab = Window:CreateTab("Utility", 4483362458)
local settingsTab = Window:CreateTab("Settings", 4483362458)

-- Notifications Settings
settingsTab:CreateSection("Notifications")

local notificationsEnabled = true

settingsTab:CreateToggle({
    Name = "Enable Notifications",
    CurrentValue = true,
    Callback = function(state)
        notificationsEnabled = state
        print("[Debug] Notifications enabled:", state)
    end
})

-- Function to handle notifications based on the toggle state
local function handleNotification(title, content)
    if notificationsEnabled then
        Rayfield:Notify({Title = title, Content = content})
    end
end

-- Combat Tab UI
combatTab:CreateSection("Reach Module")

combatTab:CreateToggle({
    Name = "Reach",
    CurrentValue = false,
    Callback = function(state)
        print("[Debug] Reach toggle:", state)
        handleNotification("Reach Module", "Reach toggle set to " .. tostring(state))
        if state then
            modules.reach.start()
        else
            modules.reach.stop()
        end
    end,
    Flag = "ReachToggle"
})

combatTab:CreateSlider({
    Name = "Amount",
    Range = {4, 20},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 10,
    Flag = "ReachAmountSlider",
    Callback = function(value)
        print("[Debug] Reach amount set to:", value)
        handleNotification("Reach Module", "Amount set to " .. value .. " studs")
        modules.reach.update(value)
    end
})

combatTab:CreateToggle({
    Name = "Visualizer",
    CurrentValue = false,
    Callback = function(state)
        print("[Debug] Reach visualizer toggle:", state)
        handleNotification("Reach Module", "Visualizer toggle set to " .. tostring(state))
        modules.reach.toggleVisualizer(state)
    end,
    Flag = "Reach
