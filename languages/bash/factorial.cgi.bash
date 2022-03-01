#!/bin/bash
echo "Content-type: text/plain"
echo
MAXIMUM=`wc -l ../factorials | grep -o "[0-9][0-9]*"`
NUMBER=`echo $QUERY_STRING | grep -o "[0-9][0-9]*"`
if [ -z "$NUMBER" ]; then
  echo Please supply a number between 0 and $MAXIMUM
  exit 0
fi
if [ "$NUMBER" -gt "$MAXIMUM" ] ; then
  echo Please try a number up to $MAXIMUM
  exit 0
fi
if [ "$NUMBER" -eq 0 ] ; then
  echo 1
  exit 0
fi
head -$QUERY_STRING ../factorials | tail -1
