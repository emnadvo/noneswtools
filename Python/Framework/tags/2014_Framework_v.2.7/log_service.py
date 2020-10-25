#!C:\NOne\Python26  #upravit dle uzivatelskeho nastaveni
#-*- coding: cp1250 -*-

'''     Created on 14.1.2010
      @author: e_mnadvo
       Description: 
       @change: 
    @version: 1.0.1
    @contact: nadvornm@gmail.com
    @copyright: NO WARRANTY  BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
                         FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. NOne © Tech 2009
'''

import os
import sys
import datetime
import string
import logging

import archive_service
import file_service

LOG_UNIT_HEAD = '#\tPROGRAM UNIT {0} STARTED '
LOG_EMPT_LINE = '#{0}#'
LOG_LINE_USR = '#\tUSER: {0}\tPC: {1}'
LOG_LINE_DT = '#\tDATE: {0}\tTIME: {1}'
LOG_LINE_PC = '#\tPROC: {0}\tMAX INT: {1}'

START_HEAD = "Start skript"

class _logmanager_variables_(object):
    '''
    Class for save variables for master class CLogManager
    '''    
    def __init__(self):
        self.out_stream = None
        self.outstream_set = False        
        self.err_stream = None
        self.errstream_set = False
        self.logfilename = None
        self.logfile_set = False
         

class CLogManager(object):
    '''
    classdocs
    '''
    
    def __init__(self, path="", **kwargs):
        '''
        Constructor
        '''
        self.var = _logmanager_variables_()
        
        flmanag = file_service.CFileService(True)
        global msgFormat
        msgFormat = "{0}|{1} |{2}\n"
        logHeader = "Start skript"
        now = datetime.datetime.today()
        ArchiveFile = now.strftime('%d%m%Y')+'_Archive_{0}'
        self.logName = ''
        #keyword parsing
        for ky in kwargs.keys():
            param = string.upper(ky)
            if param == 'LOGNAME':
                self.logName = '_'+kwargs[ky]+'.log'
                continue            
                
        if len(self.logName) == 0:
            self.logName = "_syslog.log"
        
        #Logs directory check and create            
        if len(path) == 0:
            path = os.path.join(os.getcwd(),'Logs')
        
        if os.path.isdir(path):
            if path.find('Logs'):
                pass
            else:
                path = os.path.join(path,'Logs')                
                os.mkdir(path)
        else:
            os.mkdir(path)
            
        
        fileExist = False
        SrcFileName = ''
        DestFileName = ''
        OldItem = ''
        CntOldArch = 0
        
        for fileItem in os.listdir(path):
            if os.path.isfile(os.path.join(path,fileItem)):
                if fileItem.find(self.logName) > 0:
                    #zabalit stary soubor
                    testChar = fileItem[:8]
                    if testChar == now.strftime('%d%m%Y'):
                        fileExist = True
                        OldItem = fileItem
                    continue
                if fileItem.find('.gz')>0:
                    testChar = fileItem[:8]
                    if testChar == now.strftime('%d%m%Y'):
                        CntOldArch += 1
                    continue
        
