
# OpenGL


LuaAV provides a Lua-friendly wrapper of the [OpenGL programming API](http://www.khronos.org/opengl/) in the ```gl``` module. OpenGL is probably the most widely used graphics interfaces in use today, implemented by most graphics processing unit (GPU) hardware in personal computers and mobile devices. 

```lua
local gl = require "gl"
```

## OpenGL version

Currently this module is based on OpenGL version 2.1 (and GLSL 1.2), which is more compatible with the various operating systems on laptops today. It's worth nothing this, because a lot of tutorial material out there on the internet is for older or newer versions of OpenGL, and thus easily misleading. OpenGL 2.1 includes support for "old-school" immediate mode rendering (```gl.Begin()``` etc.), as well as some of the more modern-style vertex buffers and shader pipelines.

- [Read more about OpenGL 1 "immedate mode" geometry here](tutorial_opengl_1.html)
- [Read more about OpenGL 2 buffer-style geometry here](tutorial_opengl_2.html)

## OpenGL API

The main OpenGL bindings are low-level functions mapping directly to the OpenGL C API. These functions can be accessed via the gl module directly, or via shortened form. This makes it very easy to port OpenGL code written in C into LuaAV:

For example:

```lua
-- raw C API:
gl.glClear(bit.bor(gl.GL_COLOR_BUFFER_BIT, gl.GL_DEPTH_BUFFER_BIT))
gl.glColor4f(1, 0, 0, 1)

-- shorter form API:
gl.Clear(bit.bor(gl.COLOR_BUFFER_BIT, gl.DEPTH_BUFFER_BIT))
gl.Color4f(1, 0, 0, 1)
```

It is in most cases very easy to translate OpenGL code from C to Lua. Any function prefix ```glxxx``` becomes ```gl.xxx```, and any constant prefix ```GL_XXX``` also becomes ```gl.XXX```. 

## Simplified API

In addition, many common functions have even simpler forms (avoiding the need for type suffixes) and useful defaults by leveraging Lua's dynamic typing support, making authoring OpenGL code in Lua a more pleasant experience:

```lua
-- friendly form:
gl.Clear(gl.COLOR_BUFFER_BIT, gl.DEPTH_BUFFER_BIT) -- or just gl.Clear()
gl.Color(1, 0, 0)
``` 

These friendly forms are documented in the ```gl``` module reference; all other OpenGL calls should be derived from the OpenGL C API documentation.

## Higher level wrappers

Some OpenGL objects can be complex to work with (such as textures, framebuffer objects, etc.). LuaAV provides several higher-level modules that "wrap" the OpenGL API in user-friendly forms for common use cases. 

## Resource management

Some OpenGL objects (textures, buffers, displaylists etc.) need recreating whenever the OpenGL context is refreshed, such as when entering fullscreen on some platforms. When using LuaAV windows and high-level resource objects (such as ```texture```, ```displaylist``` etc.), this is all handled automatically for you. 

If you create your own resource objects you may want to add them to the resource manager. To do so, your object should implement ```object:context_create()``` and ```object:context_destroy()``` methods to acquire/submit and release the resources respectively, and register itself with the context via ```gl.context_register(object)```. (Take a look at the displaylist.lua module for a simple example.)

In addition, if you are *not* using LuaAV's window manager, then your window manager should call ```gl.context_create()``` when the OpenGL context becomes ready (e.g. the first frame), and ```gl.context_destroy()``` when the OpenGL context is destroyed (e.g. when the window is closed). 