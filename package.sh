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



echo "Script is started executing: $TIMESTAMP" >>$LOGFILE

CHECKROOT

dnf list installed mysql-server &>>$LOGFILE
if [ $? -ne 0 ]
then
    dnf install nodejs -y &>>$LOGFILE
    VALIDATION $? "Installing nodejs"
    systemctl enable mysqld &>>$LOGFILE
    systemctl start mysqld  &>>$LOGFILE
    if [$? -ne 0]
       echo "Service is not started ..$R failure$N" &>>$LOGFILE
       exit 1
    then 
       mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
else
    echo -e "Package is already $Y installed$N"
fi
