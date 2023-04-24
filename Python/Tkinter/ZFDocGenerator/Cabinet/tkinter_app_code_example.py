import os
import shutil

# specify the filename to search
filename = "filename.txt"

# specify the directory to search in
search_dir = "C:/mydirectory/"

# search for the file in the directory and subdirectories
for root, dirs, files in os.walk(search_dir):
    if filename in files:
        # archive the file
        shutil.make_archive("archive", "zip", search_dir, filename)

        # get the full path of the file and open it
        filepath = os.path.join(root, filename)
        with open(filepath, "r") as file:
            data = file.read()
            # do something with the content of the file



import tkinter as tk
import sqlite3

class Application(tk.Frame):
    def __init__(self, master=None):
        super().__init__(master)
        self.master = master
        self.pack()
        
        # Connect to SQLite database
        self.conn = sqlite3.connect('example.db')
        self.c = self.conn.cursor()
        
        # Create a table if it doesn't exist
        self.c.execute('''CREATE TABLE IF NOT EXISTS example
                        (id INTEGER PRIMARY KEY, name TEXT)''')
        self.conn.commit()
        
        self.create_widgets()

    def create_widgets(self):
        # Create label and entry for user input
        self.name_label = tk.Label(self, text="Name:")
        self.name_label.pack(side="left")
        
        self.name_entry = tk.Entry(self)
        self.name_entry.pack(side="left")
        
        # Create button to add data to database
        self.add_button = tk.Button(self, text="Add", command=self.add_data)
        self.add_button.pack(side="left")

    def add_data(self):
        # Get user input from entry
        name = self.name_entry.get()
        
        # Insert data into database
        self.c.execute("INSERT INTO example (name) VALUES (?)", (name,))
        self.conn.commit()
        
        # Clear entry field
        self.name_entry.delete(0, 'end')

# Create Tkinter root window
root = tk.Tk()

# Create instance of application
app = Application(master=root)

# Start main event loop
app.mainloop()




import tkinter as tk
from tkinter import ttk
import sqlite3

class MyApp:
    def __init__(self, master):
        self.master = master
        self.master.title("My Application")

        # Create a notebook with two tabs
        self.notebook = ttk.Notebook(self.master)
        self.notebook.pack(fill='both', expand=True)

        # Create the first tab
        self.tab1 = ttk.Frame(self.notebook)
        self.notebook.add(self.tab1, text="Tab 1")

        # Create the second tab
        self.tab2 = ttk.Frame(self.notebook)
        self.notebook.add(self.tab2, text="Tab 2")

        # Create a tree view in the first tab
        self.treeview = ttk.Treeview(self.tab1, columns=('column1', 'column2'))
        self.treeview.heading('#0', text='ID')
        self.treeview.heading('column1', text='Column 1')
        self.treeview.heading('column2', text='Column 2')
        self.treeview.pack()

        # Connect to the SQLite database
        self.conn = sqlite3.connect('mydatabase.db')
        self.cursor = self.conn.cursor()

        # Create a table in the database
        self.cursor.execute('CREATE TABLE IF NOT EXISTS mytable (id INTEGER PRIMARY KEY, column1 TEXT, column2 TEXT)')

        # Insert some data into the table
        self.cursor.execute('INSERT INTO mytable (column1, column2) VALUES (?, ?)', ('Data 1', 'Data 2'))

        # Retrieve data from the table and populate the tree view
        self.cursor.execute('SELECT * FROM mytable')
        rows = self.cursor.fetchall()
        for row in rows:
            self.treeview.insert('', 'end', text=row[0], values=(row[1], row[2]))

        # Commit changes and close the database connection
        self.conn.commit()
        self.conn.close()

if __name__ == '__main__':
    root = tk.Tk()
    app = MyApp(root)
    root.mainloop()


