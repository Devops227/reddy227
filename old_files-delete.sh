#!/bin/bash

USERID=$(id -u)

SOURCE_DIR="/root/reddy227"

LOGDIR="/var/log"
LOGNAME="$(echo $0 |awk -F. '{print $1}')"
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOGFILE="$LOGDIR/$LOGNAME-$TIMESTAMP-deleting.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

CHECKROOT (){
        if [ $USERID -ne 0 ]
        then
           echo "ERROR:: You must have sudo access to execute this script"
           exit 1 # other than 0
        fi
}

VALIDATION () {
    if [ $1 -ne 0 ]
    then
       echo -e "$1 ...$R Failure$N"
       exit 1
    else
       echo -e "$2 ... $G Success$N"
    fi
}

echo "Script is started executing: $TIMESTAMP" >>$LOGFILE

F2D=$(find $SOURCE_DIR -name "*.log" -mtime +1)
echo  "files to be deleted: $F2D"
while read -r file
do
 echo  "deleting files: $file"
 rm -rf $file

done <<< $F2D
