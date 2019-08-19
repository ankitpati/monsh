#!/usr/bin/env bash

mydir="$(dirname "$0")/"
config_file="$mydir/../etc/config.json"

servicedesc="$1"
serviceoutput="$2"
servicestate="$3"

slack_url="$(jq -r '.slack_url' "$config_file")"
slack_channel="$(jq -r '.slack_channel' "$config_file")"

webhook_message='payload={
    "channel": "'"$slack_channel"'",
    "attachments": [
        {
            "color": "%s",
            "author_name": "%s",
            "text": "%s"
        }
    ]
}
'

case "$servicestate" in
    'OK') slack_color='good' ;;
    'WARNING') slack_color='warning' ;;
    'CRITICAL') slack_color='danger' ;;
    'UNKNOWN') slack_color='#0000ff' ;;
esac

curl -X POST --data-urlencode "$(printf "$webhook_message" "$slack_color" \
    "$servicedesc" "$serviceoutput")" "$slack_url"
