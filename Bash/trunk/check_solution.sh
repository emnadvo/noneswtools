#!/bin/bash

for FILE in `find ./ -type f -regex '.*/Resul.*/.*cgns'`
do 
	  LOOKFORDIR=$(dirname $FILE); 
	  RESDIR=`find $LOOKFORDIR -type d -regex '.*data.results'`
	  if [[ -f $LOOKFORDIR && -d $RESDIR ]]; then 
			 printf "ITEM %s IS OK\n" "$LOOKFORDIR" 
	  else 
			 printf "CHECK THIS ITEM %s\n" "$LOOKFORDIR" 
	  fi
done

exit 0



for FILE in `find ./ -type f -regex '.*/Resul.*/.*cgns'`; do LOOKFORDIR=$(dirname $FILE); RESDIR=`find $LOOKFORDIR -type d -regex '.*data.results'`; if [ -z "$RESDIR" ]; then echo $LOOKFORDIR; fi done
