(load "sequencer.scm")
;; simple drum track
;; WARNING: drums take a _very_ long time to generate
(signal->wavfile (drum 8 '(O X #f) 90))
