#!/usr/bin/env bash

pid=$(pidof wf-recorder)
if [ -n "$pid" ]; then
  kill -INT "$pid"
  notify-send -t 5000 -u normal -i simplescreenrecorder-paused "Screen recording stopped"
  exit 0
fi

# Buttons
screen="󰍹 Capture Desktop"
area="󰆞 Capture Area"
window="󰖲 Capture Window"
inthree="󰔝 Take in 3s"
record=" Record area"

# countdown
countdown() {
  for sec in $(seq "$1" -1 1); do
    notify-send -t 1000 -u low -i alarm-timer "Taking shot in: $sec"
    sleep 1
  done
}

# take shots
shotnow() {
  sleep 0.5
  grimblast --notify copy output
}

shot3() {
  countdown '3'
  grimblast --notify copy output
}

shotwin() {
  countdown '3'
  grimblast --notify copy active
}

shotarea() {
  sleep 0.5
  grimblast --notify copy area
}

record() {
  time=$(date +%F%T)

  mkdir -p ~/Videos/screen-recordings
  geom=$(slurp)

  wf-recorder -g "$geom" -f ~/Videos/screen-recordings/"$time".mp4 &

  notify-send -t 5000 -u normal -i simplescreenrecorder-recording "Screen recording started"
}

# Variable passed to rofi
options="$area\n$screen\n$window\n$inthree\n$record"

chosen="$(echo -e "$options" | rofi -p 'Take A Shot' -dmenu -selected-row 0)"
case $chosen in
$screen)
  shotnow
  ;;
$area)
  shotarea
  ;;
$window)
  shotwin
  ;;
$inthree)
  shot3
  ;;
$record)
  record
  ;;
esac
