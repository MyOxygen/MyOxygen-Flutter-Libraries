#!/bin/bash

# We need one parameter, which should be the single library name.
if [ -z "$1" ]; then
    exit 1;
fi

cd "$1/"
flutter packages get
flutter analyze
flutter test
