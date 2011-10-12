#!/bin/bash

if [ $# != 1 ]; then
    echo 'usage: ./play.sh <program>'
    exit 0
fi

# generates, then plays when asked, uses the file name tmp.wav
./synth.sh $1 tmp.wav && echo ok && read && aplay -f cd tmp.wav
