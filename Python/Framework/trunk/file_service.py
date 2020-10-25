#!'C:\Documents and Settings\vign54\Dokumenty\Python27\python.exe'
#-*- coding: UTF-8 -*-
'''
Created on 19.10.2010
    @author:  e_mnadvo
    @summary: service for file operation
    @change:  
    @version: 1.0.8
    @contact: nadvornm@gmail.com
    @copyright: NO WARRANTY  BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
                FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. AFD © Studio 2010
'''

#for command line argument parse
import optparse

import os               
import sys              #system 
import exceptions as ex #exceptions
import string           #string functions
import re               #regular expression

#check correct import
try:
    import service_constants as const       #defined constants and messages
    import service_methods as service
except ex.ImportError, ie:
    sys.stderr.write('Invalid import of module \"service_constants\" or \"service_methods\"\n{0}'.format(ie))
    raise ex.SystemExit


class messages:
    '''
    @note: messages for file_service
    '''
    INVALID_CMD_APPEND = 'You used append operation without the filename!'
    INVALID_CMD_WRITE = 'You used write operation without the filename!'
    INVALID_CMD_READ = 'You used read operation without the filename!'
    INVALID_CMD_CHECKFILE = 'You used check file operation without the filename!'
    INVALID_CMD_CHECKDIR = 'You used check directory operation without the path!'
    MESSAGE_WRITE = 'Message was written to file'
    MESSAGE_APPEND = 'Message was append to file'
    MESSAGES = 'Message %s'
    EXCEPT_NEW_FILE = 'New file execution failed\n{0}'
    EXCEPT_OLD_FILE = 'Old file execution failed\n{0}'
    EXCEPT_OSERROR = 'Error when opening your file {0}\nOSError raised: {1}'
    EXCEPT_VALUERERROR = 'Error when opening your file {0}\nValueError raised: {1}'
    FILE_EXIST_WARNING = 'file {0} exist! If you can write to his, call function AppendFile'
    NOTEXIST_FILENAME = 'filename {0} was invalid otherwise don\'t exist'
    

class fls_variables:
    '''
    @note: variables for class CFileService
    ''' 
    def __init__(self):
        self.path = None
        self.filename = None
        self.newfile = None
        self.appendfile = None
        self.find_file = None          
        self.find_path = None
        self.allfiles = None
        self.content = None
        self.no_path = None
        
    def __clear__(self):
        if len(self.allfiles) > 0:
            del self.allfiles[:]
        self.path = None
        self.filename = None
        self.newfile = None
        self.appendfile = None
        self.find_file = None
        self.find_path = None
        if self.content is not None and len(self.content) > 0:
            del self.content[:]
        self.no_path = None
        

