#!/usr/bin/python
#-*- coding: UTF-8 -*-
''' Created on 19.10.2010
    @author: e_mnadvo
    @summary: service for archiving other file
    @change: 
    @version: 1.2.1
    @contact: nadvornm@gmail.com
    @copyright: NO WARRANTY  BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. AFD © Studio 2010
'''

#archive modules
import tarfile

#for command line argument parse
import optparse

#other usefully modules
import sys
import os
import datetime
import string
import exceptions as ex       #exceptions

#check correct import
try:
    import service_constants as const
    import service_methods as service
except ex.ImportError, ie:
    sys.stderr.write('Invalid import of module \"service_constants\" or \"service_methods\"\n{0}'.format(ie))
    raise ex.SystemExit
   
#global property
global def_ext, def_name, def_path

class messages:
    '''
    @note: error messages for arch_service class
    '''
    INVALID_CMD_COMPRESS = 'You used compress operation but the filename was undefined!'
    INVALID_CMD_EXTRACT = 'You used extract operation but the filename was undefined!'
    EXCEPT_COMPRESSION = 'Exception was raised when opening archfile {0} for compress operation!\n{1}'
    EXCEPT_EXTRACTION = 'Exception was raised when opening archfile {0} for extraction operation!\n{1}'


class arch_variable(object):
    '''
    @note: variables for class arch_variable
    ''' 
    def __init__(self):
        object.__init__(self)
        self.default_name = 'ARCH_'
        self.default_path = os.getcwd()
        self.default_type = '.tar.bz2'
        self.filename = None
        self.archname = None
        self.path = None
        self.extent = None
        
    def __clear__(self):
        self.filename = None
        self.archname = None
        self.path = None
        self.extent = None
    


