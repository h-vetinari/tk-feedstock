@echo ON
setlocal EnableDelayedExpansion

if "%target_platform%"=="win-64" (
  set MACHINE="AMD64"
)
if "%target_platform%"=="win-arm64" (
  set MACHINE="ARM64"
)

if "%build_platform%"=="win-64" (
  set BUILD_MACHINE="AMD64"
)
if "%build_platform%"=="win-arm64" (
  set BUILD_MACHINE="ARM64"
)

if NOT "%target_platform%"=="%build_platform%" (
  set "TCLSH_NATIVE=TCLSH_NATIVE=%BUILD_PREFIX%\Library\bin\tclsh86.exe"
)

rmdir /s /q "tcl%PKG_VERSION%\pkgs"

pushd tcl%PKG_VERSION%\win
setlocal EnableDelayedExpansion
  if NOT "%target_platform%"=="%build_platform%" (
    set "CC=%CC_FOR_BUILD%"
    set "CXX=%CXX_FOR_BUILD%"
    set "LIB=%LIB_FOR_BUILD%"
    set "INCLUDE=%INCLUDE_FOR_BUILD%"
  )
  %CC% nmakehlp.c
  nmakehlp.exe --help
  REM for /r "%SRC_DIR%\tcl%PKG_VERSION%\pkgs" %%d in (.) do (
  REM   if exist "%%d\nmakehlp.c" (
  REM     pushd "%%d"
  REM       %CC% nmakehlp.c
  REM       nmakehlp.exe --help
  REM     popd
  REM   )
  REM )
endlocal
nmake -f makefile.vc INSTALLDIR=%LIBRARY_PREFIX% %TCLSH_NATIVE% MACHINE=%MACHINE% release
if %ERRORLEVEL% GTR 0 exit 1
nmake -f makefile.vc INSTALLDIR=%LIBRARY_PREFIX% %TCLSH_NATIVE% MACHINE=%MACHINE% install install-libraries
if %ERRORLEVEL% GTR 0 exit 1
popd

:: Tk build

pushd tk%PKG_VERSION%\win
setlocal EnableDelayedExpansion
  if NOT "%target_platform%"=="%build_platform%" (
    set "CC=%CC_FOR_BUILD%"
    set "CXX=%CXX_FOR_BUILD%"
    set "LIB=%LIB_FOR_BUILD%"
    set "INCLUDE=%INCLUDE_FOR_BUILD%"
  )
  %CC% nmakehlp.c
  nmakehlp.exe --help
endlocal
nmake -f makefile.vc INSTALLDIR=%LIBRARY_PREFIX% %TCLSH_NATIVE% MACHINE=%MACHINE% TCLDIR=..\..\tcl%PKG_VERSION% release
if %ERRORLEVEL% GTR 0 exit 1
nmake -f makefile.vc INSTALLDIR=%LIBRARY_PREFIX% %TCLSH_NATIVE% MACHINE=%MACHINE% TCLDIR=..\..\tcl%PKG_VERSION% install
if %ERRORLEVEL% GTR 0 exit 1

set VERSION_NODOT=%PKG_VERSION:.=%
set MAJ_MIN=%VERSION_NODOT:~0,2%

:: Make sure that `tclsh` can be called without the version info.
copy %LIBRARY_PREFIX%\bin\tclsh%MAJ_MIN%.exe %LIBRARY_PREFIX%\bin\tclsh.exe
if %ERRORLEVEL% GTR 0 exit 1
copy %LIBRARY_PREFIX%\bin\wish%MAJ_MIN%.exe %LIBRARY_PREFIX%\bin\wish.exe
if %ERRORLEVEL% GTR 0 exit 1
popd

dir /s %LIBRARY_PREFIX%\lib
dir /s %LIBRARY_PREFIX%\bin
