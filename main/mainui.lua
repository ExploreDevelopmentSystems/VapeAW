shared.VapeIndependent = true
shared.CustomSaveVape = "VapeAWLiveV1"

print("[Debug] UI loading.")

-- UI Setup
local GuiLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua", true))()
local Combat = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api
local Blatant = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api
local Render = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api
local Utility = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api
local World = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api

print("[Debug] UI loaded.")

-- Local for Modules
local modules = {}

local function loadModule(name, url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url, true))()
    end)
    if success then
        modules[name] = result
        print("[Debug] Loaded module:", name)
    else
        warn("[Debug] Failed to load module '" .. name .. "' from URL:", url)
    end
end

local moduleURLs = {
    reach = "https://raw.githubusercontent.com/ExploreDevelopmentSystems/VapeAW/main/main/modules/reach.lua",
    velocity = "https://raw.githubusercontent.com/ExploreDevelopmentSystems/VapeAW/main/main/modules/velocity.lua",
    punch = "https://raw.githubusercontent.com/ExploreDevelopmentSystems/VapeAW/main/main/modules/punch.lua",
    bosses = "https://raw.githubusercontent.com/ExploreDevelopmentSystems/VapeAW/main/main/modules/bosses.lua",
    build = "https://raw.githubusercontent.com/ExploreDevelopmentSystems/VapeAW/main/main/modules/build.lua",
    tag = "https://raw.githubusercontent.com/ExploreDevelopmentSystems/VapeAW/main/main/modules/tag.lua",
    fov = "https://raw.githubusercontent.com/ExploreDevelopmentSystems/VapeAW/main/main/modules/fov.lua"
}

-- Load Modules
for name, url in pairs(moduleURLs) do
    loadModule(name, url)
end

-- Ensure modules are loaded successfully
assert(modules.reach, "[Debug] Reach module failed to load.")
assert(modules.velocity, "[Debug] Velocity module failed to load.")
assert(modules.punch, "[Debug] Punch module failed to load.")
assert(modules.bosses, "[Debug] Bosses module failed to load.")
assert(modules.build, "[Debug] Build module failed to load.")
assert(modules.tag, "[Debug] Tag module failed to load.")
assert(modules.fov, "[Debug] FOV module failed to load.")

-- UI Elements for each module

-- Reach Module UI
local reach = Combat.CreateOptionsButton({
    Name = "Reach",
    Function = function(callback)
        if callback then
            modules.reach.start()
        else
            modules.reach.stop()
        end
    end,
    HoverText = "Modification of local-player punch reach.",
    Default = false,
    ExtraText = function() return modules.reach.getHeadSize() end
})

reach.CreateSlider({
    Name = "Amount",
    Min = 4,
    Max = 20,
    Function = function(val)
        modules.reach.update(val)
    end,
    HoverText = "Studs",
    Default = 10,
    Double = 1
})

reach.CreateToggle({
    Name = "Visualizer",
    HoverText = "Make nearby hitboxes visible.",
    Function = function(callback)
        modules.reach.toggleVisualizer(callback)
    end,
    Default = false
})

reach.CreateToggle({
    Name = "Angle",
    HoverText = "Only apply for players in front.",
    Function = function(callback)
        modules.reach.toggleAngleCheck(callback)
    end,
    Default = false
})

-- Velocity Module UI
local velocity = Combat.CreateOptionsButton({
    Name = "Velocity",
    Function = function(callback)
        if callback then
            modules.velocity.start()
        else
            modules.velocity.stop()
        end
    end,
    HoverText = "Modify horizontal and vertical forces.",
    Default = false,
    ExtraText = function() return "Horizontal: " .. math.floor(modules.velocity.getHorizontalPercent() * 100) .. "%, Vertical: " .. math.floor(modules.velocity.getVerticalPercent() * 100) .. "%" end
})

