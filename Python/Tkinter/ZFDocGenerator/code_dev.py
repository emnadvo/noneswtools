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
