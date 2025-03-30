#%% 
with open("coding_qual_input.txt", 'r') as f:
    data = [lines.strip() for lines in f.readlines()]
# %%
def parse_input(data):
    data_dict = {}  
    for i,pair in enumerate(data):
        c = pair.find(' ')
        data_dict[int(pair[:c])] = pair[(c+1):]
    return data_dict 

data_dict = parse_input(data)
numbers = list(data_dict.keys())
numbers.sort()
# %%
def decode(data):
  data_dict = parse_input(data)
  numbers = list(data_dict.keys())
  numbers.sort()
  step = 1 
  code_string = []
  while len(numbers) != 0:
    subsets = []
    if len(numbers) >= step:
      subsets= numbers[0:step]
      last_val = subsets[-1]
      code_string.append(data_dict[last_val])
      numbers = numbers[step:]
      step += 1
    else:
      return False
  return ' '.join(code_string)
  

# %%
print(decode(data))
# %%
test_list = ['3 love',
'6 computers',
'2 dogs',
'4 cats',
'1 I',
'5 you']
# %%
dd = parse_input(test_list)
# %%
decode(test_list)
# %%
