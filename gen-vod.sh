#!/bin/sh

HTMLFILE='/srv/videos.html'
HTMLFILENEW='/tmp/videos.html'

FILES=$(find /vod -iname *.flv | sort)


printf "<!DOCTYPE html>
<html>
<head>
  <title>Video on Demand</title>
  <style>
    table, th, td {
    border: 1px solid black;
    border-collapse: collapse;
    }
    th, td {
    text-align: left;
    padding: 4px;
    }
  </style>
</head>
<h2>Video on Demand</h2>
<table>
  <tr>
    <th>File</th>
    <th>Time</th>
    <th>Date</th>
  </tr>" > "$HTMLFILENEW"

for i in $FILES; do
  STAMP=${i##*_}
  STAMP=${STAMP%.*}
  DATE=$(date -d $STAMP +'%d.%m.%Y')
  TIME=$(date -d $STAMP +'%R')
  printf "
  <tr>
    <td><a href="$i">${i##/vod/}</a></td>
    <td>$TIME</td>
    <td>$DATE</td>
  </tr>" >> "$HTMLFILENEW"
done

printf "
</table>
</html>" >> "$HTMLFILENEW"

mv "$HTMLFILENEW" "$HTMLFILE"
