# Problem Set 11: Simulating robots
# Name:
# Collaborators:
# Time:

import math
import numpy
import pylab
import random
import ps11_visualize
# === Provided classes

class Position(object):
    """
    A Position represents a location in a two-dimensional room.
    """
    def __init__(self, x, y):
        """
        Initializes a position with coordinates (x, y).

        x: a real number indicating the x-coordinate
        y: a real number indicating the y-coordinate
        """
        self.x = x
        self.y = y
    def getX(self):
        return self.x
    def getY(self):
        return self.y
    def getNewPosition(self, angle, speed):
        """
        Computes and returns the new Position after a single clock-tick has
        passed, with this object as the current position, and with the
        specified angle and speed.

        Does NOT test whether the returned position fits inside the room.

        angle: integer representing angle in degrees, 0 <= angle < 360
        speed: positive float representing speed

        Returns: a Position object representing the new position.
        """
        old_x, old_y = self.getX(), self.getY()
        # Compute the change in position
        delta_y = speed * math.cos(math.radians(angle))
        delta_x = speed * math.sin(math.radians(angle))
        # Add that to the existing position
        new_x = old_x + delta_x
        new_y = old_y + delta_y
        return Position(new_x, new_y)
    def __str__(self):
        return str(self.x) + ", " +  str(self.y)


# === Problems 1 and 2

class RectangularRoom(object):
    """
    A RectangularRoom represents a rectangular region containing clean or dirty
    tiles.

    A room has a width and a height and contains (width * height) tiles. At any
    particular time, each of these tiles is either clean or dirty.
    """
    def __init__(self, width, height):
        """
        Initializes a rectangular room with the specified width and height.
        Initially, no tiles in the room have been cleaned.

        width: an integer > 0
        height: an integer > 0
        """
        assert width > 0
        assert height > 0
        self.width = width
        self.height = height
        self.tiles = {}
        for w in range(0, width):
            for h in range(0, height):
                self.tiles[(w,h)] = 0

    def cleanTileAtPosition(self, pos):
        """
        Mark the tile under the position POS as cleaned.
        Assumes that POS represents a valid position inside this room.

        pos: a Position
        """
        xCoords = self.width

        yCoords = self.height
        posX = pos.getX()
        posY = pos.getY()
        floorX = -1
        for i in range(1, xCoords +1 ):
            floorX += 1
            if floorX <= posX < i:

                floorY = -1
                for j in range(1, yCoords+1 ):
                    floorY += 1
                    if floorY <= posY < j:
                        self.tiles[(i - 1, j - 1)] = 1
        return self.tiles

    def isTileCleaned(self, m, n):
        """
        Return True if the tile (m, n) has been cleaned.

        Assumes that (m, n) represents a valid tile inside the room.

        m: an integer
        n: an integer
        returns: True if (m, n) is cleaned, False otherwise
        """
        position = (m,n)
        if self.tiles[position] == 1:
            return True
        else:
            return False
    def getNumTiles(self):
        """
        Return the total number of tiles in the room.

        returns: an integer
        """
        return self.height * self.width

    def getNumCleanedTiles(self):
        """
        Return the total number of clean tiles in the room.

        returns: an integer
        """
        cleaned = self.tiles.values()
        count = 0
        for i in cleaned:
            if i == 1:
                count += 1
        return count
    def getRandomPosition(self, testSeed = None):
        """
        Return a random position inside the room.

        returns: a Position object.
        """
        if testSeed == None:
            return Position(random.uniform(0, self.width), random.uniform(0, self.height))
        else:
            random.seed(testSeed)
            return Position(random.uniform(0, self.width), random.uniform(0, self.height))

    def isPositionInRoom(self, pos):
        """
        Return True if POS is inside the room.

        pos: a Position object.
        returns: True if POS is in the room, False otherwise.
        """
        if (0 <= pos.getX() < self.width) and (0 <= pos.getY() < self.height):
            return True
        else:
            return False


