__author__ = 'dillonflannery-valadez'
class Shape:
    def __init__(self,in1, in2):
        self.length = in1
        self.width = in2
    def area(self):
        return self.length*self.width
    def __str__(self):
        return str(self.length) + "," + str(self.width)

class Triangle(Shape):
    def __init__(self, in1, in2):
        self.tri = Shape(in1, in2)
        self.base = self.tri.length
        self.height = self.tri.width
    def area(self, base, height):
        return .5* self.base * self.height



s = Shape(3,4)
print s.area()
t = Triangle(3,4)
print t.area(3,4)