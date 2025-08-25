# Docker для Tourism System

Этот раздел содержит все необходимые файлы для запуска Tourism System в Docker контейнерах.

## 🐳 Структура Docker

```
docker/
├── Dockerfile.delphi      # Образ для Delphi backend
├── Dockerfile.web         # Образ для веб-интерфейса
├── docker-compose.yml     # Оркестрация всех сервисов
├── nginx.conf            # Конфигурация Nginx
├── init-db.sh            # Скрипт инициализации БД
├── start.sh              # Скрипт запуска (Linux/Mac)
├── stop.sh               # Скрипт остановки (Linux/Mac)
├── start.ps1             # Скрипт запуска (Windows)
├── stop.ps1              # Скрипт остановки (Windows)
└── README.md             # Этот файл
```

## 🚀 Быстрый запуск

### Windows (PowerShell)
```powershell
# Запуск
.\docker\start.ps1

# Остановка
.\docker\stop.ps1
```

### Linux/Mac (Bash)
```bash
# Запуск
chmod +x docker/start.sh
./docker/start.sh

# Остановка
chmod +x docker/stop.sh
./docker/stop.sh
```

### Ручной запуск
```bash
# Сборка и запуск
docker-compose up --build -d

# Просмотр логов
docker-compose logs -f

# Остановка
docker-compose down
```

## 🏗️ Архитектура Docker

### Сервисы

1. **db** - MS SQL Server 2019
   - Порт: 1433
   - База данных: TourismDB
   - Пользователь: sa
   - Пароль: YourStrong@Passw0rd

2. **delphi** - Delphi Web Application Backend
   - Порт: 8080
   - API endpoints для туров, клиентов, бронирований
   - Подключение к MS SQL Server

3. **web** - Nginx веб-сервер
   - Порт: 80
   - Статические файлы фронтенда
   - Проксирование API запросов к Delphi backend

4. **redis** - Кэш-сервер (опционально)
   - Порт: 6379
   - Ускорение работы приложения

5. **adminer** - Веб-интерфейс для управления БД
   - Порт: 8081
   - Администрирование MS SQL Server

## 🔧 Конфигурация

### Переменные окружения
- `DB_CONNECTION_STRING` - строка подключения к БД
- `ASPNETCORE_URLS` - URL для Delphi backend
- `ASPNETCORE_ENVIRONMENT` - окружение (Production/Development)

### Порты
- **80** - Веб-интерфейс
- **8080** - API Backend
- **1433** - MS SQL Server
- **6379** - Redis
- **8081** - Adminer

## 📊 Мониторинг

### Проверка здоровья сервисов
```bash
# Статус всех сервисов
docker-compose ps

# Логи конкретного сервиса
docker-compose logs -f delphi
docker-compose logs -f web
docker-compose logs -f db

# Проверка здоровья
docker-compose exec delphi curl -f http://localhost:8080/api/tours
docker-compose exec web curl -f http://localhost/
```

### Метрики
- Health checks для всех сервисов
- Автоматический перезапуск при сбоях
- Логирование в реальном времени

## 🛠️ Разработка

### Вход в контейнер
```bash
# Delphi backend
docker-compose exec delphi bash

# Веб-сервер
docker-compose exec web sh

# База данных
docker-compose exec db bash
```

### Обновление кода
```bash
# Пересборка конкретного сервиса
docker-compose build delphi
docker-compose up -d delphi

# Пересборка всех сервисов
docker-compose up --build -d
```

## 🔒 Безопасность

- Изолированные сети для сервисов
- Непривилегированные пользователи в контейнерах
- Проверка здоровья сервисов
- Логирование всех запросов

## 📝 Логирование

### Логи Nginx
- Access logs: `/var/log/nginx/access.log`
- Error logs: `/var/log/nginx/error.log`

### Логи Delphi
- Консольный вывод в Docker logs
- Структурированное логирование

### Логи MS SQL Server
- Системные логи в контейнере
- Транзакционные логи

## 🚨 Устранение неполадок

### Частые проблемы

1. **Порт уже занят**
   ```bash
   # Проверка занятых портов
   netstat -an | findstr :80
   netstat -an | findstr :8080
   ```

2. **База данных не запускается**
   ```bash
   # Проверка логов БД
   docker-compose logs db
   
   # Проверка доступности
   docker-compose exec db /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -Q "SELECT 1"
   ```

3. **Delphi backend не отвечает**
   ```bash
   # Проверка логов
   docker-compose logs delphi
   
   # Проверка подключения к БД
   docker-compose exec delphi env | grep DB_CONNECTION_STRING
   ```

### Очистка
```bash
# Полная очистка
docker-compose down --volumes --remove-orphans
docker system prune -f
docker volume prune -f
```

## 📚 Полезные команды

```bash
# Просмотр использования ресурсов
docker stats

# Просмотр образов
docker images

# Просмотр томов
docker volume ls

# Просмотр сетей
docker network ls

# Очистка неиспользуемых ресурсов
docker system prune -a
```

## 🔄 Обновления

### Обновление образов
```bash
# Обновление всех образов
docker-compose pull

# Перезапуск с новыми образами
docker-compose up -d
```

### Обновление конфигурации
```bash
# Пересборка с новой конфигурацией
docker-compose up --build -d
```

## 📞 Поддержка

При возникновении проблем:
1. Проверьте логи: `docker-compose logs`
2. Убедитесь, что все порты свободны
3. Проверьте версии Docker и Docker Compose
4. Обратитесь к документации проекта
