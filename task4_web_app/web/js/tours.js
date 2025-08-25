// JavaScript файл для управления турами

document.addEventListener('DOMContentLoaded', function() {
    // Загрузка всех туров
    loadAllTours();
    
    // Инициализация зависимостей между полями формы
    initializeFormDependencies();
    
    // Обработка формы добавления тура
    const addTourForm = document.getElementById('addTourForm');
    if (addTourForm) {
        addTourForm.addEventListener('submit', handleAddTour);
    }
    
    // Обработка формы редактирования тура
    const editTourForm = document.getElementById('editTourForm');
    if (editTourForm) {
        editTourForm.addEventListener('submit', handleEditTour);
    }
});

// Функция загрузки всех туров
async function loadAllTours() {
    try {
        // В реальном приложении здесь будет запрос к Delphi backend
        // const response = await fetch('/api/tours');
        // const tours = await response.json();
        
        // Имитация данных для демонстрации
        const tours = [
            {
                id: 1,
                name: 'Отдых в Анталье',
                country: 'Турция',
                city: 'Анталья',
                duration: 7,
                price: 45000,
                startDate: '2024-06-01',
                endDate: '2024-06-08',
                type: 'Пляжный отдых',
                hotel: 'Antalya Resort',
                maxTourists: 25,
                description: 'Незабываемый отдых на турецком побережье'
            },
            {
                id: 2,
                name: 'Экскурсия по Москве',
                country: 'Россия',
                city: 'Москва',
                duration: 3,
                price: 25000,
                startDate: '2024-07-01',
                endDate: '2024-07-04',
                type: 'Экскурсионный тур',
                hotel: 'Гранд Отель Москва',
                maxTourists: 15,
                description: 'Познавательная экскурсия по столице'
            },
            {
                id: 3,
                name: 'Отдых в Хургаде',
                country: 'Египет',
                city: 'Хургада',
                duration: 10,
                price: 65000,
                startDate: '2024-08-01',
                endDate: '2024-08-11',
                type: 'Пляжный отдых',
                hotel: 'Hurghada Palace',
                maxTourists: 20,
                description: 'Отдых на Красном море с экскурсиями'
            },
            {
                id: 4,
                name: 'Культурный тур по Питеру',
                country: 'Россия',
                city: 'Санкт-Петербург',
                duration: 5,
                price: 35000,
                startDate: '2024-09-01',
                endDate: '2024-09-06',
                type: 'Экскурсионный тур',
                hotel: 'Отель Европа',
                maxTourists: 18,
                description: 'Погружение в культуру Северной столицы'
            }
        ];
        
        displayTours(tours);
    } catch (error) {
        console.error('Ошибка загрузки туров:', error);
        showNotification('Ошибка загрузки туров', 'error');
    }
}

// Функция отображения туров
function displayTours(tours) {
    const toursGrid = document.getElementById('toursGrid');
    if (!toursGrid) return;
    
    toursGrid.innerHTML = '';
    
    tours.forEach(tour => {
        const tourCard = createTourCard(tour);
        toursGrid.appendChild(tourCard);
    });
}

// Функция создания карточки тура для страницы управления
function createTourCard(tour) {
    const tourCard = document.createElement('div');
    tourCard.className = 'tour-card';
    
    tourCard.innerHTML = `
        <div class="tour-image">
            <i class="fas fa-plane"></i>
        </div>
        <div class="tour-content">
            <h3 class="tour-title">${tour.name}</h3>
            <div class="tour-details">
                <p><i class="fas fa-map-marker-alt"></i> ${tour.country}, ${tour.city}</p>
                <p><i class="fas fa-calendar"></i> ${tour.duration} дней</p>
                <p><i class="fas fa-tag"></i> ${tour.type}</p>
                <p><i class="fas fa-hotel"></i> ${tour.hotel}</p>
                <p><i class="fas fa-calendar-alt"></i> ${formatDate(tour.startDate)} - ${formatDate(tour.endDate)}</p>
                <p><i class="fas fa-users"></i> Макс. туристов: ${tour.maxTourists}</p>
            </div>
            <div class="tour-price">${formatPrice(tour.price)}</div>
            <div class="tour-actions">
                <button class="btn btn-edit" onclick="editTour(${tour.id})">
                    <i class="fas fa-edit"></i> Редактировать
                </button>
                <button class="btn btn-delete" onclick="deleteTour(${tour.id})">
                    <i class="fas fa-trash"></i> Удалить
                </button>
            </div>
        </div>
    `;
    
    return tourCard;
}

// Функция инициализации зависимостей между полями формы
function initializeFormDependencies() {
    const countrySelect = document.getElementById('country');
    const citySelect = document.getElementById('city');
    const hotelSelect = document.getElementById('hotel');
    
    if (countrySelect && citySelect) {
        countrySelect.addEventListener('change', function() {
            updateCities(this.value);
            citySelect.value = '';
            hotelSelect.value = '';
        });
    }
    
    if (citySelect && hotelSelect) {
        citySelect.addEventListener('change', function() {
            updateHotels(this.value);
            hotelSelect.value = '';
        });
    }
}

