Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   Iniciando Autos Colombia (Backend + Frontend)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

$baseDir = $PSScriptRoot

Write-Host "1. Levantando Backend FastAPI en http://127.0.0.1:8000..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location '$baseDir\AutosColombia\backend'; .\.venv\Scripts\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload"

Write-Host "2. Levantando Frontend Angular en http://127.0.0.1:4200..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location '$baseDir\AutosColombia\frontend'; npm start -- --host 127.0.0.1 --port 4200 -o"

Write-Host "`nServicios lanzados en ventanas independientes:" -ForegroundColor Green
Write-Host " - Backend API:  http://127.0.0.1:8000" -ForegroundColor Gray
Write-Host " - Swagger Docs: http://127.0.0.1:8000/docs" -ForegroundColor Gray
Write-Host " - Frontend:     http://127.0.0.1:4200" -ForegroundColor Gray
Write-Host "`n[Angular abrira la pagina en tu navegador automaticamente al compilar]" -ForegroundColor Cyan
