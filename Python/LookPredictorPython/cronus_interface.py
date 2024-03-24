#%% 
from sqlalchemy.engine import URL, create_engine 
import pandas as pd 

def get_data(proc, server_name, action_type, input_id, **kwargs):
    if len(kwargs)==0:
        action_string = ','.join([action_type, str(input_id)])
        query = ' '.join(['exec', proc, action_string])
        conn_string = 'DRIVER={SQL Server};SERVER='+server_name+';DATABASE=Market'
        conn_url = URL.create('mssql+pyodbc', query={'odbc_connect': conn_string})
        engine = create_engine(conn_url)
        with engine.begin() as conn:
            return pd.read_sql(query, conn)
    else:
        try:
            if 'osdate' in kwargs.keys():
                osdate = kwargs['osdate']
                action_string = ','.join([action_type, '@InputId='+str(input_id), 
                                      '@osdate=\'' + str(osdate) +'\'',
                                      '@periods_out='+str(kwargs['periods_out'])])
            else:
                action_string = ','.join([action_type, '@InputId='+str(input_id), 
                                      '@periods_out='+str(kwargs['periods_out'])])    

            query = ' '.join(['exec', proc, action_string])
            conn_string = 'DRIVER={SQL Server};SERVER='+server_name+';DATABASE=Market'
            conn_url = URL.create('mssql+pyodbc', query={'odbc_connect': conn_string})
            engine = create_engine(conn_url)
            with engine.begin() as conn:
                return pd.read_sql(query, conn)
        except Exception as e:
            print(e)
            

if __name__=='__main__':
    pass 
    # print('cronus interface')
    # X = get_data('TestQ', 'Awsdevsql013')
    # if int(X['Test'])==1:
    #     print('Test 1: Success')
    # else:
    #     print('Test 1: Failed')
# %%
