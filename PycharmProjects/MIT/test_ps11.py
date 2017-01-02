from unittest import TestCase
from ps11 import *

__author__ = 'dillonflannery-valadez'


class TestRectangularRoom(TestCase):
    def test(self):
        recRoom = RectangularRoom(5, 5)
        self.assertEqual(recRoom.width , recRoom.height)
        self.assertRaises(AssertionError, RectangularRoom, -1, 1)
        self.assertRaises(AssertionError, RectangularRoom, 1, -1)
        for key in recRoom.tiles:
            self.assertTrue(recRoom.tiles[key] == 0)

    def test_clean_tile(self):
        pos = Position(1,1)
        recRoom = RectangularRoom(3,3)
        recRoom.cleanTileAtPosition(pos)
        failMsg = "Tile (1,1) Not Clean."
        self.assertTrue(recRoom.tiles[(1,1)] == 1, failMsg)
        pos2 = Position(2,2)
        recRoom.cleanTileAtPosition(pos2)
        self.assertTrue(recRoom.tiles[(2,2)] == 1 and recRoom.tiles[(1,1)] == 1, failMsg)
        pos3 = Position(0,0)
        recRoom.cleanTileAtPosition(pos3)
        self.assertTrue(recRoom.tiles[(0,0)] == 1, failMsg)
        pos4 = Position(0,2)
        recRoom.cleanTileAtPosition(pos4)
        self.assertTrue(recRoom.tiles[(0,2)] == 1, failMsg )
        # print recRoom.tiles

    def test_is_tile_cleaned(self):
        pos = Position(0,0)
        recRoom = RectangularRoom(3,3)
        recRoom.cleanTileAtPosition(pos)
        self.assertFalse(recRoom.isTileCleaned(0,2))
        self.assertTrue(recRoom.isTileCleaned(pos.getX(), pos.getY()))
        pos2 = Position(1,1)
        recRoom.cleanTileAtPosition(pos2)
        self.assertTrue(recRoom.isTileCleaned(pos2.getX(),pos2.getY()))

    def test_numTiles(self):
        recRoom = RectangularRoom(3,3)
        self.assertTrue(recRoom.getNumTiles() == 9, "Num tiles = 9")

    def test_getNumCleanedTiles(self):
        pos = Position(1,1)
        recRoom = RectangularRoom(3,3)
        # Cleaned 1 tile
        recRoom.cleanTileAtPosition(pos)
        failMsg = "Tile (1,1) Not Clean."
        self.assertTrue(recRoom.tiles[(1,1)] == 1, failMsg)
        pos2 = Position(2,2)
        # Cleaned 2 tiles
        recRoom.cleanTileAtPosition(pos2)
        self.assertTrue(recRoom.tiles[(2,2)] == 1 and recRoom.tiles[(1,1)] == 1, failMsg)
        pos3 = Position(0,0)
        # Cleaned 3 tiles
        recRoom.cleanTileAtPosition(pos3)
        self.assertTrue(recRoom.tiles[(0,0)] == 1, failMsg)
        pos4 = Position(0,2)
        # Cleaned 4 tiles
        recRoom.cleanTileAtPosition(pos4)
        self.assertTrue(recRoom.tiles[(0,2)] == 1, failMsg )
        self.assertTrue(recRoom.getNumCleanedTiles() == 4)
        pos5 = Position(1,0)
        # Cleaned 5 tiles
        recRoom.cleanTileAtPosition(pos5)
        self.assertTrue(recRoom.getNumCleanedTiles() == 5)

    def test_getRandomPos(self):
        recRoom = RectangularRoom(3,3)
        for i in range(1, 100):
            # print recRoom.getRandomPosition().getX(),recRoom.getRandomPosition().getY()
            pass

    def test_inRoom(self):
        recRoom = RectangularRoom(3,3)
        # Not in 3x3 Room tests
        pos1 = Position(2,2.2)
        pos2 = Position(-1,0)
        # print pos1.getX()
        # print pos1.getY()
        # print recRoom.width
        # print recRoom.height
        self.assertTrue(recRoom.isPositionInRoom(pos1))
        self.assertFalse(recRoom.isPositionInRoom(pos2))
        for i in range(1, 100):
            pos = Position(random.randint(-100, -1), random.randint(-100, -1))
            self.assertFalse(recRoom.isPositionInRoom(pos))
        for i in range(1, 100):
            pos = Position(random.randint(4, 100), random.randint(4,100))
            self.assertFalse(recRoom.isPositionInRoom(pos))
        for i in range(1,100):
            pos= Position(random.randint(0,2), random.randint(4,100))
            self.assertFalse(recRoom.isPositionInRoom(pos))
        for i in range(1,100):
            pos = Position(random.randint(4,1100), random.randint(0,2))
            self.assertFalse(recRoom.isPositionInRoom(pos))
        for i in range(1, 100):
            pos = recRoom.getRandomPosition()
            self.assertTrue(recRoom.isPositionInRoom(pos))
    # Base Robot Tests
    def test_Init(self):
        wid = 3
        height = 3
        recRoom = RectangularRoom(wid, height)
        speed = 1.5
        for i in range(0, 360, 1):
            robo = BaseRobot(recRoom, speed)
            # print robo.direction, robo.speed, robo.position
            pass
    #     self.assertFalse(False)

    def test_getRoboPosis(self):
        recRoom = RectangularRoom(3,3)
        robo = BaseRobot(recRoom, 1.5)
        self.assertTrue(robo.getRobotPosition().getX() == 0, "If failure check seed in getRandomPosition method, set "
                                                             "to one in tests.")

    def test_getDirection(self):
        recRoom = RectangularRoom(3,3)
        robo = BaseRobot(recRoom, 1.5, "h")
        print robo.getRobotDirection()
        self.assertTrue(robo.getRobotDirection() == 48, "This test will fail if optional seed parameter removed. ")

    def test_RobotUpdateAndClean(self):
        recRoom = RectangularRoom(3,3)
        robo = Robot(recRoom, 1.0)

        for i in range(1,100):
            roboPos = recRoom.getRandomPosition()
            robo.setRobotPosition(roboPos)
            pos = robo.updatePositionAndClean()
            newpos = robo.setRobotPosition(pos)
            print roboPos, newpos
            self.assertTrue(0 <= (robo.updatePositionAndClean().getX()
                                  and robo.updatePositionAndClean().getY()) < 3.0)





    def test_nexttest(self):
        pass








