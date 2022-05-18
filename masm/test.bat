@echo off

:: process of compile

ML %1.asm

if not exist %1.obj goto fail

LINK %1.obj ,,,,,

if not exist %1.exe goto fail

:: if successfully compiled, do the exe

goto success

:success
	cls
	echo compile success, now to debug
	debug %1.exe
	goto end

:fail
	echo fail compile
	goto end

:end
	echo _build end
	pause
