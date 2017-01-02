# __author__ = 'dillonflannery-valadez'

import Tkinter


class simpleApp(Tkinter.Tk):
    def __init__(self, parent):
        Tkinter.Tk.__init__(self, parent)
        self.parent = parent
        self.initialize()

    def initialize(self):
        self.grid()
        self.entry = Tkinter.Entry(self)
        self.entry.grid(column = 0, row = 0, sticky = "EW" )

if __name__ == "__main__":
    app = simpleApp(None)
    app.title("My App")
    app.mainloop()

