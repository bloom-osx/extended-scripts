#!/bin/bash

# List the metadata attributes for the selected files.
# It’s better to add this as an action, since the output is a bit tricky and Bloom cannot handle it properly.
# Also, make sure the output option is set to "Full Output," so that when the script finishes, Bloom will create a new window to display the output.
mdls "$@"
