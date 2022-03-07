#!/bin/bash
echo "Content-type: text/plain"
echo
DIGITS=`echo $QUERY_STRING | tr -dc '[0-9]'`
echo $DIGITS
date -d "1970-01-01 GMT $DIGITS sec"
