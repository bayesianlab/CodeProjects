#%%
from fredapi import Fred
from sqlalchemy import create_engine

# Obtain a database connection to the MySQL instance
db_host = 'localhost'
db_user = 'dillon'
db_pass = 'Zelzah12'
db_name = 'Securities'

class Connection:

    def __init__(self,db_host, db_user, db_pass, db_name) -> None:
        self.host = db_host
        self.user = db_user
        self.passwd = db_pass
        self.db_name = db_name
        self.connstring = ''.join(['mysql+pymysql://', self.user, ':',
                                   self.passwd, '@', self.host, '/', self.db_name])
        self.engine = create_engine(self.connstring, echo=False)

fred = Fred(api_key='1593ee3cad0646216ab4b80aa9f63cd2')