(library (clojure)
    (export fn def if loop try quote do let
	    defn defmacro defonce)
    (import (clojure syntax)
	    (clojure macro)))