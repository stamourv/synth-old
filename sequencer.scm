(load "utilities.scm")

(random-source-randomize! default-random-source)

;; for octave 0 (A4 is 440)
;; found at http://www.phy.mtu.edu/~suits/notefreqs.html
(define notes-frequencies
  '((C  . 16.35)
    (C# . 17.32)
    (D  . 18.35)
    (D# . 19.45)
    (E  . 20.60)
    (F  . 21.83)
    (F# . 23.12)
    (G  . 24.50)
    (G# . 25.96)
    (A  . 27.50)
    (A# . 29.14)
    (B  . 30.87)))

(define (get-note-frequency note octave)
  (define (normalize note)
    (case note
      ((Bb) 'A#)
      ((Db) 'C#)
      ((Eb) 'D#)
      ((Gb) 'F#)
      ((Ab) 'G#)
      (else note)))
  (* (expt 2 octave)
     (cdr (assq (normalize note)
		notes-frequencies))))

(define pi 3.14159)
;; (define fs 44100)
(define fs 22050) ;; TODO somewhere, it seems I multiply that, since in python, I encode in 44k, and it's twice as slow as it should be

;; function generation
(define (sine-wave freq)
  (let ((f (/ (* freq 2 pi) fs)))
    (lambda (x)
      (sin (* f x)))))

;; takes a generator function and a set of weights and returns a function that
;; operates as a generator which generated the weighted sum of harmonics
(define (weighted-harmonics func carrier)
  (lambda (fund)
    ;; a list of generators whose result is multiplied by weights
    ;; (map (lambda (w) )
    ;;  weights)
    (let ((harmonics-weights
	   (let loop ((weights carrier)
		      (l       '())
		      (freq    fund))
	     (if (null? weights)
		 l
		 (loop (cdr weights)
		       (let ((new-func (func freq)))
			 (cons (lambda (x) (* (car weights) (new-func x))) l))
		       (* freq 2))))))
      (lambda (x)
	(foldl (lambda (y f) (+ y (f x)))
	       0
	       harmonics-weights)))))

(define (generate-harmonics n test)
  ;; the test can be used to keep only certain harmonics (i.e. the odd ones)
  (let loop ((n       n)
	     (divisor 1)
	     (l       '()))
    (if (= n 0)
	(reverse l)
	(loop (- n 1)
	      (+ divisor 1)
	      (cons (if (test divisor) (/ 1 divisor) 0) l)))))
(define n-harmonics 11) ; more precision bring longer synthesis times
(define square-wave
  ;; sum of the odd harmonics
  ;; could have been generated in a more strightforward way (by simply putting
  ;; -1 and 1), but where's the fun in that
  (weighted-harmonics sine-wave (generate-harmonics n-harmonics odd?)))

(define sawtooth-wave
  ;; once again, could have been done directly, but that's cheating
  (lambda (freq)
    ;; this generates an inverse sawtooth
    (let ((f ((weighted-harmonics sine-wave
				 (generate-harmonics n-harmonics
						     (lambda (x) #t)))
	      freq)))
      (lambda (x)
	(- (f x))))))


;; generates a scale of the given type (major, minor, ...) starting at root
;; the starting ocatve and duration of each note should also be given
;; custom scales can also be generated y giving the list of semitones
(define (scale root octave duration type . notes)
  (define semitones
    ;; matching between semitones from C and note names
    '((0  . C)
      (1  . C#)
      (2  . D)
      (3  . D#)
      (4  . E)
      (5  . F)
      (6  . F#)
      (7  . G)
      (8  . G#)
      (9  . A)
      (10 . A#)
      (11 . B)))
  (define (note->semitone note) (car (inv-assq note semitones)))
  (define (semitone->note semitone) (cdr (assq semitone semitones)))
  (define (semitone->note+octave semitone)
    (cons (semitone->note (modulo semitone 12))
	  (+ octave (floor (/ semitone 12)))))
  (define (add-semitone n) ; returns root + n
    (let ((note (semitone->note+octave (+ n (note->semitone root)))))
      (list (car note) (cdr note) duration)))
  (map add-semitone
       (case type
	 ((major ionian) '(0 2 4 5 7 9 11 12))
	 ((minor aeolian) '(0 2 3 5 7 8 10 12)) ; natural minor
	 ((minor-harmonic mohammedan) '(0 2 3 5 7 8 11 12))
	 ((minor-melodic) '(0 2 3 5 7 9 11 12))
	 ;; different from the reverse of minor melodic
	 ((minor-melodic-descending) '(12 10 8 7 5 3 2 0))
	 ((dorian) '(0 2 3 5 7 9 10 12))
	 ((phrygian) '(0 1 3 5 7 8 10 12))
	 ((lydian) '(0 2 4 6 7 9 11 12))
	 ((mixolydian) '(0 2 4 5 7 9 10 12))
	 ((locrian) '(0 1 3 5 6 8 10 12))
	 ((major-arpeggio) '(0 4 7))
	 ((minor-arpeggio) '(0 3 7))
	 ((custom) notes))))

;; similar to scale, except that it generates a chord
(define (chord root octave duration type . notes)
  (let ((notes (apply scale `(,root ,octave ,duration ,type ,@notes))))
    (list (map (lambda (x) `(,(car x) ,(cadr x))) notes)
	  #f
	  duration)))

;; repeats n times the sequence encoded by the pattern, at tempo bpm
(define (sequence n pattern tempo function)
  ;; notes are represented by a list (note octave duration)
  ;; duration is in beats
  ;; ex : '(A 3 1)
  ;; pauses are represented as (#f #f duration)
  ;; chords can also be represented in patterns, in which case a list of notes
  ;; is found instead of a note
  ;; ex : '(((C 3) (E 3) (G 3)) #f 1)
  ;;  would give a major C chord on octave 3 of duration 1

  ;; simple preprocessing, if we have chords in the pattern, each note must be
  ;; a chord (to solve normalization issues)
  (if (foldl (lambda (x y) (or x (list? (car y))))
	     #f
	     pattern)
      (set! pattern (map (lambda (x)
			   (if (list? (car x))
			       x
			       `(((,(car  x) ,(cadr x)))
				 #f
				 ,(caddr x)))) ; construct a 1-note chord
			 pattern)))
  
  (let ((samples-per-beat (/ (* fs 60) tempo)))
    (repeat n
	    (foldl
	     append '()
	     (map (lambda (note)
		    (if (list? (car note)) ; chord
			(apply dub
			       (map (lambda (x)
				      (list (sequence
					      1
					      `((,(car x) ; note
						 ,(cadr x) ; octave
						 ,(caddr note))) ; duration
					       tempo function)
					    1)) ; all of equal weight
				    (car note)))
			(let ((f (if (car note)
				     (function (get-note-frequency (car note)
								   (cadr note)))
				     (lambda (x) 0)))) ; pause
			  (build-list (* samples-per-beat (caddr note)) f))))
		  pattern)))))

;; limited drum machine
;; drum patterns are simply lists with either O (bass drum), X (snare) or
;; #f (pause)
;; WARNING: drum generation takes a _long_ time
(define (drum n pattern tempo)
  ;; these drum patterns are lists (length pattern)
  (define bass-drum
    ;; 0.05 seconds of noise whose value changes every 12 samples
    (list (* fs 0.05)
	  (foldl (lambda (x y) (append x (repeat 12 (list (- (random-real) 0.5)))))
		 '()
		 (iota (/ (* fs 0.05) 12)))))
  (define snare
    ;; 0.05 seconds of noise
    (list (* fs 0.05)
	  (foldl (lambda (x y) (append x (list (- (random-real) 0.5))))
		 '()
		 (iota (* fs 0.05)))))
  (define (make-drum type samples-per-beat)
    (append (cadr type)
	    (repeat (- samples-per-beat (car type))
		    '(0))))
  (let* ((samples-per-beat (/ (* fs 60) tempo))
	 (bass-drum (make-drum bass-drum samples-per-beat))
	 (snare     (make-drum snare     samples-per-beat))
	 (pause     (make-drum '(0 ())   samples-per-beat)))
    (repeat n
	    (foldl append '()
		   (map (lambda (beat)
			  (case beat
			    ((O)  bass-drum)
			    ((X)  snare)
			    ((#f) pause)))
			pattern)))))

;; weighted sum of signals, receives a list of lists (signal weight)
(define (dub . signals)
  (let loop ((signals (map (lambda (x) (map (lambda (y) (* y (cadr x)))
					    (normalize-signal (car x))))
			   signals))
	     (y       '()))
	(if (foldl (lambda (x y) (and x (null? y)))
		   #t
		   signals)
	    ;; if all the signals are empty, stop
	    (reverse y)
	    (loop (map (lambda (x) (if (null? x) '() (cdr x))) signals)
		  (cons (foldl (lambda (x y) (+ x (if (null? y) 0 (car y))))
			       0
			       signals)
			y)))))

;; takes a signal with arbitrary values centered at 0 and transfers it to
;; [0, 65535]
(define (normalize-signal signal)
  (if (not (list? signal)) (pp signal))
  (let ((max-val (foldl (lambda (x y) (max x (abs y)))
			1 ; can't be 0, would give division by 0 with pauses
			signal)))
    (map (lambda (x)
	   (inexact->exact (floor (* (/ x max-val) 32767))))
	 signal)))

;; sends the signal (values from 0 to 65535) to a python process that does the
;; encoding to wav
(define (signal->wavfile signal)
  ;; prints data to stdout so the python process can read it
  (for-each (lambda (sample) (print sample "\n"))
	    (normalize-signal signal)))
