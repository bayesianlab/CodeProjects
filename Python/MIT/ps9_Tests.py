__author__ = 'dillonflannery-valadez'
#
from MIT.ps9 import*
import math
#
#
mysquare= Square(2)
mysquare2 = Square(math.sqrt(80))
# print mysquare
# print
triangle = Triangle(10,15)
triangle2 = Triangle(16,10)
# print triangle == triangle2
# print
mycirc = Circle(5)
mycirc2 = Circle(2)
# print type(mycirc) == Circle


shapes = ShapeSet()
shapes.addShape(triangle)
shapes.addShape(mysquare)
shapes.addShape(mysquare2)
shapes.addShape(mycirc)
shapes.addShape(triangle2)
# print shapes
# print "finding areas"
# print triangle.area(), "tri 1 area"
# print mysquare.area(), "sqr 1 area"
# print mysquare2.area(), "sqr 2 area"
# print mycirc.area(), "circ area"
# print triangle2.area(), "tri 2 area"
print
# print "test of shapeset print method"
print
# print shapes
# print mysquare2.area(), "sqr 2 area"

# print
# print "Finding largest shape"
# print
# print findLargest(shapes)
# print
# shapeFile  = readShapesFromFile('shapes.txt')
# print shapeFile
x = 'triangle,4,5'
y = "circle, 100"
# with open('testfile.txt') as testrun:
#     x = -1
#     for line in testrun:
#         x += 1
#         if x != 0:
#             print Square(interpretStirng(line))

print readShapesFromFile("shapes.txt")
print "pset done."


