#!/usr/bin/python
#-*- coding: UTF-8 -*-
'''
    Created on 19.11.2010
    @author:  e_mnadvo
    @summary: global methods for all services 
    @change:  
    @version: 1.8.3
    @contact: nadvornm@gmail.com
    @copyright: NO WARRANTY  BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
                FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. AFD � Studio 2010
'''
import os
import sys
import exceptions as ex
import datetime
import subprocess as proc
import string
import ConfigParser as cfg_pars
import shlex
import select
import errno
import time
import xml.dom.minidom as xmlminidom
import re
import math
import logging
import time
import threading
import copy
import csv

#check correct import
try:
    import service_constants as const
except ex.ImportError, ie:
    sys.stderr.write('Invalid import of module \"service_constants\"\n{0}'.format(ie))
    raise ex.SystemExit

try:
    import except_service as exsrv
except ex.ImportError, ie:
    sys.stderr.write('Invalid import of module \"service_constants\"\n{0}'.format(ie))
    raise ex.SystemExit

#services section
work_path  = os.getcwd() + const.SLASH
file_service_name = 'file_service.py'

class _Point_3D(object):
    '''
    Class 
    '''
    def __init__(self):
        object.__init__(self)
        self.x = None
        self.y = None
        self.z = None
        

def ShowStdout(output):
    '''
    @note: Method for show output messsage to stdout
    '''
    if output is None:
        sys.stderr.write(const.ERR_STDOUT_EMPTY)
        sys.stderr.write(const.NEWLINE)
            
    if type(output) == type(list()):
        for i in output:            
            sys.stdout.write(i)
            sys.stdout.write(const.NEWLINE)                        
    elif type(output) == type(str()):
        sys.stdout.write(output)
        sys.stdout.write(const.NEWLINE)
    else:
        sys.stderr.write(const.ERR_UNKNOWN_TYPE)
        sys.stderr.write(const.NEWLINE)
            

def ShowStderr(output):
    '''
    @note: Method for show output messsage to stderr
    '''
    if output is None:
        sys.stderr.write(const.ERR_STDOUT_EMPTY)
        sys.stderr.write(const.NEWLINE)
            
    if type(output) == type(list()):
        for i in output:            
            sys.stderr.write(i)
            sys.stderr.write(const.NEWLINE)
    elif type(output) == type(str()):
        sys.stderr.write(output)
        sys.stderr.write(const.NEWLINE)
    else:
        sys.stderr.write(const.ERR_UNKNOWN_TYPE)
        sys.stderr.write(const.NEWLINE)


def StrDateTime(dateformat=const.DATEFORMAT, timeformat=const.TIMEFORMAT):
    '''
    @note: Return current date and time as string
    '''
    return '{0} {1}'.format(datetime.datetime.today().strftime(dateformat), datetime.datetime.now().strftime(timeformat))            


def StrDate(format=const.DATEFORMAT):
    '''
    @note: Return current date as string
    '''
    return datetime.datetime.today().strftime(format)


def StrTime(format=const.TIMEFORMAT):
    '''
    @note: Return current time as string
    '''
    return datetime.datetime.now().strftime(format)


def GetFilesList(directory):
    '''
    @note: Service return list with all items in directory  
    '''
    if os.path.isdir(directory):
        return os.listdir(directory)
    else:
        return None


def GetFloatFromInput(info_string):
    '''
    @note: Service return number as float if it's input correctly or 0.0  
    '''
    return_value = raw_input(info_string)
    try:
       return_value = float(return_value)
    except:
       return_value = 0.0
    
    return return_value

def GetLongFromInput(info_string):
    '''
    @note: Service return number as float if it's input correctly or 0.0  
    '''
    return_value = raw_input(info_string)
    try:
       return_value = long(return_value)
    except:
       return_value = 0.0
    
    return return_value

def GetCoordinateByLine(first, first_min, first_max, second_min, second_max):
    '''
    @note: Service return value from 2D line equation by input parameters  
    '''        
    DF = first_max - first_min
    DS = second_max - second_min
         
    val = second_min + DS*((first-first_min)/DF)
    return val

    