class CFileService:
#============CLASS METHOD============    
    '''
    @note: Service for file operation
    '''
    def arg_parse(self):
        '''
        @note: function parse command line arguments
        @return: True or False
        '''
        #cmd arg parse options
        info_usage = 'This %prog is service for operations with file.\n\t%prog [-f] filename [-p] pathname'
        option_list = [
            optparse.make_option("-f", "--file",\
                                 type='string',\
                                 dest='filename',\
                                 help='your file',\
                                 metavar='FILE'),                
            optparse.make_option("-p", "--path",\
                                 type='string',\
                                 dest='pathname',\
                                 help='your path',\
                                 metavar='PATH'),
            optparse.make_option("-w",\
                                 action='store_true',\
                                 dest='write',\
                                 help='write to file action'),
            optparse.make_option("-m", "--msg",\
                                 type='string',\
                                 dest='msgbody',\
                                 help='message write to file. Use with param -w or -a',\
                                 metavar='MESSAGE'),
            optparse.make_option("-r",\
                                 action='store_true',\
                                 dest='readfile',\
                                 help='read from file. Use with param -f'),
            optparse.make_option("-c",\
                                 action='store_true',\
                                 dest='checkfile',\
                                 help='check file if exists. Use with param -f'),                                 
             optparse.make_option("-a",\
                                 action='store_true',\
                                 dest='appendfile',\
                                 help='append to file. Use with param -f'),
            optparse.make_option("-l",\
                                 action='store_true',\
                                 dest='filelist',\
                                 help='file list return. Use with param -p'),
            optparse.make_option("-d",\
                                 action='store_true',\
                                 dest='checkdir',\
                                 help='directory checked if exist. Use with param -p'),
            optparse.make_option("-v",\
                                 action='store_true',\
                                 dest='verbose',\
                                 help='show arguments'),
            optparse.make_option("-q",\
                                 action='store_false',\
                                 dest='quiet',\
                                 help='don\'t print status messages to stdout')

            ]
        #create cmd parser
        arch_parser = optparse.OptionParser(usage=info_usage, option_list=option_list)
        #incoming arguments parse 
        (self.options, args) = arch_parser.parse_args()            
        #validation
        if len(args) > 0:
            ermsg = const.MSG_INVAL_ARGS
            for i in args:
                ermsg += i + const.TABULATOR
            if not self.options.quiet:    
                service.ShowStderr(ermsg)
        
        without_args = False
        if self.options.write is None and self.options.msgbody is None and  \
           self.options.readfile is None and self.options.appendfile is None and \
           self.options.filelist is None and self.options.checkfile is None and self.options.checkdir is None:
            without_args = True
        
        if self.options.appendfile and not self.options.filename:
            arch_parser.error(messages.INVALID_CMD_APPEND)
            raise ex.Warning
        elif self.options.write and not self.options.filename:
            arch_parser.error(messages.INVALID_CMD_WRITE)
            raise ex.Warning 
        elif self.options.readfile and not self.options.filename:
            arch_parser.error(messages.INVALID_CMD_READ)
            raise ex.Warning
        elif self.options.checkfile and not self.options.filename and not self.options.pathname:
            arch_parser.error(messages.INVALID_CMD_CHECKFILE)
            raise ex.Warning
        elif self.options.checkdir and not self.options.pathname:
            arch_parser.error(messages.INVALID_CMD_CHECKDIR)
            raise ex.Warning

        if self.options.verbose:
            print const.MSG_ARGS
            print const.FRMT_FILENAME % self.options.filename
            print const.FRMT_PATH.format(self.options.pathname)
            print messages.MESSAGES.format(self.options.msgbody)
            
        
        if not without_args:
            return True
        else:
            arch_parser.print_help()
            return False

#============CLASS METHOD============    
    def __init__(self, internal = False):
        '''
        @note: Constructor
        '''
        self.var = fls_variables()
        if not internal:    
            if self.arg_parse():
                if self.options.write:
                    if self.WriteContent(self.options.msgbody, self.options.filename):
                        service.ShowStdout(messages.MESSAGE_WRITE)
                    sys.exit()
                        
                if self.options.appendfile:
                    if self.WriteContent(self.options.msgbody, self.options.filename, True):
                        service.ShowStdout(messages.MESSAGE_APPEND)
                    sys.exit()
                
                if self.options.readfile:                        
                    if self.ReadContent(self.options.filename):
                        service.ShowStdout(self.var.content)                            
                    sys.exit()
                
                if self.options.filelist:                    
                    if self.AllFilesInDir(self.options.pathname, True):
                        service.ShowStdout(self.var.allfiles)                        
                    else:
                        service.ShowStderr(const.ERR_INVALID_PATH)
                    sys.exit()
                    
                if self.options.checkfile: 
                    val = self.FindFile(self.options.filename, self.options.pathname)
                    if val:
                        service.ShowStdout(const.EXEC_OK)
                        service.ShowStdout(self.var.allfiles)                        
                    else:
                        service.ShowStdout(const.EXEC_FALSE)
                    sys.exit()
                
                if self.options.checkdir:
                    val = self.ExistDir(self.options.pathname)
                    if val:
                        service.ShowStdout(const.EXEC_OK)
                        service.ShowStdout(self.var.find_path)
                    else:
                        service.ShowStdout(const.EXEC_FALSE)                
                    sys.exit()
                
                service.ShowStderr(const.EXCEPT_MSG_UNKNOWN.format('__init__'))
                raise ex.Warning
            else:            
                sys.exit()        
            

#============CLASS METHOD============
    def __del__(self):
        '''
        @note: destructor
        '''
        if self.var.newfile is not None:
            try:
                self.var.newfile.close()
            except OSError, e:
                service.ShowStderr(messages.EXCEPT_NEW_FILE.format(e))
        if self.var.appendfile is not None:
            try:
                self.var.appendfile.close()
            except OSError, e:
                service.ShowStderr(messages.EXCEPT_OLD_FILE.format(e))
        
