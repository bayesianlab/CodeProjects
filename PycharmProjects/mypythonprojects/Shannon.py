import openpyxl

def inputList(filename, listOfValues, location):
    wb = openpyxl.Workbook()
    ws = wb.active
    ws[location] = ','.join(str(i) for i in listOfValues)
    if filename.find('.xlsx') != -1:
        wb.save(filename)
        print('Workbook created')
    else:
        name = filename + '.xlsx'
        wb.save(name)
        print('Workbook created')


