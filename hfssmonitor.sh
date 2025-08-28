#!/bin/bash

source "./config.sh"
if [ "$OS" = "W" ]; then
    RUN_HFSS=$(wslpath -u "$RUN_HFSS")
fi
"$RUN_HFSS" -showmonitorjob &

