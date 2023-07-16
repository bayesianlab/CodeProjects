#!/home/dillon/venvs/myenv/bin/python 

#%%
import pandas as pd 
from pdfminer.pdfparser import PDFParser
from pdfminer.pdfdocument import PDFDocument
from io import BytesIO
import sqlite3
import os 
import glob
from pathlib import Path 

con = sqlite3.connect("pdfs.db") 

def column_names(con): 
    sql = "select * from pdfs"
    cur = con.cursor() 
    d = cur.execute(sql) 
    return [i[0] for i in d.description]

    
def insert_into(con, tablename, data):
    cnames = column_names(con) 
    cur = con.cursor()
    vals = [] 
    columns_in = []    
    for i in cnames:
        try:
            vals.append(data[i])  
            columns_in.append(i) 
        except:
            pass 
    vals = '"' + '","'.join(vals) + '"' 
    columns_in = ', '.join(columns_in) 
    sql = """ insert into {0}({1}) values({2})""".format(tablename,columns_in, vals)  
    cur.execute(sql) 
    con.commit()

def connect_to(con, id,  tags):
    cur = con.cursor()
    for i in tags:
        try:
            cur.execute("""insert into connections(research_id, tag) values("{0}", "{1}")""".format(id, i))
        except:
            pass 
    con.commit() 
    


#%%
pdfdb = pd.read_sql("select * from pdfs", con)  
fnames = list(pdfdb['file'] ) 
pdffiles = glob.glob('*.pdf') 
new_files = [] 
for i in pdffiles:
    if i not in fnames:
        fp = open(i, 'rb')
        parser = PDFParser(fp)
        doc = PDFDocument(parser)
        new_files.append(i)  

for i in new_files:
    insert_into(con, "pdfs", {'file':i}) 


pdfdb = pd.read_sql("select * from pdfs", con)  
# print(pdfdb)
connect_to(con, "1", ["gibbs", "mcmc", "jeliazkov"]) 
print(pd.read_sql("select * from connections", con))

# %%
