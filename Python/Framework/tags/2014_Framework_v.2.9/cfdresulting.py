#!/usr/bin/python
#-*- coding: UTF-8 -*-

'''
 Created on 26.09.2011 14:17:14
 
 @author: mnadvornik
 @summary:
 @change: 
 @version: 1.0.1
 @contact: mnadvornik@pwrw0366
 @copyright: 
	  Copyright (c) 26.09.2011 14:17:14, mnadvornik
	  All rights reserved.

	  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

			 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
			 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
			 * Neither the name of the SKODA POWER nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

	  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
'''



try:
	import service_methods as srv
except ImportError:
	print "IMPORT ERROR WHEN IMPORT MODULE SERVICE METHOD!"
	raise 

X_COLUMN = 0
Y_COLUMN = 1
Z_COLUMN = 2
VARIABLE_SCALAR_COLUMN = 3

VARIABLE_VECTOR_XCOORD = 3
VARIABLE_VECTOR_YCOORD = 4
VARIABLE_VECTOR_ZCOORD = 5

ZERO_VAL = 0.0

class _cfdresulting_property(object):	
	'''
	Class for capsulate property of master class.
	'''
	def __init__(self):
		object.__init__(self)
		self.SECTION_INLET = 'INPUT'
		self.SECTION_OUTLET = 'OUTPUT'
		self.SECTION_BLADE = 'BLADE'
		self.FRMT_BLADE_FILE = '%8.8f\t%8.8f\t%8.8f\t%8.8f\t%8.8f\t%8.8f\t%8.8f\t%8.8f\t%8.8f'
		self.SURFACE_BLADE_HEADER = 'x[mm]\ty[mm]\tMaiz[1]\tPs[Pa]\tCp[1]\tTstat[K]\tY+[1]\tTau_w[Pa]\tU*[1]'

		 
 
