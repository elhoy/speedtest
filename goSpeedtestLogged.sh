#! /bin/sh
## Homebrew version of Ooklas CLI speedtest, to add CSV logging.
## elhoy :oD, Dec 2021
##

##CHANGELOG
## 20211223 first upload to github
## 20211221 conversion of speed via case to bits per sec
## 20211216 first script

clear

NOWTIME=$(date -Iminutes)
TESTURL="http://ipv4.download.thinkbroadband.com/5MB.zip"
WAITTIME=60

if [ ! -z $1 ]
then
  LOGFILE=$1
else
  LOGFILE="speedtestlogfile_$NOWTIME.txt"
fi

touch $LOGFILE
echo "Starting speedtest logfile, " $LOGFILE
echo "Time,DL Speed,Unit,Packet Loss,Ping (ms)" > $LOGFILE

while 
  NOWTIME=$(date -Iminutes)  
  echo $NOWTIME
  echo
## all-in-one easy test from Ookla
##  ./speedtest --ca-certificate=cacert.pem
##  wget -O /dev/null -q --show-progress http://ipv4.download.thinkbroadband.com/20MB.zip | cut -d " " -f 4

  echo "Download test..."
  echo $TESTURL
  #note report-speed=bits shows bps rather than Bytes per sec
  DLRESULT=$(wget --report-speed=bits -o- --delete-after http://ipv4.download.thinkbroadband.com/5MB.zip | grep saved | cut -d " " -f 3,4)
  SPEEDVAL=$(echo $DLRESULT | cut -d "(" -f 2  | cut -d " " -f 1)
  SPEEDUNIT=$(echo $DLRESULT | cut -d " " -f 2 | cut -d ")" -f 1)
  echo $SPEEDVAL $SPEEDUNIT
  
  echo "Ping Test..."
  PINGRESULT=$(ping -c 3 ox.ac.uk | grep -A 2 stat)
  LOSS=$(echo $PINGRESULT | cut -d "," -f 3 | cut -d "%" -f 1)
  RTT=$(echo $PINGRESULT | cut -d "=" -f 2 | cut -d "/" -f 2)
  echo $RTT

  #Display to screen
  echo $NOWTIME","$SPEEDVAL $SPEEDUNIT","$LOSS"% loss,"$RTT"ms."
  #CSV to file, with speed in plottable units
  case "$SPEEDUNIT" in
    *G* ) echo "gig"; SPEEDVALLOG=$(echo "$SPEEDVAL*10^9" | bc);;
    *M* ) echo "mega";SPEEDVALLOG=$(echo "$SPEEDVAL*10^6" | bc);;
    *K* ) echo "kilo";SPEEDVALLOG=$(echo "$SPEEDVAL*10^3" | bc);;
    * ) echo "bits";SPEEDVALLOG=$SPEEDVAL;;
  esac
  echo $NOWTIME","$SPEEDVALLOG","$SPEEDUNIT","$LOSS","$RTT >> $LOGFILE

  
  printf "waiting...\n\n"
  sleep $WAITTIME
  do :
  done
  
  see $LOGFILE

