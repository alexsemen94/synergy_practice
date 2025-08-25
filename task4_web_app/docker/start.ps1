# PowerShell скрипт запуска Tourism System через Docker Compose

Write-Host "🚀 Запуск Tourism System..." -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

# Проверяем наличие Docker
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker найден: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker не установлен. Установите Docker Desktop для Windows." -ForegroundColor Red
    exit 1
}

# Проверяем наличие Docker Compose
try {
    $composeVersion = docker-compose --version
    Write-Host "✅ Docker Compose найден: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Compose не установлен. Установите Docker Compose." -ForegroundColor Red
    exit 1
}

# Останавливаем существующие контейнеры
Write-Host "🛑 Остановка существующих контейнеров..." -ForegroundColor Yellow
docker-compose down

# Удаляем старые образы (опционально)
$removeImages = Read-Host "Удалить старые образы? (y/N)"
if ($removeImages -eq "y" -or $removeImages -eq "Y") {
    Write-Host "🗑️ Удаление старых образов..." -ForegroundColor Yellow
    docker-compose down --rmi all --volumes --remove-orphans
}

# Собираем и запускаем проект
Write-Host "🔨 Сборка и запуск проекта..." -ForegroundColor Yellow
docker-compose up --build -d

# Ждем запуска сервисов
Write-Host "⏳ Ожидание запуска сервисов..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Проверяем статус сервисов
Write-Host "📊 Статус сервисов:" -ForegroundColor Cyan
docker-compose ps

# Проверяем логи
Write-Host "📋 Логи последних событий:" -ForegroundColor Cyan
docker-compose logs --tail=20

Write-Host ""
Write-Host "✅ Tourism System запущен!" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Веб-интерфейс: http://localhost" -ForegroundColor White
Write-Host "🔧 API Backend: http://localhost:8080" -ForegroundColor White
Write-Host "🗄️ База данных: localhost:1433" -ForegroundColor White
Write-Host "📊 Adminer: http://localhost:8081" -ForegroundColor White
Write-Host ""
Write-Host "📝 Полезные команды:" -ForegroundColor Cyan
Write-Host "  docker-compose logs -f [service]  - просмотр логов в реальном времени" -ForegroundColor Gray
Write-Host "  docker-compose exec [service] bash - вход в контейнер" -ForegroundColor Gray
Write-Host "  docker-compose down - остановка проекта" -ForegroundColor Gray
Write-Host "  docker-compose restart [service] - перезапуск сервиса" -ForegroundColor Gray
Write-Host ""
Write-Host "🎯 Для тестирования откройте http://localhost в браузере" -ForegroundColor Yellow

# Открываем браузер
$openBrowser = Read-Host "Открыть браузер? (Y/n)"
if ($openBrowser -ne "n" -and $openBrowser -ne "N") {
    Start-Process "http://localhost"
}
