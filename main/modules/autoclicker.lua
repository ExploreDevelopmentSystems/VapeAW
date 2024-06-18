
local rangeModule = {}


local active = false


function rangeModule.start()
    active = true
    print("Range module started")

end


function rangeModule.end()
    active = false
    print("Range module ended")

end


function rangeModule.update()
    if active then

        print("Range module is updating")
    end
end


return rangeModule
