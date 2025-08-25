#!/bin/bash

# Скрипт тестирования Docker окружения Tourism System

echo "🧪 Тестирование Docker окружения..."
echo "=================================="

# Проверяем статус сервисов
echo "📊 Проверка статуса сервисов..."
docker-compose ps

# Проверяем логи
echo ""
echo "📋 Последние логи:"
docker-compose logs --tail=10

# Тестируем веб-интерфейс
echo ""
echo "🌐 Тестирование веб-интерфейса..."
if curl -f http://localhost/ > /dev/null 2>&1; then
    echo "✅ Веб-интерфейс доступен"
else
    echo "❌ Веб-интерфейс недоступен"
fi

# Тестируем API backend
echo ""
echo "🔧 Тестирование API backend..."
if curl -f http://localhost:8080/api/tours > /dev/null 2>&1; then
    echo "✅ API backend доступен"
else
    echo "❌ API backend недоступен"
fi

# Тестируем базу данных
echo ""
echo "🗄️ Тестирование базы данных..."
if docker-compose exec db /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -Q "SELECT 1" > /dev/null 2>&1; then
    echo "✅ База данных доступна"
else
    echo "❌ База данных недоступна"
fi

# Тестируем Adminer
echo ""
echo "📊 Тестирование Adminer..."
if curl -f http://localhost:8081/ > /dev/null 2>&1; then
    echo "✅ Adminer доступен"
else
    echo "❌ Adminer недоступен"
fi

# Проверяем использование ресурсов
echo ""
echo "📈 Использование ресурсов:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

echo ""
echo "🎯 Тестирование завершено!"
echo "Откройте http://localhost в браузере для проверки системы"
