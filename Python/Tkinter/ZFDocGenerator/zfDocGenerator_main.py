# import modules
import tkinter as tk
import zfDocGeneratorApp_CONST as APPCONST
import zfDocGeneratorApp_SQL as SQLPARAMS
import sqlite_service as dbservice


class ZFDocGeneratorApp(object):
    def __init__(self, root) -> None:
        self.master = root
        if isinstance(self.master, tk.Tk):
            self.master.title(APPCONST.TITLE)
            self.master.geometry(APPCONST.GEOMETRY_RESOLUTION)

    def __connect_db__(self) -> None:
        self.db_source = dbservice.DbManager(SQLPARAMS.DBNAME, SQLPARAMS.DBUSERNAME, SQLPARAMS.DBPASSWORD)


# function territory
def welcome():
    name = nameTf.get()
    return Label(ws, text=f'Welome {name}', pady=15, bg='#567').grid(row=2, columnspan=2)

if __name__ == '__main__':
    # configure workspace
    ws = tk.Tk()
    ws.title("First Program")
    ws.geometry('250x150')
    ws.configure(bg="#567")
    # label & Entry boxes territory
    nameLb = Label(ws, text="Enter Your Name", pady=15, padx=10, bg='#567')
    nameTf = Entry(ws)

    # button territory
    welBtn = Button(ws, text="ClickMe!", command=welcome)

    # Position Provide territory
    nameLb.grid(row=0, column=0)
    nameTf.grid(row=0, column=1)
    welBtn.grid(row=1, columnspan=2)

    # infinite loop 
    ws.mainloop()
