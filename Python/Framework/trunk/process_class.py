#!'C:\app\Python37\python.exe'
#-*- coding: UTF-8 -*-
'''
 Created on 06.01.2012 12:14:52
 
 @author: mnadvornik
 @summary:
 @change: 
 @version: 1.0.1
 @contact: mnadvornik@pwrw0366
 @copyright: 
	  Copyright (c) 06.01.2012 12:14:52, mnadvornik
	  All rights reserved.

	  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

			 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
			 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
			 * Neither the name of the <SKODA POWER> nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

	  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
'''
import ex
import sys

#check correct import
try:
    import service_method as srv
except ex.ImportError, ie:
    sys.stderr.write('Invalid import of module \"service_method\" in process_class.py module\n{0}'.format(ie))
    raise ex.SystemExit


class _Process_Info_(object):
    '''
    class for summary information about running process
    '''
    def __init__(self):
        object.__init__(self)        
        self.pid = None
        self.process_exe = None
        self.process_name = None
        self.stdout = None
        self.stderr = None
        self.except_info = None
        self.status = None
        self.args = None        
        self.mesh_dir = None        
        self.project_dir = None
        self.calc_dir = None
        self.bin_dir = srv.os.getcwd()
        self.logfile = None        
        
    
    def get_process_status(self):
        if self.status != 'ZOMBIE' and self.status is not None:
            self.check_process_status()

        return self.status
    
    def check_process_status(self):
        try:
            check_args = srv.os.path.join(self.bin_dir, appconst.CHECK_PROCESS_CMD.format(self.pid, self.logfile))
            result = srv.execute_process3(check_args)
            if result[0] == True and isinstance(result[1], list) is True:
                for item in result[1]:
                    value = srv.string.lower(item)
                    if srv.string.find(value, 'run') != -1:
                        self.status = 'RUN'
                    elif srv.string.find(value, 'sleep') != -1:
                        self.status = 'SLEEP'
                    elif srv.string.find(value, 'zombie') != -1:
                        self.status = 'ZOMBIE'
                    else:
                        self.status = 'UNKNOWN'
            else:
                raise srv.ex.UserWarning
        except:
            self.except_info += 'FAILED WHEN CHECK PROCESS STATUS!'
            self.status = 'UNKNOWN'
            
    def run(self, cwd_dir):
        if self.args is not None and srv.isDir(cwd_dir):
            try:
                self.process_exe = srv.proc.Popen(self.args, stdout=srv.proc.PIPE, stderr=srv.proc.PIPE, shell=True, cwd=cwd_dir)                
            except OSError, e:
                self.except_info = "{0}".format(e)
                self.process_exe = None
        
        if isinstance(self.process_exe, srv.proc.Popen):
            self.pid = self.process_exe.pid
            self.status = 'RUN'

    def get_output(self):
        if isinstance(self.process_exe, srv.proc.Popen) and (self.get_process_status() == 'ZOMBIE' or self.get_process_status() == 'UNKNOWN'):
            output = self.process_exe.communicate()
            self.stdout = output[0]
            self.stderr = output[1]
            self.status = "SOLVED"
            return True
        else:
            return False
        
    def get_report(self):
        report = ''
        if self.stdout is not None:
            report += self.stdout
        if self.stderr is not None:
            report += self.stderr
        if self.except_info is not None:
            report += self.except_info
            
        return report