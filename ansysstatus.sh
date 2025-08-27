#!/bin/bash
source ./config.sh

"$LMSTAT_CMD"

echo 
read -r -p "Press any key to exit..." -n1 -s
echo