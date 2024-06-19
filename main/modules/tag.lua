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
    HoverText = "Render through walls if enabled. Use raycast if disabled.",
    Function = function(callback)
        modules.tag.togglePriority(callback)
    end,
    Default = false
})

tag.CreateToggle({
    Name = "Delete OG",
    HoverText = "Makes the original nametag invisible.",
    Function = function(callback)
        modules.tag.toggleDeleteOG(callback)
    end,
    Default = false
})

tag.CreateToggle({
    Name = "Show BG",
    HoverText = "Toggle the background of the nametag.",
    Function = function(callback)
        modules.tag.toggleShowBG(callback)
    end,
    Default = true
})

tag.CreateToggle({
    Name = "Display",
    HoverText = "Show the display name instead of the username.",
    Function = function(callback)
        modules.tag.toggleDisplay(callback)
    end,
    Default = false
})

tag.CreateToggle({
    Name = "Distance",
    HoverText = "Show the distance to the player.",
    Function = function(callback)
        modules.tag.toggleDistance(callback)
    end,
    Default = false
})

tag.CreateToggle({
    Name = "Ability",
    HoverText = "Show the player's Ability value.",
    Function = function(callback)
        modules.tag.toggleAbility(callback)
    end,
    Default = false
})

tag.CreateSlider({
    Name = "Scale",
    Min = 0.5,
    Max = 3,
    Function = function(val)
        modules.tag.updateScale(val)
    end,
    HoverText = "Scale of the nametag.",
    Default = 1,
    Double = 1
})

tag.CreateSlider({
    Name = "Height",
    Min = 0,
    Max = 5,
    Function = function(val)
        modules.tag.updateHeight(val)
    end,
    HoverText = "Height of the nametag above the player.",
    Default = 2,
    Double = 1
})
