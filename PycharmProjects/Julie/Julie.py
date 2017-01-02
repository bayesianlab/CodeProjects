import os
import sys
from PyQt4.QtCore import *
from PyQt4.QtGui import*
import pafy


class Julie(QWidget):

    def __init__(self, parent=None):
        super(Julie, self).__init__(parent)
        self.setGeometry(400, 400, 600, 150)

        self.setupUiLayout()

        self.show()

    def setupButtons(self):
        self.downloadButton()
        self.quitButton()
        self.buttonGrid = QHBoxLayout()
        self.buttonGrid.addWidget(self.download)
        self.buttonGrid.addWidget(self.quitApp)

    def setupURLLine(self):
        self.urlLine()
        self.urlLine = QHBoxLayout()
        self.urlLine.addWidget(self.lab)
        self.urlLine.addWidget(self.le)

    def setupProgress(self):
        self.progBar()
        self.barStuff = QHBoxLayout()
        self.barStuff.addWidget(self.progLabel)
        self.barStuff.addWidget(self.progress)

    def setupUiLayout(self):
        self.setupButtons()
        self.setupURLLine()
        self.setupProgress()
        self.vbox = QVBoxLayout()
        self.vbox.addLayout(self.urlLine)
        self.vbox.addLayout(self.buttonGrid)
        self.vbox.addLayout(self.barStuff)
        self.vbox.addWidget(self.progress)
        self.setLayout(self.vbox)

    def urlLine(self):
        self.lab = QLabel("Enter URL")
        self.le = QLineEdit()

    def progBar(self):
        self.progLabel = QLabel("Download Progress")
        self.progress = QProgressBar()
        self.progress.setRange(0,1)

    def downloadButton(self):
        self.download = QPushButton("Download")
        self.connect(self.download, SIGNAL("clicked()"), self.getURL)

    def quitButton(self):
        self.quitApp = QPushButton("Quit")
        self.quitApp.clicked.connect(self.close)

    def errMessage(self):
        err = QErrorMessage()
        err.showMessage("Error: No URL Specified.")
        err.exec_()

    def badURLErrorMessage(self):
        err = QErrorMessage()
        err.showMessage("URL Does Not exist or pafy is not able to find or access this URL. Try checking if "
                        "URL is correct or a different URL.")
        err.exec_()

    def getURL(self):
        URL = str(self.le.text())
        if(URL == ''):
            self.errMessage()
        else:
            try:
                vid = pafy.new(URL)
                best = vid.getbest()
                best.download(quiet=True, callback=self.call)
            except ValueError:
                self.badURLErrorMessage()

    def call(self, total, recvd, ratio, rate, eta):
        print ratio
        self.progress.setValue(ratio)

def runJulie():
    app = QApplication(sys.argv)
    app.setApplicationName("Julie")
    julie = Julie()
    sys.exit(app.exec_())
runJulie()