// Функция обновления списка городов
function updateCities(countryId) {
    const citySelect = document.getElementById('city');
    if (!citySelect) return;
    
    // Очищаем текущий список
    citySelect.innerHTML = '<option value="">Выберите город</option>';
    
    // В реальном приложении здесь будет запрос к Delphi backend
    const citiesByCountry = {
        '1': ['Москва', 'Санкт-Петербург', 'Сочи', 'Казань'],
        '2': ['Анталья', 'Стамбул', 'Измир', 'Бодрум'],
        '3': ['Хургада', 'Шарм-эль-Шейх', 'Каир', 'Луксор'],
        '4': ['Барселона', 'Мадрид', 'Валенсия', 'Севилья'],
        '5': ['Рим', 'Милан', 'Венеция', 'Флоренция']
    };
    
    const cities = citiesByCountry[countryId] || [];
    cities.forEach(city => {
        const option = document.createElement('option');
        option.value = city;
        option.textContent = city;
        citySelect.appendChild(option);
    });
}

// Функция обновления списка отелей
function updateHotels(cityName) {
    const hotelSelect = document.getElementById('hotel');
    if (!hotelSelect) return;
    
    // Очищаем текущий список
    hotelSelect.innerHTML = '<option value="">Выберите отель</option>';
    
    // В реальном приложении здесь будет запрос к Delphi backend
    const hotelsByCity = {
        'Москва': ['Гранд Отель Москва', 'Метрополь', 'Националь'],
        'Санкт-Петербург': ['Отель Европа', 'Астория', 'Коринтия'],
        'Анталья': ['Antalya Resort', 'Calista Luxury Resort', 'Akra Hotel'],
        'Хургада': ['Hurghada Palace', 'Steigenberger Aqua Magic', 'Alf Leila Wa Leila']
    };
    
    const hotels = hotelsByCity[cityName] || [];
    hotels.forEach(hotel => {
        const option = document.createElement('option');
        option.value = hotel;
        option.textContent = hotel;
        hotelSelect.appendChild(option);
    });
}

// Функция обработки добавления тура
async function handleAddTour(event) {
    event.preventDefault();
    
    if (!validateForm(event.target)) {
        return;
    }
    
    const formData = new FormData(event.target);
    const tourData = Object.fromEntries(formData.entries());
    
    try {
        // В реальном приложении здесь будет отправка данных на Delphi backend
        // const response = await fetch('/api/tours', {
        //     method: 'POST',
        //     headers: { 'Content-Type': 'application/json' },
        //     body: JSON.stringify(tourData)
        // });
        
        // Имитация успешного добавления
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        showNotification('Тур успешно добавлен!', 'success');
        closeModal('addTourModal');
        event.target.reset();
        
        // Перезагружаем список туров
        loadAllTours();
        
    } catch (error) {
        console.error('Ошибка добавления тура:', error);
        showNotification('Ошибка добавления тура', 'error');
    }
}

// Функция обработки редактирования тура
async function handleEditTour(event) {
    event.preventDefault();
    
    if (!validateForm(event.target)) {
        return;
    }
    
    const formData = new FormData(event.target);
    const tourData = Object.fromEntries(formData.entries());
    
    try {
        // В реальном приложении здесь будет отправка данных на Delphi backend
        // const response = await fetch(`/api/tours/${tourData.tourId}`, {
        //     method: 'PUT',
        //     headers: { 'Content-Type': 'application/json' },
        //     body: JSON.stringify(tourData)
        // });
        
        // Имитация успешного обновления
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        showNotification('Тур успешно обновлен!', 'success');
        closeModal('editTourModal');
        
        // Перезагружаем список туров
        loadAllTours();
        
    } catch (error) {
        console.error('Ошибка обновления тура:', error);
        showNotification('Ошибка обновления тура', 'error');
    }
}

// Функция редактирования тура
function editTour(tourId) {
    // В реальном приложении здесь будет загрузка данных тура с сервера
    // const tour = await fetch(`/api/tours/${tourId}`);
    
    // Пока что используем заглушку
    const tour = {
        id: tourId,
        name: 'Название тура',
        type: '1',
        country: '1',
        city: 'Москва',
        hotel: 'Гранд Отель Москва',
        duration: 7,
        price: 50000,
        maxTourists: 20,
        startDate: '2024-06-01',
        endDate: '2024-06-08',
        description: 'Описание тура'
    };
    
    // Заполняем форму данными
    fillEditForm(tour);
    
    // Открываем модальное окно
    openModal('editTourModal');
}