class BaseRobot(object):
    """
    Represents a robot cleaning a particular room.

    At all times the robot has a particular position and direction in
    the room.  The robot also has a fixed speed.

    Subclasses of BaseRobot should provide movement strategies by
    implementing updatePositionAndClean(), which simulates a single
    time-step.
    """
    def __init__(self, room, speed, seed = None):
        """
        Initializes a Robot with the given speed in the specified
        room. The robot initially has a random direction d and a
        random position p in the room.

        The direction d is an integer satisfying 0 <= d < 360; it
        specifies an angle in degrees.

        p is a Position object giving the robot's position.

        room:  a RectangularRoom object.
        speed: a float (speed > 0)
        """
        if seed == None:
            pass
        else:
            random.seed(1)
        self.rm = room
        self.dir = random.randint(0, 360)
        self.speed = speed
        self.pos = room.getRandomPosition()
        random.setstate(random.getstate())

    def getRobotPosition(self):
        """
        Return the position of the robot.

        returns: a Position object giving the robot's position.
        """
        return self.pos
    def getRobotDirection(self):
        """
        Return the direction of the robot.

        returns: an integer d giving the direction of the robot as an angle in
        degrees, 0 <= d < 360.
        """
        return self.dir

    def setRobotPosition(self, position):
        """
        Set the position of the robot to POSITION.

        position: a Position object.
        """
        self.pos = position
        return self.pos
    def setRobotDirection(self, direction):
        """
        Set the direction of the robot to DIRECTION.

        direction: integer representing an angle in degrees
        """
        self.dir = direction
        return self.dir


class Robot(BaseRobot):
    """
    A Robot is a BaseRobot with the standard movement strategy.

    At each time-step, a Robot attempts to move in its current
    direction; when it hits a wall, it chooses a new direction
    randomly.
    """
    def updatePositionAndClean(self):
        """
        Simulate the passage of a single time-step.

        Move the robot to a new position and mark the tile it is on as having
        been cleaned.
        """

        robotPosition = self.getRobotPosition()

        # print robotPosition, "initial"
        self.rm.cleanTileAtPosition(robotPosition)
        direction = self.getRobotDirection()
        speed = self.speed
        potentialPosition = robotPosition.getNewPosition(direction, speed)
        # print potentialPosition, "new "
        postion_in_room = self.rm.isPositionInRoom(potentialPosition)
        if postion_in_room == True:
            self.pos = potentialPosition
            return self.pos
        else:
            self.setRobotDirection(random.randint(0,359))
            return self.updatePositionAndClean()


# === Problem 3

def createRobotObjects(num_robots, robot_type, room, speed):
    roboList = []
    for robot in range(0, num_robots):
        robo = robot_type(room, speed)
        roboList.append(robo)
    return roboList


def runSimulation(num_robots, speed, width, height, min_coverage, num_trials,
                  robot_type, visualize):
    """
    Runs NUM_TRIALS trials of the simulation and returns a list of
    lists, one per trial. The list for a trial has an element for each
    timestep of that trial, the value of which is the percentage of
    the room that is clean after that timestep. Each trial stops when
    MIN_COVERAGE of the room is clean.

    The simulation is run with NUM_ROBOTS robots of type ROBOT_TYPE,
    each with speed SPEED, in a room of dimensions WIDTH x HEIGHT.

    Visualization is turned on when boolean VISUALIZE is set to True.

    num_robots: an int (num_robots > 0)
    speed: a float (speed > 0)
    width: an int (width > 0)
    height: an int (height > 0)
    min_coverage: a float (0 <= min_coverage <= 1.0)
    num_trials: an int (num_trials > 0)
    robot_type: class of robot to be instantiated (e.g. Robot or
                RandomWalkRobot)
    visualize: a boolean (True to turn on visualization)
    """
    totalTiles = width*height
    numTicks = 4000
    clockTicks = numTicks
    clockTicksList = []
    simResults = []
    for trial in range(0, num_trials):
        """ Clears room """
        room = RectangularRoom(width, height)
        robotList = createRobotObjects(num_robots, robot_type, room, speed)
        """Putting the robots in a random place in the room. """
        for robot in robotList:
            initPos = room.getRandomPosition()
            robot.setRobotPosition(initPos)
        """Initializing simulation list and other variables."""
        simList = []
        clockTicksPerSimulation = []
        clockTicks = numTicks
        percentCleaned = 0.0
        """Running one sim."""
        if visualize == True:
            anim = ps11_visualize.RobotVisualization(num_robots, width, height)
        while clockTicks > 0:
            """ Run simulation"""
            if visualize == True:
                anim.update(room, robotList)
            clockTicks -= 1
            if clockTicks <= 0 or percentCleaned >= min_coverage:
                clockTicksList.append(numTicks - clockTicks)
                simResults.append(simList)
                if visualize == True:
                    anim.done()
                break
            else:
                for robot in robotList:
                    robot.updatePositionAndClean()
                    currentCleanedTiles = room.getNumCleanedTiles()
                    percentCleaned = float(currentCleanedTiles) / totalTiles
                    simList.append(percentCleaned)
    return simResults, clockTicksList


