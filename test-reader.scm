(add-load-path ".")
#!read-macro=clojure
(import (clojure)
	(srfi :64))

(test-begin "Toy clojure test")

(test-assert "[]" (vector? [a b]))
(test-assert "fn" (procedure? (fn [a] a)))

(test-end)

