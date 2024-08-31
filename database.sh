#!/bin/bash
USERID=$(id -u)
ROOT()
{
    if [ $USERID -ne 0 ]
    then
        echo "YOU ARE NOT IN ROOT PREVILIGES PLEASE RUN WITH SUDO"
        exit 1
    else
        echo "SERVER STARTED FOR EXECUTING SERVICES"
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
        echo "MYSQL SERVER NOT INSTALLED PROPERLLY RETRY"
        exit 1
       else
          echo "MYSQL_SERVER INSTALLED SUCCESSFULLY"
      fi
else
    echo "MYSQL_SERVER PACKEGES ARE ALREADY AVAILABLE";
fi

systemctl enable mysqld
if [ $? -ne 0]
then 
    echo "mysql server going to enable "
    systemctl start mysqldf    
    VALIDATE() $? "MYSQL_SERVER"
fi