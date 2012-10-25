(library (clojure syntax)
    (export fn def loop try quote
	    true false nil
	    (rename (begin do)
		    (clj:let let)
		    (clj:if if)
		    ;; this is actually not a syntax though
		    (raise-continuable throw)))
    (import (rnrs)
	    (for (clojure helper) run expand))

(define-syntax fn
  (lambda (x)
    (define (parse-args args acc)
      (define (finish opt)
        (if (null? acc)
            opt
            (append (reverse acc) opt)))
      (syntax-case args (&)
        (() (finish '()))
        ((& rest) (finish #'rest))
        ((a . d)
         (parse-args #'d (cons #'a acc)))))

    (define (parse-body body acc)
      (syntax-case body ()
        (() (reverse acc))
        (((#(args ...) exprs ...) . rest)
         (with-syntax ((formals (parse-args #'(args ...) '())))
           (parse-body #'rest 
                       (cons #'(formals exprs ...) acc))))))
    (syntax-case x ()
      ((_ #(args ...) exprs ...)
       #'(fn dummy #(args ...) exprs ...))
      ((_ name #(args ...) exprs ...)
       (identifier? #'name)
       #'(fn name (#(args ...) exprs ...)))
      ((_ (#(args ...) exprs ...) ...)
       #'(fn dummy (#(args ...) exprs ...) ...))
      ((_ name (#(args ...) exprs ...) ...)
       (identifier? #'name)
       (with-syntax ((((formals body ...) rest ...)
                      (parse-body #'((#(args ...) exprs ...) ...) '())))
         #'(letrec ((name (case-lambda 
                           (formals body ...)
                           rest ...)))
             name))))))

(define-syntax def
  (syntax-rules ()
    ((_ name expr) (define name expr))))

(define-syntax clj:let
  (lambda (x)
    (syntax-case x ()
      ((_ #(bindings ...) exprs ...)
       (with-syntax (((((var val) rest ...) body ...)
		      (parse-bindings #'((bindings ...) exprs ...) '())))
	 #'(let* ((var val) rest ...) body ...))))))

(define-syntax loop
  (lambda (x)
    (syntax-case x ()
      ((k #(bindings ...) exprs ...)
       (with-syntax ((recur (datum->syntax #'k 'recur))
		     ((((var val) rest ...) body ...)
		      (parse-bindings #'((bindings ...) exprs ...) '())))
	 #'(let recur ((var val) rest ...) body ...))))))

;; sort of...
(define-syntax try
  (lambda (x)
    (define (parse-clauses exprs ex body cat fin)
      (syntax-case exprs (catch finally)
	(() (list (reverse body) (reverse cat) fin))
	(((catch class e cls ...) . d)
	 (or (and (identifier? #'class) (identifier? #'e))
	     (syntax-violation 'try "invalid catch clause" exprs))
	 (with-syntax ((e2 ex))
	   (parse-clauses #'d ex body
			  (cons #'((class e2) (let ((e e2)) cls ...)) cat)
			  fin)))
	(((finally cls ...) . d)
	 (list (reverse body) (reverse cat) #'(lambda () cls ...)))
	((a . d)
	 (parse-clauses #'d ex (cons #'a body) cat fin))))

    (syntax-case x ()
      ((k exprs ...)
       (with-syntax ((e (datum->syntax #'k 'ex)))
	 (with-syntax ((((cls ...) (cat ...) fin)
			(parse-clauses #'(exprs ...) #'e '() '() '())))
	   #'(let ((h fin))
	       (let-values ((r (with-exception-handler
				(lambda (e)
				  (let ((er (cond cat ...)))
				    (h)
				    er))
				(lambda () cls ...))))
		 (h)
		 (apply values r)))))))))

(define-syntax clj:if
  (lambda (x)
    (syntax-case x ()
      ((_ test then)
       #'(clj:if test then nil))
      ((_ test then els)
       ;; nil must be false
       #'(if (let ((t test))
	       (and t (not (null? t))))
	     test
	     els)))))

)