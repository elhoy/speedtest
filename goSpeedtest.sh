#! /bin/sh
## Quick script to run Ookla CLI speedtest repeatedly
## (see https://www.speedtest.net/apps/cli)
## elhoy :oD, Dec 2021
##
clear
while date -Iminutes; ./speedtest --ca-certificate=cacert.pem; printf "waiting...\n\n"; sleep 120 ; do :; done

