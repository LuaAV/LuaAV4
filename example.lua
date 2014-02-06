local gl = require "gl"
local vec2 = require "vec2"
local draw2D = require "draw2D"

go(function()
    while true do
        local result = wait("foo")
        print("received", result)
    end
end)

go(function()
    while true do
        event("foo", math.random())
        wait(0.5)
    end
end)


function resize(width, height)
	print("resize", width, height)
end

local win = Window {
	title = "foo",
	sync = false,
	--autoclear = false,
}

function win:key(...) print(...) end

function win:mouse(event, button, x, y)
    -- event is a string, e.g. "down", "up", etc.
    -- button is "left", "right" or "middle"
    -- x and y are the mouse location (in pixels)
    -- or delta offsets for "scroll" event
    
    print(event, button, x, y)
    
    if event == "scroll" then
        agent.force:sub(vec2(x, y) * 0.1)
    end
end
