if [ "$1" == "" ]; then
    echo "Usage: $(basename $0) FILENAME"
    exit 1
fi

readonly filename="$1"

# -r 25: Number of frames per second
ffmpeg -r 25 -f image2 -s 640x480 -i image%03d.png \
    -vcodec libx264 -pix_fmt yuv420p \
    $filename.mp4