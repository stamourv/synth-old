(define (repeat n l)
  (let loop ((n n) (res '()))
    (if (= n 0)
	res
	(loop (- n 1) (append res l)))))

(define (foldl f base lst)
  (if (null? lst)
      base
      (foldl f (f base (car lst)) (cdr lst))))

(define (build-list n f)
  (let loop ((n (- n 1)) (l '()))
    (if (< n 0) l (loop (- n 1) (cons (f n) l)))))

(define (iota n) (build-list n (lambda (x) x)))


;; returns the first element of the list whose cdr is x
(define (inv-assq x l)
  (cond ((null? l)        #f)
	((eq? (cdar l) x) (car l))
	(else             (inv-assq x (cdr l)))))