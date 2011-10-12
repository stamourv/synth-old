(load "sequencer.scm")
;; sine wave example with a pause in the middle
(signal->wavfile (sequence 4 '((C 3 1) (#f #f 1) (E 3 1)) 120 sine-wave))
