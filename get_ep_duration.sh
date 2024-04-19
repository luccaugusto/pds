#!/bin/sh

[ "$1" ] || ( echo "usage: $0 <file>" && exit )

echo "bytes_length: $(wc -c "$1" | cut -d ' ' -f 1)"
echo "duration: $(ffmpeg -i "$1" 2>&1 | grep 'Duration' | cut -d ' ' -f 4 | sed s/\.[0-9]*,//)"
