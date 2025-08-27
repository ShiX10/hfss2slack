#!/bin/bash
source "./config.sh"

message="$1"
thread_ts="$2"


if [ -z "$message" ]; then
    echo "Usage: $0 \"message text\" [Thread ID]"
    exit 1
fi

if [ -z "$thread_ts" ]; then
    response=$(curl -s -X POST "https://slack.com/api/chat.postMessage" \
        -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
        -H "Content-type: application/json" \
        --data "{\"channel\":\"$SLACK_CHANNEL_ID\",\"text\":\"$message\"}")

    ts=$(echo "$response" | sed -n 's/.*"ts":"\([^"]*\)".*/\1/p')
    echo "$ts"
else
    curl -s -X POST "https://slack.com/api/chat.postMessage" \
        -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
        -H "Content-type: application/json" \
        --data "{\"channel\":\"$SLACK_CHANNEL_ID\",\"text\":\"$message\",\"thread_ts\":\"$thread_ts\"}" >/dev/null
fi
