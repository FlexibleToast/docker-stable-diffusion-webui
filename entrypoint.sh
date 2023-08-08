#!/bin/bash

set -eu
changed=false

# Check if PUID needs to be updated for sduser
current_puid=$(id -u sduser)
if [[ $current_puid != $PUID ]]; then
  usermod -u "$PUID" sduser
  changed=true
fi

# Check if PGID needs to be updated for sdgroup
current_pgid=$(getent group sdgroup | cut -d: -f3)
if [[ $current_pgid != $PGID ]]; then
  groupmod -g "$PGID" sdgroup
  changed=true
fi

if [[ $changed == true ]]; then
  find /app -mount -exec chown sduser:sdgroup {} \;
fi

# Run webui.sh as the sduser
exec gosu sduser /app/stable-diffusion-webui/webui.sh "$@"
