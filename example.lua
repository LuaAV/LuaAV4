for i = 1, 100 do
	print("i", i)
end

local vec2 = require "vec2"

local glfw = require "glfw"
local gl = require "gl"

function reshape( window, width,  height )
	print("reshape", width, height)
end

function key(window, k, s, action, mods )
	print(k, s, action, mods)
end

function draw()
	gl.Clear()
	gl.Begin(gl.LINES)
	for i =  1, 100 do
		gl.Vertex(math.random() - 0.5, math.random() - 0.5, 0)
	end
	gl.End()
end

if glfw.Init() == 0 then
	error("Failed to initialize GLFW\n" );
end
glfw.WindowHint(glfw.DEPTH_BITS, 16);

local window = glfw.CreateWindow( 300, 300, "Gears", nil, nil );
if (window == NULL) then
	error("Failed to open GLFW window\n" );
	glfw.Terminate();
end

glfw.SetFramebufferSizeCallback(window, reshape);
glfw.SetKeyCallback(window, key);

glfw.MakeContextCurrent(window);
glfw.SwapInterval( 1 );

-- width, height are int
--glfw.GetFramebufferSize(window, &width, &height);
-- reshape(window, width, height);

function step()
	draw()
	--animate();

	-- Swap buffers
	glfw.SwapBuffers(window);
	glfw.PollEvents();
end

jit.off(step)

while( glfw.WindowShouldClose(window) == 0 ) do
	step()
end

glfw.Terminate();
