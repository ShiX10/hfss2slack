#!/bin/bash
source "./config.sh"

message="$1"
thread_ts="$2"

if [ -z "$message" ]; then
    echo "Usage: $0 \"message text\" [Thread ID]"
    exit 1
fi

if command -v curl >/dev/null 2>&1; then
    USE_CURL=true
else
    USE_CURL=false
fi

if [ "$USE_CURL" = true ]; then
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
else
    if [ -z "$thread_ts" ]; then
        response=$(wget -qO- --header="Authorization: Bearer $SLACK_BOT_TOKEN" \
            --header="Content-Type: application/json" \
            --post-data "{\"channel\":\"$SLACK_CHANNEL_ID\",\"text\":\"$message\"}" \
            "https://slack.com/api/chat.postMessage")

        ts=$(echo "$response" | sed -n 's/.*"ts":"\([^"]*\)".*/\1/p')
        echo "$ts"
    else
        wget -qO- --header="Authorization: Bearer $SLACK_BOT_TOKEN" \
            --header="Content-Type: application/json" \
            --post-data "{\"channel\":\"$SLACK_CHANNEL_ID\",\"text\":\"$message\",\"thread_ts\":\"$thread_ts\"}" \
            "https://slack.com/api/chat.postMessage" >/dev/null
    fi
fi
