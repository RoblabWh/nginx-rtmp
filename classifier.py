#!/usr/bin/env python3
# from: https://mmdetection.readthedocs.io/en/latest/1_exist_data_model.html

import argparse

from mmdet.apis import init_detector, inference_detector
from cv2 import VideoCapture
from subprocess import Popen, PIPE

parser = argparse.ArgumentParser(description='Inference for MMDetection')
parser.add_argument('--input', help='Input media', required=True)
parser.add_argument('--output', help='Output media')
parser.add_argument('--config', help='Config file for MMDetection (yolo)', required=True)
parser.add_argument('--checkpoint', help='Checkpoint file for MMDetection (yolo)', required=True)
parser.add_argument('--score_thr', default=0.1, help='Threshold for BBox Detection')
parser.add_argument('--batch_size', default=1, help='Batch size for Model')
args = parser.parse_args()

# build the model from a config file and a checkpoint file
model = init_detector(args.config, args.checkpoint, device='cuda:0')

# open input
reader = VideoCapture(args.input)
if not reader.isOpened():
	print("Couldn't open input.")
	exit(1)
ret, img_in = reader.read()

# open output
ffmpeg_cmd = ["ffmpeg",
				"-f", "rawvideo",
				"-vcodec", "rawvideo",
				"-pix_fmt", "bgr24",
				"-s", "{}x{}".format(img_in.shape[1], img_in.shape[0]),
				"-i", "-",
				"-c:v", "libx264",
				"-pix_fmt", "yuv420p",
				"-preset", "ultrafast",
				"-f", "flv",
				args.output]
streamer = Popen(ffmpeg_cmd, stdin=PIPE)

# run detection on input and send on output
while ret:
	result = inference_detector(model, img_in)
	img_out = model.show_result(img_in, result)
	streamer.stdin.write(img_out.tobytes())

	ret, img_in = reader.read()
