#!/home/dillon/miniconda3/ens/test/bin/python
import sqlite3
import pandas as pd
import os
import pikepdf
import argparse
import subprocess
import re
import datetime
from dateutil.tz import tzutc, tzoffset
import sys


con = sqlite3.connect("/home/dillon/GoogleDrive/PDFs/testpdfs/mylib.db")

class Library:
    def __init__(self, con) -> None:
        self.con = con 
        self.cur = self.con.cursor()
        self.cur.execute("""
                    create table if not exists
                    library(
                        Title string Primary key,
                        Authors string Not Null,
                        Date integer not null,
                        filename string not null
                    )
                    """)
        self.cur.execute("""
                         create table if not exists
                         tags(
                             Title string Primary key,
                             Tag string not null)
                         """)
        self.cur.execute("""
                         create table if not exists
                         quotes(
                             Title Primary key,
                             Quote not null)
                             """
                         )
        self.cur.execute("""
                         create table if not exists
                         cachedfiles(FileName Primary Key,
                         Cached integer)
                         """)

    def insert_record(self, info_dict):
        insertstring = "insert or replace into library values ( '{0}', '{1}', {2}, '{3}')".format(info_dict["/Title"],
                                                                                           info_dict["/Author"],
                                                                                           info_dict["/CreationDate"],
                                                                                           info_dict['filename'])
        self.cur.execute(insertstring)
        self.con.commit()

    def insert_tags(self, title, taglist):
        for i in taglist:
            insert = """
                insert or replace into tags values(
                    {0}, {1}
                )
                """.format(title, i)
            self.cur.execute(insert)
        self.con.commit()

    def print_db(self):
        df = pd.read_sql_query("select * from library", self.con)
        print(df)
        # for r in self.cur.execute("select * from library"):
        #     print(r)

    def delete_record(self, title):
        delstring = "delete from library where Title = '{0}'".format(title)
        self.cur.execute(delstring)
        self.con.commit()

    def close_con(self):
        self.con.close()


class ScanDir:
    def __init__(self, path, con) -> None:
        self.con = con 
        self.pdfmetadata = []
        self.path = path
        self.scan1()
        self.scan2()
        
    def scan1(self):
        os.chdir(self.path)
        files = os.listdir(self.path)
        cur = self.con.cursor() 
        for i in files:
            m = i.find(".")
            if(i[m:] == ".pdf"):
                cur.execute(""" 
                        insert or ignore into 
                        cachedfiles values('{0}', {1})
                        """.format(i, 0))

    def scan2(self):
        os.chdir(self.path)
        files = os.listdir(self.path)
        for i in files:
            m = i.find(".")
            d = {}
            if(i[m:] == ".pdf"):
                r = pikepdf.Pdf.open(i)
                r = r.docinfo
                d['filename'] = i 
                for key, value in r.items():
                    try: 
                        if str(value).startswith("D:"):
                            value = transform_date(str(r["/CreationDate"])).year  
                        d[key] = value
                    except:
                        d[key] = value
                    if(key == "/Title" and value == ''):
                        d[key] = i
                self.pdfmetadata.append(d)
        




pdf_date_pattern = re.compile(''.join([
    r"(D:)?",
    r"(?P<year>\d\d\d\d)",
    r"(?P<month>\d\d)",
    r"(?P<day>\d\d)",
    r"(?P<hour>\d\d)",
    r"(?P<minute>\d\d)",
    r"(?P<second>\d\d)",
    r"(?P<tz_offset>[+-zZ])?",
    r"(?P<tz_hour>\d\d)?",
    r"'?(?P<tz_minute>\d\d)?'?"]))

def transform_date(date_str):
    """
    Convert a pdf date such as "D:20120321183444+07'00'" into a usable datetime
    http://www.verypdf.com/pdfinfoeditor/pdf-date-format.htm
    (D:YYYYMMDDHHmmSSOHH'mm')
    :param date_str: pdf date string
    :return: datetime object
    """
    global pdf_date_pattern
    match = re.match(pdf_date_pattern, date_str)
    if match:
        date_info = match.groupdict()

        for k, v in date_info.items():  # transform values
            if v is None:
                pass
            elif k == 'tz_offset':
                date_info[k] = v.lower()  # so we can treat Z as z
            else:
                date_info[k] = int(v)

        if date_info['tz_offset'] in ('z', None):  # UTC
            date_info['tzinfo'] = tzutc()
        else:
            multiplier = 1 if date_info['tz_offset'] == '+' else -1
            date_info['tzinfo'] = tzoffset(None, multiplier*(3600 * date_info['tz_hour'] + 60 * date_info['tz_minute']))

        for k in ('tz_offset', 'tz_hour', 'tz_minute'):  # no longer needed
            del date_info[k]

        return datetime.datetime(**date_info)


lib = Library(con)
sd = ScanDir('/home/dillon/GoogleDrive/PDFs/testpdfs', con)


def check_cached(con):
    # res = con.execute(
    # """
    # select cachedfiles.filename, cachedfiles.Cached
    # from library 
    # inner join cachedfiles on library.filename = cachedfiles.filename
    # """
    # )
    cur = con.cursor()
    res = cur.execute("""
    select cachedfiles.filename, cachedfiles.Cached
    from library 
    inner join cachedfiles on 
    library.filename = cachedfiles.filename
    """)
    con.commit()
    
    
    
    # df= pd.read_sql_query("select * from cachedfiles", con)
    # print(df)
    
check_cached(lib.con)        


for rec in sd.pdfmetadata:
    lib.insert_record(rec)

lib.print_db()
lib.close_con()
