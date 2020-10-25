#!/bin/awk -f
# 
BEGIN { 
			 MIN = 100000000; 
			 MAX = -100000000; 
			 RWCOUNT = 0;
}
{ 	
	  if ($0 ~ /-------/) { 
			 RWCOUNT = 0;
	  }
	  if ($1 ~ /[[:digit:]]/ && $2 ~ /[[:digit:]]/ && $3 ~ /[[:digit:]]/ && $4 ~ /[[:digit:]]/) { 	
			 RWCOUNT++; 
			 MIN = ( MIN < $2 ? MIN : $2 ); 
			 MAX = ( MAX > $2 ? MAX : $2 );
			 if(RWCOUNT != 2) { 
					print $2, $3, $4;
			 }
	  }
}
END{ 
	  print "\n\n","\"MinX =",MIN,"\n\"MaxX = ",MAX;
}
