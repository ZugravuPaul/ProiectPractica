#!/bin/bash

#set -o errexit

# ---- Default configuration ----
SEARCH_TMP_DIRS="/tmp /var/tmp"
CAPACITY=45
FILE_AGE=+15
LINK_AGE=+15
SOCK_AGE=+15
#mail to send report
EMAIL_LOGGER="zugravupaul16@gmail.com"
#colors for update logs
GREEN="\033[1;32m"
NOCOLOR="\033[0m"

EMPTYFILES=true

capacity=$(df -k "$HOME" | tail -1 | awk '{print $5}')
capacity=${capacity%'%'}

printf "Starting cleanup!\n"
printf "deleting any old log files...\n" #older than 30 days
find /var/log -name "*.log" -type f -mtime +30 -print #-delete


if [ $capacity -gt $CAPACITY ]
then

printf "deleting any old tmp files..."
find $SEARCH_TMP_DIRS -depth -type f -a -ctime $FILE_AGE -print #-delete

printf "\ndeleting any old tmp symlinks..."
find $SEARCH_TMP_DIRS -depth -type l -a -ctime $LINK_AGE -print #-delete

if /usr/bin/$EMPTYFILES ;
then
printf "\ndeleting any empty files..."
find $SEARCH_TMP_DIRS -depth -type f -a -empty -print #-delete
fi

printf "\ndeleting any old Unix sockets..."
find $SEARCH_TMP_DIRS -depth -type s -a -ctime $SOCK_AGE -a -size 0 -print #-delete

printf "\ndeleting any empty directories (other than lost+found)..."
find $SEARCH_TMP_DIRS -depth -mindepth 1 -type d -a -empty -a ! -name 'lost+found' -print #-delete

logger "cleanup.sh - Done cleaning tmp and log files!"
printf "\nCleanup Script Successfully Executed\n"

# Usage: mail_util.py SUBJECT MESSAGE EMAIL_DEST
/usr/bin/python3 /usr/local/bin/mail_util.py "Cleanup has been performed successfully!" "The cleanup script was executed at $(date)" "$EMAIL_LOGGER"

fi

mylog() {
        STEP=$1
        MSG=$2

        printf "\nstep $STEP: ${GREEN}${MSG}${NOCOLOR}\n"
        logger "step $STEP: $MSG"
}

printf "Searching for updates..!\n"

mylog 1 "pre-configuring packages"
dpkg --configure -a

mylog 2 "fix and attempt to correct a system with broken dependencies"
apt-get install -f

mylog 3 "update apt cache"
apt-get update

mylog 4 "upgrade packages"
apt-get upgrade

mylog 5 "distribution upgrade"
apt-get dist-upgrade

mylog 6 "remove unused packages"
apt-get --purge autoremove

mylog 7 "cleaning up.."
apt-get autoclean

exit 0
