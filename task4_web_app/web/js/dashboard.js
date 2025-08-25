// JavaScript файл для дашборда туристической системы

document.addEventListener('DOMContentLoaded', function() {
    // Загрузка статистики
    loadDashboardStats();
    
    // Загрузка последних туров
    loadRecentTours();
    
    // Обновление данных каждые 30 секунд
    setInterval(loadDashboardStats, 30000);
});

// Функция загрузки статистики дашборда
async function loadDashboardStats() {
    try {
        // В реальном приложении здесь будет запрос к Delphi backend
        // const response = await fetch('/api/dashboard/stats');
        // const stats = await response.json();
        
        // Имитация данных для демонстрации
        const stats = {
            totalTours: 24,
            totalClients: 156,
            totalBookings: 89,
            totalRevenue: 2845000
        };
        
        updateStatsDisplay(stats);
    } catch (error) {
        console.error('Ошибка загрузки статистики:', error);
        showNotification('Ошибка загрузки статистики', 'error');
    }
}

// Функция обновления отображения статистики
function updateStatsDisplay(stats) {
    const totalTours = document.getElementById('totalTours');
    const totalClients = document.getElementById('totalClients');
    const totalBookings = document.getElementById('totalBookings');
    const totalRevenue = document.getElementById('totalRevenue');
    
    if (totalTours) {
        animateNumber(totalTours, parseInt(totalTours.textContent) || 0, stats.totalTours);
    }
    
    if (totalClients) {
        animateNumber(totalClients, parseInt(totalClients.textContent) || 0, stats.totalClients);
    }
    
    if (totalBookings) {
        animateNumber(totalBookings, parseInt(totalBookings.textContent) || 0, stats.totalBookings);
    }
    
    if (totalRevenue) {
        const currentRevenue = parseInt(totalRevenue.textContent.replace(/[^\d]/g, '')) || 0;
        animateNumber(totalRevenue, currentRevenue, stats.totalRevenue, ' ₽');
    }
}

// Функция анимации чисел
function animateNumber(element, start, end, suffix = '') {
    const duration = 1000;
    const startTime = performance.now();
    
    function updateNumber(currentTime) {
        const elapsed = currentTime - startTime;
        const progress = Math.min(elapsed / duration, 1);
        
        // Плавная анимация с использованием easeOutQuart
        const easeProgress = 1 - Math.pow(1 - progress, 4);
        const current = Math.round(start + (end - start) * easeProgress);
        
        element.textContent = current + suffix;
        
        if (progress < 1) {
            requestAnimationFrame(updateNumber);
        }
    }
    
    requestAnimationFrame(updateNumber);
}

// Функция загрузки последних туров
async function loadRecentTours() {
    try {
        // В реальном приложении здесь будет запрос к Delphi backend
        // const response = await fetch('/api/tours/recent');
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
                type: 'Пляжный отдых'
            },
            {
                id: 2,
                name: 'Экскурсия по Москве',
                country: 'Россия',
                city: 'Москва',
                duration: 3,
                price: 25000,
                startDate: '2024-07-01',
                type: 'Экскурсионный тур'
            },
            {
                id: 3,
                name: 'Отдых в Хургаде',
                country: 'Египет',
                city: 'Хургада',
                duration: 10,
                price: 65000,
                startDate: '2024-08-01',
                type: 'Пляжный отдых'
            }
        ];
        
        displayRecentTours(tours);
    } catch (error) {
        console.error('Ошибка загрузки туров:', error);
        showNotification('Ошибка загрузки туров', 'error');
    }
}

// Функция отображения последних туров
function displayRecentTours(tours) {
    const toursGrid = document.getElementById('recentToursGrid');
    if (!toursGrid) return;
    
    toursGrid.innerHTML = '';
    
    tours.forEach(tour => {
        const tourCard = createTourCard(tour);
        toursGrid.appendChild(tourCard);
    });
}

// Функция создания карточки тура
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
                <p><i class="fas fa-calendar-alt"></i> ${formatDate(tour.startDate)}</p>
            </div>
            <div class="tour-price">${formatPrice(tour.price)}</div>
            <button class="tour-button" onclick="viewTourDetails(${tour.id})">
                Подробнее
            </button>
        </div>
    `;
    
    return tourCard;
}

// Функция просмотра деталей тура
function viewTourDetails(tourId) {
    // В реальном приложении здесь будет переход на страницу тура
    // или открытие модального окна с деталями
    showNotification(`Просмотр тура ID: ${tourId}`, 'info');
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
    const toursGrid = document.getElementById('recentToursGrid');
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

// Функция экспорта данных
function exportData(format) {
    // В реальном приложении здесь будет экспорт данных через Delphi backend
    showNotification(`Экспорт данных в формате ${format}`, 'info');
}

// Функция печати отчета
function printReport() {
    window.print();
}

// Инициализация дополнительных функций дашборда
function initializeDashboard() {
    // Добавление обработчиков событий для фильтров
    const filterButtons = document.querySelectorAll('.filter-btn');
    filterButtons.forEach(btn => {
        btn.addEventListener('click', function() {
            const filterType = this.dataset.filter;
            filterToursByType(filterType);
            
            // Обновление активного состояния кнопок
            filterButtons.forEach(b => b.classList.remove('active'));
            this.classList.add('active');
        });
    });
    
    // Добавление обработчика для поиска
    const searchInput = document.querySelector('.search-input');
    if (searchInput) {
        searchInput.addEventListener('input', function() {
            searchTours(this.value);
        });
    }
    
    // Добавление обработчика для сортировки
    const sortSelect = document.querySelector('.sort-select');
    if (sortSelect) {
        sortSelect.addEventListener('change', function() {
            sortTours(this.value);
        });
    }
}

// Вызов инициализации при загрузке страницы
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeDashboard);
} else {
    initializeDashboard();
}
