PYTHON_V=2.7.9
OPENSSL_V=1.0.2a

all: pythonstatic.7z

clean:
	-rmdir /s /q Python-$(PYTHON_V)
	-rmdir /s /q openssl-$(OPENSSL_V)

Python-$(PYTHON_V)\stamp: Python-$(PYTHON_V).tgz python-2.7-superstatic-build.patch
	@echo Unpacking Python $(PYTHON_V)
	7za x -y Python-$(PYTHON_V).tgz >nul:
	7za x -y Python-$(PYTHON_V).tar >nul:
	del Python-$(PYTHON_V).tar
	cd Python-$(PYTHON_V) && patch -p1 < ..\python-2.7-superstatic-build.patch
	echo>$@
	
	cd Python-$(PYTHON_V)
	-del PC\frozen_dllmain.c PC\python3dll.c PC\w9xpopen.c PC\WinMain.c PC\make_versioninfo.c PC\empty.c PC\dl_nt.c PC\_msi.c PC\generrmap.c
	-del Python\dynload_s* Python\dynload_next.c Python\dynload_aix.c Python\dynload_dl.c Python\dynload_hpux.c Python\dynload_os2.c Python\dup2.c Python\python.c
	-del Modules\tk*.c Modules\_tk*.c Modules\getnameinfo.c Modules\getaddrinfo.c Modules\grpmodule.c Modules\pwdmodule.c Modules\nismodule.c Modules\termios.c Modules\_gestalt.c Modules\syslogmodule.c Modules\spwdmodule.c Modules\bz2module.c Modules\readline.c Modules\ossaudiodev.c Modules\fcntlmodule.c Modules\_test* Modules\main.c Modules\getpath.c Modules\pyexpat.c Modules\_dbmmodule.c Modules\_cursesmodule.c Modules\_scproxy.c Modules\resource.c Modules\_posixsubprocess.c Modules\_elementtree.c Modules\_gdbmmodule.c Modules\getcwd.c
	-del Python\getcwd.c
#	-del Modules\signalmodule.c # needed on 2.7
	-del Modules\_bsddb.c Modules\_curses_panel.c Modules\glmodule.c Modules\timingmodule.c Modules\fmmodule.c Modules\flmodule.c Modules\dbmmodule.c Modules\linuxaudiodev.c Modules\sunaudiodev.c Modules\almodule.c Modules\clmodule.c Modules\dlmodule.c Modules\bsddbmodule.c Modules\gdbmmodule.c Modules\imgfile.c Modules\winsound.c
	-del Python\dynload_beos.c Python\dynload_atheos.c Python\mactoolboxglue.c Python\sigcheck.c
	-del Modules\_ctypes\_ctypes_test* Modules\_ctypes\libffi_msvc\types.c
	-del Modules\zlib\minigzip.c Modules\zlib\example.c Modules\zlib\gzclose.c Modules\zlib\gzlib.z Modules\zlib\gzread.c Modules\zlib\gzwrite.c
	-del Modules\cdmodule.c Modules\sgimodule.c Modules\svmodule.c
	-del Parser\pgen.c Parser\pgenmain.c Parser\printgrammar.c Parser\tokenizer_pgen.c Parser\intrcheck.c	
	
	cd ..

openssl-$(OPENSSL_V)\stamp: openssl-$(OPENSSL_V).tar.gz
	@echo Unpacking OpenSSL $(OPENSSL_V)
	7za x -y openssl-$(OPENSSL_V).tar.gz >nul:
	7za x -y openssl-$(OPENSSL_V).tar >nul:
	del openssl-$(OPENSSL_V).tar
	echo>$@

openssl-$(OPENSSL_V)/out32/libeay32.lib: openssl-$(OPENSSL_V)\stamp
	cd openssl-$(OPENSSL_V)
	perl Configure VC-WIN32
	ms\do_nasm
	nmake -f ms\nt.mak
	cd ..

Python-$(PYTHON_V)/PCbuild/pythonembed.lib: Python-$(PYTHON_V)\stamp openssl-$(OPENSSL_V)/out32/libeay32.lib
	cd Python-$(PYTHON_V)\PCbuild
	cd
	copy ..\..\python.vcxproj.tpl python.vcxproj
	msbuild /m:$(NUMBER_OF_PROCESSORS) python.vcxproj "/p:OPENSSL_V=$(OPENSSL_V);Configuration=Debug"
	msbuild /m:$(NUMBER_OF_PROCESSORS) python.vcxproj "/p:OPENSSL_V=$(OPENSSL_V);Configuration=Release"	
  cd ..\..\

dist: Python-$(PYTHON_V)/PCbuild/pythonembed.lib
  -rd /s /q dist
	mkdir dist
	copy Python-$(PYTHON_V)\PCbuild\pythonembed.lib dist
	copy Python-$(PYTHON_V)\PCbuild\pythonembed_d.lib dist
	copy Python-$(PYTHON_V)\PCbuild\pythonembed.pdb dist
	copy openssl-$(OPENSSL_V)\out32\libeay32.lib dist
	copy openssl-$(OPENSSL_V)\out32\ssleay32.lib dist
	copy openssl-$(OPENSSL_V)\tmp32\lib.pdb dist
	mkdir dist\include
	copy Python-$(PYTHON_V)\PC\pyconfig.h dist\include
	copy Python-$(PYTHON_V)\Include\*.h dist\include
	xcopy /S openssl-$(OPENSSL_V)\include dist\include
  xcopy /SI Python-$(PYTHON_V)\Lib dist\python-lib
  
# Cleans up the library a bit
  cd dist\python-lib
  rd /s /q test
  rd /s /q plat-aix3
  rd /s /q plat-aix4
  rd /s /q plat-atheos
  rd /s /q plat-beos5
  rd /s /q plat-darwin
  rd /s /q plat-freebsd4
  rd /s /q plat-freebsd5
  rd /s /q plat-freebsd6
  rd /s /q plat-freebsd7
  rd /s /q plat-freebsd8
  rd /s /q plat-generic
  rd /s /q plat-irix5
  rd /s /q plat-irix6
  rd /s /q plat-linux2
  rd /s /q plat-mac
  rd /s /q plat-netbsd1
  rd /s /q plat-next3
  rd /s /q plat-os2emx
  rd /s /q plat-riscos
  rd /s /q plat-sunos5
  rd /s /q plat-unixware7
  rd /s /q multiprocessing
  rd /s /q idlelib
  rd /s /q lib2to3
  rd /s /q lib-tk
  rd /s /q email
  rd /s /q curses
  rd /s /q bsddb
  rd /s /q ensurepip
  rd /s /q distutils
  rd /s /q msilib
  rd /s /q pydoc_data
  rd /s /q sqlite3  
  rd /s /q unittest  
  rd /s /q wsgiref  
  cd ..\..\

pythonstatic.7z: dist
  cd dist
  7z a ..\pythonstatic.7z *
  cd ..\
