#!/bin/awk -f
# 
BEGIN	{ MODEFILEBLOCK = 0;
		  MODEFILEREGEX = "FUNCTION: mode1";
	     MODEFILEINSERT = IN_MODEFILE;
		  NODALDIAMETERCALC = IN_NDIAM;
		  FREQUENCY = IN_FREQ;
	     NEWRESFILENAME = IN_NEWRESFILE;
	     TIMESTEPS = 100;
	     COMPTIMESTEPS = 0.0;

	     if(NODALDIAMETERCALC == 0.0) {
					NODALDIAMETERCALC = 1;
	     }

	     while(TIMESTEPS%NODALDIAMETERCALC != 0) {
					TIMESTEPS++;
	     }

 }

{
	  if ( match($0,MODEFILEREGEX) ) {
			 MODEFILEBLOCK = 1;
			 print $0;
	  }
	  else if(MODEFILEBLOCK == 1 && $0 ~ /File Name/ ) {
			 printf("File Name = %s\n",MODEFILEINSERT);
			 MODEFILEBLOCK = 0; }
	  else if($0 ~ /Phase Angle Multiplier =/) {
			 printf("Phase Angle Multiplier = %d \n",IN_NDIAM); }
	  else if($0 ~ /Computed Timestep/) {
			 printf("Computed Timestep = %e [s]\n",1/FREQUENCY/TIMESTEPS); }
	  else if($0 ~ /Number of Timesteps per Period =/) {
			 printf("Number of Timesteps per Period = %d\n", TIMESTEPS); }
	  else if($0 ~ /Solver Input File =/) {
			 printf("Solver Input File = %s\n", NEWRESFILENAME); }
	  else {
			 print $0;
	  }
}

END { }
