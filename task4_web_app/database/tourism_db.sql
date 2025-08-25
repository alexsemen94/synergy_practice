-- Создание базы данных для системы управления туристическими турами
-- MS SQL Server

USE master;
GO

-- Создание базы данных
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'TourismDB')
BEGIN
    CREATE DATABASE TourismDB;
END
GO

USE TourismDB;
GO

-- Создание таблицы стран
CREATE TABLE Countries (
    CountryID INT IDENTITY(1,1) PRIMARY KEY,
    CountryName NVARCHAR(100) NOT NULL,
    CountryCode NVARCHAR(3) NOT NULL,
    Description NVARCHAR(500)
);

-- Создание таблицы городов
CREATE TABLE Cities (
    CityID INT IDENTITY(1,1) PRIMARY KEY,
    CityName NVARCHAR(100) NOT NULL,
    CountryID INT FOREIGN KEY REFERENCES Countries(CountryID),
    Description NVARCHAR(500)
);

-- Создание таблицы отелей
CREATE TABLE Hotels (
    HotelID INT IDENTITY(1,1) PRIMARY KEY,
    HotelName NVARCHAR(200) NOT NULL,
    CityID INT FOREIGN KEY REFERENCES Cities(CityID),
    Stars INT CHECK (Stars >= 1 AND Stars <= 5),
    Address NVARCHAR(300),
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    Description NVARCHAR(1000)
);

-- Создание таблицы типов туров
CREATE TABLE TourTypes (
    TourTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500)
);

-- Создание таблицы туров
CREATE TABLE Tours (
    TourID INT IDENTITY(1,1) PRIMARY KEY,
    TourName NVARCHAR(200) NOT NULL,
    TourTypeID INT FOREIGN KEY REFERENCES TourTypes(TourTypeID),
    CountryID INT FOREIGN KEY REFERENCES Countries(CountryID),
    CityID INT FOREIGN KEY REFERENCES Cities(CityID),
    HotelID INT FOREIGN KEY REFERENCES Hotels(HotelID),
    Duration INT NOT NULL, -- количество дней
    Price DECIMAL(10,2) NOT NULL,
    StartDate DATE,
    EndDate DATE,
    MaxTourists INT DEFAULT 20,
    Description NVARCHAR(1000),
    IsActive BIT DEFAULT 1
);

-- Создание таблицы клиентов
CREATE TABLE Clients (
    ClientID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Phone NVARCHAR(20),
    PassportNumber NVARCHAR(20),
    BirthDate DATE,
    RegistrationDate DATETIME DEFAULT GETDATE()
);

-- Создание таблицы бронирований
CREATE TABLE Bookings (
    BookingID INT IDENTITY(1,1) PRIMARY KEY,
    TourID INT FOREIGN KEY REFERENCES Tours(TourID),
    ClientID INT FOREIGN KEY REFERENCES Clients(ClientID),
    BookingDate DATETIME DEFAULT GETDATE(),
    TouristsCount INT DEFAULT 1,
    TotalPrice DECIMAL(10,2),
    Status NVARCHAR(20) DEFAULT 'Confirmed', -- Confirmed, Cancelled, Completed
    Notes NVARCHAR(500)
);

-- Вставка тестовых данных
INSERT INTO Countries (CountryName, CountryCode, Description) VALUES
('Россия', 'RUS', 'Самая большая страна в мире'),
('Турция', 'TUR', 'Страна на стыке Европы и Азии'),
('Египет', 'EGY', 'Страна древних пирамид'),
('Испания', 'ESP', 'Страна фламенко и корриды'),
('Италия', 'ITA', 'Страна искусства и кухни');

INSERT INTO Cities (CityName, CountryID, Description) VALUES
('Москва', 1, 'Столица России'),
('Санкт-Петербург', 1, 'Культурная столица России'),
('Анталья', 2, 'Туристический центр Турции'),
('Хургада', 3, 'Курорт на Красном море'),
('Барселона', 4, 'Город Гауди и футбола'),
('Рим', 5, 'Вечный город');

