#!/bin/bash

#
# eventhandler.sh — Handles playback events from librespot for multiroom audio.
# Controls a Marantz amplifier via ESPHome based on player events (e.g., play, pause).
# Includes logic for muting, powering on/off, and timed shutdown after inactivity.
# 
# Tjibbe van der Laan (2025)
# 

# ESPHome IP address of the Marantz Remote. Please specify in Dockerfile
ipaddress="${ESPHOME_IPADDRESS:?You must set ESPHOME_IPADDRESS}"

# Environment variable for the Player event
player_event="${PLAYER_EVENT}"

# File to store the PID of the 'power-off-timer' background process
pid_file="/tmp/power_off_timer_pid"

# Log file path
log_file="/var/log/marantz_remote.log"

# Flag to enable/disable logging
LOGGING_ENABLED=false

###############################################################################
# Function: log
# Logs a message to $log_file, prefixed with a timestamp, if logging is enabled
###############################################################################
log() {
  if [[ "$LOGGING_ENABLED" == true ]]; then
    echo "[$(date +%F_%T)] $*" >> "$log_file"
  fi
}

###############################################################################
# Function: send_command
# Sends a curl request to the Marantz Remote with the given button command
###############################################################################
send_command() {
  local button="$1"
  log "Sending command: $button"
  curl -X POST "http://${ipaddress}/button/${button}/press"
}

###############################################################################
# Function: kill_power_off_timer
# Cleanly stops any running 'power-off-timer' process
###############################################################################
kill_power_off_timer() {
  if [[ -f "$pid_file" ]]; then
    old_pid=$(cat "$pid_file")
    # Check if the process is still running
    if kill -0 "$old_pid" 2>/dev/null; then
      log "Killing power-off-timer process with PID: $old_pid"
      kill "$old_pid"
    fi
    rm -f "$pid_file"
  fi
}

log "Script invoked with PLAYER_EVENT='${player_event}'"

###############################################################################
# Main event handling (case statement)
###############################################################################
case "$player_event" in

  session_connected)
    kill_power_off_timer
    log "Handling 'session_connected' event — sending power_on"
    send_command "power_on"
    ;;

  session_disconnected)
    kill_power_off_timer
    log "Handling 'session_disconnected' event — sending power_off"
    send_command "power_off"
    ;;

  playing)
    kill_power_off_timer
    log "Handling 'playing' event — sending mute_off"
    # In most cases, the Marantz amplifier stays powered on. 
    # Simply turning mute off allows audio playback to resume quickly.
    # However, if playback was paused for a long time, this script may have 
    # powered off the amplifier to save energy.
    # In that case, we need to power it back on. To avoid delaying librespot playback 
    # while waiting for the power_on command to complete, we trigger it in a non-blocking way. 
    # This ensures librespot can resume playback as quickly as possible in most cases.
    send_command "mute_off"

    # Non-blocking power_on
    log "Initiating non-blocking power_on"
    (
      send_command "power_on"
    ) &
    ;;

  paused)
    kill_power_off_timer
    log "Handling 'paused' event — sending mute_on"
    send_command "mute_on"

    # Start a background process that calls power_off after 30 seconds,
    # unless a new event interrupts it (kill_power_off_timer).
    log "Starting 30-second power-off-timer for power_off"
    (
      sleep 30
      # If this process has not been killed in the meantime, it will proceed:
      log "30-second timer expired — sending power_off"
      send_command "power_off"
    ) &
    echo $! > "$pid_file"
    log "Power-off-timer process started with PID: $!"
    ;;

esac