#!/bin/bash
FILEPATH="/var/log/mysql_logs"
SCRIPT=$(echo $0 | cut -d "." -1 f)
TIME_STAMP=$(date +%D)
LOG_FILE=$SCRIPT$TIME_STAMP$FILEPATH.log
mkdir -p $FILEPATH

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

ROOT()
{
    if [ $USERID -ne 0 ]
    then
        echo -e "$R YOU ARE NOT IN ROOT PREVILIGES PLEASE RUN WITH SUDO $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$G SERVER STARTED FOR EXECUTING SERVICES $N" | tee -a $LOG_FILE
    fi
}
VALIDATE() {
    if [ $1 -ne 0 ]
    then 
        echo "$2 is : FAILED" | tee -a $LOG_FILE
        exit 1
    else
        echo "$2 is : SUCCESS" | tee -a $LOG_FILE
    fi
}

ROOT

dnf list installed mysql-server;
if [ $? -ne 0 ]
then
    echo "MYSQL SERVER NOT INSTALLED..GOING TO INSTALLING" | tee -a $LOG_FILE
    dnf install mysql-server -y | & >>$LOG_FILE
      if [ $? -ne 0 ]
      then
            echo -e "$R MYSQL SERVER NOT INSTALLED PROPERLLY RETRY $N" | tee -a $LOG_FILE
        exit 1
       else
            echo -e "$G SQL_SERVER INSTALLED SUCCESSFULLY $N" | tee -a $LOG_FILE
      fi
else
    echo -e "$Y MYSQL_SERVER PACKEGES ARE ALREADY AVAILABLE $N"; | tee -a $LOG_FILE
fi

systemctl enable mysqld
VALIDATE $? "MYSQL_SERVER_ENABLED"

systemctl start mysqld
VALIDATE $? "MYSQL_SERVER_STARTED"