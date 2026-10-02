#!/bin/bash

output=$(hyprctl getoption general:layout)

current_layout=$(echo "$output" | grep "^str:" | awk '{print $2}')

if [[ "$current_layout" == "scrolling" ]]; then
    hyprctl eval 'hl.config({ general = { layout = "dwindle" } })'
else 
    hyprctl eval 'hl.config({ general = { layout = "scrolling" } })'
fi
