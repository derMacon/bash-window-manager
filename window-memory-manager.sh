#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
LOG_FILE="$SCRIPT_DIR/log.out"
BUFFER_FILE="$SCRIPT_DIR/buffer.env"
MEM_PREFIX="WINDOW_MEMORY_SLOT_"

function set_memory_slot {
  local input_window_name=$1
  selected_window_id=$(xdotool getactivewindow)
  echo "$input_window_name=$selected_window_id" >>$BUFFER_FILE
}

function toggle_visibility {
  input=$1
  window_id="${!input}"

  active_window_id=$(xdotool getactivewindow)
  if [[ "$active_window_id" == "$window_id" ]]; then
    echo "minimize window: $window_id" >>$LOG_FILE
    xdotool windowminimize $window_id
  else
    echo "activate window: $window_id" >>$LOG_FILE
    xdotool windowactivate $window_id
  fi
}

function activate_visibility {
  input=$1
  window_id="${!input}"

  active_window_id=$(xdotool getactivewindow)
  if [[ "$active_window_id" == "$window_id" ]]; then
    echo "minimize window: $window_id" >>$LOG_FILE
    xdotool windowminimize $window_id
  else
    echo "activate window: $window_id" >>$LOG_FILE
    xdotool windowactivate $window_id
  fi
}

function debug_window_states {
  for window_id in $(xdotool search --onlyvisible ""); do
    window_name=$(xdotool getwindowname $window_id)
    echo "Window ID: $window_id  Window Name: $window_name" >>$LOG_FILE
  done
}

function reset_memory_slots {
  rm $BUFFER_FILE
}

function window_with_id_exists {
  window_id=$1
  window_info=$(xdotool search --onlyvisible --pid 0 $window_id 2>/dev/null)
  if [[ -n $window_info ]]; then
    return 0
  else
    echo 1
  fi
}

function read_buffer {
  while IFS= read -r line; do
    if [[ "$line" == *"="* ]]; then
      var_name="${line%%=*}"
      var_value="${line#*=}"

      echo "$var_name=$var_value" >>$LOG_FILE
      window_pid=$(xdotool getwindowpid "$var_value" 2>/dev/null)
      if [[ -z "$window_pid" ]]; then
        echo 'cleaning buffer file from old window id' >>$LOG_FILE
        sed -i "/$var_name=$var_value/d" "$BUFFER_FILE"
      else
        export $var_name=$var_value
      fi
    fi
  done <"$BUFFER_FILE"
}

function early_exit_when_already_allocated {
  current_window_name=$(xdotool getwindowfocus getwindowname)
  if [ "${current_window_name:0:${#MEM_PREFIX}}" = "$MEM_PREFIX" ]; then
    echo 'window already allocated - early exit'
    exit 1
  fi
}

if [ "$1" = "r" ]; then
  echo "reset parameter 'r' set" >>$LOG_FILE
  reset_memory_slots
  exit 1
fi

read_buffer
memory_slot_window_name="$MEM_PREFIX$1"

if [[ -v "$memory_slot_window_name" ]]; then
  echo 'memory slot taken - activate visibility' >>$LOG_FILE
  activate_visibility "$memory_slot_window_name"
else
  echo 'memory slot not taken - set slot with current selected window id' >>$LOG_FILE
  set_memory_slot "$memory_slot_window_name"
fi
