__author__ = 'dillonflannery-valadez'

import sys
import csv
from PyQt4.QtCore import *
from PyQt4.QtGui import *

class hello(QDialog):
    def __init__(self, parent=None):
        super(hello, self).__init__(parent)
        inpt = QInputDialog()
        lay = QHBoxLayout()
        lay.addWidget(inpt)
        self.setLayout(lay)


if __name__ == '__main__':
    app = QApplication(sys.argv)
    inst = hello()
    inst.exec_()