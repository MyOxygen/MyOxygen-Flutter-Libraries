#!/bin/bash

# This Bash script runs through each library's commit hash, and compares it to 
# the HEAD commit hash (the latest commit). For each library, if the commit hash
# matches that of HEAD, it means that the library recently went through changes,
# and test and analysis must be done.
# 
# It is important to note that a change in the root repository folder (for 
# example, to the main ReadMe file), all the library commit hashes will update 
# to the latest HEAD hash. This will cause all the libraries to be tested and 
# analysed.

# Get the latest commit hash
LATEST_COMMIT=$(git rev-parse HEAD)

# Declare the list of libraries to test and analyze.
declare -a libraries=(
    "database_provider"
    "do_on_build"
    "infinite_scroll_view"
    "media_downloader"
    "quickdialogs"
    "store"
    "rest_api"
    "unfocus_handler"
    )

for i in "${libraries[@]}" ; do
    LIBRARY_COMMIT=$(git log -1 --format=format:%H --full-diff $i)
    
    # Check which of the libraries was changed. Test and analyze each library 
    # whose commit hash matches that of HEAD.
    if [ $LIBRARY_COMMIT = $LATEST_COMMIT ]; then
        echo "Detected changes or modifications in the \"$i\" library."
        bash .circleci/test_and_analyze_library.sh "$i"
    fi
done

# Returns success.
exit 0;
