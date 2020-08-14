#!/usr/bin/env bash

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar -rq music &
polybar -rq tray &
polybar -rq ws &
