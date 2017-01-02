__author__ = 'dillonflannery-valadez'

import stat

names = ["marcus", "priscilla", "karen", "melody", "gustavo",
         "gabriela", "erikaL", "angel", "caleb", "erikaP", "junhyuk", "deborah"]
scores = [21.5, 23, 19.5, 21, 16, 16, 6, 0, 17, 14, 41, 31]

names_scores = zip(names, scores)

percentage_score = []
for name, score, in names_scores:
    percentage_score.append(100.0 * (score/(50.0)))
    # print name + "'s score is: %.2f" % (100.0 * (score/(50.0))) + " %"

def mean(data):
    numObs = len(data)
    total = 0.0
    for i in data:
        total += i
    return(round((total/ numObs), 4 ))

# print mean(scores), "average"
string_scores = ""
for i in scores:
    string_scores += str(i) + ", "
string_scores = string_scores[:len(string_scores) - 2]
print string_scores
# print mean(percentage_score), "average percentage"

csv_file = open("log_test.csv", "w")
csv_file.write(string_scores)
# print csv_file.read()
# print csv_file

csv_file.close()

