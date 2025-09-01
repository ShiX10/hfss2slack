#!/bin/bash

source ./config.sh

USER_NAME=$(whoami)
HOURS=${1:-1}
END_TIME=$(date -d "+$(echo "$HOURS * 60" | bc | cut -d. -f1) minutes" "+%Y-%m-%d %H:%M")

#Obtain license status
if [ "$SHARED_LICENSE" = "True" ]; then

    IP=$(hostname -I | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b')
    if [ "$IP" != "$LICENSE_SERV" ]; then
        output=$(ssh "$SSH_ACCOUNT" "$LMSTAT_CMD")
    else
        output=$(eval "$LMSTAT_CMD")
    fi

    gui_line=$(echo "$output" | grep "electronics_desktop:")
    line_num=$(grep -n "electronics_desktop:" <<<"$output" | cut -d: -f1)
    line=$(sed -n "$((line_num + 6))p" <<<"$output")
    gui_user=$(echo "$line" | awk '{print $1}')
    pcname=$(echo "$line" | awk '{print $2}')

    # Check whether GUI license is free or not
    if [ -z "$gui_line" ]; then
        # When GUI license is free
        if [ "$OS" = "W" ]; then
            RUN_HFSS=$(wslpath -u "$RUN_HFSS")
        fi
        "$RUN_HFSS" &
        HFSS_PID=$!
        MESSAGESTATUS=$(./send_slack_message.sh ":computer: GUI session started by *$USER_NAME* on *$HOSTNAME*! \n  \`Estimated Time to End : $END_TIME\`")
        wait $HFSS_PID
        ./send_slack_message.sh "Finished!" "$MESSAGESTATUS"
    else
        # When GUI license is used
        echo -e "GUI license is currently occupied by \e[;1m$gui_user (Computer : $pcname)\e[m."
        exit 0
    fi

elif [ "$SHARED_LICENSE" = "False" ]; then

    if [ "$OS" = "W" ]; then
        RUN_HFSS=$(wslpath -u "$RUN_HFSS")
    fi
    "$RUN_HFSS" &
    HFSS_PID=$!
    MESSAGESTATUS=$(./send_slack_message.sh ":computer: GUI session started by *$USER_NAME* on *$HOSTNAME*! \n  \`Estimated Time to End : $END_TIME\`")
    wait $HFSS_PID
    ./send_slack_message.sh "Finished!" "$MESSAGESTATUS"
fi
