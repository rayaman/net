REM make sure the 'openssl.exe' commandline tool is in your path before starting!
REM set the path below;
set opensslpath=C:\OpenSSL-Win32\bin
setlocal
set path=%opensslpath%;%path%
call roota.bat
call servera.bat
call clienta.bat