// Функция заполнения формы редактирования
function fillEditForm(tour) {
    const form = document.getElementById('editTourForm');
    if (!form) return;
    
    // Заполняем поля формы
    form.querySelector('[name="tourId"]').value = tour.id;
    form.querySelector('[name="tourName"]').value = tour.name;
    form.querySelector('[name="tourType"]').value = tour.type;
    form.querySelector('[name="country"]').value = tour.country;
    
    // Обновляем города и отели
    updateCities(tour.country);
    setTimeout(() => {
        form.querySelector('[name="city"]').value = tour.city;
        updateHotels(tour.city);
        setTimeout(() => {
            form.querySelector('[name="hotel"]').value = tour.hotel;
        }, 100);
    }, 100);
    
    form.querySelector('[name="duration"]').value = tour.duration;
    form.querySelector('[name="price"]').value = tour.price;
    form.querySelector('[name="maxTourists"]').value = tour.maxTourists;
    form.querySelector('[name="startDate"]').value = tour.startDate;
    form.querySelector('[name="endDate"]').value = tour.endDate;
    form.querySelector('[name="description"]').value = tour.description;
}

// Функция удаления тура
async function deleteTour(tourId) {
    if (!confirm('Вы уверены, что хотите удалить этот тур?')) {
        return;
    }
    
    try {
        // В реальном приложении здесь будет запрос на удаление к Delphi backend
        // const response = await fetch(`/api/tours/${tourId}`, {
        //     method: 'DELETE'
        // });
        
        // Имитация успешного удаления
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        showNotification('Тур успешно удален!', 'success');
        
        // Перезагружаем список туров
        loadAllTours();
        
    } catch (error) {
        console.error('Ошибка удаления тура:', error);
        showNotification('Ошибка удаления тура', 'error');
    }
}

// Функция валидации формы
function validateForm(form) {
    const requiredFields = form.querySelectorAll('[required]');
    let isValid = true;
    
    requiredFields.forEach(field => {
        if (!field.value.trim()) {
            field.classList.add('error');
            isValid = false;
        } else {
            field.classList.remove('error');
        }
    });
    
    // Дополнительная валидация
    const price = form.querySelector('[name="price"]');
    if (price && price.value < 0) {
        price.classList.add('error');
        isValid = false;
    }
    
    const duration = form.querySelector('[name="duration"]');
    if (duration && (duration.value < 1 || duration.value > 30)) {
        duration.classList.add('error');
        isValid = false;
    }
    
    if (!isValid) {
        showNotification('Пожалуйста, заполните все обязательные поля корректно', 'warning');
    }
    
    return isValid;
}

// Функция поиска туров
function searchTours(query) {
    const searchInput = document.querySelector('.search-input');
    if (!searchInput) return;
    
    const searchTerm = query.toLowerCase();
    const tourCards = document.querySelectorAll('.tour-card');
    
    tourCards.forEach(card => {
        const tourTitle = card.querySelector('.tour-title').textContent.toLowerCase();
        const tourDetails = card.querySelector('.tour-details').textContent.toLowerCase();
        
        if (tourTitle.includes(searchTerm) || tourDetails.includes(searchTerm)) {
            card.style.display = 'block';
        } else {
            card.style.display = 'none';
        }
    });
}

// Функция фильтрации туров по типу
function filterToursByType(type) {
    const tourCards = document.querySelectorAll('.tour-card');
    
    tourCards.forEach(card => {
        const tourType = card.querySelector('.tour-details').textContent.toLowerCase();
        
        if (type === 'all' || tourType.includes(type.toLowerCase())) {
            card.style.display = 'block';
        } else {
            card.style.display = 'none';
        }
    });
}

// Функция сортировки туров
function sortTours(criteria) {
    const toursGrid = document.getElementById('toursGrid');
    if (!toursGrid) return;
    
    const tourCards = Array.from(toursGrid.children);
    
    tourCards.sort((a, b) => {
        let aValue, bValue;
        
        switch (criteria) {
            case 'price-asc':
                aValue = parseFloat(a.querySelector('.tour-price').textContent.replace(/[^\d]/g, ''));
                bValue = parseFloat(b.querySelector('.tour-price').textContent.replace(/[^\d]/g, ''));
                return aValue - bValue;
                
            case 'price-desc':
                aValue = parseFloat(a.querySelector('.tour-price').textContent.replace(/[^\d]/g, ''));
                bValue = parseFloat(b.querySelector('.tour-price').textContent.replace(/[^\d]/g, ''));
                return bValue - aValue;
                
            case 'duration-asc':
                aValue = parseInt(a.querySelector('.tour-details').textContent.match(/(\d+)\s+дней/)[1]);
                bValue = parseInt(b.querySelector('.tour-details').textContent.match(/(\d+)\s+дней/)[1]);
                return aValue - bValue;
                
            case 'name-asc':
                aValue = a.querySelector('.tour-title').textContent.toLowerCase();
                bValue = b.querySelector('.tour-title').textContent.toLowerCase();
                return aValue.localeCompare(bValue);
                
            default:
                return 0;
        }
    });
    
    // Пересортировка элементов в DOM
    tourCards.forEach(card => toursGrid.appendChild(card));
}