INSERT INTO TourTypes (TypeName, Description) VALUES
('Пляжный отдых', 'Отдых на море с проживанием в отеле'),
('Экскурсионный тур', 'Познавательные поездки по достопримечательностям'),
('Горнолыжный тур', 'Отдых в горах с катанием на лыжах'),
('Лечебный тур', 'Оздоровительные программы и лечение'),
('Круиз', 'Морские путешествия на круизном лайнере');

INSERT INTO Hotels (HotelName, CityID, Stars, Address, Phone, Email, Description) VALUES
('Гранд Отель Москва', 1, 5, 'ул. Тверская, 1', '+7(495)123-45-67', 'info@grandhotel.ru', 'Роскошный отель в центре Москвы'),
('Отель Европа', 2, 4, 'Невский пр., 25', '+7(812)234-56-78', 'info@europehotel.ru', 'Комфортный отель в центре города'),
('Antalya Resort', 3, 4, 'Beach Road, 15', '+90(242)345-67-89', 'info@antalyaresort.com', 'Отель на берегу моря'),
('Hurghada Palace', 4, 5, 'Marina Road, 10', '+20(65)456-78-90', 'info@hurghadapalace.com', 'Престижный отель на Красном море');

INSERT INTO Tours (TourName, TourTypeID, CountryID, CityID, HotelID, Duration, Price, StartDate, EndDate, MaxTourists, Description) VALUES
('Отдых в Анталье', 1, 2, 3, 3, 7, 45000.00, '2024-06-01', '2024-06-08', 25, 'Незабываемый отдых на турецком побережье'),
('Экскурсия по Москве', 2, 1, 1, 1, 3, 25000.00, '2024-07-01', '2024-07-04', 15, 'Познавательная экскурсия по столице'),
('Отдых в Хургаде', 1, 3, 4, 4, 10, 65000.00, '2024-08-01', '2024-08-11', 20, 'Отдых на Красном море с экскурсиями'),
('Культурный тур по Питеру', 2, 1, 2, 2, 5, 35000.00, '2024-09-01', '2024-09-06', 18, 'Погружение в культуру Северной столицы');

-- Создание представлений для удобства работы
CREATE VIEW vw_TourDetails AS
SELECT 
    t.TourID,
    t.TourName,
    tt.TypeName,
    c.CountryName,
    ci.CityName,
    h.HotelName,
    h.Stars,
    t.Duration,
    t.Price,
    t.StartDate,
    t.EndDate,
    t.MaxTourists,
    t.Description
FROM Tours t
JOIN TourTypes tt ON t.TourTypeID = tt.TourTypeID
JOIN Countries c ON t.CountryID = c.CountryID
JOIN Cities ci ON t.CityID = ci.CityID
JOIN Hotels h ON t.HotelID = h.HotelID
WHERE t.IsActive = 1;

-- Создание хранимых процедур
CREATE PROCEDURE sp_GetToursByCountry
    @CountryID INT
AS
BEGIN
    SELECT * FROM vw_TourDetails WHERE CountryID = @CountryID;
END;

CREATE PROCEDURE sp_GetBookingsByClient
    @ClientID INT
AS
BEGIN
    SELECT 
        b.BookingID,
        t.TourName,
        b.BookingDate,
        b.TouristsCount,
        b.TotalPrice,
        b.Status
    FROM Bookings b
    JOIN Tours t ON b.TourID = t.TourID
    WHERE b.ClientID = @ClientID;
END;

-- Создание индексов для оптимизации
CREATE INDEX IX_Tours_CountryID ON Tours(CountryID);
CREATE INDEX IX_Tours_CityID ON Tours(CityID);
CREATE INDEX IX_Tours_StartDate ON Tours(StartDate);
CREATE INDEX IX_Bookings_ClientID ON Bookings(ClientID);
CREATE INDEX IX_Bookings_TourID ON Bookings(TourID);

PRINT 'База данных TourismDB успешно создана и заполнена тестовыми данными!';
GO
