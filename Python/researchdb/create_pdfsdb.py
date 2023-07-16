#!/home/dillon/venvs/myenv/bin/python

import sqlite3

con = sqlite3.connect("pdfs.db") 
cur = con.cursor() 
cur.execute("Drop table if exists pdfs") 
cur.execute("Create Table if not exists pdfs(id Integer Primary Key autoincrement not null,  \
        file varchar not null, title varchar, author varchar, year Integer, journal varchar )")

cur.execute("drop table if exists connections")
cur.execute("Create Table if not exists connections(research_id not null, tag not null unique)")

con.commit() 
