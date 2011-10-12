(load "sequencer.scm")
;; another mixer example, the second track is 5 times louder than the first
(signal->wavfile (dub (list (sequence 1 '((G 3 2) (E 3 2)) 60 sine-wave) 1)
		      (list (sequence 1 '((A 4 1) (F 4 1) (#f #f 1) (A 3 1))
				      60 sine-wave) 5)))
