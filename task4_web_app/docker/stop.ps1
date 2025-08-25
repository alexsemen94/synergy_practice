# PowerShell скрипт остановки Tourism System

Write-Host "🛑 Остановка Tourism System..." -ForegroundColor Red
Write-Host "================================" -ForegroundColor Red

# Останавливаем все сервисы
Write-Host "⏹️ Остановка сервисов..." -ForegroundColor Yellow
docker-compose down

# Показываем статус
Write-Host "📊 Статус контейнеров:" -ForegroundColor Cyan
docker ps -a | Select-String "tourism"

Write-Host ""
Write-Host "✅ Tourism System остановлен!" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Для полной очистки используйте:" -ForegroundColor Cyan
Write-Host "  docker-compose down --volumes --remove-orphans" -ForegroundColor Gray
Write-Host "  docker system prune -f" -ForegroundColor Gray
