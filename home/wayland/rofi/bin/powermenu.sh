#!/usr/bin/env bash
rofi_command="rofi -theme $HOME/.config/rofi/config/powermenu.rasi"

uptime=$(uptime | sed -e 's/up //g')

ddir="$HOME/.config/rofi/config"
shutdown="󰐥"
reboot="󰜉"
lock="󰍁"
suspend="󰒲"
logout="󰍃"

# Ask for confirmation
rdialog() {
  rofi -dmenu -i -no-fixed-num-lines -p "Are You Sure? : " \
    -theme "$ddir/confirm.rasi"
}

# Display Help
show_msg() {
  rofi -theme "$ddir/askpass.rasi" -e "Options : yes / no / y / n"
}

# Variable passed to rofi
options="$lock\n$suspend\n$logout\n$reboot\n$shutdown"

chosen="$(echo -e "$options" | $rofi_command -p "UP - $uptime" -dmenu -selected-row 0)"
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
