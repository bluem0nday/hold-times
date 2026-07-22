#!/bin/bash
# Emits the paste-ready hold-times block.
# The opening and closing lines are hardcoded here on purpose:
# the model formats slot lines, but it cannot drop the frame.

if [ "$#" -eq 0 ]; then
  echo "usage: make-times-block.sh 'Fri, 7/24 at 8:30 AM PT (11:30 AM ET)' ..." >&2
  exit 1
fi

printf "Holding these times for a call. If one works, I'll send an invite.\n\n"
for line in "$@"; do
  printf '%s\n' "$line"
done
printf "\nOr propose a time that works better for you.\n"
