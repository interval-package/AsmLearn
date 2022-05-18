echo off

if not exist %1.obj goto fail
if not exist %1.exe goto fail

:success
	cls
	%1.exe
	goto end

:fail
	echo file not alive
	goto end

:end
	echo end process
	pause
