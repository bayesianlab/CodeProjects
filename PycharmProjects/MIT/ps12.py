# 6.00 Problem Set 12
#
# Name:
# Collaborators:
# Time:

import numpy
import random
import pylab
from ps11 import*

def addLists(list_of_lists):
    """
    Assumes all lists are same length
    :param list_of_lists:
    :return: sum across multiple lists of element i for all i.
    """
    sumOfLists = []
    x = -1
    y = -1
    for i in range(0, len(list_of_lists[0])):
        x += 1
        keep = 0
        while y < len(list_of_lists) - 1:
            y += 1
            keep += list_of_lists[y][x]
            # raw_input()
        y = -1
        sumOfLists.append(keep)
    return sumOfLists

def computeAverageAcrossLists(list_of_lists):
    if len(list_of_lists) == 1:
        return list_of_lists[0]
    else:
        sumOfLists = addLists(list_of_lists)
        numElems = len(list_of_lists)
        mean = []
        for i in sumOfLists:
            mean.append(i / float(numElems))
        return mean

class NoChildException(Exception):
    """
    NoChildException is raised by the reproduce() method in the SimpleVirus
    and ResistantVirus classes to indicate that a virus particle does not
    reproduce. You can use NoChildException as is, you do not need to
    modify/add any code.
    """    



class SimpleVirus(object):
    """
    Representation of a simple virus (does not model drug effects/resistance).
    """
    
    def __init__(self, maxBirthProb, clearProb):
        """
        Initialize a SimpleVirus instance, saves all parameters as attributes
        of the instance.        
        
        maxBirthProb: Maximum reproduction probability (a float between 0-1)        
        
        clearProb: Maximum clearance probability (a float between 0-1).
        """
        self.maxBirthProb = maxBirthProb
        self.clearProb = clearProb

    def doesClear(self):
        """
        Stochastically determines whether this virus is cleared from the
        patient's body at a time step. 

        returns: Using a random number generator (random.random()), this method
        returns True with probability self.clearProb and otherwise returns
        False.
        """

        draw = random.random()
        # print draw, "d"
        if self.clearProb >= draw:
            return True
        else:
            return False
    
    def reproduce(self, popDensity):
        """
        Stochastically determines whether this virus particle reproduces at a
        time step. Called by the update() method in the SimplePatient and
        Patient classes. The virus particle reproduces with probability
        self.maxBirthProb * (1 - popDensity).
        
        If this virus particle reproduces, then reproduce() creates and returns
        the instance of the offspring SimpleVirus (which has the same
        maxBirthProb and clearProb values as its parent).         

        popDensity: the population density (a float), defined as the current
        virus population divided by the maximum population.         
        
        returns: a new instance of the SimpleVirus class representing the
        offspring of this virus particle. The child should have the same
        maxBirthProb and clearProb values as this virus. Raises a
        NoChildException if this virus particle does not reproduce.               
        """
        splitProb = self.maxBirthProb * (1 - popDensity)
        cut = random.random()
        # print splitProb, cut, "split prob, cut"
        if splitProb >= cut:
            return SimpleVirus(self.maxBirthProb, self.clearProb)
        else:
            raise NoChildException()


class SimplePatient(object):
    """
    Representation of a simplified patient. The patient does not take any drugs
    and his/her virus populations have no drug resistance.
    """
    
    def __init__(self, viruses, maxPop):
        """
        Initialization function, saves the viruses and maxPop parameters as
        attributes.

        viruses: the list representing the virus population (a list of
        SimpleVirus instances)
        
        maxPop: the  maximum virus population for this patient (an integer)
        """
        self.viruses = viruses
        self.maxPop = maxPop

    def popDensity(self):
        return self.getTotalPop() / float(self.maxPop)

    def getTotalPop(self):
        """
        Gets the current total virus population. 

        returns: The total virus population (an integer)
        """
        return len(self.viruses)

    def listSnip(self, locationToSnip, aList):
        """
        Snips a list and patches it

        :return: Sniiped list
        """
        if len(aList) > 0:
            return aList[:locationToSnip] + aList[(locationToSnip + 1):]
        else:
            return []

    def virusDieOff(self):
        lenList = len(self.viruses)
        x = 0
        while x <= lenList:
            try:
                clear = self.viruses[x].doesClear()
                if clear == True:

                    self.viruses = self.listSnip(x, self.viruses)

                    x -= 1
                x += 1
            except:
                IndexError
                break
        # return self.viruses

    def virusGrowth(self, pDense):
        for virusObj in self.viruses:
            try:
                self.viruses.append(virusObj.reproduce(pDense))
            except:
                NoChildException

    def update(self):
        """
        Update the state of the virus population in this patient for a single
        time step. update() should execute the following steps in this order:

        - Determine whether each virus particle survives and updates the list
          of virus particles accordingly.

        - The current population density is calculated. This population density
          value is used until the next call to update() 

        - Determine whether each virus particle should reproduce and add
          offspring virus particles to the list of viruses in this patient.                    

        returns: the total virus population at the end of the update (an
        integer)
        """
        self.virusDieOff()
        self.virusGrowth(self.popDensity())
        return self.getTotalPop()


