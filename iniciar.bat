@echo off
title Lanzador Autos Colombia
echo ========================================================
echo   Iniciando Autos Colombia (Backend + Frontend)
echo ========================================================

set "BASE_DIR=%~dp0"

echo 1. Levantando Backend FastAPI en http://127.0.0.1:8000...
start "Backend - Autos Colombia (Puerto 8000)" cmd /k "cd /d "%BASE_DIR%AutosColombia\backend" && .\.venv\Scripts\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload"

echo 2. Levantando Frontend Angular en http://127.0.0.1:4200...
start "Frontend - Autos Colombia (Puerto 4200)" cmd /k "cd /d "%BASE_DIR%AutosColombia\frontend" && npm start -- --host 127.0.0.1 --port 4200 -o"

echo.
echo ========================================================
echo Ambos servicios fueron lanzados en ventanas dedicadas.
echo.
echo - Angular abrira la pagina en tu navegador automaticamente al compilar.
echo - Backend API:  http://127.0.0.1:8000
echo - Swagger Docs: http://127.0.0.1:8000/docs
echo - Frontend:     http://127.0.0.1:4200
echo.
echo [No cierres las ventanas negras de consola mientras uses la app]
echo ========================================================
pause
