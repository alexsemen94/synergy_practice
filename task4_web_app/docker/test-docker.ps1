# PowerShell скрипт тестирования Docker окружения Tourism System

Write-Host "🧪 Тестирование Docker окружения..." -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

# Проверяем статус сервисов
Write-Host "📊 Проверка статуса сервисов..." -ForegroundColor Yellow
docker-compose ps

# Проверяем логи
Write-Host ""
Write-Host "📋 Последние логи:" -ForegroundColor Yellow
docker-compose logs --tail=10

# Тестируем веб-интерфейс
Write-Host ""
Write-Host "🌐 Тестирование веб-интерфейса..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost" -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Веб-интерфейс доступен" -ForegroundColor Green
    } else {
        Write-Host "❌ Веб-интерфейс недоступен (код: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Веб-интерфейс недоступен: $($_.Exception.Message)" -ForegroundColor Red
}

# Тестируем API backend
Write-Host ""
Write-Host "🔧 Тестирование API backend..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/tours" -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ API backend доступен" -ForegroundColor Green
    } else {
        Write-Host "❌ API backend недоступен (код: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ API backend недоступен: $($_.Exception.Message)" -ForegroundColor Red
}

# Тестируем базу данных
Write-Host ""
Write-Host "🗄️ Тестирование базы данных..." -ForegroundColor Yellow
try {
    $result = docker-compose exec db /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -Q "SELECT 1" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ База данных доступна" -ForegroundColor Green
    } else {
        Write-Host "❌ База данных недоступна" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ База данных недоступна: $($_.Exception.Message)" -ForegroundColor Red
}

# Тестируем Adminer
Write-Host ""
Write-Host "📊 Тестирование Adminer..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8081/" -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Adminer доступен" -ForegroundColor Green
    } else {
        Write-Host "❌ Adminer недоступен (код: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Adminer недоступен: $($_.Exception.Message)" -ForegroundColor Red
}

# Проверяем использование ресурсов
Write-Host ""
Write-Host "📈 Использование ресурсов:" -ForegroundColor Yellow
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

Write-Host ""
Write-Host "🎯 Тестирование завершено!" -ForegroundColor Green
Write-Host "Откройте http://localhost в браузере для проверки системы" -ForegroundColor Yellow

# Открываем браузер
$openBrowser = Read-Host "Открыть браузер для тестирования? (Y/n)"
if ($openBrowser -ne "n" -and $openBrowser -ne "N") {
    Start-Process "http://localhost"
}