def GetCfgDataFromFiles(self, cfg_file=None):
    '''
    @note: Service return list of cfg values from file   
    '''  
    if cfg_file is not None and os.path.isfile(cfg_file):        
        cfg_data = list()
        try:
            cfg_flname = cfg_file
            cfg_file = open(cfg_flname, 'r')         
            stop = False
            while(stop is not True):
                line = cfg_file.readline()                
                line = string.strip(line)
                if (line == '' or len(line) == 0):
                    stop = True
                else:
                    if( line[0] != "#"):
                        cfg_data.append(line)

        except:
            sys.stderr.write(const.EXCEPT_MSG_IOERROR)
            raise
        
        return cfg_data


def LogStart(filename, script_name=None):
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
        raise

    
def LogToFile(filename, message):
    '''
    @note: Service write message to file, primary to log file  
    '''  
    try:
        if len(filename) > 3:
            file = open(filename, 'a')
            if file and len(message) <> 0:                
                str = const.LOG_FORMAT_3.format(StrTime(), const.USER, message)
                str += const.NEWLINE               
                file.write(str)
            file.close()
        else:
            sys.stderr.write(const.ERR_INVALID_INPUT_1.format(filename))
    except:
        sys.stderr.write(const.EXCEPT_MSG_FILEOPERATION.format(filename))
        raise


def LogEnd(filename):
    '''
    @note: Service write end  message to logfile, primary to log file  
    ''' 
    if os.path.isfile(filename) is not True:
        return 
    
    try:
        ENDLINE = 20
        file = open(filename, 'a')
        str = const.LOG_EMPT_LINE.format((ENDLINE-1)/2*'#')
        str += ' END SCRIPT '
        str += const.LOG_EMPT_LINE.format((ENDLINE-1)/2*'#') + const.NEWLINE
        str += const.NEWLINE
        file.write(str)
        file.close()
    except:
        sys.stderr.write(const.EXCEPT_MSG_FILEOPERATION.format(filename))
        raise


def SaveToFile(filename, content):
    '''
    @note: Service write content to file  
    '''  
    try:
        if len(filename) > 3:
            file = open(filename, 'w')
            if file and len(content) <> 0:                
                str = content
                if re.search(const.NEWLINE, str) is None:
                    str += const.NEWLINE               
                file.write(str)
            file.close()
        else:
            sys.stderr.write(const.ERR_INVALID_INPUT_1.format(filename))
    except:
        sys.stderr.write(const.EXCEPT_MSG_FILEOPERATION.format(filename))
        raise


def AppendToFile(filename, content):
    '''
    @note: Service write content to file  
    '''  
    try:
        if len(filename) > 3:
            file = open(filename, 'a')
            if file and len(content) <> 0:                
                str = content
                if re.search(const.NEWLINE, str) is None:
                    str += const.NEWLINE               
                file.write(str)
            file.close()
        else:
            sys.stderr.write(const.ERR_INVALID_INPUT_1.format(filename))
    except:
        sys.stderr.write(const.EXCEPT_MSG_FILEOPERATION.format(filename))
        raise




def ShowOutputAndLog(logfile, msg):
    ShowStdout(msg)
    if len(logfile) > 0:
        LogToFile(logfile, msg)


def ShowErrorAndLog(logfile, msg):
    ShowStderr(msg)
    if len(logfile) > 0:
        LogToFile(logfile, msg)    

    
def isDir(param):
    if os.path.isdir(param) is not False:
        return True
    else:
        return False    


def isFile(param):
    if os.path.isfile(param) is not False:
        return True
    else:
        return False    


def getUpDir(path):
    retval = const.SLASH
    if os.path.isdir(path) is True:        
        items = string.splitfields(path, const.SLASH)
        if items[0] == "":
            del items[0]
            
        if len(items) > 0:
            for i in range(len(items)-1):
                retval = os.path.join(retval, items[i])
            
    if len(retval) > len(const.SLASH):
        return retval
    else:
        return path


