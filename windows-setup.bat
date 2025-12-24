@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo        EP Notes Installer (Windows)
echo ==========================================
echo.

:: Check if g++ is available
where g++ >nul 2>nul
if %errorlevel% neq 0 (
    echo [X] Error: g++ not found!
    echo Please install MinGW or similar C++ compiler
    pause
    exit /b 1
)

echo [*] Building EP Notes...
g++ -std=c++17 src\epnotes.cpp -o epnotes.exe -lpdcurses
if %errorlevel% neq 0 (
    echo [X] Build failed!
    pause
    exit /b 1
)
echo [√] Build successful

:: Create bin directory if it doesn't exist
if not exist "%USERPROFILE%\bin" (
    echo [*] Creating bin directory...
    mkdir "%USERPROFILE%\bin"
)

:: Copy binary
echo [*] Installing binary...
copy /Y epnotes.exe "%USERPROFILE%\bin\" >nul
echo [√] Binary installed to %USERPROFILE%\bin\epnotes.exe

:: Check if bin is in PATH
echo %PATH% | find /i "%USERPROFILE%\bin" >nul
if %errorlevel% neq 0 (
    echo.
    echo [!] Warning: %USERPROFILE%\bin is not in your PATH
    echo [!] Add it to PATH to run epnotes from anywhere
    echo.
    echo To add to PATH:
    echo 1. Open System Properties ^> Environment Variables
    echo 2. Add %USERPROFILE%\bin to your PATH variable
    echo.
)

echo.
echo ==========================================
echo [√] EP Notes installed successfully!
echo ==========================================
echo.
echo Run 'epnotes.exe file.epnotes' to start
echo.
pause
