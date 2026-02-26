@echo off
setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
set CERTS_DIR=%SCRIPT_DIR%certs

if exist "%SCRIPT_DIR%..\..\.env" (
    for /f "usebackq tokens=1,* delims==" %%a in ("%SCRIPT_DIR%..\..\.env") do (
        set "line=%%a"
        if "!line:~0,1!" neq "#" (
            set "value=%%b"
            if defined value (
                set "value=!value:"=!"
                set "value=!value:'=!"
                set "%%a=!value!"
            )
        )
    )
)

if "%PROJECT_DOMAIN%"=="" set PROJECT_DOMAIN=myapp.test

if not exist "%CERTS_DIR%" mkdir "%CERTS_DIR%"

where openssl >nul 2>nul
if %errorlevel% neq 0 (
    echo OpenSSL is not installed or not in PATH.
    echo.
    echo On Windows, you can install OpenSSL via:
    echo   - Git for Windows ^(includes OpenSSL^)
    echo   - Win32OpenSSL: https://slproweb.com/products/Win32OpenSSL.html
    echo   - Chocolatey: choco install openssl
    exit /b 1
)

openssl req -x509 -nodes -days 365 -newkey rsa:2048 ^
    -keyout "%CERTS_DIR%\%PROJECT_DOMAIN%.key" ^
    -out "%CERTS_DIR%\%PROJECT_DOMAIN%.crt" ^
    -subj "/C=US/ST=State/L=City/O=Organization/CN=%PROJECT_DOMAIN%"

if %errorlevel% neq 0 (
    echo Failed to generate certificates.
    exit /b 1
)

copy /Y "%CERTS_DIR%\%PROJECT_DOMAIN%.crt" "%CERTS_DIR%\server.crt" >nul
copy /Y "%CERTS_DIR%\%PROJECT_DOMAIN%.key" "%CERTS_DIR%\server.key" >nul

echo.
echo SSL certificates generated in %CERTS_DIR%
echo   - %PROJECT_DOMAIN%.crt
echo   - %PROJECT_DOMAIN%.key
echo.
echo To trust the certificate on Windows, run PowerShell as Administrator:
echo Import-Certificate -FilePath '%CERTS_DIR%\%PROJECT_DOMAIN%.crt' -CertStoreLocation Cert:\LocalMachine\Root

endlocal