#============CLASS METHOD============
    def ExistFile(self, filename=''):
        '''
        @note: chech file when exist or not
        @return: True or False, find file is in property var.filename
        '''
        assert len(filename) <> 0
        if len(filename) < 1:
            return False

        if os.path.isfile(filename):
            self.var.filename = filename
            self.var.find_path = os.getcwd()
            return True

        path = os.getcwd()         
        
        #filename without path
        sepr_name_path = string.splitfields(filename, const.SLASH)
        if len(sepr_name_path) > 1:
            self.var.no_path = False
            
        if self.var.no_path is None:
            sepr_name_path = string.splitfields(path, const.SLASH)
            testfile = ''
            for it in sepr_name_path:                
                testfile = os.path.join(testfile, it)
                testfile += const.SLASH
                if os.path.isfile(os.path.join(testfile, filename)):
                    self.var.filename = os.path.join(testfile, filename)
                    self.var.find_path = testfile
                    return True
                
        return False

#============CLASS METHOD============    
    def ExistDir(self, dirname=''):
        '''
        @note: chech directory when exist or not
        @return: True or False
        '''
        assert len(dirname) <> 0
        if len(dirname) < 1:
            return False

        if os.path.isdir(dirname):
            self.var.find_path = dirname
            return True

        no_path = True
        path = os.getcwd() 
        
        #filename without path
        sepr_name_path = string.splitfields(dirname, const.SLASH)
        if len(sepr_name_path) > 1:
            no_path = False
            
        if no_path:
            sepr_name_path = string.splitfields(path, const.SLASH)
            testdir = ''
            for it in sepr_name_path:                
                testdir = os.path.join(testdir, it)
                testdir += const.SLASH
                if os.path.isdir(os.path.join(testdir, dirname)):
                    self.var.find_path = os.path.join(testdir, dirname)
                    return True
                
        return False        

#============CLASS METHOD============
    def CreateFile(self, filename):
        '''
        @note: open file if exist, otherwise will create new
        @return: File or False
        '''
        assert len(filename) <> 0        
        if not self.ExistFile(filename):
            try:
                FILE = open(filename, 'w')
            except ex.OSError, e:
                service.ShowStderr(messages.EXCEPT_OSERROR.format(filename, e))
            except ex.ValueError, vle:
                service.ShowStderr(messages.EXCEPT_VALUERERROR.format(filename, vle))
            else:
                return FILE
        else:
            service.ShowStderr(messages.FILE_EXIST_WARNING.format(filename))
            
        return False
    
#============CLASS METHOD============
    def OpenFile(self, filename):
        '''
        @note: open file for read, if exist, otherwise raise exception
        @return: File or False
        '''
        assert len(filename) <> 0
        if self.ExistFile(filename):
            try:
                FILE = open(self.var.filename, 'r')
            except ex.OSError, e:
                service.ShowStderr(messages.EXCEPT_OSERROR.format(filename, e))
            except ex.ValueError, vle:
                service.ShowStderr(messages.EXCEPT_VALUERERROR.format(filename, vle))
            else:
                return FILE
        else:
            service.ShowStderr(messages.FILE_EXIST_WARNING.format(filename))
            
        return False

#============CLASS METHOD============    
    def AppendFile(self, filename):
        '''
        @note: open file for append, file must exist or raise exception IOError
        @return: File or False
        '''
        assert len(filename) <> 0 
        if not self.ExistFile(filename):
            service.ShowStderr(messages.NOTEXIST_FILENAME.format(filename))
            return False
        else:
            try:
                FILE = open(self.var.filename, 'a')
            except ex.OSError, e:
                service.ShowStderr(messages.EXCEPT_OSERROR.format(filename, e))
                print sys.stderr
            except ex.ValueError, vle:
                service.ShowStderr(messages.EXCEPT_VALUERERROR.format(filename, vle))
            else:
                return FILE

        return False
    
