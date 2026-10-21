#!/bin/sh
# Generates the original "Signal Drift" demo episodes into ./media (needs ffmpeg with libx264 and libvpx).
set -e
cd "$(dirname "$0")"
mkdir -p media
i=1
for spec in "mandelbrot=size=640x360:rate=24|440" "gradients=size=640x360:rate=24:speed=0.03:nb_colors=4|330" "life=size=640x360:rate=24:mold=10:ratio=0.1:death_color=#102040:life_color=#ffb347,scale=640:360:flags=neighbor|523"; do
  src=${spec%|*}; f=${spec#*|}
  ffmpeg -loglevel error -y -f lavfi -i "$src" -f lavfi -i "sine=frequency=$f:sample_rate=44100" -t 20 -pix_fmt yuv420p -c:v libvpx -b:v 600k -deadline realtime -cpu-used 8 -c:a libvorbis -shortest media/ep$i.webm
  ffmpeg -loglevel error -y -f lavfi -i "$src" -f lavfi -i "sine=frequency=$f:sample_rate=44100" -t 20 -pix_fmt yuv420p -c:v libx264 -preset veryfast -c:a aac -shortest -movflags +faststart media/ep$i.mp4
  i=$((i+1))
done
