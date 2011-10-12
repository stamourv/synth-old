(load "sequencer.scm")
;; same example as sine.scm, but with a weigthed sum of harmonics instead of a
;; sine wave. the fundamental has weight 4, the first harmonic 2, the second 1
;; sounds a bit like an organ
(signal->wavfile (sequence 2 '((A 3 1) (G 3 1) (F 3 2)) 60
			   (weighted-harmonics sine-wave '(4 2 1))))