class cfdresulting(object):
	'''
	Class for result processing.
	'''
 
	def __init__(self):
		'''
		Constructor
		'''
		object.__init__(self)
		self.var = _cfdresulting_property()

	
	def prepare_input_data(self, inputs):
		'''
		Method for preparing inputs data that return type is always list
		'''
		items = list()
		
		if isinstance(inputs, float):
			items.append(inputs)
		elif isinstance(inputs, str) and srv.isnumber(inputs):
			items.append(float(inputs))
		elif isinstance(inputs, list):
			if isinstance(inputs[0], tuple):
				for it in inputs:
					items.append(it[len(it)-1])
			else:
				 items = inputs
		else:
			print type(inputs)			
			
		return items
	

	def calc_izoMach_from_press(self, kappa, static_press_items):
		'''
		Method for calculate izoentropic Mach number from presses
		'''
		result = list()
		items = self.prepare_input_data(static_press_items)
		
		if len(items) > 0:
			reference_press = max(items)
			for val in items:
				Mach_num = (2/(kappa - 1))*(srv.math.pow((reference_press/val),((kappa - 1) / kappa)) - 1)
				if Mach_num >= 0.0:
					Mach_num = srv.math.sqrt(Mach_num)
					result.append(Mach_num)
				else:
					continue
		
		if len(result) == 1:
			return result[0]
		else:
			return result
	

	def calc_losses_from_temperature(self, kappa, abs_temp_ref, static_temp_items, abs_press_ref, static_press_items):
		'''
		Method for calculate loss coeficient from presses and temperatures
		'''		
		result = list()
		
		if abs_press_ref == 0.0 or abs_temp_ref == 0.0:
			srv.ShowStderr("ABS TEMPERATURE (%f) IS ZERO OR ABS PRESS (%f) IS ZERO!\NDIVIDE BY ZERO IS NOT PERMISSION." % (abs_temp_ref, abs_press_ref))
			raise ZeroDivisionError
		
		static_press = self.prepare_input_data(static_press_items)
		static_temp = self.prepare_input_data(static_temp_items)
		
		if len(static_press) > 0 and len(static_temp) > 0:
			val_idx = 0
			while val_idx < len(static_press) and val_idx < len(static_temp):
				static_press_i = static_press[val_idx]
				static_temp_i = static_temp[val_idx]
				press_param = pow((static_press_i / abs_press_ref), ((kappa - 1) / kappa))
				dzeta_val = (static_temp_i - (abs_temp_ref * press_param)) / (abs_temp_ref * (1 - press_param))
				result.append(dzeta_val)
				val_idx += 1
		
		if len(result) == 1:
			return result[0]
		else:
			return result
	
	def calc_angle(self, velocity_compA, velocity_compB, section=None):
		'''
		Method for calculate angle from velocity components by the section type
		'''
		result = list()
		vel_A = self.prepare_input_data(velocity_compA)
		vel_B = self.prepare_input_data(velocity_compB)
		non_calc = False
		
		val_idx = 0
		while val_idx < len(vel_A) and val_idx < len(vel_B):
			if vel_B[val_idx] == 0.0:
				if srv.string.upper(section) == self.var.SECTION_BLADE:
				    result.append(0)
				    non_calc = True
				else:
					srv.ShowStderr("COMPONENT OF SPEED B (%f) IS ZERO!\NDIVIDE BY ZERO IS NOT PERMISSION." % (vel_B[val_idx]))
					raise ZeroDivisionError
			
			if non_calc is False:		
				if srv.string.upper(section) == self.var.SECTION_INLET:
					result.append(srv.math.asin(vel_A[val_idx] / vel_B[val_idx]) * (180 / srv.math.pi))
				else:
					result.append(srv.math.atan(vel_A[val_idx] / vel_B[val_idx]) * (180 / srv.math.pi))
			else:
				non_calc = False
				
			val_idx += 1
			
		if len(result) == 1:
			return result[0]
		else:
			return result

	

	def calc_skoda_angle(self, velocity_A, velocity_B, section=None):
		'''
		Method for calculate angle from velocity components by the section type
		'''
		result = list()
		angle = self.calc_angle(velocity_A, velocity_B, section)
		
		if isinstance(angle, list):
			for it in angle:
				if srv.string.upper(section) == self.var.SECTION_INLET or srv.string.upper(section) == self.var.SECTION_BLADE:
					result.append(90 + it)
				elif srv.string.upper(section) == self.var.SECTION_OUTLET:
					result.append(abs(it))
		else:
			if srv.string.upper(section) == self.var.SECTION_INLET or srv.string.upper(section) == self.var.SECTION_BLADE:
				result = 90 + angle
			elif srv.string.upper(section) == self.var.SECTION_OUTLET:
				result = abs(angle)
			else:
				result = angle
			
		return result
	
	
	def calc_losses_from_pressY(self, total_press_ref, total_press_items, static_press_items):
		'''
		Method for calculation loss coeficient from press
		'''
		result = list()
		
		abs_press = self.prepare_input_data(total_press_items)
		static_press = self.prepare_input_data(static_press_items)
		val_idx = 0
		
		while val_idx < len(abs_press) and val_idx < len(static_press):
			press_diffr = (abs_press[val_idx] - static_press[val_idx])
			if press_diffr != 0:
				ypress = (total_press_ref - abs_press[val_idx]) / press_diffr
				result.append(ypress)
			else:
				result.append(0.0)
				srv.ShowStderr("DIFFERENCE OF ABS AND STATIC PRESSES (%f) IS ZERO!\nDIVIDE BY ZERO IS NOT PERMISSION." % (press_diffr))				
			val_idx += 1
		
		if len(result) == 1:
			return result[0]
		else:
			return result

	
	def calc_abs_velocity_2D(self, component_x, component_y):
		'''
		Method for calculation loss coeficient from press
		'''
		result = list()
		comp_x = self.prepare_input_data(component_x)
		comp_y = self.prepare_input_data(component_y)
		val_idx = 0
		
		while val_idx < len(comp_x) and val_idx < len(comp_y):
			resval = srv.math.sqrt((srv.math.pow(comp_x[val_idx], 2) + srv.math.pow(comp_y[val_idx], 2)))
			result.append(resval)
			val_idx += 1
		
		if len(result) == 1:
			return result[0]
		else:
			return result

	
	def calc_Cp_coeficient(self, total_press_ref, static_press_ref, static_press_blade):
		'''
		Method for calculate coeficient Cp from static press on blade
		'''
		result = list()
		blade_press =  self.prepare_input_data(static_press_blade)
		delta_press_inlet = (total_press_ref - static_press_ref)
		
		if delta_press_inlet == 0.0:
			srv.ShowStderr("DIFFERENCE OF STATIC AND ABS PRESS ON INLET (%f) IS ZERO!\NDIVIDE BY ZERO IS NOT PERMISSION." % (delta_press_inlet))
			raise ZeroDivisionError
		
		reference_static_press = max(blade_press)
		
		for bld_press in blade_press:
			yloss_blade = (bld_press - reference_static_press)/delta_press_inlet
			result.append(yloss_blade)
			
		if len(result) == 1:
			return result[0]
		else:
			return result


	def get_volume_from_density(self, density):
		'''
		Method transform density to volume	
		'''
		vol = self.prepare_input_data(density)
		result = list()
		
		for num in vol:
			res_val = 1/num
			result.append(res_val)
		
		if len(result) == 1:
			return result[0]
		else:
			return result	
	
	
	def calc_Re_number2D(self, velcomponent_x, velcomponet_y, density, character_length, dynamic_viscosity):
		'''
		Method calculate Reynold number from velocity component, characteric length and dynamic viscosity
		'''
		magn_vel = self.calc_abs_velocity_2D(velcomponent_x, velcomponet_y)
		magn_vel = self.prepare_input_data(magn_vel)
		dens = self.prepare_input_data(density)
		length = character_length
		dynVisc = dynamic_viscosity
		result = list()
		
		if isinstance(dynVisc, float) is not True and isinstance(length, float) is not True:
			srv.ShowStderr("Dynamic viscosity and characteric length have to be numbers!")
			raise ValueError
		elif len(dens) != len(magn_vel):
			srv.ShowStderr("Velocity and density have to same length!")
			raise ValueError
		
		ln_idx = 0
		if dynVisc == 0:
			srv.ShowStderr("Dynamic viscosity have to value zero!")
			raise ValueError
		
		while ln_idx < len(dens) and ln_idx < len(magn_vel): 
			Rey = (magn_vel[ln_idx]*length*dens[ln_idx])/(dynVisc)
			result.append(Rey)
			ln_idx+=1
			
		if len(result) == 1:
			return result[0]
		else:
			return result
		
	
	def get_values_from_2Dsufacefile(self, filename, sort_indx=None, reverse=False):
		'''
		Method return all numerical values from dat file.
		'''
		if srv.os.path.isfile(filename) is not True:
			return list()
		retVals = list()
		
		try:
			datafile = open(filename, 'r')
			alldata = datafile.readlines()
			if len(alldata) > 0:
				for item in alldata:
					is_only_numbers = True
					test_nums = srv.string.split(item)
					for word in test_nums:
						if srv.is_number(word) is not True:
							is_only_numbers = False
							break
					
					if is_only_numbers == True:
						line_data = srv.string.splitfields(item)
						max_item = len(line_data)
						if len(line_data) == 4 and float(line_data[X_COLUMN]) == ZERO_VAL: #scalar variable
							value = (float(line_data[X_COLUMN]), float(line_data[Y_COLUMN]), float(line_data[Z_COLUMN]), float(line_data[VARIABLE_SCALAR_COLUMN]))
							retVals.append(value)
						elif len(line_data) == 6 and float(line_data[X_COLUMN]) == ZERO_VAL: #vector components variable
							value = (float(line_data[X_COLUMN]), float(line_data[Y_COLUMN]), float(line_data[Z_COLUMN]), float(line_data[VARIABLE_VECTOR_XCOORD]), \
									 float(line_data[VARIABLE_VECTOR_YCOORD]), float(line_data[VARIABLE_VECTOR_ZCOORD]))
							retVals.append(value)
		except:
			srv.ShowStderr('Failed when open field quantity data file.\n')
			raise
		
		if sort_indx is not None:
			retVals.sort(key=lambda tpl: tpl[sort_indx], reverse=reverse)
			
		if len(retVals) == 1:
			return retVals[0]
		else:
			return retVals
	
	
	def save_list_to_file(self, filename, content):
		'''
		@note: Service write content to file  
		'''
		try:
			if len(filename) > 3:
				file = open(filename, 'w')
				if file and len(content) <> 0:
					for str in content:
						if srv.re.search(srv.const.NEWLINE, str) is None:
							str += srv.const.NEWLINE
						
						file.write(str)
				file.close()
			else:
				srv.ShowStderr("FILENAME WAS SHORT! IT HAVE TO MORE THEN 3 CHARACTERS." % (filename))
		except:
			srv.ShowStderr("FILE %s CORRUPTED!" % (filename))	


	def create_surface_resultfile(self, filename, header, static_press_items, mach_numbers, Cp_items, StaticTemp_items, YPlus_items, visc_stress_bld=None, fricU=None):
		'''
		Method for save surface blade values to dat file.
		'''						
		if len(mach_numbers) != len(Cp_items) or len(mach_numbers) != len(static_press_items):
			srv.ShowStderr("ITEMS OF INPUTS LIST IS NOT EQUAL! RAISE VALUE ERROR!")
			raise ValueError
		elif len(filename) < 3:
			srv.ShowStderr("FILENAME WAS SHORT! IT HAVE TO MORE THEN 3 CHARACTERS." % (filename))
			raise NameError
		
		output = list()
		if isinstance(header, list):
			for line in header:
				output.append(line)
		
		output.append(self.var.SURFACE_BLADE_HEADER)
		
		line_idx = 0
		while line_idx < len(static_press_items) and line_idx < len(mach_numbers) and line_idx < len(Cp_items):
			#	X	Y	Maiz	Ps	Tstat Y
			strval = self.var.FRMT_BLADE_FILE%(	static_press_items[line_idx][Z_COLUMN]*srv.const.M_TO_MM, static_press_items[line_idx][Y_COLUMN]*srv.const.M_TO_MM,\
												mach_numbers[line_idx],\
												static_press_items[line_idx][VARIABLE_SCALAR_COLUMN],\
												Cp_items[line_idx],\
												StaticTemp_items[line_idx][VARIABLE_SCALAR_COLUMN],\
												YPlus_items[line_idx][VARIABLE_SCALAR_COLUMN], \
												visc_stress_bld[line_idx], \
												fricU[line_idx] )
			output.append(strval)
			line_idx += 1
			
		self.save_list_to_file(filename, output)


	def calc_abs_value_of3DVector(self, vector_items):
		'''
		Method for calculate length of vector from components
		'''
		if isinstance(vector_items, list) is not True:
			vectors = self.prepare_input_data(vector_items)
		else:
			vectors = vector_items
		
		retVals = list()
		for item in vectors:
			value = srv.math.sqrt( (srv.math.pow(item[VARIABLE_VECTOR_XCOORD], 2) + srv.math.pow(item[VARIABLE_VECTOR_YCOORD], 2) + srv.math.pow(item[VARIABLE_VECTOR_ZCOORD], 2)) )
			retVals.append(value)
			
		if len(retVals) == 1:
			return retVals[0]
		else:
			return retVals
	
	def calc_abs_value_ofFrictStrenght(self, vector_items):
		'''
		Method for calculate length of vector from components
		'''
		if isinstance(vector_items, list) is not True:
			vectors = self.prepare_input_data(vector_items)
		else:
			vectors = vector_items
		
		retVals = list()
		for item in vectors:
			value = srv.math.sqrt( (srv.math.pow(item[VARIABLE_VECTOR_ZCOORD], 2) + srv.math.pow(item[VARIABLE_VECTOR_YCOORD], 2)) )
			retVals.append(value)
			
		if len(retVals) == 1:
			return retVals[0]
		else:
			return retVals
		

	def calc_fricU(self, viscous_stress, density):
		'''
		Method for calculate length of vector from components
		'''
		if isinstance(density, list) is not True:
			density = self.prepare_input_data(density)		
			
		visStress = self.prepare_input_data(viscous_stress)
		
		idx = 0
		retVals = list()
		if len(density) == len(visStress):
			while idx < len(density) and idx < len(visStress):
				if density[idx][VARIABLE_SCALAR_COLUMN] != 0:
					value = srv.math.sqrt( (visStress[idx]/density[idx][VARIABLE_SCALAR_COLUMN]) )
				else:
					value = -777
								
				retVals.append(value)
				idx += 1
				
			 
		if len(retVals) == 1:
			return retVals[0]
		else:
			return retVals
		
	
	def calc_dynamic_press(self, density, speed):
		'''
		Method for dynamic press calculation from absolute press and static press	
		'''	
		if isinstance(density, list) is not True:
			density = self.prepare_input_data(density)
			
		if isinstance(speed, list) is not True:
			density = self.prepare_input_data(speed)
			
		idx=0
		retVals = list()
		if len(density) == len(speed):
			while idx < len(density) and idx < len(speed):
				value=0.5*density[idx]*srv.math.pow(speed[idx], 2)
				retVals.append(value)				
				idx += 1

		if len(retVals) == 1:
			return retVals[0]
		else:
			return retVals
		

	def calc_dynamic_press_fromAbs(self, absolute_press, static_press):
		'''
		Method for dynamic press calculation from absolute press and static press	
		'''				
		absolute_press = self.prepare_input_data(absolute_press)
		static_press = self.prepare_input_data(static_press)
			
		idx=0
		retVals = list()
		if len(absolute_press) == len(static_press):
			while idx < len(absolute_press) and idx < len(static_press):
				value = absolute_press[idx] - static_press[idx]
				retVals.append(value)		
				idx += 1

		if len(retVals) == 1:
			return retVals[0]
		else:
			return retVals
	
	def calc_isoentropic_velocity(self, ref_total_temperature, ref_total_pressure, pressure, kappa, rconst):
		'''
		Method for calculation izoentropic velocity from pressure and temperature by Saint-Venant-Wantzel equation
		'''
		
		static_press = self.prepare_input_data(pressure)
		
		idx=0
		retVals = list()
		while idx < len(static_press):
			value = srv.math.sqrt(abs(2*kappa*rconst*ref_total_temperature*(1-srv.math.pow(static_press[idx]/ref_total_pressure,(kappa-1)/kappa))/(kappa-1)))
			retVals.append(value)
			idx += 1
		
		if len(retVals) == 1:
			return retVals[0]
		else:
			return retVals
		
	def calc_kineticenergy_loss(self, isoentr_velocity, velocity):
		'''
		Method for calculation kinetic energy loss
		'''
		
		velocity_iso = self.prepare_input_data(isoentr_velocity)
		velocity = self.prepare_input_data(velocity)
		
		idx=0
		retVals = list()
		if len(velocity_iso) == len(velocity):
			while idx < len(velocity_iso) and idx < len(velocity):
				value = 1 - srv.math.pow(velocity[idx]/velocity_iso[idx],2)
				retVals.append(value)
				idx += 1

		if len(retVals) == 1:
			return retVals[0]
		else:
			return retVals	
		
		
	def get_values_from_plotfile(self, filename, sort_indx=None, reverse=False):
		'''
		Method return all numerical values from dat file.
		'''
		if srv.os.path.isfile(filename) is not True:
			return list()
		retVals = list()
		
		try:
			datafile = open(filename, 'r')
			alldata = datafile.readlines()
			if len(alldata) > 0:
				for item in alldata:
					is_only_numbers = True
					test_nums = srv.string.split(item)
					for word in test_nums:
						if srv.is_number(word) is not True:
							is_only_numbers = False
							break
					
					if is_only_numbers == True:
						line_data = srv.string.splitfields(item)
						max_item = len(line_data)
						if len(line_data) == 4: #scalar variable
							value = (float(line_data[X_COLUMN]), float(line_data[Y_COLUMN]), float(line_data[Z_COLUMN]), float(line_data[VARIABLE_SCALAR_COLUMN]))
							retVals.append(value)
						elif len(line_data) == 6: #vector components variable
							value = (float(line_data[X_COLUMN]), float(line_data[Y_COLUMN]), float(line_data[Z_COLUMN]), float(line_data[VARIABLE_VECTOR_XCOORD]), \
									 float(line_data[VARIABLE_VECTOR_YCOORD]), float(line_data[VARIABLE_VECTOR_ZCOORD]))
							retVals.append(value)
		except:
			srv.ShowStderr('Failed when open field quantity data file.\n')
			raise
		
		if sort_indx is not None:
			retVals.sort(key=lambda tpl: tpl[sort_indx], reverse=reverse)
			
		if len(retVals) == 1:
			return retVals[0]
		else:
			return retVals

#=======================================================================================
if __name__ == '__main__':
	if srv.sys.version_info < (2, 5): 
		raise "YOU MUST USE PYTHON 2.6 OR GREATER!"
	
	prg = cfdresulting()

	print "program ended."

	
	
	
	
