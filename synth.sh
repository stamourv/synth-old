#!/bin/bash

if [ $# != 2 ]; then
    echo 'usage: ./synth.sh <program> <outfile>'
    exit 0
fi

gsi $1 | python encode.py $2
