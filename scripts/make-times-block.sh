#!/bin/bash
# Emits the paste-ready hold-times block.
# The opening and closing lines are hardcoded here on purpose:
# the model formats slot lines, but it cannot drop the frame.
#
# Slots print in date and time order. A day with one slot prints on
# one line as given ("Fri, 11/6 at 1:00 PM ET"). A day with two or
# more gets a label line ("Fri, 11/6") with its times tucked under,
# day dropped, and a blank line sets that group off from its
# neighbors. Back-to-back one-slot days sit together.

if [ "$#" -eq 0 ]; then
  echo "usage: make-times-block.sh 'Fri, 7/24 at 8:30 AM PT (11:30 AM ET)' ..." >&2
  exit 1
fi

slots=$(printf '%s\n' "$@" | awk '
  {
    at = index($0, " at ")
    day = substr($0, 1, at - 1)
    time = substr($0, at + 4)
    if (!at || day !~ /^[A-Z][a-z][a-z], [0-9][0-9]?\/[0-9][0-9]?$/ ||
        time !~ /^[0-9][0-9]?:[0-9][0-9] [AP]M/) {
      print "make-times-block.sh: not a slot line: " $0 > "/dev/stderr"
      bad = 1
      exit 1
    }
    split(substr(day, 6), md, "/")
    split(time, hm, "[: ]")
    n++
    line[n] = $0; label[n] = day; slot[n] = time
    month[n] = md[1] + 0; date[n] = md[2] + 0
    mins[n] = (hm[1] % 12 + (hm[3] == "PM" ? 12 : 0)) * 60 + hm[2]
    if (n == 1 || month[n] < lo) lo = month[n]
    if (n == 1 || month[n] > hi) hi = month[n]
  }
  END {
    if (bad) exit 1
    for (i = 1; i <= n; i++) {
      # A window that crosses New Year puts January after December.
      m = month[i]
      if (hi - lo > 6 && m < 7) m += 12
      key[i] = ((m * 32 + date[i]) * 1440 + mins[i]) * 1000 + i
      count[label[i]]++
    }
    for (i = 1; i <= n; i++) order[i] = i
    for (i = 2; i <= n; i++) {
      j = i
      while (j > 1 && key[order[j - 1]] > key[order[j]]) {
        t = order[j]; order[j] = order[j - 1]; order[j - 1] = t
        j--
      }
    }
    for (k = 1; k <= n; k++) {
      i = order[k]
      multi = count[label[i]] > 1
      if (label[i] != last) {
        if (k > 1 && (multi || lastmulti)) print ""
        if (multi) print label[i]
        last = label[i]; lastmulti = multi
      }
      print (multi ? slot[i] : line[i])
    }
  }
') || exit 1

printf "Holding these times for a chat. If one works, I'll send an invite.\n\n"
printf '%s\n' "$slots"
printf "\nOr propose a time that works better for you.\n"
