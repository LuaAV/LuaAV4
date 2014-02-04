#ifndef AV_HPP
#define AV_HPP

#if defined(_WIN32) || defined(__WINDOWS_MM__) || defined(_WIN64)
	#define AV_WINDOWS 1
	#include <windows.h>
	
	//#include "glew.h"
	//#include <gl\gl.h> 
	//#include <gl\glu.h> 
	//#include <direct.h>
	
	#define AV_EXPORT extern "C" __declspec(dllexport)
#else
	// Unixen:
	#include <unistd.h>
	
	#if defined( __APPLE__ ) && defined( __MACH__ )
		#define AV_OSX 1
		//#include <OpenGL/gl.h>
	#else
		#define AV_LINUX 1
		//#include <GL/gl.h>
		
	#endif
	
	#define AV_EXPORT extern "C"
#endif

extern "C" {
	#include "lua.h"
	#include "lualib.h"
	#include "lauxlib.h"
	#include "luajit.h"
	//#include "av.h"
}

#endif // AV_HPP