FILEPATH="/var/log/frontend_logs"
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

dnf list installed nginx -y &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo -e "$G NGINX IS GOING TO INSTALL $N" | tee -a $LOG_FILE
    dnf install nginx -y &>>$LOG_FILE
    VALIDATE $? "NGINX INSTALLED"
else
    echo -e "$G NGINX IS ALREADY INSTALLED $N--$YSKIPPING $N" | tee -a $LOG_FILE
fi
systemctl enable nginx
VALIDATE $? "NGINX ENABLED"

systemctl start nginx
VALIDATE $? "NGINX STARTED"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "DUMMY FILES REMOVED IN THE PATH "

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
cd /usr/share/nginx/html

unzip /tmp/frontend.zip &>>$LOG_FILE

cp /home/ec2-user/expences_project/frontend.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "configuration file copied to expence.conf"

systemctl restart nginx
VALIDATE $? "NGENIX RESTARTED"

echo -e "$Y YOU PROJECT IS READY TO EXECUTE $N"