'''
Metoda spusti vzdaleny proces
'''
def execute_process(args, usercwd=os.getcwd(), usershell=True, logfile=None):    
    try:
        #command
        process_err = ''
        retval = None
        #
        if logfile is not None:
            LogToFile(logfile, args)
            logfileno = open(logfile, 'a')
        else:
            logfileno = open(const.NULL_OUTPUT, 'w')
        
        plt_proc = proc.Popen(args, bufsize=const.BUFFSIZE, stdout=logfileno, stderr=logfileno, shell=usershell, cwd=usercwd)  #close_fds=True,
        
        while retval is None:
            retval = plt_proc.poll()
        '''        
        retval = plt_proc.communicate()
        plt_proc.stdout.close()
        plt_proc.stderr.close()

        process_out = retval[0]
        process_err = retval[1]  
        
        if len(process_out) > 0 and logfile is not None:
            LogToFile(logfile, process_out)
        
        if len(process_err) > 0 and logfile is not None:
            LogToFile(logfile, process_err)
        ''' 
        return (True, retval)
                           
    except ex.OSError, ie:
        process_err += const.EXCEPT_MSG_PROCESS_EXE.format(ie)
        if len(process_err) > 0:
            if logfile is not None:
                LogToFile(logfile, process_err)
            else:
                ShowStderr(process_err)

        return (False, process_err)
    
'''
Metoda spusti vzdaleny proces
'''
def execute_process3(args, usercwd=os.getcwd(), usershell=True, logfile=None):    
    try:        
        retval = None
        output = None
        logfileno = open(os.path.join(usercwd,const.TEMP_OUTPUT), 'w')
             
        if logfile is not None:
            LogToFile(logfile, args)
        
        plt_proc = proc.Popen(args, bufsize=const.BUFFSIZE, stdout=logfileno, stderr=logfileno, shell=usershell, cwd=usercwd)  #close_fds=True, 
        logfileno.close()
        while retval is None:
            retval = plt_proc.poll()
        
        if isFile(const.TEMP_OUTPUT) is True:
            logfileno = open(const.TEMP_OUTPUT, 'r')
            
            if retval >= 0:
                output = logfileno.read() 
        '''
        retval = plt_proc.communicate()
        plt_proc.stdout.close()
        plt_proc.stderr.close()
        process_out = retval[0]
        process_err = retval[1]  
        
        if len(process_out) > 0 and logfile is not None:
            LogToFile(logfile, process_out)            
            
        if len(process_err) > 0 and logfile is not None:
            LogToFile(logfile, process_err)
        ''' 
        if output is not None:
            return (True, output)
        else:
            return (False, retval)
                           
    except ex.OSError, ie:
        process_err = const.EXCEPT_MSG_PROCESS_EXE.format(ie)
        if len(process_err) > 0:
            if logfile is not None:
                ShowErrorAndLog(logfile, process_err)
            else:
                ShowStderr(process_err)
        raise    
        return (False, process_err)


'''
Metoda provede zamenu dvou stringu old to new u vsech souboru v zadanem adresari 
'''
def change_strings_in_files(directory, old_string, new_string, logfile=None):
    if isDir(directory):
        #nastavim command
        command = 'grep -rl \'{0}\' ./ '
                
        if string.rfind(old_string,'/') != -1:
            oldch_string = string.replace(old_string, "/", "\/")
        else:
            oldch_string = old_string
            
        if string.rfind(new_string, '/')!= -1:
            new_string = string.replace(new_string, "/", "\/")            
        
        command = command.format(old_string)
        #args = shlex.split(command)
        output = execute_process3(command, directory, True, logfile)
        #ShowStdout(output)
        if output[0] is True:
            lines = string.splitfields(output[1], const.NEWLINE)
            for i in lines:
                if len(i) > 1:
                    perlcmd = 'perl -pi -W -e \'s/{0}/{1}/g\' {2}'
                    perlcmd = perlcmd.format(oldch_string, new_string, i)
                    output = execute_process3(perlcmd, directory, True, logfile)
                    
                    return output[0]
        else:
            return output[0]

    else:
        return False
        
        
