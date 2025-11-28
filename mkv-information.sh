#!/bin/bash

FILE="$1"

if [ -z "$FILE" ]; then
  echo "Please provide MKV filename as argument."
  exit 1
fi

ffprobe -v quiet -print_format json -show_format -show_streams "$FILE" | jq -r '
  "Duration:" + (
    (.format.duration | tonumber) as $d |
    ($d/60 | floor | tostring) + "m" +
    ($d%60 | floor | tostring) + "s"
  ),
  "Resolution:" + (
    (.streams[] | select(.codec_type=="video") | "\(.width)x\(.height)")
  ),
  "Frame Rate:" + (
    (.streams[] | select(.codec_type=="video") | 
      (.r_frame_rate | 
        split("/") | 
        (.[0] | tonumber) / (.[1] | tonumber) | 
        round | tostring
      ) + " fps"
    )
  ),
  "Bit Rate:" + (
    (.format.bit_rate | tonumber/1000 | floor | tostring) + " kbps"
  ),
  "Codec:" + (
    (.streams[] | select(.codec_type=="video") | .codec_name)
  ),
  "Audio Track Count:" + (
    ([.streams[] | select(.codec_type=="audio")] | length | tostring)
  ),
  "Audio Tracks:" + (
    ([.streams[] | select(.codec_type=="audio")] | 
      to_entries | 
      map(
        (.value.tags.title // "NoTitle") + "(" + ((.key + 1) | tostring) + ")"
      ) | join(", ")
    )
  ),
  "Audio Bit Rates:" + (
    ([.streams[] | select(.codec_type=="audio")] | 
      to_entries | 
      map(
        ((.value.bit_rate // "0") | tonumber/1000 | floor | tostring) + " kbps(" + ((.key + 1) | tostring) + ")"
      ) | join(", ")
    )
  ),
  "Audio Sample Rates:" + (
    ([.streams[] | select(.codec_type=="audio")] | 
      to_entries | 
      map(
        (.value.sample_rate // "0") + " Hz(" + ((.key + 1) | tostring) + ")"
      ) | join(", ")
    )
  ),
  "Subtitle Track Count:" + (
    ([.streams[] | select(.codec_type=="subtitle")] | length | tostring)
  ),
  "Subtitle Tracks:" + (
    ([.streams[] | select(.codec_type=="subtitle")] | 
      to_entries | 
      map(
        (.value.tags.title // "NoTitle") + "(" + ((.key + 1) | tostring) + ")"
      ) | join(", ")
    )
  )
'
