# import modules
from tkinter import *

# configure workspace
ws = Tk()
ws.title("First Program")
ws.geometry('250x150')
ws.configure(bg="#567")

# function territory
def welcome():
    name = nameTf.get()
    return Label(ws, text=f'Welome {name}', pady=15, bg='#567').grid(row=2, columnspan=2)

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
