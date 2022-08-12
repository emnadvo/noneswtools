# Piece of code for operation with path, directories or files

//change working directory because xml include another xml
string currentDir = Directory.GetCurrentDirectory();
string newPath = Path.GetDirectoryName(xmlSignalFilter);
DirectoryInfo workDirectory = new DirectoryInfo(newPath);

Directory.SetCurrentDirectory(workDirectory.Parent.FullName);