# === Provided function
def computeMeans(list_of_lists):
    """
    Returns a list as long as the longest list in LIST_OF_LISTS, where
    the value at index i is the average of the values at index i in
    all of LIST_OF_LISTS' lists.

    Lists shorter than the longest list are padded with their final
    value to be the same length.
    """
    # Find length of longest list
    longest = 0
    for lst in list_of_lists:
        if len(lst) > longest:
           longest = len(lst)
    # Get totals
    tots = [0]*(longest)
    for lst in list_of_lists:
        for i in range(longest):
            if i < len(lst):
                tots[i] += lst[i]
            else:
                tots[i] += lst[-1]
    # Convert tots to an array to make averaging across each index easier
    tots = pylab.array(tots)
    # Compute means
    means = tots/float(len(list_of_lists))
    return means

def computeAvgs(runSimResults):
    total = 0.0
    avg = []
    clockTicks = runSimResults[1]
    numElems = len(clockTicks)
    for ticks in clockTicks:
        total += ticks
    return total / numElems



# === Problem 4
def showPlot1():
    """
    Produces a plot showing dependence of cleaning time on room size.
    """
    roomSizes = (5,5)
    yvals = []
    domain = []
    for i in range(1,6):
        domain.append(5*i)
        avgs = runSimulation(1, 1.0, roomSizes[0]*i, roomSizes[1]*i, .75, 10, Robot, False)
        yvals.append(computeAvgs(avgs))
    pylab.plot(domain,yvals)
    pylab.xlabel("Room Size")
    pylab.ylabel("Average Time")
    pylab.title("Room Size v. Average Time To Clean")
    pylab.show()

def showPlot2():
    """
    Produces a plot showing dependence of cleaning time on number of robots.
    """
    xvals = []
    yvals = []
    maxBots = 10
    for bot in range(1,maxBots + 1):
        xvals.append(bot)
        avgs = runSimulation(bot, 1.0, 25,25, .75, 10, Robot, False)
        yvals.append(computeAvgs(avgs))
    pylab.plot(xvals,yvals)
    pylab.xlabel("Number of Robots")
    pylab.ylabel("Average Time")
    pylab.title("Number of Robots v. Average Time To Clean")
    pylab.show()


def showPlot3():
    """
    Produces a plot showing dependence of cleaning time on room shape.
    20x20, 25x16, 40x10, 50x8, 80x5, and 100x4
    """
    ratioWidHeight = []
    yvals = []
    roomSizes = [(20,20), (25,16), (40,10), (50,8), (80,5), (100,4)]
    for room in roomSizes:
        ratioWidHeight.append(room[0]/room[1])
        avg = runSimulation(2, 1.0, room[0], room[1], .75, 20, Robot, False)
        yvals.append(computeAvgs(avg))
    pylab.plot(ratioWidHeight, yvals)
    pylab.xlabel("Ratio of Width to Height of Room")
    pylab.ylabel("Average Time")
    pylab.title("Ratio of Width to Height of A room v. Average Time To Clean")
    pylab.show()


