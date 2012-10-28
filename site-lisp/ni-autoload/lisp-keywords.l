(in-package "editor")

(defvar *lisp-keyword-hash-table* nil "lisp keyword hashtable")
(defvar *lisp-keyword-highlight* nil "decide lisp keyword highlight on lisp-mode")
(export '(*lisp-keyword-highlight*))

(defun use-lisp-keyword ()
  "hook function for highlight lisp keywords"
  (setq *lisp-keyword-hash-table*
	(or *lisp-keyword-hash-table*
	    (load-keyword-file "lisp")))
  (and
   *lisp-keyword-highlight*
   *lisp-keyword-hash-table*
   (make-local-variable 'keyword-hash-table)
   (setq keyword-hash-table *lisp-keyword-hash-table*)))

(add-hook '*lisp-mode-hook* 'use-lisp-keyword)
(add-hook '*lisp-interaction-mode-hook* 'use-lisp-keyword)
