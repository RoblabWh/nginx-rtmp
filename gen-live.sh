#!/bin/sh

HTMLFILE='/srv/streams.html'
HTMLFILENEW='/tmp/streams.html'
LIVEFILE='/tmp/livestreams'

# generate html with videojs player
gen_player()
{
  if [ -f "/srv/$1-$2.html" ]; then return; fi
  printf "<!DOCTYPE html>
  <html>
  <head>
    <title>$1 $2</title>
    <link href=\"https://vjs.zencdn.net/7.20.1/video-js.css\" rel=\"stylesheet\" />
  </head>
  <body style=\"margin:0;\">
    <video style=\"width:100vw;height:100vh;\" class=\"video-js\" controls autoplay muted preload=\"auto\" data-setup=\"{}\">
        <source src=\"/$2/$1\" type=\"application/vnd.apple.mpegurl\" />
        <p class=\"vjs-no-js\">
            To view this video please enable JavaScript, and consider upgrading to a
            web browser that
            <a href=\"https://videojs.com/html5-video-support/\" target=\"_blank\">supports HTML5 video</a>
        </p>
    </video>
    <script src=\"https://vjs.zencdn.net/7.20.1/video.min.js\"></script>
  </body>
  </html>" > "/srv/$1-$2.html"
}

gen_html()
{
  STREAMS=$(cat "$LIVEFILE" 2>/dev/null)

  printf "<!DOCTYPE html>
  <html>
  <head>
    <title>Livestreams</title>
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
  <h2>Livestreams</h2>
  <table>
    <tr>
      <th>Stream</th>
      <th>Full Resolution</th>
      <th>480p Resolution</th>
      <th>Full Resolution Detection</th>
      <th>480p Resolution Detection</th>
    </tr>" > "$HTMLFILENEW"

  for i in $STREAMS; do
    gen_player "$i" "live"
    gen_player "$i" "lowres"
    gen_player "$i" "detection"
    gen_player "$i" "detection-lowres"
    printf "
    <tr>
      <td>$i</td>
      <td><a href=\"/$i-live.html\">view</a></td>
      <td><a href=\"/$i-lowres.html\">view</a></td>
      <td><a href=\"/$i-detection.html\">view</a></td>
      <td><a href=\"/$i-detection-lowres.html\">view</a></td>
    </tr>" >> "$HTMLFILENEW"
  done

  printf "
  </table>
  </html>" >> "$HTMLFILENEW"
  mv "$HTMLFILENEW" "$HTMLFILE"
}

# handle input
if [ "$#" = "0" ]; then
  gen_html
elif [ "$1" = '+' ]; then
  printf "$2\n" >> "$LIVEFILE"
  sort -o "$LIVEFILE" "$LIVEFILE"
  gen_html
elif [ "$1" = '-' ]; then
  STREAMS=$(cat "$LIVEFILE")
  echo "$2"
  echo "$STREAMS" | grep -Fxv "$2" > "$LIVEFILE"
  gen_html
else
  printf "invalid operation '$1'\n"
  exit 1
fi
