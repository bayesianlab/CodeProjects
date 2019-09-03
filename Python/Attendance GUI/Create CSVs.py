__author__ = 'dillonflannery-valadez'

import csv
with open("mycsv.csv", "wb") as csvfile:
    write = csv.writer(csvfile, delimiter = ' ',quotechar='|',quoting=csv.QUOTE_MINIMAL)
    write.writerow(['Spam'] * 5 + ['Baked Beans'])
    write.writerow(['Spam', 'Lovely Spam', 'Wonderful Spam'])

