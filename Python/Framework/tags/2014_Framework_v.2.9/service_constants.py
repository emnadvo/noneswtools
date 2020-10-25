#!'C:\Documents and Settings\vign54\Dokumenty\Python27\python.exe'
#-*- coding: UTF-8 -*-

'''
Created on 18.11.2010
    @author:  e_mnadvo
    @summary: constants for all services 
    @change:  
    @version: 1.8.5
    @contact: nadvornm@gmail.com
    @copyright: NO WARRANTY  BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
                FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. AFD � Studio 2010
'''
import platform
import os

#SYSTEM PROPERTIES
if (platform.uname()[0] != 'Linux'):
    SLASH = '\\'
    ISLINUX = False
    USER = os.getenv("USERNAME")
    MACHINE = os.getenv('COMPUTERNAME')
    NULL_OUTPUT = 'trash_logfile.log'
    ENDFILE_LEN = 1
else:
    SLASH = '/'
    ISLINUX = True
    USER = os.getenv("USER")
    MACHINE = os.getenv('HOST')
    FILE_MOVE = 'mv -v --backup=t {0} {1}'
    FILE_COPY = 'cp -v --backup=t {0} {1}'
    FILE_RM = 'rm {0}'
    FILES_STRCHANGE ='perl -pi -W -e \'s/{0}/{1}/g\' {2}'
    NULL_OUTPUT = '/dev/null'
    ENDFILE_LEN = 2
    


#VALUE CONSTANTS
MIN_EXT_LN = 3  #minimalni delka pripony
MM_TO_METR = 1e-3
M_TO_MM = 1e3
INCHTOMM = 25.4
MPA_TO_PA = 1000000
MPA_TO_BAR = 10
PA_TO_BAR = 10e5
PI = 3.14159265358979
DEG_TO_RAD = float(PI/180)
DEG_TO_KELVIN = 273.15
BUFFSIZE = 4096


#CHAR CONSTANTS
DEFAULT_ARCH_NAME = 'MAINTENANCE'
NEWLINE= '\n'   #znak noveho radku
TABULATOR = '\t'
SEPARATOR = '_'
MSEPARATOR = '-'
DOTSEPAR = '.'
DATEFORMAT = '%d.%m.%Y'
SHORTDATEFORMAT = '%d%m%y'
TIMEFORMAT = '%H:%M:%S'
SPACE = ' '
LOG_FORMAT_1 = '{0}'
LOG_FORMAT_2 = '{0}|{1}'
LOG_FORMAT_3 = '{0}|{1}|{2}'
HASH = '#'
YES = 'A'
NO = 'N'
EMPTY_LINE = '\b.*'
FIND_CHAR = '.*[a-zA-Z].*'
RE_DOT = '[\.]' 
TEMP_OUTPUT = 'temp_out.out'

#FORMAT MESSAGES
FRMT_FILENAME = "Filename: %s"
FRMT_PATH = "Path: %s"
FRMT_CNT = '.{0}'
FRMT_GVAL_4D = '{0:4G}'
FRMT_VAL_I = '{0}'
FRMT_VAL_2 = '{0} {1}'
FRMT_FVAL = '{0:6.6f}'
FRMT_FVAL_1 = '{0:6.0f}'
FRMT_FVAL_2 = '{0:6.5f} {1:6.5f}'
FRMT_FVAL_4 = '{0:6.8f} {1:6.8f} {2:6.7f} {3:6.7f}'

NFO_CREATEDIR_P1 = 'CREATE DIRECTORY {0}'

#regular expressions
RGX_CHARS = '[a-zA-Z]'
RGX_NUMBER = '[0-9]'



#PRINT MESSAGES
MSG_INVAL_ARGS = 'INVALID ARGUMENTS: '
MSG_ARGS = "ARGUMENTS:\n" 
LOG_HEAD = '#\tPROGRAM UNIT {0} STARTED '
LOG_EMPT_LINE = '#{0}#'
LOG_LINE_USR = '#\tUSER: {0}\tPC: {1}'
LOG_LINE_DT = '#\tDATE: {0}\tTIME: {1}'
LOG_LINE_PC = '#\tPROC: {0}\tMAX INT: {1}'
MAX_LOG_START_LINE = 8
EXEC_OK = 'TRUE'
EXEC_FALSE = 'FALSE'
EXEC_FAIL = 'FAILED'
EXEC_ERROR = 'ERROR'

#ERROR MESSAGES
ERR_STDOUT_EMPTY = 'NOTHING FOR OUTPUT'
ERR_INVALID_FILE = 'YOUR FILENAME IS NOT VALID. CHECK IT!'
ERR_INVALID_PATH = 'YOUR PATH IS NOT VALID. CHECK IT!'
ERR_UNKNOWN_TYPE = 'UNKNOWN TYPE FOR OUTPUT'
ERR_INVALID_INPUT = 'INVALID INPUT PARAMS'
ERR_INVALID_INPUT_1 = 'INVALID INPUT PARAM {0}'


#EXCEPTION MESSAGE
EXCEPT_MSG_CATCH = 'CATCH EXCEPTION\t{0}!.\n'
EXCEPT_MSG_UNKNOWN = 'UNKNOWN EXCEPTION RAISE IN FUNCTION {0}!\n'
EXCEPT_MSG_IOERROR = 'IO EXCEPTION RAISED IN FUNCTION {0}\n{1}!'
EXCEPT_MSG_OSERROR = 'OS EXCEPTION RAISED IN FUNCTION {0}\n{1}!'
EXCEPT_MSG_VALERROR = 'VALUE EXCEPTION RAISED IN FUNCTION {0}\n{1}!'
EXCEPT_MSG_TYPE = 'TYPE EXCEPTION RAISE IN FUNCTION {0}\n{1}!'
EXCEPT_MSG_FILEOPERATION = 'EXCEPTION THROW WHEN FILE OPERATION EXECUTED IN FILE {0}.\n'
EXCEPT_MSG_PROCESS_EXE = 'SUBPROCESS THROW EXCEPTION!\t{0}\n'
EXCEPT_MSG_OPERATION = 'EXCEPTION CATCH WHEN EXECUTION METHOD {0}'
EXCEPT_MSG_CATCH_IN_METHOD = 'EXCEPTION {0} WAS CATCHED IN METHOD {1}.\n{2}'
