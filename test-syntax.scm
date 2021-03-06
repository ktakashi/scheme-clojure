(import (clojure syntax) 
	(only (rnrs) define for-each display newline zero? - * procedure?)
	;;(srfi :64)
	)

(def print (fn #(& args) (for-each display args) (newline)))
(def test-begin print)
(def test-assert print)
(def test-equal print)
(def test-end print)

(test-begin "Toy clojure test")

(test-assert "fn" (procedure? (fn #(a) a)))

(test-assert "if (true)" (if (zero? 0) true))
(test-equal  "if (false)" nil (if (zero? 1) true))
(test-equal  "if (false nil)" nil (if nil true))
(test-equal  "if (false)" false (if nil true false))

(test-equal "let" 1 (let #(x 1 y x) y))

(test-equal "loop" 120 (loop #(cnt 5 acc 1)
			   (if (zero? cnt)
			       acc
			       (recur (- cnt 1) (* acc cnt)))))

(test-equal "try" 'ok (try 'ok
			   (catch zero? e 'ng)
			   (finally (display 'finally) (newline))))

(test-equal "try (throw)" 'ok 
	    (try (throw 0)
		 (catch zero? e 'ok)
		 (finally (display 'finally) (newline))))

(test-end)

