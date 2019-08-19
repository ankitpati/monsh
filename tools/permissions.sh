#!/usr/bin/env bash

mydir="$(dirname "$0")/"
target_directory="$mydir/../"

find "$target_directory" -type d                  -exec chmod 755 {} +
find "$target_directory" -type f      -executable -exec chmod 755 {} +
find "$target_directory" -type f -not -executable -exec chmod 644 {} +