#============CLASS METHOD============    
    def AllFilesInDir(self, directory, includesubdir=False):
        '''
        @note: return list with all files in directory include subdirectory
        @return: True or False, all files is in property "allFiles" 
        '''
        if self.var.allfiles is None:
            self.var.allfiles = list()
            
        if self.ExistDir(directory):
            for fndpath, fnddir, findfiles in os.walk(self.var.find_path):                
                if includesubdir and len(fnddir) > 0:
                    for it in fnddir:
                        if fndpath[len(fndpath)-1:len(fndpath)] <> const.SLASH:
                            dir = fndpath + const.SLASH
                        else:
                            dir = fndpath
                        dir = os.path.join(dir, it)
                        self.AllFilesInDir(dir, includesubdir)

                #fndpath = fndpath[0:3] +  fndpath[4:] + newline   #WIN version                    
                self.var.allfiles.append(fndpath)
                for i in findfiles:
                    self.var.allfiles.append(i)    
                return True
        else:
            return False
            
#============CLASS METHOD============
    def FindFile(self, filename, path):
        '''
        @note: find file when exist
        @return: True or False
        name is save in property "find_file"
        '''
        assert len(filename) <> 0
        if len(filename) < 1:
            return False
        
        finded = False
        findFiles = list()
        
        if self.ExistFile(filename):
            findFiles.append(self.var.filename)            
            finded = True
        
        if not finded:
            flname_length = len(filename)
                
            if self.AllFilesInDir(path, True): 
                assert len(self.var.allfiles) <> 0
                node = ''
                fnd_path = ''
                
                if len(self.var.allfiles) > 0:
                    expres = '\w*{0}\w*'.format(filename)
                    regex = re.compile(expres, re.IGNORECASE)
                    for item in self.var.allfiles:
                        fnd_path = string.splitfields(item, const.SLASH)  
                        if len(fnd_path) > 1:  #zjistim, zda-li to neni nadrazeny adresar
                            node = item
                        else:
                            if len(item) >= flname_length: #nazev polozky je vetsi nez nazev hledaneho souboru
                                fl = re.findall(regex, item)
                                if len(fl) > 0: #nasel jsem pozadovany soubor
                                    findFiles.append(node + const.SLASH + item)
                                    finded = True
            
        if finded:
            self.ClearVariables()
            for i in findFiles:            
                self.var.allfiles.append(i)
            return True
        else:
            return False        

#============CLASS METHOD============        
    def ClearVariables(self):
        '''
        @note: service variables clear
        '''        
        assert self.var is not None
        self.var.__clear__()

#============CLASS METHOD============
    def WriteContent(self, content, filename, append=False):
        '''
        @note: service variables clear
        @return: True or False
        '''         
        if len(content) < 1:
            return False
        elif len(filename) < 1:
            return False
        
        exst = self.ExistFile(filename)
        if exst and append:
            FILE = self.AppendFile(self.var.filename)
        else:
            if not self.var.no_path or self.var.no_path is None:
                path = os.getcwd()
                path += const.SLASH
                path += filename
                filename = path
            
            FILE = self.CreateFile(filename)
        
        if FILE:
            if type(content) == type(list()):
                FILE.writelines(content)
            else:
                FILE.write(content)
                
            FILE.close()
            return True
        else:
            return False

#============CLASS METHOD============
    def ReadContent(self, filename):
        '''
        @note: service read content from input filename
        @return: True or False
        '''         
        if len(filename) < 1:
            return False

        FILE = self.OpenFile(filename)
        if FILE:                
            cont = FILE.readlines()
            FILE.close()
            if len(self.var.content) > 0:
                del self.var.content[:]
            self.var.content = cont
            return True
        else:
            return False
        
    def WriteMessage(self, message, filename):
        '''
        @note: service write user message to input filename
        @return: True or False
        '''
        if len(message) < 1:
            return False
        
        message += const.NEWLINE
        return self.WriteContent(message, filename, True)
        
    
#============CLASS METHOD============
#__main__ section
#==========================================================================
if __name__ == '__main__':
    msr = CFileService()
#===========================================================================
# print 'Proces start {0} {1}\n'.format(datetime.datetime.today().strftime('%d.%m.%Y'), datetime.datetime.now().strftime('%H:%M:%S'))
# print 'Proces end {0} {1}\n'.format(datetime.datetime.today().strftime('%d.%m.%Y'), datetime.datetime.now().strftime('%H:%M:%S'))
#===========================================================================