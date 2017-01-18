from roperData import RoperData
#
# file_april9_1976 = 'april9_1976.dat'
# colNames = ['age', 'race', 'state', 'weights', 'educ', 'gender', 'question']
# beginIndices = [22, 25, 30, 32, 21, 25, 15]
# endIndices = [23, 25,31,32,21, 25, 15]
# whatRow = [0, 0, 0,0, 0, 0, 0]
# april9_1976 = RoperData(file_april9_1976)
# april9_1976.dataToCSV(1, colNames, beginIndices, endIndices, whatRow, 0, 'april9_1976')

# Age only given as birth year
# file_dec7_1982 = 'dec7_1982.DAT'
# colNames = ['weights', 'question', 'educ', 'age', 'race', 'gender', 'state']
# beginIndices = [24, 44, 51, 52, 60, 62, 73]
# endIndices = [32, 44, 51, 53, 60, 62, 73]
# whatRow = [2, 1, 1, 1, 1, 1, 1]
# dec7_1982 = RoperData(file_dec7_1982)
# dec7_1982.dataToCSV(3, colNames, beginIndices, endIndices, whatRow, 7, 'dec7_1982')

# file_feb8_1999 = 'feb8_1999.dat'
# colNames = ['weights', 'gender', 'age', 'educ', 'race', 'state', 'question']
# beginIndices = [12, 43, 44, 46, 13, 77, 51]
# endIndices = [14, 43, 45, 46, 14, 78, 51]
# whatRow = [0, 0, 0, 0, 4, 0, 6]
# feb8_1999 = RoperData(file_feb8_1999)
# feb8_1999.dataToCSV(7, colNames, beginIndices, endIndices, whatRow, 1, 'feb8_1999')

# no state
# file_feb23_1985 = 'feb23_1985.dat'
# colNames = ['weights', 'race', 'age', 'gender', 'educ', 'state']
# beginIndices = [15, 75, 32, 51, 37]
# whatRow = [0, 0, 0, 0, 0]
# feb23_1985 = RoperData(file_feb23_1985)
# feb23_1985.dataToCSV(3, colNames, beginIndices, endIndices, whatRow, 0, 'feb23_1985')
# endIndices = [19, 75, 33, 51, 37]

# file_jan10_1986 = 'jan10_1986.dat'
# colNames = ['state', 'weights', 'age', 'question', 'educ', 'gender', 'race']
# beginIndices = [189, 4, 172, 127, 171, 178, 179]
# endIndices = [190, 6, 173, 127, 171, 178, 179]
# whatRow = [0, 0, 0, 0, 0, 0, 0]
# jan10_1986 = RoperData(file_jan10_1986)
# jan10_1986.dataToCSV(1,colNames, beginIndices, endIndices, whatRow, 1, 'jan10_1986')

# Gallup poll
# file_jan11_1985 = 'jan11_1985.dat'
# jan11_1985 = RoperData(file_jan11_1985)
# colNames = ['state', 'educ', 'age', 'gender', 'race', 'question', 'weights']
# beginIndices = [92, 74, 75, 81, 82, 15, 4]
# endIndices = [93, 74, 76, 81, 82, 15, 6]
# whatRow = [0, 0, 0, 0, 0, 0, 0]
# jan11_1985.dataToCSV(1,colNames, beginIndices, endIndices, whatRow, 1, 'jan11_1985')

# # Gallup poll Gender and race in same question
# file_jan23_1969 = 'jan23_1969.dat'
# jan23_1969 = RoperData(file_jan23_1969)
# colNames = ['state', 'age', 'question', 'educ', 'genderrace', 'weights']
# beginIndices = [58, 50, 13, 43, 54, 62]
# endIndices = [59, 51, 13, 43, 54, 62]
# whatRow = [0, 0, 0, 0, 0, 0]
# jan23_1969.dataToCSV(1, colNames, beginIndices, endIndices, whatRow, 0, 'jan23_1969')

