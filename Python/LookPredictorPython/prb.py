#%% 
def function(tuple_input):
    if 'x' in tuple_input[1]:
        raise ValueError('x cant be in the list' )
    tuple_input[1].append('x')


tuple_input = (1, ['a', 'b', 'c'])
function(tuple_input)
# works 
tuple_input[1].remove('x')
# doesn't work 
tuple_input[1] = ['a', 'b', 'c']
function(tuple_input)

# %%
