(load "sequencer.scm")
;; ascending major C scale
(signal->wavfile (sequence 2 (scale 'C 3 1 'major) 120 sine-wave))
