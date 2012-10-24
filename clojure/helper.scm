(library (clojure helper)
    (export parse-bindings)
    (import (rnrs))

;; internal use
;; used by let and loop
;; For Sagittarius binds&body must be set otherwise it won't work.
(define (parse-bindings binds&body acc)
  (syntax-case binds&body ()
    ((() body ...) (cons (reverse acc) #'(body ...)))
    (((var val . rest) body ...)
     (identifier? #'var)
     (parse-bindings #'(rest body ...) (cons #'(var val) acc)))
    ;; TODO vector and :as
    ))



)