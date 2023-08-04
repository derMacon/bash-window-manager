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
  echo "toggle window_id: $window_id" >>$LOG_FILE

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

function read_buffer {
  while IFS= read -r line; do
    # Check if the line is a variable assignment
    if [[ "$line" == *"="* ]]; then
      # Extract the variable name and value
      var_name="${line%%=*}"
      var_value="${line#*=}"

      # Print the variable name and value
      echo "$var_name=$var_value" >>$LOG_FILE
      export $var_name=$var_value
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
  echo 'memory slot taken - toggle visibility' >>$LOG_FILE
  #  early_exit_when_already_allocated
  toggle_visibility "$memory_slot_window_name"
else
  echo 'memory slot not taken - set slot with current selected window id' >>$LOG_FILE
  set_memory_slot "$memory_slot_window_name"
fi
