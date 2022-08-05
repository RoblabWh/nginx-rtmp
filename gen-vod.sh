#!/bin/sh

HTMLFILE='/srv/videos.html'
HTMLFILENEW='/tmp/videos.html'

# create folder if not mounted
if ! [ -d /vod ]; then mkdir /vod; fi

# convert .flv recording tp .mp4
[ -f "/tmp/$1.flv" ] && ffmpeg -i "/tmp/$1.flv" -c copy -f mp4 "/vod/$1.mp4"

# generate html with videojs player
gen_player()
{
  if [ -f "/srv/$1.html" ]; then return; fi
  printf "<!DOCTYPE html>
  <html>
  <head>
    <title>$1</title>
    <link href=\"https://vjs.zencdn.net/7.20.1/video-js.css\" rel=\"stylesheet\" />
  </head>
  <body style=\"margin:0;\">
    <video style=\"width:100vw;height:100vh;\" class=\"video-js\" controls autoplay muted preload=\"auto\" data-setup=\"{}\">
        <source src=\"/vod/$1.mp4\" type=\"video/mp4\" />
        <p class=\"vjs-no-js\">
            To view this video please enable JavaScript, and consider upgrading to a
            web browser that
            <a href=\"https://videojs.com/html5-video-support/\" target=\"_blank\">supports HTML5 video</a>
        </p>
    </video>
    <script src=\"https://vjs.zencdn.net/7.20.1/video.min.js\"></script>
  </body>
  </html>" > "/srv/$1.html"
}

# search vods
FILES=$(find /vod -iname *.mp4 | sort)

# generate html
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
    <th>View</th>
    <th>Download</th>
    <th>Time</th>
    <th>Date</th>
  </tr>" > "$HTMLFILENEW"

for i in $FILES; do
  STAMP=${i##*_}
  STAMP=${STAMP%.*}
  DATE=$(date -d $STAMP +'%d.%m.%Y')
  TIME=$(date -d $STAMP +'%R')
  FILE=${i##/vod/}
  BASE=${FILE%.*}
  gen_player $BASE
  printf "
  <tr>
    <td>${FILE}</td>
    <td><a href=\"/$BASE.html\">view</a></td>
    <td><a href=\"$i\" download>download</a></td>
    <td>$TIME</td>
    <td>$DATE</td>
  </tr>" >> "$HTMLFILENEW"
done

printf "
</table>
</html>" >> "$HTMLFILENEW"

# update online version
mv "$HTMLFILENEW" "$HTMLFILE"
