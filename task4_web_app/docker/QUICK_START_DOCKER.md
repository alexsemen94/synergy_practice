# 🚀 Быстрый запуск Tourism System в Docker

## 📋 Требования

- Docker Desktop для Windows
- Docker Compose
- Минимум 4GB RAM
- 10GB свободного места на диске

## ⚡ 5-минутный запуск

### 1. Клонирование и переход в директорию
```bash
cd task4_web_app
```

### 2. Запуск через PowerShell (Windows)
```powershell
# Запуск
.\docker\start.ps1

# Или вручную
docker-compose up --build -d
```

### 3. Запуск через Bash (Linux/Mac)
```bash
# Сделать скрипты исполняемыми
chmod +x docker/*.sh

# Запуск
./docker/start.sh

# Или вручную
docker-compose up --build -d
```

### 4. Проверка статуса
```bash
docker-compose ps
```

### 5. Открытие в браузере
- **Веб-интерфейс**: http://localhost
- **API Backend**: http://localhost:8080
- **Adminer**: http://localhost:8081

## 🔍 Проверка работы

### Тестирование через скрипт
```bash
# Windows
.\docker\test-docker.ps1

# Linux/Mac
./docker/test-docker.sh
```

### Ручное тестирование
```bash
# Статус сервисов
docker-compose ps

# Логи
docker-compose logs -f

# Тест API
curl http://localhost:8080/api/tours
```

## 🛑 Остановка

### Windows
```powershell
.\docker\stop.ps1
```

### Linux/Mac
```bash
./docker/stop.sh
```

### Ручная остановка
```bash
docker-compose down
```

## 🚨 Устранение проблем

### Порт занят
```bash
# Проверка занятых портов
netstat -an | findstr :80
netstat -an | findstr :8080

# Остановка служб IIS (если запущены)
net stop w3svc
```

### Недостаточно памяти
```bash
# Остановка неиспользуемых контейнеров
docker stop $(docker ps -q)

# Очистка
docker system prune -f
```

### База данных не запускается
```bash
# Проверка логов
docker-compose logs db

# Перезапуск
docker-compose restart db
```

## 📊 Мониторинг

### Ресурсы
```bash
# Использование ресурсов
docker stats

# Логи в реальном времени
docker-compose logs -f [service]
```

### Здоровье сервисов
```bash
# Проверка здоровья
docker-compose ps
```

## 🔧 Настройка

### Переменные окружения
1. Скопируйте `docker/env.example` в `docker/.env`
2. Отредактируйте значения под свои нужды
3. Перезапустите: `docker-compose down && docker-compose up -d`

### Изменение портов
Отредактируйте `docker/.env`:
```env
WEB_PORT=8080
DELPHI_PORT=9090
DB_PORT=1434
```

## 📚 Полезные команды

```bash
# Пересборка конкретного сервиса
docker-compose build web
docker-compose up -d web

# Просмотр логов
docker-compose logs -f delphi
docker-compose logs -f web
docker-compose logs -f db

# Вход в контейнер
docker-compose exec delphi bash
docker-compose exec web sh
docker-compose exec db bash

# Очистка
docker-compose down --volumes --remove-orphans
docker system prune -a
```

## 🎯 Готово!

После успешного запуска у вас будет:
- ✅ Веб-интерфейс на http://localhost
- ✅ Delphi API на http://localhost:8080
- ✅ MS SQL Server на localhost:1433
- ✅ Adminer на http://localhost:8081
- ✅ Redis на localhost:6379

Откройте http://localhost и наслаждайтесь работой с Tourism System! 🎉
