import sqlite3

con = sqlite3.connect('mydb.sqlite')

csr = con.cursor()

tableName = 'Bible'

field1 = 'Book'

type1 = 'INTEGER NOT NULL'

field2 = 'Chapter'

type2 = 'INTEGER NOT NULL'

field3 = 'Verse'

type3= 'INTEGER NOT NULL'

field4 = 'Markup'

type4 = 'TEXT'

field5 = 'Strongs'

type5 = 'INTEGER'

field6 = 'Text'

type6 = 'TEXT NOT NULL'

csr.execute('DROP TABLE IF EXISTS {tn}'.format(tn=tableName))
csr.execute('CREATE TABLE {tn} ({f1} {t1}, {f2} {t2}, {f3} {t3}, '
            '{f4} {t4}, {f5} {t5}, {f6} {t6})'.format(tn=tableName, f1=field1, t1=type1,
                                           f2=field2, t2=type2, f3=field3, t3=type3,
                                           f4=field4, t4=type4, f5=field5, t5=type5, f6=field6, t6=type6))