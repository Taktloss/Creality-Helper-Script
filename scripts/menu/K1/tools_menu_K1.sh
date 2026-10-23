#!/bin/sh

set -e

function tools_menu_ui_k1() {
  top_line
  title '[ TOOLS MENU ]' "${yellow}"
  inner_line
  hr
  menu_option ' 1' 'Prevent updating' 'Klipper configuration files'
  menu_option ' 2' 'Allow updating' 'Klipper configuration files'
  menu_option ' 3' 'Fix' 'printing Gcode files from folder'
  hr
  menu_option ' 4' 'Enable' 'camera settings in Moonraker'
  menu_option ' 5' 'Disable' 'camera settings in Moonraker'
  hr
  menu_option ' 6' 'Fix' 'internal camera (Firmware 1.3.5.22+)'
  menu_option ' 7' 'Remove fix' 'internal camera'
  hr
  menu_option ' 8' 'Show' 'Creality timelapses in Fluidd/Mainsail'
  menu_option ' 9' 'Hide' 'Creality timelapses in Fluidd/Mainsail'
  menu_option '10' 'Enable' 'Moonraker Timelapse recording'
  menu_option '11' 'Disable' 'Moonraker Timelapse recording'
  hr
  menu_option '12' 'Restart' 'Nginx service'
  menu_option '13' 'Restart' 'Moonraker service'
  menu_option '14' 'Restart' 'Klipper service'
  hr
  menu_option '15' 'Update' 'Entware packages'
  hr
  menu_option '16' 'Clear' 'cache'
  menu_option '17' 'Clear' 'logs files'
  hr
  menu_option '18' 'Restore' 'a previous firmware'
  hr
  menu_option '19' 'Reset' 'factory settings'
  hr
  inner_line
  hr
  bottom_menu_option 'b' 'Back to [Main Menu]' "${yellow}"
  bottom_menu_option 'q' 'Exit' "${darkred}"
  hr
  version_line "$(get_script_version)"
  bottom_line
}

function tools_menu_k1() {
  clear
  tools_menu_ui_k1
  local tools_menu_opt
  while true; do
    read -p " ${white}Type your choice and validate with Enter: ${yellow}" tools_menu_opt
    case "${tools_menu_opt}" in
      1)
        if [ -f "$INITD_FOLDER"/disabled.S55klipper_service ]; then
          error_msg "Updating Klipper configuration files is already prevented!"
        else
          run "prevent_updating_klipper_files" "tools_menu_ui_k1"
        fi;;
      2)
        if [ ! -f "$INITD_FOLDER"/disabled.S55klipper_service ]; then
          error_msg "Updating Klipper configuration files is already allowed!"
        else
          run "allow_updating_klipper_files" "tools_menu_ui_k1"
        fi;;
      3)
        if [ -f "$KLIPPER_KLIPPY_FOLDER"/gcode.py ]; then
          run "printing_gcode_from_folder" "tools_menu_ui_k1"
        fi;;
      4)
        if grep -q "^\[webcam Camera\]$" "$MOONRAKER_CFG"; then
          error_msg "Camera settings are alredy enabled in Moonraker!"
        else
          run "enable_camera_settings" "tools_menu_ui_k1"
        fi;;
      5)
        if grep -q "^#\[webcam Camera\]" "$MOONRAKER_CFG"; then
          error_msg "Camera settings are alredy disabled in Moonraker!"
        else
          run "disable_camera_settings" "tools_menu_ui_k1"
        fi;;
      6)
        if [ -f "$CAMERA_FIX_FILE" ]; then
          error_msg "Internal Camera Fix is already installed!"
        else
          run "install_camera_fix" "tools_menu_ui_k1"
        fi;;
      7)
        if [ ! -f "$CAMERA_FIX_FILE" ]; then
          error_msg "Internal Camera Fix is not installed!"
        else
          run "remove_camera_fix" "tools_menu_ui_k1"
        fi;;
      8)
        if [ ! -d "$CREALITY_TIMELAPSE_FOLDER" ]; then
          error_msg "No Creality timelapses folder found!"
        elif [ -L "$CREALITY_TIMELAPSE_LINK" ]; then
          error_msg "Creality timelapses are already shown!"
        elif [ ! -f "$TIMELAPSE_FILE" ]; then
          error_msg "Moonraker Timelapse is needed, please install it first!"
        else
          run "show_creality_timelapses" "tools_menu_ui_k1"
        fi;;
      9)
        if [ ! -L "$CREALITY_TIMELAPSE_LINK" ]; then
          error_msg "Creality timelapses are already hidden!"
        else
          run "hide_creality_timelapses" "tools_menu_ui_k1"
        fi;;
      10)
        if [ ! -f "$TIMELAPSE_FILE" ]; then
          error_msg "Moonraker Timelapse is needed, please install it first!"
        else
          run "enable_moonraker_timelapse_recording" "tools_menu_ui_k1"
        fi;;
      11)
        if [ ! -f "$TIMELAPSE_FILE" ]; then
          error_msg "Moonraker Timelapse is not installed!"
        else
          run "disable_moonraker_timelapse_recording" "tools_menu_ui_k1"
        fi;;
      12)
        if [ ! -d "$NGINX_FOLDER" ]; then
          error_msg "Nginx is not installed!"
        else
          run "restart_nginx_action" "tools_menu_ui_k1"
        fi;;
      13)
        if [ ! -d "$MOONRAKER_FOLDER" ]; then
          error_msg "Moonraker is not installed!"
        else
          run "restart_moonraker_action" "tools_menu_ui_k1"
        fi;;
      14)
        if [ ! -f "$INITD_FOLDER"/S55klipper_service ]; then
          error_msg "Klipper service is not present!"
        else
          run "restart_klipper_action" "tools_menu_ui_k1"
        fi;;
      15)
        if [ ! -f "$ENTWARE_FILE" ]; then
          error_msg "Entware is not installed!"
        else
          run "update_entware_packages" "tools_menu_ui_k1"
        fi;;
      16)
        run "clear_cache" "tools_menu_ui_k1";;
      17)
        run "clear_logs" "tools_menu_ui_k1";;
      18)
        run "restore_previous_firmware" "tools_menu_ui_k1";;
      19)
        run "reset_factory_settings" "tools_menu_ui_k1";;
      B|b)
        clear; main_menu; break;;
      Q|q)
         clear; exit 0;;
      *)
         error_msg "Please select a correct choice!";;
    esac
  done
  tools_menu_k1
}
