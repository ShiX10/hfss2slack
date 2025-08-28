#!/bin/bash

#OS ("W" for Windows, "L" for Linux)
OS="W"

#HFSS
#If license is shared with other PC ("True" or "False")
SHARED_LICENSE="True"
#When $SHARED_LICENSE is “True”, edit the three lines below.
LICENSE_SERV="IP address of license server"
SSH_ACCOUNT="account_name@$LICENSE_SERV"
LMSTAT_CMD="path_of/lmutil lmstat -c 1055@$LICENSE_SERV -A"

#Full path of HFSS
RUN_HFSS="path_of\ansysedt.exe"
#Your working directory for HFSS (on Windows, set a path that works for everyone)
WORK_DIR="Your HFSS Directory"
#Keywords for extaracting log
LOG_KEYWORDS=$(printf "%s|" \
    "Pass Number:" \
    "Parametric Analysis is done" \
    "Normal completion of simulation" \
    "A variation " \
    "Adaptive Passes converged")
LOG_KEYWORDS=${LOG_KEYWORDS%|}

#SLACK
#Channel id
SLACK_CHANNEL_ID="Cxxxxxxxxxx"
#Slack bot token
SLACK_BOT_TOKEN="xoxb-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#Send job log to Slack ("True" or "False")
SEND_LOG="True"

#YAD (Size of dialogue windows for hfsssub.sh)
YADHEIGHT=200
YADWIDTH=400