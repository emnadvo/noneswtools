
import sys
import os
import re
import subprocess
import tkinter as tk
import win32api
import win32file
import win32wnet
from tkinter import ttk
from tkinter.messagebox import showerror, showinfo, showwarning
import psutil as psutil
import pathlib as PathLb
import zfBswIntTools_CONST as CONST

class ZfBswIntTools:
    def __init__(self, root) -> None:
        self.process_pids = []
        self.master = root
        if isinstance(self.master, tk.Tk):
            self.master.title(CONST.TITLE)
            self.master.geometry(CONST.GEOMETRY_RESOLUTION)

            self.__create_widgets__()


    def __get_views__(self) -> None:
        self.drives = dict()
        softwaredir = ''
        for partition in psutil.disk_partitions(all=True):
            try:
              drivetype = win32file.GetDriveType(partition.device)
              if drivetype == win32file.DRIVE_REMOTE:
                  name=win32wnet.WNetGetUniversalName(partition.device,1)
                  if name.find(CONST.CLEARCASE_VIEW) > 0 and name.find(CONST.CCUSERID) > 0:
                    for base_dir in CONST.DIRECTORY_PATH_L0:
                        if PathLb.Path(os.path.join(partition.mountpoint, base_dir, CONST.SOFTWARE_DIRNAME)).exists():
                            softwaredir = os.path.join(partition.mountpoint, base_dir)
                            self.drives[name] = softwaredir
                            break
              else:
                  continue
            except Exception as e:
              sys.stderr.write("Drive {0} doesn't allowed read".format(partition.device))


    def __create_widgets__(self) -> None:
        self.frame_base = ttk.Frame(master=self.master, relief=tk.RAISED, borderwidth=1)

        self.__get_views__()

        COLUMN_ID = 0
        # Create a combobox
        comboItems = []
        for item in self.drives.keys():
            comboItems.append(item)

        # First row from application
        ROW_ID = 0
        frame_cmb = ttk.LabelFrame(self.frame_base, text=CONST.CMB_LABEL)
        frame_cmb.grid(column=COLUMN_ID, row=ROW_ID, columnspan=CONST.COLUMNSPAN, padx=CONST.GRID_PAD, pady=CONST.GRID_PAD, sticky=tk.EW)

        self.clearviews_cmb = ttk.Combobox(frame_cmb, height=8, width=CONST.COMBO_HEIGHT, values=comboItems)
        self.clearviews_cmb.grid(column=0, row=0, sticky=tk.EW)

        # Second row from application
        ROW_ID = 1             
        # Create four buttons below the combobox
        #sys.stderr.write("Test directory {}\n".format(os.path.join(icons_path, 'resource','trace32.ico')))
        frame_btn = ttk.LabelFrame(self.frame_base, text=CONST.BTN_LABEL)
        frame_btn.grid(column=COLUMN_ID, row=ROW_ID, columnspan=4, sticky=tk.EW)
        #icons_path = os.path.dirname(__file__)
        #LAUTERBACH_ICON=tk.PhotoImage(file=os.path.join(icons_path, 'resource','trace32.ico'))

        COLUMN_ID += 1 # = 1
        self.debuger_btn = ttk.Button(frame_btn, width=CONST.BUTTON_WIDTH, text="Debugger", command=self.lauterbach_run) #, image=LAUTERBACH_ICON)
        self.debuger_btn.grid(column=COLUMN_ID, row=0, ipadx=CONST.BUTTON_WIDTH, ipady=CONST.BUTTON_HEIGHT)

        COLUMN_ID += 1 # = 2
        self.button2 = ttk.Button(frame_btn, text="RBS", command=self.rbs_run)
        self.button2.grid(column=COLUMN_ID, row=0, ipadx=CONST.BUTTON_WIDTH, ipady=CONST.BUTTON_HEIGHT)

        COLUMN_ID += 1 # = 3
        self.button3 = ttk.Button(frame_btn, text="Analyzer", command=self.analyze_run)
        self.button3.grid(column=COLUMN_ID, row=0, ipadx=CONST.BUTTON_WIDTH, ipady=CONST.BUTTON_HEIGHT)

        COLUMN_ID += 1 # = 4
        self.button4 = ttk.Button(frame_btn, text="Build", command=self.build_run)
        self.button4.grid(column=COLUMN_ID, row=0, ipadx=CONST.BUTTON_WIDTH, ipady=CONST.BUTTON_HEIGHT)

        COLUMN_ID += 1 # = 5
        self.button5 = ttk.Button(frame_btn, text="Close", command=self.close)
        self.button5.grid(column=COLUMN_ID, row=0, ipadx=CONST.BUTTON_WIDTH, ipady=CONST.BUTTON_HEIGHT)

        self.frame_base.pack()      


    def lauterbach_run(self) -> None:
        self.__execute_command__(CONST.DIRECTORY_L3, CONST.DEBUGGER_PATHS, CONST.DEBUGGER_CMD)

    def rbs_run(self) -> None:
        self.__execute_command__(CONST.DIRECTORY_L3, CONST.RBS_PATHS, CONST.RBS_CMD)
    
    def analyze_run(self) -> None:
        self.__execute_command__(CONST.DIRECTORY_L3, CONST.ANALYSIS_PATHS, CONST.ANALYSIS_CMD)     
    
    def build_run(self) -> None:
        self.__execute_command__(CONST.DIRECTORY_L2, CONST.BUILD_PATHS, CONST.BUILD_CMD)
               
    def __get_cmd_file__(self, cmd_file, path) -> str:
        cmd_file = ''
        for root, dirs, files in os.walk(path):
                for dir in dirs:
                    for file in files:
                        cmd_file = os.path.join(root, dir, file)
                        if PathLb.Path(cmd_file).exists():
                            return cmd_file
        return cmd_file
    
    def __get_search_dir__(self, search_dir, path) -> str:
        searched_dir = ''
        for root, dirs, files in os.walk(path, topdown=False):
            
            if (re.search('adk', os.path.join(root)) is not None or re.search('awd',os.path.join(root)) is not None):
                    continue
            else:
                for dir in dirs:
                    if (re.search('adk', os.path.join(root, dir)) is not None or re.search('awd',os.path.join(root, dir)) is not None):
                        continue
                    else:
                        if re.search(search_dir, dir) is not None:
                            searched_dir = os.path.join(root, dir)
                            return searched_dir
        return searched_dir

    def __get_cmd_action__(self, driver, directory_level, cmd_path_list, cmd_list) -> str:
        str_command = ''
        dir_path = None
        for dir_lv_1 in CONST.DIRECTORY_PATH_L1:
            if PathLb.Path(os.path.join(driver, dir_lv_1)).exists():
                dir_path = os.path.join(driver, dir_lv_1)
                if directory_level >= CONST.DIRECTORY_L2:
                    for dir_lv_2 in CONST.DIRECTORY_PATH_L2:
                        if PathLb.Path(os.path.join(dir_path, dir_lv_2)).exists():
                            dir_path = os.path.join(dir_path, dir_lv_2)
                            if directory_level >= CONST.DIRECTORY_L3:
                                for dir_lv_3 in CONST.DIRECTORY_PATH_L3:
                                    if PathLb.Path(os.path.join(dir_path, dir_lv_3)).exists():
                                        dir_path = os.path.join(dir_path, dir_lv_3)
                                        break
        
        if dir_path is not None:
            if isinstance(cmd_path_list, list) and len(cmd_path_list) > 0:
                for cmd_path in cmd_path_list:
                    if len(cmd_path) == 0:
                        continue
                    if PathLb.Path(os.path.join(dir_path, cmd_path)).exists():
                        dir_path = os.path.join(dir_path, cmd_path)
                        break
            
            for cmd in cmd_list:
                if PathLb.Path(os.path.join(dir_path, cmd)).exists():
                    str_command = os.path.join(dir_path, cmd)
                    break
            
        return str_command
    
    def __execute_command__(self, directory_level, cmd_path, cmd) -> None:
        choice_view = self.clearviews_cmb.get()
        if len(choice_view) == 0:
            showwarning(CONST.SHOW_WARNING_TITLE, CONST.MISSING_CHOICE_VIEW)
            return

        item = self.drives[choice_view]
        exec_command = None
        if item is not None:
            exec_command = self.__get_cmd_action__(item, directory_level, cmd_path, cmd)

        if exec_command is not None:
            process = subprocess.Popen(exec_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            self.process_pids.append(process.pid)

    def close(self):
        self.master.quit()

# ---------------------------- MAIN FUNCTION ----------------------------
if __name__ == '__main__':
    root = tk.Tk()
    app = ZfBswIntTools(root)
    root.mainloop()












# testpath = PathLb.PureWindowsPath(name).joinpath('software','tools','debug','trace32_2G')
                    # #testpath = os.path.join(partition.device, name.strip('\\\\view'), 'software','tools','debug','trace32_2G')
                    # #testpath = os.path.join(name, 'software','tools','debug','trace32_2G')
                    # #os.path.join(name.strip('\\\\view'), 'software','tools','debug','trace32_2G')
                    # if PathLb.Path(testpath).exists():