#!/usr/bin/env bash

mydir="$(dirname "$0")/"
config_file="$mydir/../etc/config.json"

notificationtype="$1"
servicedesc="$2"
hostalias="$3"
hostaddress="$4"
servicestate="$5"
longdatetime="$6"
serviceoutput="$7"
contactemail="$8"

email_from="$(jq -r '.email_from' "$config_file")"

mail -s "** $notificationtype Service Alert: $hostalias/$servicedesc is $servicestate **" \
     -r "$email_from" "$contactemail" <<EOM
***** Nagios *****

Notification Type: $notificationtype

Service: $servicedesc
Host: $hostalias
Address: $hostaddress
State: $servicestate

Date/Time: $longdatetime

Additional Info:

$serviceoutput
EOM
