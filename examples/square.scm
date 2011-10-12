(load "sequencer.scm")
;; same example as sine.scm and harmonics.scm, but with a square wave
(signal->wavfile (sequence 2 '((A 3 1) (G 3 1) (F 3 2)) 120 square-wave))
