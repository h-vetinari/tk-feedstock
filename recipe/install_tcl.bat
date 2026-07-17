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
  for /r "%SRC_DIR%\tcl%PKG_VERSION%\pkgs" %%d in (.) do (
    if exist "%%d\nmakehlp.c" (
      pushd "%%d"
        %CC% nmakehlp.c
        nmakehlp.exe --help
      popd
    )
  )
endlocal
nmake -f makefile.vc INSTALLDIR=%LIBRARY_PREFIX% %TCLSH_NATIVE% MACHINE=%MACHINE% install
if %ERRORLEVEL% GTR 0 exit 1
popd

set VERSION_NODOT=%PKG_VERSION:.=%
set MAJ_MIN=%VERSION_NODOT:~0,2%

:: Make sure that `tclsh` can be called without the version info.
copy %LIBRARY_PREFIX%\bin\tclsh%MAJ_MIN%.exe %LIBRARY_PREFIX%\bin\tclsh.exe
if %ERRORLEVEL% GTR 0 exit 1
