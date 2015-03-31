ECHO ON
REM ----------------------------------------------------------
REM  PREPARE
REM ----------------------------------------------------------
CALL git submodule update --init --recursive

CALL SETENV.BAT

mkdir build_oce
cd build_oce

REM set GENERATOR=Visual Studio 11 2012
REM set VisualStudioVersion=11.0
set GENERATOR=Visual Studio 10 2010
set VisualStudioVersion=10.0
'"%VS100COMNTOOLS%\..\..\VC\vcvarsall.bat" x86'
ECHO PREFIX = "%PREFIX%"
ECHO CL     = "%CL%"
ECHO LINK   = "%LINK%"
ECHO PATH   = "%PATH%"

CALL cmake -DOCE_INSTALL_PREFIX:STRING="%PREFIX%" ^
-DCMAKE_SUPPRESS_REGENERATION:BOOL=ON  ^
-DOCE_MULTITHREADED_BUILD:BOOL=ON ^
-DBUILD_SHARED_LIBS:BOOL=OFF ^
-DBUILD_TESTING:BOOLEAN=OFF ^
-DOCE_DRAW:BOOLEAN=OFF ^
-DOCE_TESTING:BOOLEAN=OFF ^
-DOCE_OCAF:BOOLEAN=OFF ^
-DOCE_VISUALISATION:BOOLEAN=OFF ^
-DOCE_DISABLE_X11:BOOLEAN=ON ^
-DOCE_DISABLE_TKSERVICE_FONT:BOOLEAN=ON ^
-DOCE_USE_PCH:BOOLEAN=ON  ^
-G "%GENERATOR%" ../oce   > nul


REM msbuild /m oce.sln
CALL msbuild /m oce.sln /p:Configuration=Release > nul

CALL msbuild INSTALL.vcxproj /p:Configuration=Release > nul
ECHO PREFIX = %PREFIX%
ECHO PREFIX = %GENERATOR%
cd ..

REM ----------------------------------------------------------
REM  BUILD
REM ----------------------------------------------------------
CALL npm install

REM ----------------------------------------------------------
REM  TEST
REM ----------------------------------------------------------
CALL npm test

REM ----------------------------------------------------------
REM  PACKAGE
REM ----------------------------------------------------------
SET SRC=%PREFIX%/Win32/bin
SET SRC=%SRC:/=\%
XCOPY %SRC%\*.dll .\build\Release
SET PACKAGE=node-occ-package.zip
7z a %PACKAGE% .\build\Release\*.*
appveyor PushArtifact %PACKAGE%
