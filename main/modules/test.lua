-- Terminal GUI Library for VapeAW
local TerminalGUI = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Local Player
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Terminal GUI
local terminalFrame = Instance.new("Frame")
terminalFrame.Size = UDim2.new(0.5, 0, 0.5, 0)
terminalFrame.Position = UDim2.new(0.25, 0, 0.25, 0)
terminalFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
terminalFrame.BorderSizePixel = 0
terminalFrame.Parent = playerGui

local terminalOutput = Instance.new("ScrollingFrame")
terminalOutput.Size = UDim2.new(1, -10, 0.9, -10)
terminalOutput.Position = UDim2.new(0, 5, 0, 5)
terminalOutput.BackgroundTransparency = 1
terminalOutput.BorderSizePixel = 0
terminalOutput.CanvasSize = UDim2.new(0, 0, 0, 0)
terminalOutput.ScrollBarThickness = 5
terminalOutput.Parent = terminalFrame

local outputText = Instance.new("TextLabel")
outputText.Size = UDim2.new(1, -10, 1, -10)
outputText.Position = UDim2.new(0, 5, 0, 5)
outputText.BackgroundTransparency = 1
outputText.TextColor3 = Color3.fromRGB(0, 255, 0)
outputText.TextXAlignment = Enum.TextXAlignment.Left
outputText.TextYAlignment = Enum.TextYAlignment.Top
outputText.TextWrapped = true
outputText.Font = Enum.Font.Code
outputText.TextSize = 18
outputText.Text = ""
outputText.Parent = terminalOutput

local commandInput = Instance.new("TextBox")
commandInput.Size = UDim2.new(1, -10, 0.1, -10)
commandInput.Position = UDim2.new(0, 5, 0.9, 0)
commandInput.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
commandInput.BorderSizePixel = 0
commandInput.TextColor3 = Color3.fromRGB(0, 255, 0)
commandInput.Font = Enum.Font.Code
commandInput.TextSize = 18
commandInput.Text = ""
commandInput.ClearTextOnFocus = false
commandInput.Parent = terminalFrame

-- Module Buttons
local modules = {
    "Reach", "Punch", "Bosses", "Build", "Tag", "FOV", "Heal", "Jello"
}

local buttonHeight = 0.05
for i, moduleName in ipairs(modules) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, buttonHeight, 0)
    button.Position = UDim2.new(0.05, 0, i * buttonHeight + 0.05, 0)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Code
    button.TextSize = 18
    button.Text = moduleName
    button.Name = moduleName
    button.Parent = terminalFrame

    button.MouseButton1Click:Connect(function()
        -- Dummy function to toggle modules
        local isEnabled = button.BackgroundColor3 == Color3.fromRGB(0, 255, 0)
        button.BackgroundColor3 = isEnabled and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(0, 255, 0)
        print("[Terminal] " .. moduleName .. " toggled to " .. (not isEnabled and "ON" or "OFF"))
    end)
end

-- Example Function: Print to Terminal
function TerminalGUI.Print(message)
    outputText.Text = outputText.Text .. "\n" .. message
    terminalOutput.CanvasSize = UDim2.new(0, 0, 0, outputText.TextBounds.Y)
    terminalOutput.CanvasPosition = Vector2.new(0, outputText.TextBounds.Y)
end

-- Command Input Handling
commandInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local command = commandInput.Text
        commandInput.Text = ""
        TerminalGUI.Print("> " .. command)
        -- Process command (placeholder)
    end
end)

-- Example: Adding Sliders (for module parameters)
local function addSlider(name, min, max, default, parent)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.9, 0, buttonHeight, 0)
    sliderFrame.Position = UDim2.new(0.05, 0, #parent:GetChildren() * buttonHeight + 0.05, 0)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    sliderFrame.Parent = parent

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(0.5, 0, 1, 0)
    sliderLabel.Position = UDim2.new(0, 0, 0, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sliderLabel.Font = Enum.Font.Code
    sliderLabel.TextSize = 18
    sliderLabel.Text = name
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Parent = sliderFrame

    local slider = Instance.new("Slider")
    slider.Size = UDim2.new(0.5, -5, 1, -5)
    slider.Position = UDim2.new(0.5, 5, 0, 0)
    slider.BackgroundTransparency = 1
    slider.MinValue = min
    slider.MaxValue = max
    slider.Value = default
    slider.Parent = sliderFrame

    slider:GetPropertyChangedSignal("Value"):Connect(function()
        print("[Terminal] " .. name .. " set to " .. slider.Value)
    end)
end

-- Example Usage
addSlider("Range Amount", 4, 20, 10, terminalFrame)
addSlider("Scale", 1, 30, 1, terminalFrame)

return TerminalGUI
