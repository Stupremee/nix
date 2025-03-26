#!/usr/bin/env bash

uptime=$(uptime | sed -e 's/up //g')

shutdown="󰐥 Shutdown"
reboot="󰜉 Reboot"
lock="󰍁 Lock"
suspend="󰒲 Sleep"
logout="󰍃 Log Out"

# Ask for confirmation
rdialog() {
  rofi -dmenu -i -no-fixed-num-lines -p "Are You Sure? : "
}

# Display Help
show_msg() {
  rofi -e "Options : yes / no / y / n"
}

# Variable passed to rofi
options="$lock\n$suspend\n$logout\n$reboot\n$shutdown"

chosen="$(echo -e "$options" | rofi -p "UP - $uptime" -dmenu -selected-row 0)"
case $chosen in
$shutdown)
  ans=$(rdialog &)
  if [[ $ans == "yes" ]] || [[ $ans == "YES" ]] || [[ $ans == "y" ]]; then
    systemctl poweroff
  elif [[ $ans == "no" ]] || [[ $ans == "NO" ]] || [[ $ans == "n" ]]; then
    exit
  else
    show_msg
  fi
  ;;
$reboot)
  ans=$(rdialog &)
  if [[ $ans == "yes" ]] || [[ $ans == "YES" ]] || [[ $ans == "y" ]]; then
    systemctl reboot
  elif [[ $ans == "no" ]] || [[ $ans == "NO" ]] || [[ $ans == "n" ]]; then
    exit
  else
    show_msg
  fi
  ;;
$lock)
  swaylock
  ;;
$suspend)
  ans=$(rdialog &)
  if [[ $ans == "yes" ]] || [[ $ans == "YES" ]] || [[ $ans == "y" ]]; then
    systemctl suspend
  elif [[ $ans == "no" ]] || [[ $ans == "NO" ]] || [[ $ans == "n" ]]; then
    exit
  else
    show_msg
  fi
  ;;
$logout)
  ans=$(rdialog &)
  if [[ $ans == "yes" ]] || [[ $ans == "YES" ]] || [[ $ans == "y" ]]; then
    pkill Hyprland
  elif [[ $ans == "no" ]] || [[ $ans == "NO" ]] || [[ $ans == "n" ]]; then
    exit
  else
    show_msg
  fi
  ;;
esac
