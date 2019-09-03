import os
import sys
from PyQt4.QtCore import *
from PyQt4.QtGui import*

class TexCreator(QMainWindow):
    inst = set()
    geoms = [50,50, 500, 500]

    def __init__(self, parent=None):
        super(TexCreator, self).__init__(parent)
        TexCreator.inst.add(self)
        self.setGeometry(self.geoms[0], self.geoms[1], self.geoms[2], self.geoms[3])
        self.editor = QTextEdit()

        exitAction = QAction(QIcon('exit24.png'), 'LaTeX', self)
        exitAction.setStatusTip('Create Tex Table')
        exitAction.triggered.connect(self.printTable)

        bombAction = QAction(QIcon('bomb.png'), 'Bomb the table', self)
        bombAction.setStatusTip('Blow up input')
        bombAction.triggered.connect(self.editor.clear)

        toolbar = self.addToolBar('Exit')
        toolbar.addAction(exitAction)
        toolbar.addAction(bombAction)
        self.setCentralWidget(self.editor)
        self.statusBar()
        self.show()

    def createRowDictionary(self):
        table = str(self.editor.toPlainText())
        newstr = ''
        rows = {}
        c = 0
        for i in table.split('\n'):
            wordList = i.split()
            # wordList.append('\\')
            wordList = ' & '.join(wordList).split()
            wordList.append('\\\\')
            rows[c] = wordList
            c += 1
        return rows


    def tableEnviorment(self):
        teRaw = self.createRowDictionary()
        try:
            nCols = (len(teRaw[0]))/2
        except KeyError:
            print "Null Rows"
        nKeys = len(teRaw.keys())
        outStr = ''
        for i in xrange(nKeys):
            c = 0
            for word in teRaw[i]:
                if word == '\\\\':
                    outStr += word + '\n'
                else:
                    if c == 0:
                        outStr += '\t' + word + ' '
                    else:
                        outStr += word + ' '
                    c += 1
        cols = '{' + (nCols) * 'c' + '}\n'
        outStr = '\\begin{tabular}' + cols + outStr + '\end{tabular}'
        return outStr

    def changeGeometry(self):
        self.geoms[0] += 25
        self.geoms[1] += 25

    def printTable(self):
        print 'triggered'
        table = self.tableEnviorment()
        newWin = TexCreator()
        newWin.editor.setText(self.tableEnviorment())
        newWin.changeGeometry()
        newWin.setGeometry(newWin.geoms[0], newWin.geoms[1], newWin.geoms[2], newWin.geoms[3])








def runMain():
    app = QApplication(sys.argv)
    tc = TexCreator()
    sys.exit(app.exec_())


runMain()

