-- Define the module table
local rangeModule = {}
local active = false

-- Function to start the module
function rangeModule.start()
    active = true
    print("Range module started")
    -- Add logic to enable the feature
    -- Example: Set player punch range
end

-- Function to end the module
function rangeModule.end()
    active = false
    print("Range module ended")
    -- Add logic to disable the feature
end

-- Function to update the module (if needed)
function rangeModule.update()
    if active then
        -- Add logic to update the feature
        print("Range module is updating")
        -- Example: Adjust player punch range based on some condition
    end
end

-- Return the module table
return rangeModule