def problem2():
    """
    Run the simulation and plot the graph for problem 2 (no drugs are used,
    viruses do not have any drug resistance).    

    Instantiates a patient, runs a simulation for 300 timesteps, and plots the
    total virus population as a function of time.    
    """
    diseases = []
    numViruses = 100
    maxBirthProb = 0.10
    clearProb = 0.05
    maxPop = 1000
    for i in range(0,numViruses):
        diseases.append(SimpleVirus(maxBirthProb, clearProb))
    patient = SimplePatient(diseases, maxPop)
    timeSteps = 300
    yVals = []
    yValSto = []
    xVals = range(0,timeSteps)
    for i in range(0, 1):
        for step in range(0, timeSteps):
            yVals.append(patient.update())
        yValSto.append(yVals)
        yVals = []
    mean = computeAverageAcrossLists(yValSto)
    pylab.plot(xVals, mean)
    pylab.title(" Virus population vs Time ")
    pylab.xlabel(" Time ")
    pylab.ylabel(" Virus Growth ")
    pylab.show()

# problem2()

class ResistantVirus(SimpleVirus):
    """
    Representation of a virus which can have drug resistance.
    """

    def __init__(self, maxBirthProb, clearProb, resistances, mutProb):
        """
        Initialize a ResistantVirus instance, saves all parameters as attributes
        of the instance.
        
        maxBirthProb: Maximum reproduction probability (a float between 0-1)        
        
        clearProb: Maximum clearance probability (a float between 0-1).
        
        resistances: A dictionary of drug names (strings) mapping to the state
        of this virus particle's resistance (either True or False) to each drug.
        e.g. {'guttagonol':False, 'grimpex',False}, means that this virus
        particle is resistant to neither guttagonol nor grimpex.

        mutProb: Mutation probability for this virus particle (a float). This is
        the probability of the offspring acquiring or losing resistance to a drug.        
        """
        self.maxBirthProb = maxBirthProb
        self.clearProb = clearProb
        self.resistances = resistances
        self.mutProb = mutProb

    def getResistance(self, drug):
        """
        Get the state of this virus particle's resistance to a drug. This method
        is called by getResistPop() in Patient to determine how many virus
        particles have resistance to a drug.        

        drug: the drug (a string).

        returns: True if this virus instance is resistant to the drug, False
        otherwise.
        """
        try:
            if self.resistances[drug] == True:
                return True
            else:
                return False
        except:
            KeyError
            return False

    def mutate(self):
        aDict = self.resistances.copy()
        for drug in self.resistances:
            aRando = random.random()
            if self.resistances[drug] == True:
                if aRando <= self.mutProb:
                    aDict[drug] = False
            else:
                if aRando <= self.mutProb:
                    aDict[drug] = True
        return aDict

    def reproduceB(self, popDensity, activeDrugs):
        """
        Stochastically determines whether this virus particle reproduces at a
        time step. Called by the update() method in the Patient class.

        If the virus particle is not resistant to any drug in activeDrugs,
        then it does not reproduce. Otherwise, the virus particle reproduces
        with probability:       
        
        self.maxBirthProb * (1 - popDensity).                       
        
        If this virus particle reproduces, then reproduce() creates and returns
        the instance of the offspring ResistantVirus (which has the same
        maxBirthProb and clearProb values as its parent). 

        For each drug resistance trait of the virus (i.e. each key of
        self.resistances), the offspring has probability 1-mutProb of
        inheriting that resistance trait from the parent, and probability
        mutProb of switching that resistance trait in the offspring.        

        For example, if a virus particle is resistant to guttagonol but not
        grimpex, and `self.mutProb` is 0.1, then there is a 10% chance that
        that the offspring will lose resistance to guttagonol and a 90% 
        chance that the offspring will be resistant to guttagonol.
        There is also a 10% chance that the offspring will gain resistance to
        grimpex and a 90% chance that the offspring will not be resistant to
        grimpex.

        popDensity: the population density (a float), defined as the current
        virus population divided by the maximum population        

        activeDrugs: a list of the drug names acting on this virus particle
        (a list of strings). 
        
        returns: a new instance of the ResistantVirus class representing the
        offspring of this virus particle. The child should have the same
        maxBirthProb and clearProb values as this virus. Raises a
        NoChildException if this virus particle does not reproduce.         
        """
        for drug in activeDrugs:
            if self.getResistance(drug) == False:
                raise NoChildException()
        randNum = random.random()
        cut = self.maxBirthProb * (1 - popDensity)
        if cut >= randNum:
            return ResistantVirus(self.maxBirthProb, self.clearProb,  self.mutate(), self.mutProb)
        else:
            raise NoChildException()


