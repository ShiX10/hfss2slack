#!/bin/bash

#OS ("W" for Windows, "L" for Linux)
OS="W"

#HFSS
SHARED_LICENSE="True"
LICENSE_SERV="IP address of license server"
SSH_ACCOUNT="account_name@$LICENSE_SERV"
LMSTAT_CMD="path_of/lmutil lmstat -c 1055@$LICENSE_SERV -A"

RUN_HFSS="path_of\ansysedt.exe"
WORK_DIR="Your HFSS Directory"
LOG_KEYWORDS=$(printf "%s|" \
    "Pass Number:" \
    "Parametric Analysis is done" \
    "Normal completion of simulation" \
    "A variation " \
    "Adaptive Passes converged")
LOG_KEYWORDS=${LOG_KEYWORDS%|}

#SLACK
SLACK_CHANNEL_ID="Cxxxxxxxxxx"
SLACK_BOT_TOKEN="xoxb-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
SEND_LOG="True"

#YAD (Size of dialogue windows)
YADHEIGHT=200
YADWIDTH=400
