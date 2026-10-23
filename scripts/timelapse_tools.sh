#!/bin/sh

set -e

function creality_timelapses_message(){
  top_line
  title 'Creality timelapses in Fluidd and Mainsail' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}This allows to show timelapses recorded by Creality firmware ${white}│"
  echo -e " │ ${cyan}in the Timelapse menu of Fluidd and Mainsail (folder         ${white}│"
  echo -e " │ ${cyan}'creality'). Videos are not copied, only a link is created.  ${white}│"
  hr
  echo -e " │ ${cyan}For timelapses named like your prints with a preview, use    ${white}│"
  echo -e " │ ${cyan}the option to enable Moonraker Timelapse recording instead.  ${white}│"
  hr
  bottom_line
}

function moonraker_timelapse_recording_message(){
  top_line
  title 'Moonraker Timelapse recording' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}This allows to enable or disable timelapse recording of      ${white}│"
  echo -e " │ ${cyan}Moonraker Timelapse for Fluidd and Mainsail.                 ${white}│"
  hr
  echo -e " │ ${cyan}Layer mode: a frame is taken at each layer change. You need  ${white}│"
  echo -e " │ ${cyan}to add TIMELAPSE_TAKE_FRAME in your slicer's 'Before layer   ${white}│"
  echo -e " │ ${cyan}change G-code'.                                              ${white}│"
  echo -e " │ ${cyan}Hyperlapse mode: a frame is taken every 30 seconds. No       ${white}│"
  echo -e " │ ${cyan}slicer change is needed.                                     ${white}│"
  hr
  bottom_line
}

function timelapse_settings_request(){
  "$CURL" -s -X POST "${TIMELAPSE_SETTINGS_API}?$1" | grep -q '"result"'
}

function show_creality_timelapses(){
  creality_timelapses_message
  local yn
  while true; do
    read -p "${white} Do you want to show ${green}Creality timelapses in Fluidd and Mainsail ${white}? (${yellow}y${white}/${yellow}n${white}): ${yellow}" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ ! -d "$TIMELAPSE_FOLDER" ]; then
          mkdir -p "$TIMELAPSE_FOLDER"
        fi
        echo -e "Info: Linking Creality timelapses folder..."
        ln -sf "$CREALITY_TIMELAPSE_FOLDER" "$CREALITY_TIMELAPSE_LINK"
        ok_msg "Creality timelapses are now shown in Fluidd and Mainsail!"
        echo -e "   Note: Deleting a video in Fluidd or Mainsail also deletes it for Creality."
        echo
        return;;
      N|n)
        error_msg "Activation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function hide_creality_timelapses(){
  creality_timelapses_message
  local yn
  while true; do
    read -p "${white} Do you want to hide ${green}Creality timelapses in Fluidd and Mainsail ${white}? (${yellow}y${white}/${yellow}n${white}): ${yellow}" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Removing link (videos are kept)..."
        rm -f "$CREALITY_TIMELAPSE_LINK"
        ok_msg "Creality timelapses are no longer shown in Fluidd and Mainsail!"
        return;;
      N|n)
        error_msg "Deactivation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function enable_moonraker_timelapse_recording(){
  moonraker_timelapse_recording_message
  local mode
  while true; do
    read -p " Which mode do you want to use? (${yellow}layer${white}/${yellow}hyperlapse${white}/${yellow}n${white} to cancel): ${yellow}" mode
    case "${mode}" in
      layer|LAYER)
        echo -e "${white}"
        echo -e "Info: Enabling Moonraker Timelapse recording (layer mode)..."
        if ! timelapse_settings_request "enabled=true&mode=layermacro"; then
          error_msg "Unable to change settings, please check that Moonraker is running!"
          return
        fi
        ok_msg "Moonraker Timelapse recording has been enabled successfully!"
        echo -e "   Don't forget to add ${yellow}TIMELAPSE_TAKE_FRAME${white} in your slicer's 'Before layer change G-code'."
        echo -e "   You can disable Creality timelapse on the printer screen to avoid recording twice."
        echo
        return;;
      hyperlapse|HYPERLAPSE)
        echo -e "${white}"
        echo -e "Info: Enabling Moonraker Timelapse recording (hyperlapse mode)..."
        if ! timelapse_settings_request "enabled=true&mode=hyperlapse&hyperlapse_cycle=30"; then
          error_msg "Unable to change settings, please check that Moonraker is running!"
          return
        fi
        ok_msg "Moonraker Timelapse recording has been enabled successfully!"
        echo -e "   You can disable Creality timelapse on the printer screen to avoid recording twice."
        echo
        return;;
      N|n)
        error_msg "Activation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function disable_moonraker_timelapse_recording(){
  moonraker_timelapse_recording_message
  local yn
  while true; do
    read -p "${white} Do you want to disable ${green}Moonraker Timelapse recording ${white}? (${yellow}y${white}/${yellow}n${white}): ${yellow}" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Disabling Moonraker Timelapse recording..."
        if ! timelapse_settings_request "enabled=false&mode=layermacro"; then
          error_msg "Unable to change settings, please check that Moonraker is running!"
          return
        fi
        ok_msg "Moonraker Timelapse recording has been disabled successfully!"
        return;;
      N|n)
        error_msg "Deactivation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}
