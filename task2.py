class Animal:
    def __init__(self, name):
        self.name = name
    
    def make_sound(self):
        return "Some sound"
    
    def get_info(self):
        return f"Animal: {self.name}"

class Dog(Animal):
    def make_sound(self):
        return "Woof!"
    
    def fetch(self):
        return f"{self.name} is fetching the ball"

def test_classes():
    animal = Animal("Generic")
    dog = Dog("Buddy")
    
    print(animal.get_info())
    print(animal.make_sound())
    print(dog.get_info())
    print(dog.make_sound())
    print(dog.fetch())

if __name__ == "__main__":
    test_classes()
