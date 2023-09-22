#%%
import glob 
import zipfile 
icphots = glob.glob('/home/dillon/Downloads/iCloud*')
for i in icphots:
    with zipfile.ZipFile(i, 'r') as zref:
        print(zref)
        zref.extractall('/home/dillon/Pictures')
# %%
