#!/bin/bash

USERID=$(id -u)

LOGDIR="/var/log"
LOGNAME="$(echo $0 |awk -F. '{print $1}')"
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOGFILE="$LOGDIR/$LOGNAME-$TIMESTAMP-pkg.log"

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

#dnf list installed mysql-server &>>$LOGFILE
#if [ $? -ne 0 ]
#then
    dnf install mysql-server -y &>>$LOGFILE
    VALIDATION $? "Installing mysql service"
    systemctl enable mysqld &>>$LOGFILE
    VALIDATION $? "Enabling mysql service"
    systemctl start mysqld  &>>$LOGFILE
    VALIDATION $? "Starting mysql service service"
    
    mysql -h 54.174.92.98 -u root -pExpenseApp@1 -e 'show databases;'  
    
    if [ $? -ne 0 ]
    then
       echo -e " $Y root password is not setup$N" >>$LOGFILE
       mysql_secure_installation --set-root-passExpenseApp@1  
       VALIDATION $? "setting up root password"
    else
       echo -e " $Y root password is alredy setup$N"
    fi   
#else 
#   echo -e " $Y mysql service already installed$N"
#fi