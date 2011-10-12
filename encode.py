import sys
import string
import scipy.io.wavfile as S
import numpy as N

# takes a signal from stdin (one sample (0-65525) by line) and encodes it in
# a wav file

# wav file
filename = sys.argv[1]
fs = 44100

data = sys.stdin.readlines()

# strip newlines and convert to int
data = map (lambda x: string.atoi(x[:-1]), data)

data = N.array(data)
data = data.astype(N.int16)

S.write(filename, fs, data) # TODO resulting file seems to be at 8khz, weird
