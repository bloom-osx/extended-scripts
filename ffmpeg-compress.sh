#!/bin/bash

input_file="$1"

filename="${input_file%.*}"
extension="${input_file##*.}"
output_file="${filename}.compressed.${extension}"

ffmpeg -i "$input_file" -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k "$output_file"
