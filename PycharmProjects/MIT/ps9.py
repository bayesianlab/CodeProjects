__author__ = 'dillonflannery-valadez'
# 6.00 Problem Set 9
#
# Name:
# Collaborators:
# Time:

from string import *
import string

class Shape(object):
    def area(self):
        raise AttributeException("Subclasses should override this method.")

class Square(Shape):
    def __init__(self, h):
        """
        h: length of side of the square
        """
        if type(h) != float:
            self.side = float(h)
        else:
            self.side = h
    def area(self):
        """
        Returns area of the square
        """
        return self.side**2
    def __str__(self):
        return 'Square with side ' + str(self.side)
    def __eq__(self, other):
        """
        Two squares are equal if they have the same dimension.
        other: object to check for equality
        """
        return type(other) == Square and self.side == other.side

class Circle(Shape):
    def __init__(self, radius):
        """
        radius: radius of the circle
        """
        if type(radius) != float:
            self.radius = float(radius)
        else:
            self.radius = radius
    def area(self):
        """
        Returns approximate area of the circle
        """
        return 3.14159*(self.radius**2)
    def __str__(self):
        return 'Circle with radius ' + str(self.radius)
    def __eq__(self, other):
        """
        Two circles are equal if they have the same radius.
        other: object to check for equality
        """
        return type(other) == Circle and self.radius == other.radius


# Problem 1: Create the Triangle class
#
## TO DO: Implement the `Triangle` class, which also extends `Shape`.

class Triangle(Shape):
    def __init__(self, base, height):
        if type(base) and (height) != float:
            self.base = float(base)
            self.height = float(height)
        else:
            self.base = base
            self.height = height

    def area(self):
        return .50 * (self.base * self.height)

    def __str__(self):
        return "Triangle with base " + str(self.base) + " and height " + str(self.height)
    def __eq__(self, other):
        return type(other) == Triangle and ((self.base == other.base and self.height == other.height) or\
               (self. height == other.base and self.base == other.height))




#
# Problem 2: Create the ShapeSet class
#
## TO DO: Fill in the following code skeleton according to the
##    specifications.

class ShapeSet:
    def __init__(self):
        """
        Initialize any needed variables
        """
        self.group = []

    def addShape(self, sh):
        """
        Add shape sh to the set; no two shapes in the set may be
        identical
        sh: shape to be added
        """
        if type(sh) == Square or Triangle or Circle:
            if sh not in self.group:
                self.group += [sh]
            else:
                raise Exception("Shape in the set.")

    def __iter__(self):
        """
        Return an iterator that allows you to iterate over the set of
        shapes, one shape at a time
        """
        return iter(self.group)

    def findShape(self, shapeType):
        newline = "\n"
        shapeString = ""
        for shape in self.group:
            if type(shape) == shapeType:
                shapeString += shape.__str__() + newline
            else:
                pass
        return shapeString

    def __str__(self):
        """
        Return the string representation for a set, which consists of
        the string representation of each shape, categorized by type
        (circles, then squares, then triangles)
        """
        printableString = ""
        shapeTypes= [Circle, Square, Triangle]
        for shape in shapeTypes:
            printableString += self.findShape(shape)
        return printableString



#
# Problem 3: Find the largest shapes in a ShapeSet

def areaList(shapes):
    areas = []
    for i in shapes:
        areas.append(i.area())
    return areas

def objectList(shapes):
    shapeObjectsAsList = []
    for i in shapes:
        shapeObjectsAsList += [i]
    return shapeObjectsAsList

def findLargest(shapes):
    """
    Returns a tuple containing the elements of ShapeSet with the
       largest area.
    shapes: ShapeSet
    """
    epsilon = .0000001
    shapeObjectsList = objectList(shapes)
    areasList = areaList(shapes)
    biggestArea = max(areasList)
    biggestAreaIndex = areasList.index(biggestArea)
    biggestObject = shapeObjectsList[biggestAreaIndex]
    largest = []
    largest.append(biggestObject)
    x = -1
    for i in shapes:
        x += 1
        if abs(biggestArea - i.area()) < epsilon and x != biggestAreaIndex:
            largest.append(i)
        else:
            pass
    return tuple(largest)

# Problem 4: Read shapes from a file into a ShapeSet

def circleFromFile(filestirng):
    return float(filestirng[7:])

def interpretStirng(filestring):
    if string.count(filestring, ",") == 2:
        shapeType = 2
        base = ""
        height = ""
        lowerIndx = string.find(filestring, ",")
        for i in range(lowerIndx + 1, len(filestring) - 1):
            if filestring[i] != ",":
                base += filestring[i]
            else:
                height = filestring[i+1:]
                break
        return [shapeType, float(base), float(height)]
    elif string.find(filestring, "circle") != -1:

        return float(filestring[7:])
    else:

        return float(filestring[7:])



def readShapesFromFile(filename):
    """
    Retrieves shape information from the given file.
    Creates and returns a ShapeSet with the shapes found.
    filename: string
    """
    with open(filename) as shapeFile:
        newShapes = ShapeSet()
        for line in shapeFile:
            if string.find(line, "triangle") != -1:
                newShapes.addShape(Triangle(interpretStirng(line)[1], interpretStirng(line)[2]))
            elif string.find(line, "square") != -1:
                newShapes.addShape(Square(interpretStirng(line)))
            else:
                newShapes.addShape(Circle(interpretStirng(line)))
    return newShapes



