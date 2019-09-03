import csv
import os

dics = [{'Color':'Red', 'Age':29, 'Date':'October 2nd', 'Time':'4pm'},
        {'Color':'Blue', 'Age':32, 'Date':'December 5th', 'Time':'6pm'},
        {'Color':'Green', 'Age':12, 'Date':'January 10th', 'Time':'2pm'}]

with open("file.csv",'wb') as f:
   # Using dictionary keys as fieldnames for the CSV file header
   writer = csv.DictWriter(f, dics[0].keys())
   writer.writeheader()
   for d in dics:
      writer.writerow(d)

print os.getcwd()