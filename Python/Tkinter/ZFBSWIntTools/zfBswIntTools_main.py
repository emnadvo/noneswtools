
import sys
import os
import tkinter as tk
import win32api
import win32file
import win32wnet

from tkinter import ttk
import psutil as psutil
from pathlib import Path
import zfBswIntTools_CONST as CONST

class ZfBswIntTools:
    def __init__(self, root) -> None:
        self.master = root
        if isinstance(self.master, tk.Tk):
            self.master.title(CONST.TITLE)
            self.master.geometry(CONST.GEOMETRY_RESOLUTION)

            self.__get_views__()

            # Create a combobox
            comboItems = []
            for item in self.drives:
                comboItems.append("{0}".format(item[1]))

            self.clearviews_cmb = ttk.Combobox(self.master, height=8, width=CONST.COMBO_HEIGHT, values=comboItems)
            self.clearviews_cmb.pack()

            self.frame_btn = ttk.Frame(master=self.master, relief=tk.RAISED, borderwidth=1)

            # Create four buttons below the combobox
            sys.stderr.write("Current work directory {}\n".format(os.getcwd()))
            #LAUTERBACH_ICON=tk.PhotoImage(file='\\resource\\trace32.ico')
            self.debuger_btn = ttk.Button(self.frame_btn, width=CONST.BUTTON_WIDTH, text="Debugger", command=self.lauterbach_run) #, image=LAUTERBACH_ICON)
            self.debuger_btn.grid(column=0, row=0, ipadx=CONST.BUTTON_WIDTH, ipady=CONST.BUTTON_HEIGHT)

            self.button2 = ttk.Button(self.frame_btn, text="RBS", command=self.rbs_run)
            self.button2.grid(column=1, row=0, ipadx=CONST.BUTTON_WIDTH, ipady=CONST.BUTTON_HEIGHT)

            self.button3 = ttk.Button(self.frame_btn, text="Analyzer", command=self.analyze_run)
            self.button3.grid(column=2, row=0, ipadx=CONST.BUTTON_WIDTH, ipady=CONST.BUTTON_HEIGHT)

            self.button4 = ttk.Button(self.frame_btn, text="Build", command=self.build_run)
            self.button4.grid(column=3, row=0, ipadx=CONST.BUTTON_WIDTH, ipady=CONST.BUTTON_HEIGHT)

            self.frame_btn.pack()
            
    def __get_views__(self) -> None:
        self.drives = []
        for partition in psutil.disk_partitions(all=True):
            try:
              drivetype = win32file.GetDriveType(partition.device)
              if drivetype == win32file.DRIVE_REMOTE:
                  name=win32wnet.WNetGetUniversalName(partition.device,1)
                  if name.find(CONST.CLEARCASE_VIEW) > 0 and name.find(CONST.CCUSERID) > 0:
                    drive=(partition.device, name)
                    self.drives.append(drive)
              else:
                  continue
            except Exception as e:
              sys.stderr.write("Drive {0} doesn't allowed read".format(partition.device))

    def lauterbach_run(self) -> None:
       raise Exception 
    
    def rbs_run(self) -> None:
       raise Exception
    
    def analyze_run(self) -> None:
       raise Exception       
    
    def build_run(self) -> None:
       raise Exception
        
        
       
       


if __name__ == '__main__':
    root = tk.Tk()
    app = ZfBswIntTools(root)
    root.mainloop()