(library (clojure macro)
    (export defn defmacro defonce)
    (import (except (rnrs) do let)
	    (for (clojure syntax) run expand))

(define-syntax defn
  (syntax-rules ()
    ((_ name #(args ...) body ...)
     (defn name (#(args ...) body ...)))
    ((_ name (#(args ...) body ...) ...)
     (def name
       (fn name (#(args ...) body ...) ...)))))

;; only supports (defmacro name #(params) body ...)
(define-syntax defmacro
  (lambda (x)
    (syntax-case x ()
      ((_ name #(params ...) body ...)
       #'(define-syntax name
	   (lambda (p)
	     (syntax-case p ()
	       ((k . args)
		(let #(lst (syntax->datum #'args))
		  (datum->syntax #'k (apply (fn #(params ...) body ...) lst)))
		))))))))

;; not like clojures just dummy
(defmacro defonce #(name expr)
  (list 'def name expr))

)