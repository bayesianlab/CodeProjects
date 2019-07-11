import os 
import subprocess
with open('tbsmpy_3.sh', 'r') as template:
    print('Open file')
    print(os.getcwd())
    for j in range(3,49):
        newfile = []
        c = 0
        template.seek(0)
        for line in template:
            c += 1
            if c == 4:
                linecopy = line
                linecopy = linecopy.replace(str(3), str(j+1))
                beg = linecopy.find('t')
                if len(str(j+1)) == 2:
                    end = linecopy.find(str(j+1)) +2
                else:
                    end = linecopy.find(str(j+1)) +1
                filename = ''.join([linecopy[beg:end], '.sh'])
            elif  c == 11:
                inx = line.find(str(3))
                linecopy = line
                linecopy = linecopy.replace(str(3), str(j+1))
            else:
                linecopy = line
            newfile.append(linecopy)
        print(newfile)
        with open(filename, 'w') as tbsfile:
            for line in newfile:
                tbsfile.write("%s" %  line)



    
