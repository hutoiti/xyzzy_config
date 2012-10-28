(defpackage "ibuki" (:use "lisp" "editor"))
(use-package "ibuki")
(export '(ibuki::ibuki-mode) "ibuki")
(autoload 'ibuki-mode "ibuki" t)