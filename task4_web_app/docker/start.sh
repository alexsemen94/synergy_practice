#!/bin/bash

# Скрипт запуска Tourism System через Docker Compose

echo "🚀 Запуск Tourism System..."
echo "================================"

# Проверяем наличие Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен. Установите Docker Desktop для Windows."
    exit 1
fi

# Проверяем наличие Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose не установлен. Установите Docker Compose."
    exit 1
fi

# Останавливаем существующие контейнеры
echo "🛑 Остановка существующих контейнеров..."
docker-compose down

# Удаляем старые образы (опционально)
read -p "Удалить старые образы? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️ Удаление старых образов..."
    docker-compose down --rmi all --volumes --remove-orphans
fi

# Собираем и запускаем проект
echo "🔨 Сборка и запуск проекта..."
docker-compose up --build -d

# Ждем запуска сервисов
echo "⏳ Ожидание запуска сервисов..."
sleep 30

# Проверяем статус сервисов
echo "📊 Статус сервисов:"
docker-compose ps

# Проверяем логи
echo "📋 Логи последних событий:"
docker-compose logs --tail=20

echo ""
echo "✅ Tourism System запущен!"
echo ""
echo "🌐 Веб-интерфейс: http://localhost"
echo "🔧 API Backend: http://localhost:8080"
echo "🗄️ База данных: localhost:1433"
echo "📊 Adminer: http://localhost:8081"
echo ""
echo "📝 Полезные команды:"
echo "  docker-compose logs -f [service]  - просмотр логов в реальном времени"
echo "  docker-compose exec [service] bash - вход в контейнер"
echo "  docker-compose down - остановка проекта"
echo "  docker-compose restart [service] - перезапуск сервиса"
echo ""
echo "🎯 Для тестирования откройте http://localhost в браузере"
