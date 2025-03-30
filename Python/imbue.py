
#%%
import itertools
import random 
import math 
import numpy  as np

field = [
 "*#..#",
 ".#*#.",
 "*...*"]

K = 2


def find_checkpoints(r, rn):
    x = [] 
    for i, txt in enumerate(r):
        if txt == "*":
            x.append(rn,i)
    return x 

def shape(field):
    if len(field) > 0 :
        return (len(field)), len(field[0])
    else:
        raise ValueError

def isvalid(move, field_shape, field):
    if (move[0] < 0) or (move[0] >= field_shape[0]):
        return False 
    if (move[1] < 0) or (move[1] >= field_shape[1]):
        return False 
    if field[move[0]][move[1]] == '#':
        return False 
    else:
        return True 

def isunexplored(m, unexplored):
    if m in unexplored.keys():
        return True 
    else:
        return False 

def unexplored(field):
    rc = shape(field)
    c = itertools.product(range(rc[0]), range(rc[1]))
    ue = {}
    for i in c:
        if field[i[0]][i[1]] != '#':
            ue[i] = 0
    return ue 

def dists(field):
    rc = shape(field)
    c = itertools.product(range(rc[0]), range(rc[1]))
    dists = {} 
    for i in c:
        if field[i[0]][i[1]] != '#':
            dists[i] = np.inf
    return dists 

def calc_dists(cur, proposed, distances):
    d = distances[cur] + 1
    if d < distances[proposed]:
        distances[proposed] = d 

ue = unexplored(field)
d = dists(field)

#%%

def move(cur,  unexplored, distances, field, connections):
    s = shape(field)
    dirs = [] 
    if cur[0] > 0:
        south = (cur[0] - 1, cur[1])
        dirs.append(south)
    if cur[1] > 0:
        west = (cur[0], cur[1] - 1)
        dirs.append(west)
    if cur[0] < s[0]:
        north = (cur[0] + 1, cur[1])
        dirs.append(north)
    if cur[1] < s[1]:
        east = (cur[0], cur[1] + 1)
        dirs.append(east)
    
    for i in dirs:
        if isvalid(i, s, field):
            if isunexplored(i, unexplored):
                connections[i] = 1 
                calc_dists(cur, i , distances)
            
# %%
cur = (0,0)
d[cur] = 0 

#%%


def explore(node, unexplored, distances, field):
    if len(unexplored)==0:
        return  
    connections = {}
    move(node, unexplored, distances, field, connections)
    unexplored.pop(node)
    for i in connections.keys():
        explore(i, unexplored, distances, field)
    


explore((0,0), ue, d, field)
print(d)
# %%
