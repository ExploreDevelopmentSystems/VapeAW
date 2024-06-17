-- func.lua

local func = {}

-- Utility function to create a visualizer part
local function createVisualizerPart(size)
    local part = Instance.new("Part")
    part.Name = "VisualizerPart"
    part.Size = Vector3.new(size, 0.1, size) -- Thin square sheet
    part.Anchored = false
    part.CanCollide = false
    part.Transparency = 0.5
    part.Color = Color3.fromRGB(255, 0, 0) -- Red color
    part.Material = Enum.Material.ForceField
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.TopSurface = Enum.SurfaceType.Smooth
    return part
end

-- Utility function to create a weld
local function weldParts(part1, part2)
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = part1
    weld.Part1 = part2
    weld.Parent = part1
    return weld
end

-- Range Module
func.range = {
    enabled = false,
    value = 0,
    visualizerEnabled = false,
    visualizers = {},

    toggle = function(self, state)
        self.enabled = state
        if state then
            -- Enable range adjustment
            self:update(self.value)
        else
            -- Disable range adjustment, reset size to default
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1) -- Default size
                end
            end
            -- Remove visualizers
            self:toggleVisualizer(false)
        end
    end,

    update = function(self, newValue)
        self.value = newValue
        if self.enabled then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.Size = Vector3.new(newValue, newValue, newValue)
                    if self.visualizerEnabled then
                        self:addVisualizer(player, newValue)
                    end
                end
            end
        end
    end,

    toggleVisualizer = function(self, state)
        self.visualizerEnabled = state
        if state then
            -- Enable visualizer
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    self:addVisualizer(player, self.value)
                end
            end
        else
            -- Disable visualizer
            for _, visualizer in pairs(self.visualizers) do
                if visualizer then
                    visualizer:Destroy()
                end
            end
            self.visualizers = {}
        end
    end,

    addVisualizer = function(self, player, size)
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            -- Create visualizer part
            local visualizerPart = createVisualizerPart(size)
            visualizerPart.CFrame = hrp.CFrame * CFrame.new(0, -hrp.Size.Y / 2, 0)
            visualizerPart.Parent = hrp

            -- Weld visualizer to HumanoidRootPart
            weldParts(visualizerPart, hrp)

            -- Store visualizer
            self.visualizers[player] = visualizerPart
        end
    end
}

return func
