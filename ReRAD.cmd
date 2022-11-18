@echo off
setlocal enabledelayedexpansion

@for %%f in ("%1") do set bsppath=%%~dpnf
@for %%f in ("%1") do set bspname=%%~nf

TITLE ReRAD
ECHO ReRAD
ECHO bsp RAD recompiler
ECHO Redo lighting for your compiled bsp
ECHO This may corrupt your bsp, so ensure you make a backup first!
ECHO.
ECHO Usage: modify your bsp's point lights/texlights using Ripent or a tool such as bspguy
ECHO.
ECHO Searching for game folder, this may take a while...

for /f tokens^=1*delims^=: %%i in ('
fsutil fsinfo drives')do set "_drvs=%%~j"

for /f tokens^=*^delims^=? %%i in ('
call dir/b/a-d/s %_drvs:\=\svencoop1.wad% 2^>nul 
')do set "_fpath=%%~dpi" && set "_file=%%~fi" && goto %:^)

%:^)

set wadfolder=!_fpath!
IF %wadfolder:~-1%==\ SET wadfolder=%wadfolder:~0,-1%

ECHO Selected bsp "%bspname%"
if [%bsppath%]==[] set /p bsppath=Set the path to your BSP: 

set /p radparams=Set your optional RAD parameters:

SC-RAD_x64.exe %bsppath% -waddir "%wadfolder%" %radparams%

ECHO Done. Check %bsppath%.log for errors.
pause