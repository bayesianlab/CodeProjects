#!/home/dillon/venvs/myenv/bin/python

from PyPDF2 import PdfReader

def get_info(path):
    with open(path, 'rb') as f:
        pdf = PdfReader(f)
        info = pdf.metadata
    
    store_info = [info.author, info.title, info.creation_date] 
    author = info.author
    creator = info.creator
    producer = info.producer
    subject = info.subject
    title = info.title
   

if __name__ == '__main__':
    path = 'chibGreenberg95.pdf'
    get_info(path)
