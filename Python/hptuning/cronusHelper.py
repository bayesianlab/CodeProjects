from common_simple import *
from pdHelper import selectData
from pdHelper import execQuery
import getopt

import pyodbc

# =============================================================================
# Process command line arguments
# =============================================================================
def ProcessArguments():
    abspath = os.path.abspath(__file__)
    dname = os.path.dirname(abspath)
    os.chdir(dname)
    
    opts, args = getopt.getopt(sys.argv,"","")    
    return args

# =============================================================================
# Run action procedure to pull in data
# =============================================================================    
# addtl is for additional arguments in the action statement if neeeded
# Needs to be in array form as an input, e.g. [value]
def SQLAction(args, proc, action_type, addtl = None):
    if len(args) == 4:
        query = 'exec ' + proc + ' @ActionType = '+ action_type + ', @InputId = ' + str(args[3])
        data_table = selectData(query, server = args[1], database = args[2])    
    elif addtl is not None:
        if len(args) == len(addtl) + 4:
            query = 'exec ' + proc + ' @ActionType = '+ action_type + ', @InputId = ' + str(args[3])
            i = 4
            for field in addtl:
                query = query + ', @' + field + ' = ' + str(args[i])
                i = i + 1            
            data_table = selectData(query, server = args[1], database = args[2])

    return data_table


def SQLActionExecOnly(args, proc, action_type):
    query = 'exec ' + proc + ' @ActionType = '+ action_type + ', @InputId = '+str(args[3])
    execQuery(query, server = args[1], database = args[2])    

# =============================================================================
# Explicit management of SQL connection (used for Output / Output Dtl tables)
# =============================================================================    
def SQLActionExecOnlyConnection(args, proc, action_type, conn = None, cursor = None, persist = False):
    query = 'exec ' + proc + ' @ActionType = '+ action_type + ', @InputId = '+str(args[3])
    if conn == None:
        conn = pyodbc.connect('DRIVER={SQL Server};SERVER=' + args[1] + ';DATABASE=' + args[2])
        cursor = conn.cursor()
    
    cursor.execute(query)
    conn.commit()
    if persist == False:
        cursor.close()
        conn.close()
    else:
        return conn, cursor
