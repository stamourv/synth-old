(load "sequencer.scm")
;; ascending minor harmonic E scale
(signal->wavfile (sequence 1 (scale 'E 3 1 'minor-harmonic) 120 sine-wave))
