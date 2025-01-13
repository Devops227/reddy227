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
dnf module enable nodejs:20 -y &>>LOGFILE
dnf list installed nodejs  &>>LOGFILE
if [ $? -ne 0 ]
then
   dnf install nodejs -y &>>LOGFILE
   VALIDATION $? "installing nodejs"
   useradd expense
   mkdir /app
   curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>LOGFILE
   if [ $? -ne 0 ]
   then 
      echo -e "$R issue with curl download$N"
      exit 1
   else
      echo -e "$G downloading zip file$N"
   fi
cd /app
unzip /tmp/backend.zip &>>LOGFILE
   if [ $? -ne 0 ]
   then 
      echo -e "$R issue with curl download$N"
      exit 1
   else
      echo -e "$G unziping file$N"
   fi
cd /app
npm install &>>LOGFILE
  if [ $? -ne 0 ]
  then
     echo -e "$R issue with npm install$N"
     exit 1
  else
    echo -e "$G npm is installing..success$N"
  fi
cp /tmp/malla.sh /etc/systemd/system/backend.service
systemctl daemon-reload &>>LOGFILE
VALIDATION $? "daemon reloaning"
systemctl start backend &>>LOGFILE
VALIDATION $? "daemon starting"
systemctl enable backend &>>LOGFILE
VALIDATION $? "service enabling"
dnf install mysql -y &>>LOGFILE
VALIDATION $? "Installing mysql service"
mysql -h 172.31.95.236 -uroot -pExpenseApp@1 < /app/schema/backend.sql
VALIDATION $? "validating the access of root"
systemctl restart backend &>>LOGFILE
VALIDATION $? "reloading backend service"
fi