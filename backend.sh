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

dnf list installed nodejs -y &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo -e "$G NODEJS GOING TO INSTALLING $N" | tee -a $LOG_FILE
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "NODEJS INSTALATION"
else
    echo -e "$G NODEJS ALREADY INSTALLED $N -- $Y SKIPPING $N" | tee -a $LOG_FILE
fi

#useradd expense
id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo -e "expense user not exists... $G Creating $N"
    useradd expense &>>$LOG_FILE
    VALIDATE $? "Creating expense user"
else
    echo -e "expense user already exists...$Y SKIPPING $N"
fi

mkdir -p /app

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE

cd /app
rm -rf /app/* # remove the existing code
unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "BACKEND FILE UZIPPED"

npm install &>>$LOG_FILE
VALIDATE $? "NPM INSTALLED"

cp /home/ec2-user/expences_project/backend.service /etc/systemd/system/backend.service
VALIDATE $? "BACKEND SERVICE COPIED"

dnf list installed mysql -y &>>$LOG_FILE
if [ $? -ne 0 ]
then    
    echo -e "$G MYSQL GOING TO INSTALLING $N" | tee -a $LOG_FILE
    dnf install mysql -y &>>$LOG_FILE
    VALIDATE $? "MYSQLSERVER INSTALLED"
else
    echo -e "$G MYSQLSERVER ALREADY INSTALLED $N -- $Y SKIPPING $N" | tee -a $LOG_FILE
fi

mysql -h sql.kondarao.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE
VALIDATE $? "schema setting in database"

systemctl daemon-reload
VALIDATE $? "DEMON RELODING"


systemctl restart backend
VALIDATE $? "RESTARTING BACKEND"


systemctl start backend
VALIDATE $? "BACKEND STARTED"

systemctl enable backend
VALIDATE $? "BACKEND ENABLEING"


