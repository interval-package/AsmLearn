@echo off

:: process of compile

D:\ProgramFiles\masm32\bin\x86MasmLinker\MASM.EXE %1.asm,,,,,

if not exist %1.obj goto fail

link %1.obj,,,,,

if not exist %1.exe goto fail

:: if successfully compiled, do the exe

goto success

:success
	echo compile success
	D:\ProgramFiles\DOSBox-0.74-3\DOSBox.exe %1.exe
	goto end

:fail
	echo fail compile
	goto end

:end 
	echo _build end