# Installation
```
docker build -t nginx-rtmp:mmdet .
```
# Running
Run server on native ports and with the option to store vods permanently on the host and option to run MMDetection
```
nvidia-docker run --rm --net=host [-v /PATH/TO/VOD:/vod] [-v /PATH/TO/MMDET_CONFIG:/config.py:ro -v /PATH/TO/MMDET_CHECKPOINT:/checkpoint.pth:ro] nginx-rtmp
```
Run server with port mapping and permanent vod option
```
docker run --rm -p [HOST_IP:]HOST_PORT:80 -p [HOST_IP:]HOST_PORT:1935 [-v /PATH/TO/VOD:/vod] nginx-rtmp
```