#!/bin/bash
declare HTTPADDRESS=

if [ -z "$@" ]
 then
	  msg="NEED INPUT PARAMETER WHICH IS WEB SITE ADDRESS."
	  echo $msg
	  read HTTPADDRESS
else
	  HTTPADDRESS="${1:-""}"
fi

if [ -n "$HTTPADDRESS" ]; then
	  wget -rl 3 -k $HTTPADDRESS
fi

echo "SCRIPT FINISHED"
exit 0

#--proxy-user "\""$USER"\"" --proxy-passwd "\""$PASSWRD"\""
