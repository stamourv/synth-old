(load "sequencer.scm")
;; simple sine wave example, plays A3 G3 F3 twice at 60 BPM, with F3 twice as
;; long as the others
(signal->wavfile (sequence 2 '((A 3 1) (G 3 1) (F 3 2)) 60 sine-wave))
