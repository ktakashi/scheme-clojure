(import (clojure syntax)
	(clojure macro)
	(only (rnrs) for-each display newline car assert eq? eqv? list))

(defn print #(& args) (for-each display args) (newline))

(defmacro first #(l) (list 'car l))
(print (assert (eq? 'a (first '(a)))))
(defonce one 1)
(print (assert (eqv? one 1)))