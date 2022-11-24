#!/usr/bin/env bash
rofi_command="rofi -theme $HOME/.config/rofi/config/screenshot.rasi"

# Buttons
screen=" Capture Desktop"
area=" Capture Area"
window="缾 Capture Window"
inthree="靖 Take in 3s"

# countdown
countdown() {
  for sec in $(seq $1 -1 1); do
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

# Variable passed to rofi
options="$area\n$screen\n$window\n$inthree"

chosen="$(echo -e "$options" | $rofi_command -p 'Take A Shot' -dmenu -selected-row 0)"
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
esac
