#!/usr/bin/python
#-*- coding: UTF-8 -*-
'''
    Created on 12.05.2011
    @author:  e_mnadvo
    @summary: global exception for all services 
    @change:  
    @version: 1.0.1
    @contact: nadvornm@gmail.com
    @copyright: NO WARRANTY  BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
                FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. AFD � Studio 2010
'''

class CAppException(Exception):
    '''
    Class for special define exception for applications    
    '''
    def __init__(self):
        Exception.__init__(self)
        self.msg = None
        self.code = None
        self.function_name = None
        self.expr = None
        
    def set_raise_info(self, function_name, msg, code=700):
        self.function_name = function_name
        self.msg = msg
        self.code = code
        
    def get_raise_info(self):
        text = 'EXCEPTION: {0}|{1}|{2}'.format(self.function_name, self.code, self.msg)
        return text
        