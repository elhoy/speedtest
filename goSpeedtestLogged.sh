#! /bin/sh
## Homebrew version of Ooklas CLI speedtest, to add CSV logging.
## (all-in-one easy test from Ookla call would be ./speedtest --ca-certificate=cacert.pem)
## elhoy :oD, Dec 2021
##

##CHANGELOG
## 20220105 corrected hard coded DL URL for variable name; switched 5MB test file for 25MB (longer average)
## 20211230 added quick good/bad result field based on ADSL 4.2Mb DL min OR latency >50ms; removed Ookla call; added more comments
## 20211223 first upload to github
## 20211221 conversion of speed via case to bits per sec
## 20211216 first script

clear

## SET VALUES
NOWTIME=$(date -Iminutes)
TESTURL="http://ipv4.download.thinkbroadband.com/25MB.zip"
WAITTIME=60  #seconds
GOODPING=50  #ms
GOODSPEED=4200000  #bps

## ------------

## OPEN NEW LOGFILE
if [ ! -z $1 ]
then
  LOGFILE=$1
else
  LOGFILE="speedtestlogfile_$NOWTIME.txt"
fi

touch $LOGFILE
echo "Starting speedtest logfile, " $LOGFILE
echo "Time,DL Speed,Unit,Packet Loss,Ping (ms),Speed Result (>"$GOODSPEED"),PingResult (<"$GOODPING")" > $LOGFILE


## GO LOGGING!
while 
  NOWTIME=$(date -Iminutes)  
  echo $NOWTIME
  echo

  #Do tests
  echo "Download test..."
  echo $TESTURL
  #note report-speed=bits shows bps rather than Bytes per sec
  DLRESULT=$(wget --report-speed=bits -o- --delete-after $TESTURL | grep saved | cut -d " " -f 3,4)
  SPEEDVAL=$(echo $DLRESULT | cut -d "(" -f 2  | cut -d " " -f 1)
  SPEEDUNIT=$(echo $DLRESULT | cut -d " " -f 2 | cut -d ")" -f 1)
  echo $SPEEDVAL $SPEEDUNIT
  
  echo "Ping Test..."
  PINGRESULT=$(ping -c 3 ox.ac.uk | grep -A 2 stat)
  LOSS=$(echo $PINGRESULT | cut -d "," -f 3 | cut -d "%" -f 1)
  RTT=$(echo $PINGRESULT | cut -d "=" -f 2 | cut -d "/" -f 2)
  echo $RTT


  #Convert speed val to comparable base units, with console output
    case "$SPEEDUNIT" in
    *G* ) echo "gig"; SPEEDVALLOG=$(echo "$SPEEDVAL*10^9" | bc);;
    *M* ) echo "mega";SPEEDVALLOG=$(echo "$SPEEDVAL*10^6" | bc);;
    *K* ) echo "kilo";SPEEDVALLOG=$(echo "$SPEEDVAL*10^3" | bc);;
    * ) echo "bits";SPEEDVALLOG=$SPEEDVAL;;
  esac
  
  #Compare speed
  SPEEDTEXT="Bad Speed"
  if [ $(echo "$SPEEDVALLOG > $GOODSPEED" | bc -l) -gt 0 ]
  then
	SPEEDTEXT="Good Speed"
  fi
  #Compare ping
  PINGTEXT="Bad Latency"
  echo $(echo "$RTT < $GOODPING" | bc -l)
  if [ $(echo "$RTT < $GOODPING" | bc -l) -gt 0 ]
  then
    PINGTEXT="Good Latency"
  fi
  

  #Display to screen
  echo $NOWTIME","$SPEEDVAL $SPEEDUNIT","$LOSS"% loss,"$RTT"ms."
  echo "Result Summary = "$SPEEDTEXT"; "$PINGTEXT"."
  
  #CSV to file, with speed in plottable units
  echo $NOWTIME","$SPEEDVALLOG","$SPEEDUNIT","$LOSS","$RTT","$SPEEDTEXT","$PINGTEXT >> $LOGFILE

  
  printf "waiting...\n\n"
  sleep $WAITTIME
  do :
  done
  
  see $LOGFILE

