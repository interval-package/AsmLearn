@echo off
masm %1.asm,,,,
link %1.obj,,,,
debug %1.exe