# # Gallup Poll
# file_jan30_1981 = 'jan30_1981.dat'
# jan30_1981 = RoperData(file_jan30_1981)
# colNames = ['state', 'educ', 'age', 'question', 'gender', 'race', 'weights']
# beginIndices = [154, 138, 139, 102, 145, 144, 0]
# endIndices = [155, 138, 139, 102, 145, 144, 0]
# whatRow = [0, 0, 0, 0, 0, 0, 0]
# jan30_1981.dataToCSV(1, colNames, beginIndices, endIndices, whatRow, 0, 'jan30_1981')

# # Gallup poll
# file_june13_1991 = 'june13_1991.dat'
# june13_1991 = RoperData(file_june13_1991)
# colNames = ['state', 'question', 'race', 'age', 'gender', 'educ', 'weights']
# beginIndices = [34, 167, 20, 17, 16, 19, 6]
# endIndices = [35, 167, 20, 18, 16, 19, 9]
# whatRow =[0, 0, 0, 0, 0, 0, 0]
# june13_1991.dataToCSV(1, colNames, beginIndices, endIndices, whatRow, 2, 'june13_1991')

# # Gallup poll
# file_march3_1972 = 'march3_1972.dat'
# march3_1972 = RoperData(file_march3_1972)
# colNames = ['question', 'educ', 'state', 'age', 'genderrace', 'weight']
# beginIndices = [11, 63, 71, 64, 67, 73]
# endIndices = [11, 63, 72, 65,67,73]
# whatRow =[0, 0, 0, 0, 0, 0]
# march3_1972.dataToCSV(1, colNames, beginIndices, endIndices, whatRow, 0, 'march3_1972')

# # Gallup poll
# file_march3_1978 = 'march3_1978.dat'
# march3_1978 = RoperData(file_march3_1978)
# colNames = ['weights', 'educ', 'age', 'question', 'genderrace', 'state']
# beginIndices = [0, 25, 26, 4, 29, 38]
# endIndices = [0,25,26, 4, 29,39]
# whatRow = [0,0, 0, 0, 0, 0]
# march3_1978.dataToCSV(1, colNames, beginIndices, endIndices, whatRow, 0, 'march3_1978')

# # Gallup poll
# file_may11_1995 = 'may11_1995.dat'
# may11_1995 = RoperData(file_may11_1995)
# colNames = ['state', 'question', 'gender', 'age', 'educ', 'race', 'weights']
# begIndices = [77, 52, 43, 44, 46, 75, 12]
# endIndices = [78, 52, 43, 45, 46, 76,14]
# whatRow = [0, 4, 0, 0, 0, 5, 0]
# may11_1995.dataToCSV(6, colNames, begIndices, endIndices, whatRow, 1, 'may11_1995')

# # Gallup poll
# file_nov10_1972 = 'nov10_1972.dat'
# nov10_1972 = RoperData(file_nov10_1972)
# colNames = ['state', 'educ', 'age', 'genderrace', 'question', 'weights']
# begIndices = [63, 43, 44, 47, 22, 66]
# endIndices = [64, 43, 45, 47, 22,66]
# whatRow = [1, 1, 1, 1, 1, 1]
# nov10_1972.dataToCSV(2, colNames, begIndices, endIndices, whatRow, 0, 'nov10_1972')

# # Gallup poll
# file_oct29_1971 = 'oct29_1971.dat'
# oct29_1971 = RoperData(file_oct29_1971)
# colNames = ['state', 'educ', 'question', 'genderrace', 'age', 'weights']
# begIndices = [12, 77, 61, 9, 78, 14]
# endIndices = [13, 77, 61, 9, 79, 14]
# whatRow = [1, 0, 0, 1, 0, 1]
# oct29_1971.dataToCSV(2, colNames, begIndices, endIndices, whatRow, 0 , 'oct29_1971')

# # Gallup poll
# file_sept6_1994 = 'sept6_1994.dat'
# sept6_1994 = RoperData(file_sept6_1994)
# colNames = ['state', 'question', 'gender', 'age', 'educ', 'race', 'weights']
# begIndices = [77, 61, 43, 44, 46, 75, 12]
# endIndices = [78, 61, 43, 45,46,76, 14]
# whatRow = [0, 4, 0, 0, 0, 5, 0]
# sept6_1994.dataToCSV(6, colNames, begIndices, endIndices, whatRow, 1, 'sept6_1994')