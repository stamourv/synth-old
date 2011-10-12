(load "sequencer.scm")
;; simple drum track
;; WARNING: drums take a _very_ long time to generate
(signal->wavfile (drum 2 '(O X O X #f #f O X) 90))
