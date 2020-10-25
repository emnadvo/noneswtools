#!/bin/awk -f
# 
BEGIN	{ AXIALMOVE=1939.28; 
}
{ 
	 if ($1 ~ /[[:digit:]]/ && $2 ~ /[[:digit:]]/ && $3 ~ /[[:digit:]]/) {
			print $1,$2,$3+AXIALMOVE;
	 }
	 else{
			print $0;
	 }
}
