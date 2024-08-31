FILEPATH="/var/log/backend_logs"
SCRIPT=$(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE=$FILEPATH/$SCRIPT-$TIME_STAMP.log
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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "DISABLED NODEJS"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "ENABLED NODEJS :20"

dnf lists installed nodejs -y &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo -e "$G NODEJS GOING TO INSTALLING $N" | tee -a $LOG_FILE
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "NODEJS INSTALATION"
else
    echo -e "$G NODEJS ALREADY INSTALLED $N -- $Y SKIPPING $N" | tee -a $LOG_FILE
fi

useradd expense

mkdir -p /app

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip

cd /app

unzip /tmp/backend.zip
VALIDATE $? "BACKEND FILE UZIPPED"

npm install
VALIDATE $? "NPM INSTALLED"






