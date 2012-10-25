(library (clojure macro)
    (export defn defmacro defonce
	    (rename (clj:and and)))
    (import (except (rnrs) do let if)
	    (for (clojure syntax) run expand)
	    (for (clojure helper) expand))

(define-syntax defn
  (syntax-rules ()
    ((_ name #(args ...) body ...)
     (defn name (#(args ...) body ...)))
    ((_ name (#(args ...) body ...) ...)
     (def name
       (fn name (#(args ...) body ...) ...)))))

;; (defmacro name #(params ...) body ...)
;; (defmacro name (#(params ...) body ...) ...)
(define-syntax defmacro
  (lambda (x)
    (syntax-case x ()
      ((_ name #(params ...) body ...)
       #'(defmacro name (#(params ...) body ...)))
      ((_ name (#(params ...) body ...) ...)
       #'(define-syntax name
	   (lambda (p)
	     (syntax-case p ()
	       ((k . args)
		(let #(lst (syntax->datum #'args))
		  (datum->syntax
		   #'k (apply (fn (#(params ...) body ...) ...) lst)))))))))))

;; not like clojures just dummy
(defmacro defonce #(name expr)
  (list 'def name expr))

;; redefine for clojure (i think it's the same as Scheme)
(defmacro clj:and
  (#() true)
  (#(x) x)
  (#(x & next)
   (let #(dummy (gensym 'and))
     (list 'let (vector dummy x)
	   (list 'if dummy (cons 'and next) dummy)))))

)