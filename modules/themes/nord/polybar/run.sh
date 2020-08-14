#!/usr/bin/env bash

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar bar >$XDG_DATA_HOME/polybar.log 2>&1 &
