echo on

if exist c:\codes\work1\work1.exe goto r

if exist c:\codes\work1\work1.asm goto b

echo file error
goto end

:r
	run c:\codes\work1\work1
	goto end

:b
	build c:\codes\work1\work1
	goto end

:end
