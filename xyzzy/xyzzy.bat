@echo off
cd > xyzhome.dat
copy xyzzy.set+xyzhome.dat xyzstart.bat > NUL
echo set XYZZYCONFIGPATH=>> xyzstart.bat
echo start xyzzy.exe -config usr %1 %2 %3 %4 %5 %6 %7 %8 %9>> xyzstart.bat
call xyzstart.bat
del xyzstart.bat
del xyzhome.dat
