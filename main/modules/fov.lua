-- FOV Module
local fov = {}

local player = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local defaultFOV = camera.FieldOfView
local fovValue = defaultFOV
local fovConnection

local function debugPrint(...)
    -- Debug printing enabled only for internal checks
    print(...)
end

function fov.start()
    if fovConnection then return end
    camera.FieldOfView = fovValue
    fovConnection = game:GetService("RunService").Stepped:Connect(function()
        camera.FieldOfView = fovValue
    end)
    debugPrint("[Debug] FOV module started.")
end

function fov.stop()
    if fovConnection then
        fovConnection:Disconnect()
        fovConnection = nil
    end
    camera.FieldOfView = defaultFOV
    debugPrint("[Debug] FOV module stopped. Reverted to default FOV.")
end

function fov.update(value)
    local newValue = tonumber(value)
    if newValue then
        fovValue = newValue
        camera.FieldOfView = fovValue
        debugPrint("[Debug] FOV updated to:", fovValue)
    end
end

function fov.getFOV()
    return fovValue
end

return fov