def createPercentile():
    percentileList = []
    for i in range(10, 100, 10):
        percentileList.append(i * .01)
    return percentileList


def showPlot4():
    """
    Produces a plot showing cleaning time vs. percentage cleaned, for
    each of 1-5 robots.
    """
    percentileList = createPercentile()
    maxBots = 5
    for numBot in range(1, maxBots + 1):
        yvals = []
        for minCovered in percentileList:
            avg = runSimulation(numBot, 1.0, 25, 25, minCovered, 10, Robot, False)
            yvals.append(computeAvgs(avg))
        pylab.plot(percentileList, yvals, label = "%i Robots" %numBot)
    pylab.legend(loc = "upper left")
    pylab.title("Cleaning Time vs. Percentage Cleaned With 1-5 Robots")
    pylab.xlabel("Minimum Coverage of Floor")
    pylab.ylabel("Average Time")
    pylab.show()





class RandomWalkRobot(BaseRobot):
    """
    A RandomWalkRobot is a robot with the "random walk" movement
    strategy: it chooses a new direction at random after each
    time-step.
    """
    def randomDirection(self):
        pass



    def updatePositionAndClean(self):
        robotPosition = self.getRobotPosition()
        # print robotPosition, "initial"
        self.rm.cleanTileAtPosition(robotPosition)
        self.dir = random.randint(0,359)
        direction = self.dir
        speed = self.speed
        potentialPosition = robotPosition.getNewPosition(direction, speed)
        # print potentialPosition, "new "
        postion_in_room = self.rm.isPositionInRoom(potentialPosition)
        if postion_in_room == True:
            self.pos = potentialPosition
            return self.pos
        else:
            self.setRobotDirection(random.randint(0,359))
            return self.updatePositionAndClean()



# === Problem 6

def showPlot5():
    """
    Produces a plot comparing the two robot strategies.
    """
    """ Time for two robots to clean a 10x10 """
    roomSizes = (5,5)
    xvals = []
    yvalsreg = []
    yvalsrandom = []
    for i in range(1, 6):
        xvals.append(5*i)
        reg = runSimulation(1, 1.0, roomSizes[0]*i, roomSizes[1]*i, .99, 10, Robot, False)
        randomWalkBots = runSimulation(1, 1.0, roomSizes[0]*i, roomSizes[1]*i, .99, 10, RandomWalkRobot, False)
        yvalsreg.append(computeAvgs(reg))
        yvalsrandom.append(computeAvgs(randomWalkBots))
    pylab.plot(xvals, yvalsreg, label = "Regular Robot")
    pylab.plot(xvals, yvalsrandom, label = "Random Walk Robot")
    pylab.legend(loc = "upper left")
    pylab.title("Cleaning Time vs. Percentage Cleaned With 1-5 Robots")
    pylab.xlabel("Dimensions of Floor")
    pylab.ylabel("Average Time")
    pylab.show()

def showPlot6():
    numBots = 10
    roomSize = (15,15)
    xVals = []
    yValsReg = []
    yValsRandom = []
    for i in range(1, numBots + 1):
        xVals.append(i)
        regBots = runSimulation(i, 1.0, roomSize[0], roomSize[1], .99, 50, Robot, False)
        randomBots = runSimulation(i, 1.0, roomSize[0], roomSize[1], .99, 50, RandomWalkRobot, False)
        avgTimeReg = computeAvgs(regBots)
        avgTimeRandom = computeAvgs(randomBots)
        yValsReg.append(avgTimeReg)
        yValsRandom.append(avgTimeRandom)
    pylab.plot(xVals, yValsReg, "bo", label = "Regular Robots")
    pylab.plot(xVals, yValsRandom, "ro", label = "Random Walk Robots")
    pylab.legend(loc = "upper right")
    pylab.title(" Average Time To Clean 15x15 With 1-10 Robots ")
    pylab.xlabel(" Number of Robots ")
    pylab.ylabel(" Average Time To Finish Room " )
    pylab.show()





    
