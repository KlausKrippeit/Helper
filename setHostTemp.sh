#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <temperature_value>"
  exit 1
fi

FHEM_URL="http://fhem/fhem"
FHEM_USER=""
FHEM_PASS=""
DEVICE_NAME="TempHost"
READING_NAME="temperature1"
COOKIE_FILE="fhem_cookies.txt"
NEW_VALUE="$1"
curl_args=(
  -s -S
  --cookie-jar "$COOKIE_FILE"
  --cookie "$COOKIE_FILE"
  -A "Mozilla/5.0"
)
if [[ -n "$FHEM_USER" && -n "$FHEM_PASS" ]]; then
  curl_args+=(-u "$FHEM_USER:$FHEM_PASS")
fi
response=$(curl "${curl_args[@]}" "$FHEM_URL")
csrf_token=$(echo "$response" | grep -oP 'name="fwcsrf" value="\K[^"]+' || echo "")

if [ -z "$csrf_token" ]; then
  echo "Fehler: Kein CSRF-Token gefunden."
  exit 1
fi

curl_args+=(
  -d "fwcsrf=$csrf_token"
  -d "cmd=set $DEVICE_NAME $READING_NAME $NEW_VALUE"
)

api_response=$(curl "${curl_args[@]}" "$FHEM_URL")
