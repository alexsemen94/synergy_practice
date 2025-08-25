-- База данных "Туризм"
CREATE DATABASE IF NOT EXISTS tourism_db;
USE tourism_db;

CREATE TABLE countries (
    country_id INT PRIMARY KEY AUTO_INCREMENT,
    country_name VARCHAR(100) NOT NULL UNIQUE,
    country_code VARCHAR(3) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cities (
    city_id INT PRIMARY KEY AUTO_INCREMENT,
    city_name VARCHAR(100) NOT NULL,
    country_id INT NOT NULL,
    population INT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (country_id) REFERENCES countries(country_id) ON DELETE CASCADE
);

CREATE TABLE tour_types (
    tour_type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    average_duration_days INT,
    difficulty_level ENUM('Легкий', 'Средний', 'Сложный') DEFAULT 'Средний',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE services (
    service_id INT PRIMARY KEY AUTO_INCREMENT,
    service_name VARCHAR(200) NOT NULL,
    service_type ENUM('Транспорт', 'Проживание', 'Питание', 'Экскурсии', 'Страхование', 'Другое') NOT NULL,
    description TEXT,
    base_price DECIMAL(10,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tour_orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    client_name VARCHAR(200) NOT NULL,
    client_email VARCHAR(100) NOT NULL,
    client_phone VARCHAR(20),
    tour_type_id INT NOT NULL,
    destination_city_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    number_of_people INT NOT NULL DEFAULT 1,
    -- Детализация услуг прямо в таблице заказов
    transport_service_id INT,
    accommodation_service_id INT,
    food_service_id INT,
    excursion_service_id INT,
    insurance_service_id INT,
    -- Цены и количество для каждой услуги
    transport_price DECIMAL(10,2),
    accommodation_price DECIMAL(10,2),
    food_price DECIMAL(10,2),
    excursion_price DECIMAL(10,2),
    insurance_price DECIMAL(10,2),
    total_price DECIMAL(10,2) NOT NULL,
    order_status ENUM('Новый', 'Подтвержден', 'Оплачен', 'Выполнен', 'Отменен') DEFAULT 'Новый',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    -- Внешние ключи
    FOREIGN KEY (tour_type_id) REFERENCES tour_types(tour_type_id) ON DELETE RESTRICT,
    FOREIGN KEY (destination_city_id) REFERENCES cities(city_id) ON DELETE RESTRICT,
    FOREIGN KEY (transport_service_id) REFERENCES services(service_id) ON DELETE RESTRICT,
    FOREIGN KEY (accommodation_service_id) REFERENCES services(service_id) ON DELETE RESTRICT,
    FOREIGN KEY (food_service_id) REFERENCES services(service_id) ON DELETE RESTRICT,
    FOREIGN KEY (excursion_service_id) REFERENCES services(service_id) ON DELETE RESTRICT,
    FOREIGN KEY (insurance_service_id) REFERENCES services(service_id) ON DELETE RESTRICT
);

CREATE INDEX idx_cities_country ON cities(country_id);
CREATE INDEX idx_tour_orders_tour_type ON tour_orders(tour_type_id);
CREATE INDEX idx_tour_orders_destination ON tour_orders(destination_city_id);
CREATE INDEX idx_tour_orders_dates ON tour_orders(start_date, end_date);

INSERT INTO countries (country_name, country_code, description) VALUES
('Россия', 'RUS', 'Крупнейшая страна в мире с богатой культурой и историей'),
('Турция', 'TUR', 'Страна на стыке Европы и Азии с прекрасными курортами'),
('Италия', 'ITA', 'Страна искусства, архитектуры и кулинарных традиций'),
('Испания', 'ESP', 'Страна фламенко, корриды и средиземноморских пляжей'),
('Греция', 'GRC', 'Колыбель западной цивилизации с островами и античными руинами');

INSERT INTO cities (city_name, country_id, population, description) VALUES
('Москва', 1, 12506468, 'Столица России, культурный и экономический центр'),
('Санкт-Петербург', 1, 5371956, 'Культурная столица России, город музеев'),
('Анталья', 2, 1200000, 'Курортный город на Средиземном море'),
('Стамбул', 2, 15520000, 'Крупнейший город Турции, бывшая столица Византии'),
('Рим', 3, 4342212, 'Вечный город, столица Италии'),
('Венеция', 3, 261905, 'Город на воде, известный своими каналами'),
('Барселона', 4, 1620000, 'Столица Каталонии, город Гауди'),
('Афины', 5, 664046, 'Столица Греции, город с богатой историей');

INSERT INTO tour_types (type_name, description, average_duration_days, difficulty_level) VALUES
('Пляжный отдых', 'Отдых на море с проживанием в отеле', 7, 'Легкий'),
('Экскурсионный тур', 'Познавательные поездки по достопримечательностям', 5, 'Средний'),
('Горнолыжный тур', 'Активный отдых в горах', 7, 'Сложный'),
('Круиз', 'Морское путешествие с посещением портов', 10, 'Средний'),
('Экотуризм', 'Природные маршруты и экологические тропы', 3, 'Средний');

INSERT INTO services (service_name, service_type, description, base_price) VALUES
('Авиабилет эконом-класс', 'Транспорт', 'Перелет в эконом-классе', 15000.00),
('Авиабилет бизнес-класс', 'Транспорт', 'Перелет в бизнес-классе', 45000.00),
('Отель 3 звезды', 'Проживание', 'Проживание в отеле 3 звезды', 3000.00),
('Отель 4 звезды', 'Проживание', 'Проживание в отеле 4 звезды', 5000.00),
('Отель 5 звезд', 'Проживание', 'Проживание в отеле 5 звезд', 8000.00),
('Завтрак', 'Питание', 'Завтрак в отеле', 500.00),
('Полупансион', 'Питание', 'Завтрак и ужин', 1200.00),
('Полный пансион', 'Питание', 'Трехразовое питание', 1800.00),
('Экскурсия с гидом', 'Экскурсии', 'Обзорная экскурсия с профессиональным гидом', 2000.00),
('Страховка путешественника', 'Страхование', 'Медицинская страховка на время поездки', 800.00);

INSERT INTO tour_orders (
    client_name, client_email, client_phone, tour_type_id, destination_city_id, 
    start_date, end_date, number_of_people,
    transport_service_id, accommodation_service_id, food_service_id, excursion_service_id, insurance_service_id,
    transport_price, accommodation_price, food_price, excursion_price, insurance_price, total_price, order_status
) VALUES
('Иванов Иван', 'ivanov@email.com', '+7(999)123-45-67', 1, 3, '2024-07-15', '2024-07-22', 2,
 1, 3, 6, 9, 10,
 30000.00, 21000.00, 7000.00, 2000.00, 800.00, 60800.00, 'Подтвержден'),

('Петрова Анна', 'petrova@email.com', '+7(999)234-56-78', 2, 5, '2024-08-10', '2024-08-15', 1,
 1, 4, 7, 9, 10,
 15000.00, 25000.00, 6000.00, 2000.00, 800.00, 48800.00, 'Новый'),

('Сидоров Петр', 'sidorov@email.com', '+7(999)345-67-89', 3, 1, '2024-12-20', '2024-12-27', 3,
 2, 5, 8, 9, 10,
 135000.00, 56000.00, 37800.00, 6000.00, 2400.00, 235400.00, 'Оплачен');


/*
Структура базы данных "Туризм" (ИСПРАВЛЕННАЯ):

ТАБЛИЦЫ-СПРАВОЧНИКИ (4 таблицы):
1. countries - справочник стран
2. cities - справочник городов (связан с countries)
3. tour_types - справочник типов туров
4. services - справочник услуг

ТАБЛИЦА ПЕРЕМЕННОЙ ИНФОРМАЦИИ (1 таблица):
1. tour_orders - заказы туров с детализацией всех услуг

ИТОГО: 5 таблиц предметной области

ПЕРВИЧНЫЕ КЛЮЧИ:
- Все таблицы имеют первичные ключи (PRIMARY KEY)
- Используется автоинкремент для уникальности

ВНЕШНИЕ КЛЮЧИ:
- cities.country_id -> countries.country_id
- tour_orders.tour_type_id -> tour_types.tour_type_id
- tour_orders.destination_city_id -> cities.city_id
- tour_orders.*_service_id -> services.service_id (для каждой услуги)
*/
