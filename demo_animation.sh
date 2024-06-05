mkdir demo_animation

for angle in $(seq 0 359); do
    # Angle with three digits, e.g. angle="1" → angleNNN="001"
    angleNNN=$(printf "%03d" $angle)
    ./project demo --angle=$angle demo_animation/img$angleNNN.pfm demo_animation/img$angleNNN.png
done

# -r 25: Number of frames per second
ffmpeg -r 25 -f image2 -s 640x480 -i demo_animation/img%03d.png \
    -vcodec libx264 -pix_fmt yuv420p \
    spheres-perspective.mp4