(load "sequencer.scm")
;; mixer example, where both tracks have the same weight
(signal->wavfile (dub (list (sequence 1 '((C 3 2) (E 3 2))
				      60 sine-wave) 1)
		      (list (sequence 1 '((E 3 1) (G 3 1) (F 3 1) (A 3 1))
				      60 sine-wave) 1)))
