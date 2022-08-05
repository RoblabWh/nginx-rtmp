# Installation
```
docker build -t nginx-rtmp .
```
# Running
Run server on native ports and with the option to store vods permanently on the host
```
docker run --rm --net=host [-v /PATH/TO/VOD:/vod] nginx-rtmp
```
Run server with port mapping and permanent vod option
```
docker run --rm -p [HOST_IP:]HOST_PORT:80 -p [HOST_IP:]HOST_PORT:1935 [-v /PATH/TO/VOD:/vod] nginx-rtmp
```