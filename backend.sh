#!/bin/bash

USERID=$(id -u)

LOGDIR="/var/log"
LOGNAME="$(echo $0 |awk -F. '{print $1}')"
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOGFILE="$LOGDIR/$LOGNAME-$TIMESTAMP-backend.log"

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

dnf module disable nodejs -y &>>LOGFILE
VALIDATION $? "disabling nodejs"
dnf module enable nodejs:20 -y &>>LOGFILE
VALIDATION $? "enabling nodejs:20"
dnf list installed nodejs  &>>LOGFILE
if [ $? -ne 0 ]
then
   dnf install nodejs -y &>>LOGFILE
   VALIDATION $? "installing nodejs"
   useradd expense
   VALIDATION $? "adding user"
   mkdir /app
   VALIDATION $? "aading dir"
   curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>LOGFILE
   VALIDATION $? "downloading zip"
   cd /app
   unzip /tmp/backend.zip &>>LOGFILE
   VALIDATION $? "unziping backendfile" 
   cd /app
   npm install &>>LOGFILE
   VALIDATION $? "install npm"
   cp /tmp/malla.sh /etc/systemd/system/backend.service
   dnf install mysql -y &>>LOGFILE
   VALIDATION $? "installing mysql"
   mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pExpenseApp@1 < /app/schema/backend.sql
   VALIDATION $? "adding schema"
   systemctl daemon-reload &>>LOGFILE
   VALIDATION $? "reloading backendservice"
   systemctl start backend &>>LOGFILE
   VALIDATION $? "starting backend"
   systemctl enable backend &>>LOGFILE
   VALIDATION $? "enabling backend"
fi


 
      
   
   

