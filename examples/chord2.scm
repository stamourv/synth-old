(load "sequencer.scm")
;; I-IV-V chord progression, using the chord generator
(signal->wavfile (sequence 1 (list (chord 'C 3 2 'major-arpeggio)
				   (chord 'F 3 2 'major-arpeggio)
				   (chord 'G 3 2 'major-arpeggio))
			   90 sine-wave))
