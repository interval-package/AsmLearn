@echo off

:: process of compile

masm %1.asm,,,,,

if not exist %1.obj goto fail

link %1.obj,,,,,

if not exist %1.exe goto fail

:: if successfully compiled, do the exe

goto success

:success
	echo compile success
	call debug %1.exe
	goto end

:fail
	echo fail compile
	goto end

:end 
	echo _build end
