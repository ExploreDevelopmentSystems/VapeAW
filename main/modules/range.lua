local range_value = 20
local connection

local function start()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    connection = game:GetService("RunService").Stepped:Connect(function()
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Model") and v ~= character then
                local rootPart = v:FindFirstChild("HumanoidRootPart")
                if rootPart and (character.HumanoidRootPart.Position - rootPart.Position).Magnitude <= range_value then
                    -- apply range effect, e.g., extend hitbox or damage radius
                    -- Placeholder: Print the object within range
                    print(v.Name .. " is within range.")
                end
            end
        end
    end)
end

local function stop()
    if connection then
        connection:Disconnect()
        connection = nil
    end
end

local function update()
    -- Placeholder for updating the range dynamically if needed
    -- This function can be used to adjust the range_value or perform other updates
end

return {
    start = start,
    stop = stop,
    update = update
}
