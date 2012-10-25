(import (clojure syntax)
	(clojure macro)
	(only (rnrs) for-each display newline car assert eq? eqv? equal? list
	      quasiquote quote unquote))

(defn print #(& args) (for-each display args) (newline))

(defmacro first #(l) (list 'car l))
(print (assert (eq? 'a (first '(a)))))
(defonce one 1)
(print (assert (eqv? one 1)))

(defmacro dispatch
  (#(a) `(list ',a))
  (#(a b) `(list ',a ',b)))

(print (assert (equal? '(a) (dispatch a))))
(print (assert (equal? '(a b) (dispatch a b))))

(print (assert (and true true 1)))
