(library (clojure reader)
    (export :export-reader-macro)
    (import (rnrs) (sagittarius reader))

(define-reader-macro vector-reader #\[
  (lambda (port c)
    (list->vector (read-delimited-list #\] port))))

(define-reader-macro dummy #\]
  (lambda (port c) (error '|]-reader| "mislplaced #\\]")))

)