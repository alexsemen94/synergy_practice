"""
Задача №1
Дан одномерный массив А размерности N. 
Найти сумму отрицательных элементов, расположенных между максимальным и минимальным.
"""

def find_sum_between_max_min(arr):
    """
    Находит сумму отрицательных элементов между максимальным и минимальным
    
    Args:
        arr (list): одномерный массив чисел
        
    Returns:
        int/float: сумма отрицательных элементов между max и min
    """
    if not arr:
        return 0
    
    max_index = arr.index(max(arr))
    min_index = arr.index(min(arr))
    
    start = min(max_index, min_index)
    end = max(max_index, min_index)
    
    sum_negative = 0
    for i in range(start + 1, end):
        if arr[i] < 0:
            sum_negative += arr[i]
    
    return sum_negative

def main():
    """Основная функция для демонстрации работы"""
    print("Задача №1: Сумма отрицательных элементов между max и min")
    
    arr1 = [5, -3, 8, -1, 2, -7, 9, -4]
    result1 = find_sum_between_max_min(arr1)
    print(f"Сумма отрицательных элементов между max и min: {result1}")
    

if __name__ == "__main__":
    main()
