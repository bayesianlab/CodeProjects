import csv

class RoperData:

    def __init__(self, filename):
        self.filename = filename
        self.file = open(self.filename)
        for n, i in enumerate(self.file):
            pass
        self.nLines = n + 1
        self.file.close()
        print 'File %s has %s lines ' % (self.filename, self.nLines)

    def getCases(self, numCasesPerObs, colNames, begIndices, endIndices, rowOfColName):
        self.file = open(self.filename)
        totalCases = self.nLines / numCasesPerObs
        print "There are %i cases in this file." % totalCases
        rowMappedToVariableName = self.whereToExtract(colNames, rowOfColName)
        whatToExtractInRow = {name: indices for name, indices in zip(colNames, self.indicesToExtract(begIndices, endIndices))}
        extractedData = {name: [] for name in colNames}
        for case in range(0,totalCases):
            for c in range(0, numCasesPerObs):
                line = self.file.readline()
                try:
                    for i in rowMappedToVariableName[c]:
                        extractedData[i].append(line[whatToExtractInRow[i][0]:whatToExtractInRow[i][1]+1])
                except KeyError:
                    pass
        return extractedData
        self.file.close()

    def indicesToExtract(self, begIndices, endIndeces):
        indicesForExtraction =[]
        for i, j in zip(begIndices, endIndeces):
            indicesForExtraction.append((i,j))
        return indicesForExtraction

    def whereToExtract(self, names, rowWhereNameIs):
        whereColumnsAreInCase = {(c): [] for c in rowWhereNameIs}
        for index, row in enumerate(rowWhereNameIs):
            whereColumnsAreInCase[row].append(names[index])
        return whereColumnsAreInCase

    def dataToCSV(self, numCasesPerObs, colNames, begIndices, endIndices, rowOfColName, csvfile):
        data = self.getCases(numCasesPerObs, colNames, begIndices, endIndices, rowOfColName)
        print data['weights']
        print self.decimalWeights(data, 1)['weights']
        zd = zip(*data.values())
        with open(csvfile + '.csv', 'w') as file:
            writer = csv.writer(file, delimiter=',')
            writer.writerow(data.keys())
            writer.writerows(zd)

    def splitString(self, string, index):
        a = string[:index]
        b = string[index:]
        return ''.join([a,'.',b])

    def decimalWeights(self, casesDictionary, index):
        try:
            weights = casesDictionary['weights']
            casesDictionary['weights'] = [self.splitString(w, index) for w in weights]
            return casesDictionary
        except KeyError:
            print "No weights key, rename weights variable"
            return -1


file = 'feb8_1999.dat'

rd = RoperData(file)
d = {'weights':['012', '658']}
print rd.decimalWeights(d, 1)

colNames = ['weights', 'gender', 'age', 'educ', 'race', 'state']
beginIndices = [12, 43, 44, 46, 13, 77]
endIndices = [14, 43, 45, 46, 14, 78]
whatRow = [0, 0, 0, 0, 4, 0]

print rd.getCases(7, colNames, beginIndices, endIndices, whatRow)
# rd.dataToCSV(7, colNames, beginIndices, endIndices, whatRow, 'feb8_1999')
