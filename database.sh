#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

ROOT()
{
    if [ $USERID -ne 0 ]
    then
        echo -e "$R YOU ARE NOT IN ROOT PREVILIGES PLEASE RUN WITH SUDO $N"
        exit 1
    else
        echo -e "$G SERVER STARTED FOR EXECUTING SERVICES $N"
    fi
}
VALIDATE() {
    if [ $1 -ne 0 ]
    then 
        echo "$2 is : FAILED"
        exit 1
    else
        echo "$2 is : SUCCESS"
    fi
}

ROOT

dnf list installed mysql-server;
if [ $? -ne 0 ]
then
    echo "MYSQL SERVER NOT INSTALLED..GOING TO INSTALLING"
    dnf install mysql-server -y
      if [ $? -ne 0 ]
      then
            echo -e "$R MYSQL SERVER NOT INSTALLED PROPERLLY RETRY $N"
        exit 1
       else
            echo -e "$G SQL_SERVER INSTALLED SUCCESSFULLY $N"
      fi
else
    echo -e "$Y MYSQL_SERVER PACKEGES ARE ALREADY AVAILABLE $N";
fi

systemctl enable mysqld
VALIDATE $? "MYSQL_SERVER_ENABLED"

systemctl start mysqld
VALIDATE $? "MYSQL_SERVER_STARTED"