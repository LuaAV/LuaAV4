@if not defined INCLUDE goto :FAIL

@setlocal

echo building:

@rem /MT avoids CRT dependency
@rem /EHsc /GR /FI"iso646.h" /Zc:strictStrings /we4627 /we4927 /wd4351 /W4
@rem Delayimp.lib + /DELAYLOAD:lua51.dll allows us to use library symbols even though the DLL is not actually loaded until during main()
cl /D_CRT_SECURE_NO_DEPRECATE /MT /EHsc /O2 /D__WINDOWS_DS__ /I win32/include av_windows_main.cpp lua51.lib ole32.lib user32.lib Delayimp.lib /link /LIBPATH:win32/lib /DELAYLOAD:lua51.dll  /out:av.exe
@rem RtAudio.cpp lua51.lib glut32.lib FreeImage.lib Dsound.lib ole32.lib user32.lib Delayimp.lib /link /LIBPATH:win32/lib /DELAYLOAD:lua51.dll /DELAYLOAD:glut32.dll /DELAYLOAD:FreeImage.dll /out:av.exe
@if errorlevel 1 goto :BAD

xcopy /Y av.exe ..

@rem @call 

..\av.exe ..\example.lua

@goto :END
:BAD
@echo.
@echo *******************************************************
@echo *** Build FAILED -- Please check the error messages ***
@echo *******************************************************
@goto :END
:FAIL
@echo You must open a "Visual Studio .NET Command Prompt" to run this script
:END