class ArchService:
    '''
    Archive service tool provided base support for archiving files into tar or gzip format
    '''
    def arg_parse(self):
        '''
        @note: function parse command line arguments
        @return: True or False
        '''
        #cmd arg parse options
        info_usage = 'This %prog will compress your file into tar or gzip file\n\t%prog [-f] filename [-a] archname'
        option_list = [
            optparse.make_option("-f", "--file",\
                               type='string',\
                               dest='filename',\
                               help='name of filename for compressing',\
                               metavar='FILE'),                
            optparse.make_option("-a", "--arch",\
                               type='string',\
                               dest='archname',\
                               help='name of your archive file when to compress or extract',\
                               metavar='PATH'),
            optparse.make_option("-t", "--type",\
                               type='string',\
                               dest='comprtype',\
                               help='compress file type [Default: %default]',\
                               default='tar.bz2'),
            optparse.make_option("-c", "--compr",\
                               action='store_true',\
                               dest='compress',\
                               help='compressed file'),
            optparse.make_option("-e", "--ext",\
                               action='store_true',\
                               dest='extract',\
                               help='extract file'),                                                              
            #===================================================================
            # optparse.make_option("-r", "--dir",\
            #                   action='store_true',\
            #                   dest='include_dir',\
            #                   help='compressed including directory'),
            # optparse.make_option("-a", "--all",\
            #                   action='store_true',\
            #                   dest='all_files',\
            #                   help='compress all files in your path without directory'),
            #===================================================================
            optparse.make_option("-v",\
                                 action='store_true',\
                                 dest='verbose',\
                                 help='show arguments'),
            optparse.make_option("-q",\
                                 action='store_false',\
                                 dest='quiet',\
                                 help='don\'t print status messages to stdout'),
            ]
        #create cmd parser
        arch_parser = optparse.OptionParser(usage=info_usage, option_list=option_list)
        #incoming arguments parse 
        (self.options, args) = arch_parser.parse_args()      
        #test
        if len(args) > 0:
            ermsg = const.MSG_INVAL_ARGS
            for i in args:
                ermsg += i + const.TABULATOR
            if not self.options.quiet:    
                sys.stdout.write(ermsg)
                 
        without_args = False
        if self.options.compress is None and self.options.extract is None:
            without_args = True
        
        if not without_args:
            if self.options.compress and self.options.filename is None and \
            self.options.archname is None:
                arch_parser.error(messages.INVALID_CMD_COMPRESS)
                raise ex.Warning
            elif self.options.extract and self.options.archname is None:
                arch_parser.error(messages.INVALID_CMD_EXTRACT)
                raise ex.Warning
            
            if self.options.verbose:
                print const.MSG_ARGS
                print const.FRMT_FILENAME % self.options.filename
                print const.FRMT_PATH % self.options.archname
            
            self.var.filename = self.options.filename
            self.var.archname = self.options.archname

            if self.options.comprtype is None:
                self.var.extent = self.var.default_type
            else:
                self.var.extent = self.options.comprtype
            
            return True
        elif without_args is True:
            return True
        else:
            arch_parser.print_help()
            return False

    def __init__(self, internal = False):       
        '''
        Constructor
        '''
        #parse argument
        object.__init__(self)
        self.var = arch_variable()
        
        if not internal:
            if self.arg_parse():
                #validation your arguments
                if os.path.exists(def_path) <> True:
                    print "your path ({0}) don\'t exists!\nProgram aborted.".format(def_path)
                    #exit program
                    sys.exit()
                elif len(def_name) < 1 and self.options.include_dir <> True:
                    print "your filename ({0}) is invalid!\nProgram aborted.".format(def_name)
                    #exit program
                    sys.exit()
                else:
                    def_name = '{0}_ARCH_{1}'.format(datetime.datetime.today().strftime('%d%m%Y'), def_name)
      
            else:
                sys.exit()
        else:            
            self.var.archname = self.var.default_name
            self.var.path = self.var.default_path 
            self.var.extent = self.var.default_type

    def Compress(self, filearch, cnt=0):
        '''
        @note: compress file to archive with your extension
        @return: True or False
        ''' 
        f_in = ''       
        try:
            if self.var.extent == 'gzip':
                mode = 'w:gz'
            else:
                mode = 'w:bz2'
            
            if cnt == 0:
                f_in = '{0}_ARCH_{1}'.format(datetime.datetime.today().strftime('%d%m%Y'), self.var.archname) 
                
            else:
                f_in = self.var.default_name + self.var.archname + const.FRMT_CNT.format(cnt) + self.var.extent          

            f_in = f_in + self.var.extent
            
            defpath = os.getcwd()
            if self.var.path is not None:
                 os.chdir(self.var.path)
            
            #opening filename for compress operation
            archfile = tarfile.open(f_in, mode)            
            #archive file
            if type(filearch) == type(list()):
                for it in filearch:
                    archfile.add(it)
            else:
                archfile.add(filearch)
            #close archive
            archfile.close()
            
            os.chdir(defpath)
            return True
        
        except tarfile.CompressionError, ce:
            service.ShowStderr(messages.EXCEPT_COMPRESSION.format(f_in, ce))
        except ex.IOError, ioe:
            service.ShowStderr(const.EXCEPT_MSG_IOERROR.format('CompressFile', ioe))
        except ex.OSError, e:
            service.ShowStderr(const.EXCEPT_MSG_OSERROR.format('CompressFile', e))
        except ex.ValueError, vle:
            service.ShowStderr(const.EXCEPT_MSG_VALERROR.format('CompressFile', vle))
        except ex.TypeError, tp:
            service.ShowStderr(const.EXCEPT_MSG_TYPE.format('CompressFile', tp))
        except:
            service.ShowStderr(const.EXCEPT_MSG_UNKNOWN.format('CompressFile'))
        else:
            return False   
               
    def Extract(self, archive, destination=None):
        '''
        @note: Extract archive to destination
        @return: True or False
        ''' 
        try:              
            separname = string.splitfields(archive, const.DOTSEPAR)
            if separname[len(separname)-1] == 'gzip':
                mode = 'r:gz'
            else:
                mode = 'r:bz2'
            
            sepfile = string.splitfields(archive, const.SLASH)
            defpath = os.getcwd()
            if len(sepfile) > 1:                
                workpath = string.joinfields(sepfile[:len(sepfile)-1],const.SLASH)
            else:
                workpath = defpath
            
            os.chdir(workpath)
            
            if destination is None:
                dest_path = os.getcwd() 
            else:
                dest_path = destination

            archive = sepfile[len(sepfile)-1]
                
            f_out = tarfile.open(archive, mode)            
            f_out.extractall(dest_path)
            f_out.close()
            
            os.chdir(defpath)
            return True
        
        except tarfile.CompressionError, ce:
            service.ShowStderr(messages.EXCEPT_EXTRACTION.format(archive, ce))
        except ex.IOError, ioe:
            service.ShowStderr(const.EXCEPT_MSG_IOERROR.format('Extract', ioe))
        except ex.OSError, e:
            service.ShowStderr(const.EXCEPT_MSG_OSERROR.format('Extract', e))
        except ex.ValueError, vle:
            service.ShowStderr(const.EXCEPT_MSG_VALERROR.format('Extract', vle))
        else:
            return False
    
    def CompressDir(self, directoryname):
        '''
        @note: Method for compress all items in input directory
        @return: True or False
        '''
        if type(directoryname) == type(str()):
            seprdir = string.splitfields(directoryname, const.SLASH)
            if len(seprdir) <> 1:
                self.var.path = string.joinfields(seprdir[:len(seprdir)-1], const.SLASH)
                onlydirname = seprdir[len(seprdir)-1]
                if len(onlydirname) == 0:
                    self.var.path = string.joinfields(seprdir[:len(seprdir)-2], const.SLASH)
                    onlydirname = seprdir[len(seprdir)-2]
            else:
                self.var.path = os.getcwd()
                onlydirname = directoryname
            
            #ulozim stavajici pracovni adresar
            curdir = os.getcwd()
            
            #zmena na misto, kde je pozadovany adresar
            os.chdir(self.var.path)

            if os.path.isdir(onlydirname):
                #ziskam seznam polozek
                allitems = service.GetFilesList(onlydirname)            

                #sekce pro ziskani vsech souboru v adresari vcetne podadresaru
                stop = False
                insidedir = list()
                items = list()
                #Prvni pruchod
                max = len(allitems)  
                
                i = 0
                while stop == False:
                    if i == max:
                        stop = True
                        break
                    if os.path.isdir(os.path.join(onlydirname,allitems[i])):                       
                        insidedir.append(os.path.join(onlydirname, allitems[i]))
                        del allitems[i]
                        i -= 1
                        max -= 1
                    else:
                        i += 1
                
                #presunout zbyvajici polozky (ciste soubory) do finalniho listu
                for j in allitems:
                    items.append(os.path.join(onlydirname,j))
                
                #vycistit prvni seznam
                del allitems[0:]
                
                #projit i podadresare a ziskat seznam souboru
                if len(insidedir) > 0:
                    stop = False
                    while len(insidedir) > 0:
                        allitems = service.GetFilesList(insidedir[0]) 
                        while len(allitems) > 0:
                            if os.path.isdir(os.path.join(insidedir[0],allitems[0])): 
                                insidedir.append(os.path.join(insidedir[0],allitems[0]))
                            elif os.path.isfile(os.path.join(insidedir[0],allitems[0])):
                                items.append(os.path.join(insidedir[0],allitems[0]))

                            del allitems[0]
                        del insidedir[0]
                
                os.chdir(self.var.path)
                self.var.path = None
                result = self.Compress(items, 0)
                os.chdir(curdir)
                return result
            
        return False
        
    def GetPath(self, filename):
        '''
        @return: String with path
        '''
        if type(filename) == type(str()):
            separname = string.splitfields(filename, const.SLASH)
            if len(separname) == 1:
                return self.var.default_path
            else:
                return string.joinfields(separname[:len(separname)-1], const.SLASH)
        else:
            return self.var.default_path
        
        
        
if __name__ == '__main__':
    mservice = ArchService()
    sys.exit()