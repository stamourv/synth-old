(load "sequencer.scm")
;; same examples as sine.scm, harmonics.scm and square.scm, but with a
;; sawtooth wave
(signal->wavfile (sequence 2 '((A 3 1) (G 3 1) (F 3 2)) 120 sawtooth-wave))
