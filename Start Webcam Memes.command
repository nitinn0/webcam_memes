#!/bin/bash
# Launch Webcam Memes into OBS Virtual Camera for Teams and Google Meet.
set -euo pipefail
cd "$(dirname "$0")"

PY="./.venv/bin/python"
if [[ ! -x "$PY" ]]; then
  echo "Webcam Memes' Python environment is missing."
  echo "Expected: $(pwd)/.venv"
  exit 1
fi

if pgrep -xq OBS; then
  echo "Quit OBS Studio first."
  echo "Webcam Memes feeds OBS Virtual Camera itself. If OBS is also running its virtual camera, Meet and Teams see the OBS scene instead."
  exit 1
fi

if pgrep -f 'vanish_cam.py' >/dev/null; then
  echo "Stopping VanishCam. This Mac has one virtual camera, so only one effect can use it."
  pkill -f 'vanish_cam.py' || true
  sleep 1
fi

ext_line="$(systemextensionsctl list 2>/dev/null | grep 'com.obsproject.obs-studio.mac-camera-extension' || true)"
if [[ -z "$ext_line" ]]; then
  echo "OBS Virtual Camera is not installed yet."
  echo "Opening OBS. Click Start Virtual Camera, allow the camera extension, then quit OBS and run this again."
  open -a OBS
  exit 1
fi

if grep -q "waiting for user" <<<"$ext_line"; then
  echo "macOS still needs you to allow OBS Virtual Camera."
  echo "In System Settings → General → Login Items & Extensions → Camera Extensions, turn OBS Virtual Camera on."
  echo "Then double-click this file again."
  open "x-apple.systempreferences:com.apple.LoginItems-Settings.extension" || true
  exit 1
fi

echo "Webcam Memes is starting."
echo "In Teams or Google Meet, choose the camera named: OBS Virtual Camera"
echo "Pick Meme Webcam, Gojo Webcam, or Sukuna Webcam. Q quits."
echo

exec "$PY" run3.py "$@"
