-- Velocity Module
local velocity = {}

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local horizontalPercent = 1
local verticalPercent = 1
local velocityConnection
local originalForces = {}

local function suppressAndApplyForces()
    for _, instance in pairs(character:GetDescendants()) do
        if instance:IsA("BodyVelocity") or instance:IsA("BodyForce") then
            if not originalForces[instance] then
                originalForces[instance] = {
                    velocity = instance:IsA("BodyVelocity") and instance.Velocity or Vector3.new(0, 0, 0),
                    force = instance:IsA("BodyForce") and instance.Force or Vector3.new(0, 0, 0)
                }
            end
            if instance:IsA("BodyVelocity") then
                instance.Velocity = Vector3.new(
                    originalForces[instance].velocity.X * horizontalPercent,
                    originalForces[instance].velocity.Y * verticalPercent,
                    originalForces[instance].velocity.Z * horizontalPercent
                )
            elseif instance:IsA("BodyForce") then
                instance.Force = Vector3.new(
                    originalForces[instance].force.X * horizontalPercent,
                    originalForces[instance].force.Y * verticalPercent,
                    originalForces[instance].force.Z * horizontalPercent
                )
            end
        end
    end
end

function velocity.start()
    if velocityConnection then return end
    velocityConnection = game:GetService("RunService").Stepped:Connect(suppressAndApplyForces)
end

function velocity.stop()
    if velocityConnection then
        velocityConnection:Disconnect()
        velocityConnection = nil
        for instance, original in pairs(originalForces) do
            if instance and instance.Parent then
                if instance:IsA("BodyVelocity") then
                    instance.Velocity = original.velocity
                elseif instance:IsA("BodyForce") then
                    instance.Force = original.force
                end
            end
        end
        originalForces = {}
    end
end

function velocity.updateHorizontal(value)
    local percent = tonumber(value) / 100
    if percent then
        horizontalPercent = percent
    end
end

function velocity.updateVertical(value)
    local percent = tonumber(value) / 100
    if percent then
        verticalPercent = percent
    end
end

function velocity.getHorizontalPercent()
    return horizontalPercent
end

function velocity.getVerticalPercent()
    return verticalPercent
end

return velocity
