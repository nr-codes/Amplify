@echo off

start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"

echo Waiting for Docker Desktop to become ready...
:waitloop
docker version >nul 2>&1
if errorlevel 1 (
  timeout /t 2 >nul
  goto waitloop
)
echo Docker is ready!

wsl bash ./docker_local_bash.sh %*
