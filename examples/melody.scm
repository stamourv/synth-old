(load "sequencer.scm")
;; melody + chord background
(signal->wavfile (dub (list (sequence 1 (list (chord 'C 3 3 'major-arpeggio)
					      (chord 'D 3 3 'major-arpeggio))
				      60 sine-wave) 1)
		      (list (sequence 1 '((C 4 1) (D 4 1) (E 4 1) (G 4 1)
					  (E 4 1) (C 4 1))
				      60 square-wave) 3)))
