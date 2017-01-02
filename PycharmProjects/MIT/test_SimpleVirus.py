from unittest import TestCase
from ps12 import*

__author__ = 'dillonflannery-valadez'



class TestSimpleVirus(TestCase):
    def test_doesClear(self):
        random.seed(1)
        vir = SimpleVirus(.55, .13)
        self.assertTrue(vir.doesClear())

    def test_doesClear(self):
        virus = SimpleVirus(.3, .6)
        maxtrials = 100000
        counter = 0
        for trial in range(0, maxtrials):
            if virus.doesClear() == True:
                counter += 1
        percentCleared = counter / float(maxtrials)
        print percentCleared
        self.assertAlmostEqual(.6, percentCleared, 2)
        virus = SimpleVirus(.3, .05)
        counter = 0
        for trial in range(0, maxtrials):
            if virus.doesClear() == True:
                counter += 1
        percentCleared = counter / float(maxtrials)
        print percentCleared

    def test_reproduce(self):
        random.seed(1)
        virus = SimpleVirus(.55, .13)
        child = virus.reproduce(.5)
        self.assertIsInstance(child, SimpleVirus, "Test Failed. Not of class SimpleVirus")
        self.assertRaises(NoChildException, virus.reproduce, 0.00)
        random.seed()
        virus = SimpleVirus(.30, .20)
        passRate = virus.maxBirthProb * .5
        children = 0
        maxTrials = 100000
        for trial in range(0,maxTrials):
            try:
                virus.reproduce(.50)
                children += 1
            except:
                NoChildException
        print children
        percentInstances = children / float(maxTrials)
        print percentInstances
        self.assertAlmostEqual(passRate, percentInstances, 2)

    def test_listSnip(self):
        vir1 = SimpleVirus(.5,.5)
        vir2 = SimpleVirus(.5,.5)
        vir3 = SimpleVirus(.5,.5)
        dis = [vir1, vir2, vir3]
        patient = SimplePatient(dis, 5)
        patient.viruses = patient.listSnip(0, patient.viruses)
        self.assertTrue(vir1 not in patient.viruses)
        patient.viruses.append(vir1)
        patient.viruses = patient.listSnip(1, patient.viruses)
        self.assertTrue(vir3 not in patient.viruses)
        lis = [1,2,3,4,5,6,7,8,9]
        print patient.listSnip(0,lis)
        print patient.listSnip(8, lis)
        print patient.listSnip(3, lis)
        print patient.listSnip(10, lis)

    def test_virusDieOff(self):
        print
        print "Virus Die Off Tests"
        sims = 1000
        avg = 0
        for s in range(0,sims):
            vzz = genVirsus(100, .10, .05, {'guttagonol': False}, .10)
            p = Patient(vzz, 1000)
            p.virusDieOff()
            avg += (100 - p.getTotalPop()) / float(100)
        avg = avg / sims
        print avg
        self.assertAlmostEqual(avg, .05, 2)
        vzz = genVirsus(100, .10, .05, {'guttagonol': False}, .10)
        p = Patient(vzz, 1000)
        sims = 60
        for s in range(0,sims):
            startP = p.getTotalPop()
            p.virusDieOff()
            avg += ( startP - p.getTotalPop()) / float(startP)
        avg = avg / sims
        print avg
        self.assertAlmostEqual(avg, .05, 1)












    def test_virusGrowth(self):
        print
        print " Virus Growth Tests "
        random.seed(1)
        v1 = SimpleVirus(.5,.5)
        v2 = SimpleVirus(.5,.5)
        v3 = SimpleVirus(.5,.5)
        vs = [v1, v2, v3]
        patient = SimplePatient(vs, 100)
        patient.virusGrowth()
        print patient.getTotalPop()
        self.assertTrue(len(patient.viruses) == 4)

    def test_update(self):
        print
        print " Update Tests "
        random.seed(1)
        v1 = SimpleVirus(.5,.5)
        v2 = SimpleVirus(.5,.5)
        v3 = SimpleVirus(.5,.5)
        vs = [v1, v2, v3]
        patient = SimplePatient(vs, 100)
        patient.update()
        print patient.viruses

    def test_getResistence(self):
        drugDict = {"a": True, "b": False, 'c': False}
        resVir = ResistantVirus(.5,.5,{"a": True}, .5)
        self.assertTrue(resVir.getResistance("a") == True)
        resVir2 = ResistantVirus(.5,.5,drugDict, .5)
        self.assertFalse(resVir2.getResistance("c"))
        self.assertTrue(not resVir2.getResistance("c"))
        self.assertFalse(resVir2.getResistance("d"))



    def test_mutate(self):
        print " Mutation Tests "

        maxTrials = 10000
        counter = 0
        for m in range(0,maxTrials):
            v = ResistantVirus(.5,.5,{'guttagonal': True, 'grimpex':False}, .10)
            if v.mutate()['guttagonal'] == False:
                counter += 1
        self.assertAlmostEqual( counter / float(maxTrials), .10, 2)
        counter1 = 0
        counter2 = 0
        for m in range(0,maxTrials):
            v = ResistantVirus(.5,.5,{'guttagonal': True, 'grimpex':False}, .10)
            if v.mutate()['grimpex'] == True:
                counter1 += 1
            if v.mutate()['guttagonal'] == True:
                counter2 += 1
        self.assertAlmostEqual(counter1 / float(maxTrials), .10, 2)
        self.assertAlmostEqual(counter2 / float(maxTrials), .90, 2)


    def test_reproduceResistent(self):
        # Reproduce on average 25% of the time.
        resVir = ResistantVirus(.5, .5, {"a": True, "b": False}, .5)
        maxTrials = 100000
        counter = 0
        for i in range(0, maxTrials):
            try:
                resVir.reproduceB(.5, ["a"])
                counter += 1
            except:
                NoChildException()
        self.assertAlmostEqual( counter / float(maxTrials), .25, 2)
        resVir = ResistantVirus(.5, .5, {"a": True, "b": False}, .5)
        maxTrials = 100000
        counter = 0
        for i in range(0, maxTrials):
            try:
                resVir.reproduceB(.5, ["b"])
                counter += 1
            except:
                NoChildException()
        self.assertAlmostEqual( counter / float(maxTrials), 0.0, 2)

    def test_initialization(self):
        virA = SimpleVirus(.5,.5)
        patA = SimplePatient([virA], 5)
        patB = Patient([virA], 5)
        # print patB.maxPop, patB.viruses
        virB = ResistantVirus(.5, .5, {"a": True, "b": False}, .5)
        patC = Patient([virB], 10)
        # print patC.getResistPop(["b"])
        vList = []
        for i in range(0,100):
            vList.append(ResistantVirus(.5, .5, {"a": True, "b": False}, .5))
        patD = Patient(vList, 1000)
        patD.virusDieOff()
        # print patD.maxPop, len(patD.viruses)
        # print patD.popDensity()
        maxTrials= 10000
        epi = .01
        c = 0
        for i in range(0, maxTrials):
            patD = Patient(vList, 1000)
            patD.virusGrowth(.10, "a")
            if patD.popDensity() - .145 < epi:
                c += 1
        self.assertAlmostEqual(c / float(maxTrials), .97, 2)


    def test_getResistPop(self):
        print "Get Resistant Population"
        vir1 = ResistantVirus(.5, .5, {"abacus": True, "b": False}, .5)
        pat = Patient([vir1], 5)
        self.assertIs(pat.getResistPop(["abacus"]), 1)
        vzz = genVirsus(101, .5,.5,{"acid": True, "bromide":False}, .5)
        pat = Patient(vzz, 1000)
        self.assertEqual(pat.getResistPop(['acid']), 101)
        self.assertEqual(pat.getResistPop(['bromide']), 0)


    def test_patient(self):
        """
        drugDict: a dictionary of resistances that the resistant viruses have.
        Add perscriptions to the patient.
        """
        random.seed(2)
        drugDict = {"a": True, "b": False, 'c': False}
        vir1 = ResistantVirus(.5,.5,drugDict, .5)
        vir2 = ResistantVirus(.5,.5,drugDict, .5)
        pat = Patient([vir1, vir2], 10)
        pat.addPrescription("a")
        print pat.drugs
        print pat.popDensity()
        print pat.getResistPop(pat.drugs)
        print pat.update()
        self.assertEqual(pat.update(), 2)