class Patient(SimplePatient):
    """
    Representation of a patient. The patient is able to take drugs and his/her
    virus population can acquire resistance to the drugs he/she takes.
    """
    
    def __init__(self, viruses, maxPop):
        """
        Initialization function, saves the viruses and maxPop parameters as
        attributes. Also initializes the list of drugs being administered
        (which should initially include no drugs).               

        viruses: the list representing the virus population (a list of
        SimpleVirus instances)
        
        maxPop: the  maximum virus population for this patient (an integer)
        """
        self.maxPop = maxPop
        self.viruses = viruses
        self.drugs = []
        
    def addPrescription(self, newDrug):
        """
        Administer a drug to this patient. After a prescription is added, the 
        drug acts on the virus population for all subsequent time steps. If the
        newDrug is already prescribed to this patient, the method has no effect.

        newDrug: The name of the drug to administer to the patient (a string).

        postcondition: list of drugs being administered to a patient is updated
        """
        if newDrug not in self.drugs:
            self.drugs.append(newDrug)
        else:
            pass

    def getPrescriptions(self):
        """
        Returns the drugs that are being administered to this patient.

        returns: The list of drug names (strings) being administered to this
        patient.
        """
        return self.drugs
        
    def getResistPop(self, drugResist):
        """
        Get the population of virus particles resistant to the drugs listed in 
        drugResist.        

        drugResist: Which drug resistances to include in the population (a list
        of strings - e.g. ['guttagonol'] or ['guttagonol', 'grimpex'])

        returns: the population of viruses (an integer) with resistances to all
        drugs in the drugResist list.
        """
        assert type(drugResist) == list
        resAll = 0
        for v in self.viruses:
            redLight = False
            for i in drugResist:
                if v.resistances[i] == False:
                    redLight = True
                    break
            if redLight == False:
                resAll += 1
        return resAll

    def virusDieOff(self):
        lenList = len(self.viruses)
        x = 0
        while x <= lenList:
            try:
                clear = self.viruses[x].doesClear()
                if clear == True:
                    self.viruses = self.listSnip(x, self.viruses)
                    x -= 1
                x += 1
            except:
                IndexError
                break

    def virusGrowth(self, pD):
        for virusObj in self.viruses:
            try:
                self.viruses.append(virusObj.reproduceB(pD, self.drugs))
            except:
                NoChildException


    def update(self):
        """
        Update the state of the virus population in this patient for a single
        time step. update() should execute these actions in order:

        - Determine whether each virus particle survives and update the list of
          virus particles accordingly
          
        - The current population density is calculated. This population density
          value is used until the next call to update().

        - Determine whether each virus particle should reproduce and add
          offspring virus particles to the list of viruses in this patient. 
          The listof drugs being administered should be accounted for in the
          determination of whether each virus particle reproduces. 

        returns: the total virus population at the end of the update (an
        integer)
        """
        self.virusDieOff()
        pD = self.popDensity()
        self.virusGrowth(pD)
        return self.getTotalPop()

#
# PROBLEM 4
#

def genVirsus(num, maxBirthP, clearP, resistances, mutP):
    vList = []
    for i in range(0,num):
        vList.append(ResistantVirus(maxBirthP, clearP, resistances, mutP))
    return vList

