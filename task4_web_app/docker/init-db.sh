#!/bin/bash

# Скрипт инициализации базы данных для Docker
# Ждем, пока SQL Server будет готов

echo "Waiting for SQL Server to start..."
sleep 30

# Проверяем доступность SQL Server
until /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -Q "SELECT 1" &> /dev/null
do
  echo "SQL Server is not ready yet..."
  sleep 5
done

echo "SQL Server is ready!"

# Создаем базу данных
echo "Creating database..."
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -i /docker-entrypoint-initdb.d/tourism_db.sql

if [ $? -eq 0 ]; then
    echo "Database created successfully!"
else
    echo "Error creating database!"
    exit 1
fi

# Проверяем созданные таблицы
echo "Checking created tables..."
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -Q "USE TourismDB; SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';"

echo "Database initialization completed!"
