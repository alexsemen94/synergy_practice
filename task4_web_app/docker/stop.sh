#!/bin/bash

# Скрипт остановки Tourism System

echo "🛑 Остановка Tourism System..."
echo "================================"

# Останавливаем все сервисы
echo "⏹️ Остановка сервисов..."
docker-compose down

# Показываем статус
echo "📊 Статус контейнеров:"
docker ps -a | grep tourism

echo ""
echo "✅ Tourism System остановлен!"
echo ""
echo "💡 Для полной очистки используйте:"
echo "  docker-compose down --volumes --remove-orphans"
echo "  docker system prune -f"