def problem4():
    """
    Runs simulations and plots graphs for problem 4.

    Instantiates a patient, runs a simulation for 150 timesteps, adds
    guttagonol, and runs the simulation for an additional 150 timesteps.

    total virus population vs. time  and guttagonol-resistant virus population
    vs. time are plotted
    """
    vzz = genVirsus(100, 0.1, 0.05, {'guttagonol': False}, .005)
    patient = Patient(vzz, 1000)
    tSteps = 300
    numSims = 1
    aggRes = []
    aggTot = []
    res =[]
    tot = []
    for sim in range(0, numSims):
        for t in range(0, tSteps):
            if t == 149:
                patient.addPrescription(['guttagonol'])
            tot.append(patient.update())
            res.append(patient.getResistPop(['guttagonol']))
        # tot = []
        # res = []
    print tot
    pylab.plot(range(0,tSteps), tot, "r", label = "Total Population")
    pylab.plot(range(0,tSteps), res, "g", label = "Total Resistant Population to Guttagonol")
    pylab.legend(loc = "upper left")
    pylab.title("Virus Population Growth With Treatment of Guttagonal at t = 150")
    pylab.xlabel("Time (0, 300)")
    pylab.ylabel("Population")
    pylab.show()

# problem4()

#
# PROBLEM 5
def problem5():
    """
    Runs simulations and make histograms for problem 5.

    Runs multiple simulations to show the relationship between delayed treatment
    and patient outcome.

    Histograms of final total virus populations are displayed for delays of 300,
    150, 75, 0 timesteps (followed by an additional 150 timesteps of
    simulation).    
    """
    vzz1 = genVirsus(100, 0.1, 0.05, {'guttagonol': False}, .005)
    vzz2 = genVirsus(100, 0.1, 0.05, {'guttagonol': False}, .005)
    vzz3 = genVirsus(100, 0.1, 0.05, {'guttagonol': False}, .005)
    vzz4 = genVirsus(100, 0.1, 0.05, {'guttagonol': False}, .005)
    patA = Patient(vzz1, 1000)
    patB = Patient(vzz2, 1000)
    patC = Patient(vzz3, 1000)
    patD = Patient(vzz4, 1000)
    tSteps = 450
    numSims = 1
    patAYTot = []
    patARes = []

    patBYTot = []
    patBRes = []

    patCYTot = []
    patCRes = []

    patDYTot = []
    patDRes = []
    drug = ['guttagonol']
    for s in range(0, numSims):
        for t in range(0, tSteps):
            if t == 0:
                patD.addPrescription(drug)
            elif t == 74:
                patC.addPrescription(drug)
            elif t == 149:
                patB.addPrescription(drug)
            elif t == 299:
                patA.addPrescription(drug)
            patAYTot.append(patA.update())
            patARes.append(patA.getResistPop(drug))
            patB.update()
            patC.update()
            patD.update()
        # patAYTot.append(patA.getTotalPop())
        # patARes.append(patA.getResistPop(drug))
        # patBYTot.append(patB.getTotalPop())
        # patBRes.append(patB.getResistPop(drug))
        # patCYTot.append(patC.getTotalPop())
        # patCRes.append(patC.getResistPop(drug))
        # patDYTot.append(patD.getTotalPop())
        # patDRes.append(patD.getResistPop(drug))
        # patAYTot = []
        # patARes = []
        #
        # patBYTot = []
        # patBRes = []
        #
        # patCYTot = []
        # patCRes = []
        #
        # patDYTot = []
        # patDRes = []
    pylab.plot(range(0,tSteps), patAYTot)
    pylab.plot(range(0,tSteps), patARes)
    pylab.show()





# problem5()

#
# PROBLEM 6
#

def problem6():
    """
    Runs simulations and make histograms for problem 6.

    Runs multiple simulations to show the relationship between administration
    of multiple drugs and patient outcome.
    
    Histograms of final total virus populations are displayed for lag times of
    150, 75, 0 timesteps between adding drugs (followed by an additional 150
    timesteps of simulation).
    """
    # TODO

#
# PROBLEM 7
#
     
def problem7():
    """
    Run simulations and plot graphs examining the relationship between
    administration of multiple drugs and patient outcome.

    Plots of total and drug-resistant viruses vs. time are made for a
    simulation with a 300 time step delay between administering the 2 drugs and
    a simulations for which drugs are administered simultaneously.        
    """
    # TODO
