#!/bin/bash

file="$1"

if [[ -f "$file" ]]; then
    word_count=$(wc -w < "$file")
    line_count=$(wc -l < "$file")
    echo "Word Count: $word_count"
    echo "Line Count: $line_count"
else
    echo "File not found: $file"
fi