'''
Metoda provede zamenu dvou stringu old to new u souboru v zadanem adresari 
'''
def change_strings_in_file(file, directory, old_string, new_string, logfile=None):
    if isFile(file) and isDir(directory):
        #nastavim command
        perlcmd = 'perl -pi -W -e \'s/{0}/{1}/g\' {2}'
                       
        if string.rfind(old_string,'/') != -1:
            oldch_string = string.replace(old_string, "/", "\/")
        else:
            oldch_string = old_string
        
        if string.rfind(new_string, '/')!= -1:
            new_string = string.replace(new_string, "/", "\/")

        perlcmd = perlcmd.format(oldch_string, new_string, file)
        output = execute_process3(perlcmd, directory, True, logfile)
        #ShowStdout(output)
            
        return output[0]
    else:
        return False

'''
Metoda overuje vstupni hodnotu zda-li je cislo nebo ne
'''
def is_number(val):
    try:
        ret = float(val)
    except:        
        ret = ''
    
    if isinstance(ret, float):
        return True
    else:
        return False
    
'''
Metoda nacita libovolny soubor a vraci obsah jako list
'''
def read_file(filename, logfile=None):
    retval = None
    msg = None
    try:
        if isFile(filename):
            source = open(filename, 'r')
            retval = source.readlines()
        else:
            msg = const.ERR_INVALID_FILE
    except ex.IOError, e:
        msg = const.EXCEPT_MSG_FILEOPERATION.format(filename)
        raise        
    except:
        msg = const.EXCEPT_MSG_OPERATION.format("read_file")
        raise      
    finally:
        if msg is not None:
            ShowStderr(msg)
            if logfile is not None:
                LogToFile(logfile, msg)
        
        return retval

'''
Metoda rozlozi radek na jednotlive casti, kde oddelovac je mezera, lze zadat vyraz, ktery se ma zahrnout
'''     
def parse_line(line, include=None):
    retval = list()
    if len(line) > 1:
        items = string.split(line, ' ')
        if len(items) > 0:
            emptystring = re.compile("\\b.*")
            for i in items:                
                value = emptystring.findall(i)
                if len(value) > 0 and len(value)>0 and value != const.NEWLINE:
                    if include is None or re.search(include, i) is not None:
                        retval.append(i)
    
    return retval

'''
Metoda rozlozi radek na jednotlive casti, kde oddelovac je zadan uzivatelem
'''
def parse_line_by_sep(line, separator):
    retval = list()
    if len(line) > 1:
        #line = remove_endline(line, 1)
        items = string.split(line, separator)
        if len(items) > 0:
            emptystring = re.compile("\\b.*")
            for i in items:                
                value = emptystring.findall(i)
                if len(value) > 0 and len(value)>0 and value != const.NEWLINE:                    
                    retval.append(i)
    
    return retval    
'''
Metoda rozlozi radek na jednotlive casti, kde oddelovac je mezera, lze zadat vyraz, ktery se nema zahrnout
'''     
def parse_line_without(line, exclude=None):
    retval = list()
    if len(line) > 1:
        items = string.split(line, ' ')
        if len(items) > 0:
            emptystring = re.compile("\\b.*")
            for i in items:                
                value = emptystring.findall(i)
                if len(value) > 0 and len(value)>0 and value != const.NEWLINE:
                    if exclude is None or re.search(exclude, i) is None:
                        retval.append(i)
    
    return retval    

'''
Metoda odtranuje odradkovani na konci radku
'''
def remove_endline(line, endfile_len= const.ENDFILE_LEN):
    retval = ''
    if re.search(const.NEWLINE, line) is not None:
        last_char = (len(line)-endfile_len)
        retval = line[0:last_char]
    else:
        retval = line

    return retval

'''
Metoda rozlozi radek a pro jednotlive casti vrati cislo, pokud jej obsahuje, jako typ float
'''
def get_float_value(value, sepformat=None):
    if sepformat is not None:
        separator = sepformat
    else:
        separator = const.SPACE
    
    values = list()
    
    if isinstance(value, basestring):
        items = string.split(value, separator)
        for i in items:        
            if is_number(i) is True:
                values.append(float(i))
    
    if len(values) == 1:
        return values[0]
    else:
        return values


def get_low_value(value, values_list):
    if isinstance(values_list, list) is not True:
        return None
    else:
        val = min(values_list)
        for i in values_list:
            if i > val and i <= value:
                val = i

        if val is not None:
            return val
    
    return None


