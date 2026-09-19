#!/bin/bash

output=$(hyprctl getoption general:layout)

current_layout=$(echo "$output" | grep "^str:" | awk '{print $2}')

if [[ "$current_layout" == "scrolling" ]]; then
    hyprctl keyword general:layout dwindle
else 
    hyprctl keyword general:layout scrolling
fi
