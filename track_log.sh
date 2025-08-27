#!/bin/bash
source "./config.sh"

LOGFILE=$1
LOG_KEYWORDS=$2
MESSAGESTATUS=$3

while read -r line; do
    if [[ "$line" =~ ^\[info\] ]]; then
        if [[ "$line" =~ $LOG_KEYWORDS ]]; then
            line=$(echo "$line" | tr -d '\r\n')
            ./send_slack_message.sh "\`\`\`$line\`\`\`" "$MESSAGESTATUS" >/dev/null 2>&1
        fi
    elif [[ "$line" =~ ^\[warning\] ]] || [[ "$line" =~ ^\[error\] ]]; then
        line=$(echo "$line" | tr -d '\r\n')
        ./send_slack_message.sh "\`$line\`" "$MESSAGESTATUS" >/dev/null 2>&1
    fi
done < <(tail -F "$LOGFILE")
