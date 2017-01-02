__author__ = 'dillonflannery-valadez'

scores = [36.0/43, 34.0/43, 30.0/43, 29.0/43, 27.0/43, 21.0/43, 32.0/43, 17.0/43, 28.0/43, 26.0/43]
names = ["marcus", "priscilla", "karen", "melody", "gustavo", "gabriela", "erika", "angel", "caleb", "erika p"]

print
print "Unadjusted scores: "
for i, j in zip(scores, names):
    print 100*round(i, 5), j

# Adjustsed score

adjusted_scores = []
for i in scores:
    temp = (43*(i) + 2.6) / 43
    adjusted_scores.append(temp)
print
print "Adjusted scores: "
for i,k, j in zip(adjusted_scores, scores , names):
    print j + "'s score is: %.3f" %(100*round(i, 5)) + "%", 43*k

