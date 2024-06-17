-- func.lua

local func = {}

-- Range Module
func.range = {
    enabled = false,
    value = 0,
    visualizerEnabled = false,

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
        end
    end,

    update = function(self, newValue)
        self.value = newValue
        if self.enabled then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.Size = Vector3.new(newValue, newValue, newValue)
                end
            end
        end
    end,

    toggleVisualizer = function(self, state)
        self.visualizerEnabled = state
        -- Visualizer logic (could be using Billboards, Part, etc.)
        if state then
            -- Enable visualizer
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    if not player.Character.HumanoidRootPart:FindFirstChild("Visualizer") then
                        local visualizer = Instance.new("SelectionBox")
                        visualizer.Name = "Visualizer"
                        visualizer.Adornee = player.Character.HumanoidRootPart
                        visualizer.Parent = player.Character.HumanoidRootPart
                    end
                end
            end
        else
            -- Disable visualizer
            for _, player in pairs(game.Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local visualizer = player.Character.HumanoidRootPart:FindFirstChild("Visualizer")
                    if visualizer then
                        visualizer:Destroy()
                    end
                end
            end
        end
    end,
}

return func
