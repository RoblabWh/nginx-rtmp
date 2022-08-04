#!/bin/sh

HTMLFILE='/srv/streams.html'
HTMLFILENEW='/tmp/streams.html'
LIVEFILE='/tmp/livestreams'

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
    </tr>" > "$HTMLFILENEW"

  for i in $STREAMS; do
    printf "
    <tr>
      <td>$i</td>
      <td><a href=\"/live/$i\">/live/$i</a></td>
      <td><a href=\"/lowres/$i\">/lowres/$i</a></td>
    </tr>" >> "$HTMLFILENEW"
  done

  printf "
  </table>
  </html>" >> "$HTMLFILENEW"
  mv "$HTMLFILENEW" "$HTMLFILE"
}

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