velocity.CreateSlider({
    Name = "Horizontal",
    Min = 0,
    Max = 100,
    Function = function(val)
        modules.velocity.updateHorizontal(val)
    end,
    HoverText = "Horizontal force percentage.",
    Default = 100,
    Double = 1
})

velocity.CreateSlider({
    Name = "Vertical",
    Min = 0,
    Max = 100,
    Function = function(val)
        modules.velocity.updateVertical(val)
    end,
    HoverText = "Vertical force percentage.",
    Default = 100,
    Double = 1
})


-- Punch Module UI
local punch = Blatant.CreateOptionsButton({
    Name = "Punch",
    Function = function(callback)
        if callback then
            modules.punch.start()
        else
            modules.punch.stop()
        end
    end,
    HoverText = "Changes the fundamentals of how punches are registered to guarantee hits if in range.",
    Default = false,
    ExtraText = function() return "Range: " .. modules.punch.getRange() end
})

punch.CreateSlider({
    Name = "Range Amount",
    Min = 4,
    Max = 20,
    Function = function(val)
        modules.punch.updateRange(val)
    end,
    HoverText = "Adjust punch range.",
    Default = 10,
    Double = 1
})

punch.CreateToggle({
    Name = "Visualizer",
    HoverText = "Show punch hitboxes.",
    Function = function(callback)
        modules.punch.toggleVisualizer(callback)
    end,
    Default = false
})

punch.CreateToggle({
    Name = "Angle",
    HoverText = "Only punch targets in front.",
    Function = function(callback)
        modules.punch.toggleAngleCheck(callback)
    end,
    Default = false
})

punch.CreateToggle({
    Name = "Include NPCs",
    HoverText = "Include NPCs in punch range.",
    Function = function(callback)
        modules.punch.toggleIncludeNPCs(callback)
    end,
    Default = true
})

punch.CreateToggle({
    Name = "Particle",
    HoverText = "Show punch particle effect.",
    Function = function(callback)
        modules.punch.toggleParticle(callback)
    end,
    Default = false
})

punch.CreateToggle({
    Name = "Wall Check",
    HoverText = "Enable wall checks for punches.",
    Function = function(callback)
        modules.punch.toggleWallCheck(callback)
    end,
    Default = false
})

-- Bosses Module UI
local bosses = Blatant.CreateOptionsButton({
    Name = "Bosses",
    Function = function(callback)
        if callback then
            modules.bosses.start()
        else
            modules.bosses.stop()
        end
    end,
    HoverText = "Automatically punches bosses when they appear in the workspace.",
    Default = false
})

bosses.CreateSlider({
    Name = "Delay",
    Min = 0.1,
    Max = 1,
    Function = function(val)
        modules.bosses.updateDelay(val)
    end,
    HoverText = "Delay between punches in seconds.",
    Default = 0.5,
    Double = 0.1
})

bosses.CreateToggle({
    Name = "Falseify",
    HoverText = "Only punch bosses if 2 or more players are nearby.",
    Function = function(callback)
        modules.bosses.toggleFalseify(callback)
    end,
    Default = false
})

-- Build Module UI
local build = Blatant.CreateOptionsButton({
    Name = "Build",
    Function = function(callback)
        if callback then
            modules.build.start()
        else
            modules.build.stop()
        end
    end,
    HoverText = "Destroys all builds in workspace.",
    Default = false
})

build.CreateSlider({
    Name = "Delay",
    Min = 0.1,
    Max = 1,
    Function = function(val)
        modules.build.updateDelay(val)
    end,
    HoverText = "Delay between punching builds in seconds.",
    Default = 0.5,
    Double = 0.1
})

-- Tag Module UI
local tag = Render.CreateOptionsButton({
    Name = "Tag",
    Function = function(callback)
        if callback then
            modules.tag.start()
        else
            modules.tag.stop()
        end
    end,
    HoverText = "Creates a nametag above players.",
    Default = false
})

tag.CreateToggle({
    Name = "Priority",
    HoverText = "Render through walls if enabled. Use ray
