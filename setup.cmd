@echo off
setlocal enableextensions enabledelayedexpansion

echo Chocolatey...
call:InstallChocolatey
for /f "delims=" %%a in (chocolatey.txt) do (
    call:InstallWithChocolatey %%a
)

set DEPENDENCY_SETUP_RESULT=%errorlevel%
echo Done.
exit /b %DEPENDENCY_SETUP_RESULT%

:InstallWithChocolatey
    call:IsAlreadyInstalledByChocolatey %1.%2
    if errorlevel 1 (
        :: Package not installed... Install it...
        if "%2"=="" (
            echo     Installing %1...
            chocolatey install %1 -force
        ) else (
            echo     Installing %1 %2...
            chocolatey install %1 -version %2 -force
        )
    ) else (
        echo     %1 already installed.
    )

    exit /b 0


:IsAlreadyInstalledByChocolatey
    dir %sytemdrive%\Chocolatey\lib | find /i "%1" > nul
    if errorlevel 1 (
        exit /b 1
    )

    exit /b 0


:InstallChocolatey
    call:IsInPath chocolatey.bat
    if errorlevel 1 (
        :: Chocolatey was not found in the path.
        call:IsLocatedAt chocolatey.bat %sytemdrive%\Chocolatey\bin
        if errorlevel 1 (
            :: Chocolatey was not found in the default install path.
            echo     Installing Chocolatey...
            powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=!PATH!;!systemdrive!\chocolatey\bin
            if errorlevel 1 (
                exit /b 1
            )
        ) else (
            :: Found Chocolatey, but it's not in the path?
            set path=!path!;!systemdrive!\chocolatey\bin
            echo     Warning: Automatically detected and added Chocolatey to the system path.
            echo     Permanently add it to your system path to remove this warning.
            echo.
        )
    ) else (
        echo     Chocolatey already installed.
    )

    exit /b 0

:IsInPath
    if "%~$path:1"=="" (
        exit /b 1
    )

    exit /b 0

:IsLocatedAt
    if not exist %2\%1 (
        exit /b 1
    )

    echo %2\%1 found.
    exit /b 0