def get_high_value(value, values_list):
    if isinstance(values_list, list) is not True:
        return None
    else:
        val = min(values_list)
        for i in values_list:
            if i >= val and i > value:
                val = i
                break

        if val is not None:
            return val
    
    return None


def get_low_value_from_tuplelist(value, values_list, id):
    if isinstance(values_list, list) is not True:
        return None
    else:
        val = min(values_list, key=lambda point: [id])
        for i in values_list:
            if i[id] > val[id] and i[id] <= value:
                val = i

        if val is not None:
            return val
    
    return None


def get_high_value_from_tuplelist(value, values_list, id):
    if isinstance(values_list, list) is not True:
        return None
    else:
        val = None
        for i in values_list:
            if i[id] > value:
                val = i
                break

        if val is not None:
            return val
    
    return None


def get_index_from_tuplelist(value, values_list):
    for ind in range(len(values_list)):
        if value == values_list[ind]:
            return ind
    
    return -1


def save_3DPoints_list(points, filename=None, plotcm=True):
    if filename is not None:
        deffilename = filename
    else:
        deffilename = 'points_list.dat'
    
    format_val = '{0:8.8f} {1:8.8f} {2:8.8f}\n'
    
    filetest = open(deffilename, 'w')
    outline =''
    plotcmd = 'splot \"{3}\" using {0}:{1}:{2} with points notitle'
    
    for point in points:
        outline += format_val.format(point.x, point.y, point.z)
        filetest.write(outline)
        outline = ''
    
    if plotcm is True:
        cmd = plotcmd.format(1, 2, 3, deffilename)
        filetest.write(cmd)    
    filetest.close()

'''
Method return all numerical values from dat file.
'''    
def get_values_from_2Dsufacefile(filename):
    if os.path.isfile(filename) is not True:
        return list()
    retVals = list()
    try:
        datafile = open(filename, 'r')
        alldata = datafile.readlines()        
        if len(alldata) > 0:
            for item in alldata:                
                is_only_numbers = True
                test_nums = string.split(item)
                for word in test_nums:
                    if is_number(word) is not True:
                        is_only_numbers = False
                        break
                
                if is_only_numbers == True:
                    line_data = string.splitfields(item)                
                    if len(line_data) == 4 and float(line_data[0]) == 0.0:
                        value = (float(line_data[0]), float(line_data[1]), float(line_data[2]), float(line_data[3]))
                        retVals.append(value)                        
    except:
        print 'Failed when open field quantity data file.\n'
        raise
    
    return retVals


def SaveListToFile(filename, content):    
    '''
    @note: Service write content to file  
    '''  
    try:
        if len(filename) > 3:
            file = open(filename, 'w')
            if file and len(content) <> 0:
                for str in content:                
                    if re.search(const.NEWLINE, str) is None:
                        str += const.NEWLINE               
                    file.write(str)
            file.close()
        else:
            sys.stderr.write(const.ERR_INVALID_INPUT_1.format(filename))
    except:
        sys.stderr.write(const.EXCEPT_MSG_FILEOPERATION.format(filename))
        raise


def GetLineNumbFromList(context, lookForPatern):
    '''
    @note: Method for search line from context with given pattern
    '''
    lnIndx = 0    
    if isinstance(context, list) is not True or len(context) < 1:
        return lnIndx
    
    for line in context:
        if re.search(lookForPatern,line) is not None:
            return lnIndx
        
        lnIndx += 1
        
    return lnIndx


def WriteCSV(filename, context):
    '''
    @note: Method for write context to csv file
    '''
    retval = False
    if filename is None or context is None or len(filename) < 1 or len(context) < 1:
        return retval
    
    try:
        fl_hndl = open(filename,'wb')
        csvhndl = csv.writer(fl_hndl,delimiter='\t')
        if isinstance(context,list):
            csvhndl.writerows(context)
        
        if isinstance(context, str):
            csvhndl.writerow(context)
    except:
        sys.stderr.write(const.EXCEPT_MSG_FILEOPERATION.format(filename))
        raise
    finally:
        fl_hndl.close()
        retval = True
        
    return retval
        
    
    
if __name__ == '__main__':    
    print "Done"
    