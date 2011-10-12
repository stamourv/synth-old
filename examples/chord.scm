(load "sequencer.scm")
;; chords, described explicitly in the sequencing pattern
(signal->wavfile (sequence 1 '((C 3 1)
			       (((C 3) (E 3)) #f 1)
			       (((C 3) (E 3) (G 3)) #f 1))
			   90 sine-wave))
