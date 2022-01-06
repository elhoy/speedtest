#! /bin/sh
## Quick script to record ping times on fixed intervals
## elhoy :oD, Jan 2022
##
##CHANGELOG
## 20220104 Script created just for pings, adapted from goSpeedtestLogged script.

clear

## SET VALUES
NOWTIME=$(date -Iminutes)
PINGTARGET=9.9.9.9 #IP or URL
TIMESTEP=1  #seconds
GOODPING=50  #ms

## ------------

## OPEN NEW LOGFILE
if [ ! -z $1 ]
then
  LOGFILE=$1
else
  LOGFILE="pinglog_$NOWTIME.txt"
fi

touch $LOGFILE
echo "Starting Ping test... (logfile " $LOGFILE ")"
echo "Starting Ping test, " $NOWTIME > $LOGFILE


## GO LOGGING!
  NOWTIME=$(date -Iminutes)  
  echo $NOWTIME
  echo

  #Do tests
  echo "Ongoing Ping Test..."
  ping -i $TIMESTEP $PINGTARGET | tee -i $LOGFILE


# Extract summary at close of test
RUNTIME=$(tail -n 3 $LOGFILE | grep "time" | cut -d "," -f 4 | cut -d " " -f 2)
LOSS=$(tail -n 3 $LOGFILE | grep "loss" | cut -d "," -f 3 | cut -d "%" -f 1)
RTTAVG=$(tail -n 3 $LOGFILE | grep "rtt" | cut -d "/" -f 5)
RTTMAX=$(tail -n 3 $LOGFILE | grep "rtt" | cut -d "/" -f 6)
RTTDIFF=$(tail -n 3 $LOGFILE | grep "rtt" | cut -d "/" -f 7 | cut -d " " -f 1)

echo "------------"
echo "Test ran for "$RUNTIME
echo $LOSS "% loss" | tee $LOGFILE
echo $RTTAVG " average ping" | tee $LOGFILE
echo $RTTMAX " max ping" | tee $LOGFILE
echo $RTTDIFF " ping variation" | tee $LOGFILE


