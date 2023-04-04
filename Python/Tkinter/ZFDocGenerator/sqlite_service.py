import sqlite3 as sqdb

class DbManager:
    def __init__(self, db_name, user, password):
        self.db_name = db_name
        self.user = user
        self.password = password
        self.conn = None
    
    def connect(self):
        try:
            self.conn = sqdb.connect(self.db_name, user=self.user, password=self.password)
            print("Database connection successful")
        except sqdb.Error as e:
            print(f"Error connecting to database: {e}")
    
    def close(self):
        if self.conn:
            self.conn.close()
            print("Database connection closed")
        else:
            print("No database connection found")