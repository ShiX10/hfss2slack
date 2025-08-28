#!/bin/bash

source "./config.sh"
USER_NAME=$(whoami)
HOURS=${1:-1}
END_TIME=$(date -d "+$(echo "$HOURS * 60" | bc | cut -d. -f1) minutes" "+%Y-%m-%d %H:%M")
if [ "$OS" = "W" ]; then
    WORK_DIR=$(wslpath -u "$WORK_DIR")
fi
LOGFILE="$(date +%Y%m%d_%H%M%S_%N).log"

if ! JOBFILE=$(
    yad --file \
        --title="Select simulation file" \
        --filename="$WORK_DIR" \
        --file-filter=' .aedt | *.aedt *.AEDT' \
        --file-filter=' | *' \
        --separator="," \
        --width="500" \
        --height="250" \
        --center
); then
    exit 1
fi

DESIGNS=$(grep -oP "DesignName=[\"']\K[^\"']+" "$JOBFILE" | paste -sd'!' -)

if ! DESIGN=$(
    yad --form \
        --title="Select design" \
        --item-separater='!' \
        --field="Designs":CB "$DESIGNS" \
        --width="$YADWIDTH" \
        --height="$YADHEIGHT" \
        --center
); then
    exit 1
fi

DESIGN=$(echo "$DESIGN" | cut -d'|' -f1)

BLOCK=$(awk -v design="$DESIGN" '
    $0 ~ "DesignName=\047" design "\047" {flag=1}
    flag && /^\t\$end/ {flag=0}
    flag
' "$JOBFILE")

SETUPS=$(echo "$BLOCK" |
    grep "'Nominal Setups'" |
    grep -oP "'[^']+'" |
    tr -d "'" |
    tail -n +2 |
    paste -sd'!' -)

OPTIMETRICS=$(echo "$BLOCK" |
    grep "'Optimetrics Setups'" |
    grep -oP "'[^']+'" |
    tr -d "'" |
    tail -n +2 |
    paste -sd'!' -)

if ! CONFIG=$(
    yad --form \
        --title="Simulation Configs ($JOBFILE/$DESIGN)" \
        --item-separater='!' \
        --field="Setups":CB "$SETUPS" \
        --field="Optimetrics":CB "None!$OPTIMETRICS" \
        --width="$YADWIDTH" \
        --height="$YADHEIGHT" \
        --center
); then
    exit 1
fi

SETUP=$(echo "$CONFIG" | cut -d'|' -f1)
OPTIMETRIC=$(echo "$CONFIG" | cut -d'|' -f2)
if [ -z "$OPTIMETRIC" ] || [ "$OPTIMETRIC" = "None" ]; then
    ANALYSISSETUP="$DESIGN:Nominal:$SETUP"
else
    ANALYSISSETUP="$DESIGN:Optimetrics:$OPTIMETRIC"
fi

if [ "$OS" = "W" ]; then
    JOBFILE=$(wslpath -w "$JOBFILE")
    RUN_HFSS=$(wslpath -u "$RUN_HFSS")
fi
"$RUN_HFSS" \
    -monitor \
    -waitforlicense \
    -ng \
    -batchsolve \
    "$ANALYSISSETUP" \
    "$JOBFILE" >"$LOGFILE" 2>&1 &
HFSS_PID=$!

MESSAGESTATUS=$(./send_slack_message.sh ":rocket: JOB SUBMITTED by *$USER_NAME* on *$HOSTNAME*! \n\`Estimated Time to End : $END_TIME\`")

if [ "$SEND_LOG" = "True" ]; then
    ./track_log.sh "$LOGFILE" "$LOG_KEYWORDS" "$MESSAGESTATUS" &
    TRACK_PID=$!
    wait $HFSS_PID
    kill $TRACK_PID >/dev/null 2>&1
else
    wait $HFSS_PID
fi

./send_slack_message.sh ":white_check_mark: Job Finished!" "$MESSAGESTATUS"
rm "$LOGFILE"