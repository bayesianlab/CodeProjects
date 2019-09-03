__author__ = 'dillonflannery-valadez'

import sys
import csv
from PyQt4.QtCore import *
from PyQt4.QtGui import *
import RandomPassword

# TODO: Create dictionary of student codes and rewrite check student id function to handle dictionaries.


STUDENT_CODES = {'818':0, '011':0, '901':0, '476':0}



class Attendance(QDialog):
    def __init__(self, parent=None):
        super(Attendance,self).__init__(parent)
        self.attendanceList = []
        self.le = QLineEdit()
        self.checkList = QListWidget()
        self.enterButton = QPushButton("Enter")
        self.enterButton.setDefault(True)
        self.doneButton = QPushButton("Done")
        self.doneButton.setAutoDefault(False)


        label = QLabel("Enter your code:")
        layout = QVBoxLayout()
        layout.addWidget(label)
        layout.addWidget(self.le)

        layout.addWidget(self.enterButton)
        layout.addWidget(self.doneButton)
        layout.addWidget(self.checkList)
        self.setLayout(layout)

        self.connect(self.enterButton, SIGNAL('pressed()'), self.okFunc)
        self.connect(self.doneButton, SIGNAL('pressed()'), self.cancelFunc)

        csvfile = open("Student Attendance.csv", "wb")
        self.write = csv.writer(csvfile, delimiter = ",")

        self.setWindowTitle("Student Attendance")

    def closeEvent(self, QCloseEvent):
        self.write.writerow(self.attendanceList)

    def okFunc(self):
        if not self.checkStudentID():
            QMessageBox.question(self, "Message", "No Student", QMessageBox.Ok)
            self.le.clear()
        else:
            self.attendanceList.append(self.le.text())
            self.le.clear()

    def cancelFunc(self):
        newList = []
        otherList = []
        for key in STUDENT_CODES:
            newList.append(key)
            otherList.append(STUDENT_CODES[key])
        self.write.writerow(newList)
        self.write.writerow(otherList)
        self.accept()

    def checkStudentID(self):
        for code in STUDENT_CODES.keys():
            print self.le.text(), code
            if code == self.le.text():
                STUDENT_CODES[code] = 1
                self.checkList.addItem("Identification Accepted")
                return True
        else:
            self.checkList.addItem("Identification Rejected")
            return False



if __name__ == '__main__':
    app = QApplication(sys.argv)
    inst = Attendance()
    inst.exec_()