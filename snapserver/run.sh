#!/bin/bash
set -xeuo pipefail

# Change snapserver source to Spotify only if no custom configuration is mounted
credentials=""
if [[ -n "${USERNAME:-}" ]] && [[ -n "${PASSWORD:-}" ]]; then
  credentials="\&username=$USERNAME\&password=$PASSWORD"
elif [[ -n "${CACHE:-}" ]]; then
  credentials="\&cache=$CACHE"
fi

sed -i "s,^source = .*,source = librespot:///librespot?name=Spotify\&devicename=$DEVICE_NAME\&bitrate=320\&onevent=/eventhandler.sh\&emit-sink-events\&volume=80$credentials," /etc/snapserver.conf


exec snapserver -c /etc/snapserver.conf
