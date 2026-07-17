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

pushd tk%PKG_VERSION%\win
nmake -f makefile.vc INSTALLDIR=%LIBRARY_PREFIX% %TCLSH_NATIVE% MACHINE=%MACHINE% TCLDIR=..\..\tcl%PKG_VERSION% install
if %ERRORLEVEL% GTR 0 exit 1
popd

set VERSION_NODOT=%PKG_VERSION:.=%
set MAJ_MIN=%VERSION_NODOT:~0,2%

:: Make sure that `wish` can be called without the version info.
copy %LIBRARY_PREFIX%\bin\wish%MAJ_MIN%.exe %LIBRARY_PREFIX%\bin\wish.exe
if %ERRORLEVEL% GTR 0 exit 1
