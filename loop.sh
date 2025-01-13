#!/bin/bash

USERID=$(id -u)

LOGDIR="/var/log"
LOGNAME="$(echo $0 |awk -F. '{print $1}')"
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOGFILE="$LOGDIR/$LOGNAME-$TIMESTAMP.log"

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



echo "Script is started executing: $TIMESTAMP" &>>$LOGFILE

CHECKROOT


for i in $@
do
        dnf list installed $i &>>$LOGFILE
        if [ $? -ne 0 ]
        then
           dnf install $i -y &>>$LOGFILE
           VALIDATION $? "Installing $i"
        else
           echo -e "$i is already $G installed$N"
        fi
done