#         if fileExist:
#             ArchiveFile = ArchiveFile.format(CntOldArch)
#             ziptool = archive_service.CArchService()
#             ziptool.ArchiveFile(path + OldItem, path+ArchiveFile)
    
        self.logName = now.strftime('%d%m%Y') + self.logName
        self.logName = os.path.join(path,self.logName)
        
        try:
            self.logFile = open(self.logName, 'w')
        except ValueError, vle:
            print >>sys.stderr, "ValueError raised:", vle
        except OSError, e:
            print >>sys.stderr, "Execution failed:", e
        else:
            self.WriteToLog(type="START", msg=logHeader)
        
    def WriteToLog(self, **kwargs):
        now = datetime.datetime.now()
        Typelenght = len('warning')
        type = 'INFO'
        message = ''
        for key in kwargs.keys():
            param = string.upper(key)
            if param == 'TYPE':
                type = string.upper(kwargs[key])
                continue
            elif param == 'MSG':
                message = kwargs[key]
                continue
            else:
                continue
        #prida mezery k typu zpravy - zarovnani oddelovacu
        spaceCnt = Typelenght - len(type)        
        if spaceCnt > 0:
            type = type + (spaceCnt * ' ')
        
        if self.logFile and len(message)>0:            
            PrintMsg = msgFormat.format(now.strftime('%d/%m/%Y %H:%M.%S'),type,message)            
            self.logFile.write(PrintMsg)
            return
        
    def WriteInfo(self, message, *args, **kwargs):
        self.WriteToLog(type="info", msg=message)
        
    def WriteWarning(self, message, *args, **kwargs):
        self.WriteToLog(type="warning",msg=message)
        
    def WriteError(self, message, *args, **kwargs):
        self.WriteToLog(type="error", msg=message)
        
    def __del__(self):
        self.logFile.close()
        
    def LogStart(self, filename, script_name=None):
        '''
        @note: Service write start message to file, primary to log file  
        '''      
        try:
            if len(filename) > 3:
                file = open(filename, 'a')
                if script_name is None:
                    script_name = ''
                    
                str_len = 0
                log_line = None
                # Program unit started
                str_head = const.LOG_HEAD.format(script_name)
                if str_len < len(str_head):
                    str_len = len(str_head)
                # Uzivatel:    Pocitac:
                str_usr = const.LOG_LINE_USR.format(const.USER, const.MACHINE)
                if str_len < len(str_usr):
                    str_len = len(str_usr)
                # Datum:    Cas:
                str_date = const.LOG_LINE_DT.format(StrDate(), StrTime())
                if str_len < len(str_date):
                    str_len = len(str_date)
                # PROC:    MEM:
                str_pc = const.LOG_LINE_PC.format(os.sysconf('SC_NPROCESSORS_CONF'), os.sysconf('SC_INT_MAX'))
                if str_len < len(str_pc):
                    str_len = len(str_pc)
                
                
                hash_char = str_len - len(str_head) - 1
                str_head += hash_char*const.SPACE + const.HASH
                
                space_char = str_len - len(str_usr) - 1
                str_usr += space_char*const.SPACE + const.HASH 
                
                space_char = str_len - len(str_date) - 1
                str_date += space_char*const.SPACE + const.HASH
                
                space_char = str_len - len(str_pc) - 1
                str_pc += space_char*const.SPACE + const.HASH
                            
                border_line = const.LOG_EMPT_LINE.format((str_len)*'#')
                empt_line = const.LOG_EMPT_LINE.format((str_len)*' ')
                
                log_line = border_line + const.NEWLINE
                log_line += empt_line + const.NEWLINE
                log_line += str_head + const.NEWLINE
                log_line += empt_line + const.NEWLINE
                log_line += str_usr + const.NEWLINE
                log_line += empt_line + const.NEWLINE
                log_line += str_date + const.NEWLINE            
                log_line += empt_line + const.NEWLINE
                log_line += str_pc + const.NEWLINE
                log_line += empt_line + const.NEWLINE             
                log_line += border_line + const.NEWLINE            
                            
                file.write(log_line)
                file.close()    
        except:
            sys.stderr.write(const.EXCEPT_MSG_FILEOPERATION.format(filename))

#Test section
if __name__ == '__main__':
    logMgr = CLogManager()
    #----------------------------------- logMgr.WriteError("Dnes to nefunguje!")
    #------------------------------------ logMgr.WriteInfo("Dnes to nefunguje!")
    #--------------------------------- logMgr.WriteWarning("Dnes to nefunguje!")
    
    
    '''
             # Program unit started
            str_head = const.LOG_HEAD.format(script_name)
            if str_len < len(str_head):
                str_len = len(str_head)
            # Uzivatel:    Pocitac:
            str_usr = const.LOG_LINE_USR.format(const.USER, const.MACHINE)
            if str_len < len(str_usr):
                str_len = len(str_usr)
            # Datum:    Cas:
            str_date = const.LOG_LINE_DT.format(StrDate(), StrTime())
            if str_len < len(str_date):
                str_len = len(str_date)
            # PROC:    MEM:
            str_pc = const.LOG_LINE_PC.format(os.sysconf('SC_NPROCESSORS_CONF'), os.sysconf('SC_INT_MAX'))
            if str_len < len(str_pc):
                str_len = len(str_pc)
            
            
            hash_char = str_len - len(str_head) - 1
            str_head += hash_char*const.SPACE + const.HASH
            
            space_char = str_len - len(str_usr) - 1
            str_usr += space_char*const.SPACE + const.HASH 
            
            space_char = str_len - len(str_date) - 1
            str_date += space_char*const.SPACE + const.HASH
            
            space_char = str_len - len(str_pc) - 1
            str_pc += space_char*const.SPACE + const.HASH
                        
            border_line = const.LOG_EMPT_LINE.format((str_len)*'#')
            empt_line = const.LOG_EMPT_LINE.format((str_len)*' ')
            
            log_line = border_line + const.NEWLINE
            log_line += empt_line + const.NEWLINE
            log_line += str_head + const.NEWLINE
            log_line += empt_line + const.NEWLINE
            log_line += str_usr + const.NEWLINE
            log_line += empt_line + const.NEWLINE
            log_line += str_date + const.NEWLINE            
            log_line += empt_line + const.NEWLINE
            log_line += str_pc + const.NEWLINE
            log_line += empt_line + const.NEWLINE             
            log_line += border_line + const.NEWLINE 
            
    '''
    
