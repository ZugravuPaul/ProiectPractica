#!/bin/bash

set -o errexit

# ---- Default configuration ----
SEARCH_TMP_DIRS="/tmp /var/tmp"
CAPACITY=15
FILE_AGE=+2
LINK_AGE=+2
SOCK_AGE=+2
#mail to send report
EMAIL_LOGGER="zugravupaul666@yahoo.com"

EMPTYFILES=true

capacity=$(df -k "$HOME" | tail -1 | awk '{print $5}')
capacity=${capacity%'%'}

if [ $capacity -gt $CAPACITY ]
then

printf "Starting cleanup!\ndeleting any old tmp files..."
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

logger "cleanup.sh[$] - Done cleaning tmp directories"

mail -s "Cleanup has been performed successfully." "$EMAIL_LOGGER" <<< "The script was executed at $(date)"
printf "\nCleanup Script Successfully Executed"
fi

exit 0
