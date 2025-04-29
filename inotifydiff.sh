#!/usr/bin/env bash
# Hook into inotify to watch a file, and generate diffs for changes in real-time
#
# Requires inotify-tools (apt-get install inotify-tools)
#
# @author Filipe Dobreira <filipe.dobreira@ez.no>
#
# Edited by Behzad <be4zad@tuta.io>
# Originally copied from https://gist.github.com/fdob/5983637 with some changes

usage() {
  echo "Usage:"
  echo "  in-diff <file>|help"

  exit 1
}

# check arguments:
if [ "$1" == "" ] || [ ! -f "$1" ] || [ "$1" == "help" ]; then
  usage
fi

# check dependencies:
command -v inotifywait >/dev/null 2>&1 || { echo >&2 "inotifywait(1) not available, please install inotify-tools"; exit 1; }

FILE="$1"
SNAP=$(mktemp)

# copy the initial snapshot to a temp file
cp "$FILE" "$SNAP"

watch () {
  # start an inotifywatch loop:
  while _=$(inotifywait -q -e modify "$FILE"); do	
    date +"%Y-%m-%d %H:%M:%S"
    diff --color --text "$SNAP" "$FILE" -d
    cp "$FILE" "$SNAP"
    echo
  done
}

# Keep watching for changes, even if the file is deleted.
while true; do
  if [ ! -f "$FILE" ]; then
    echo "" > "$SNAP"
  else
    watch
  fi
done
