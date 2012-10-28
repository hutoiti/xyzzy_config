;;; -*- Mode: Lisp -*-
;;  mode:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       mode is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:

(in-package :odoc-mode)

(export '(odoc-mode *odoc-mode-map*))

(defvar *odoc-mode-syntax-table* nil)
(unless *odoc-mode-syntax-table*
  (setq *odoc-mode-syntax-table* (make-syntax-table))
  ;;   (do ((x #x21 (1+ x)))((>= x #x7f))
  ;; 	(let ((c (code-char x)))
  ;; 	  (unless (alphanumericp c)
  ;; 		(set-syntax-punctuation *odoc-mode-syntax-table* c))))
  (set-syntax-string *odoc-mode-syntax-table* #\")
  (set-syntax-match *odoc-mode-syntax-table* #\( #\))
  (set-syntax-match *odoc-mode-syntax-table* #\{ #\})
  (set-syntax-match *odoc-mode-syntax-table* #\[ #\])
  )

(defun new-odoc(str odoc dir)
  (regex-keyword-push str)
  (find-file (merge-pathnames odoc dir))
  (with-open-file(out (merge-pathnames *odoc-keyword-file* dir)
					  :direction :output
					  :if-does-not-exist :create
					  :if-exists :append)
	(format out "~A~%" str)))


(defun regex-keyword-push(keyword)
  (pushnew (apply #'compile-regexp-keyword
				  `(,keyword t ,*odoc-wikiname-color*))
		   *odoc-mode-formats* :test 'equal)
  )

(defun keyword()
  (let((line))
	(with-open-file(f (merge-pathnames *odoc-keyword-file* (default-directory))
					  :if-does-not-exist :create)
	  (while(setq line (read-line f nil nil nil))
		(and line (regex-keyword-push line))
		))))

(defvar *odoc-mode-customize* nil )
(defun odoc-custum-load()
  "(in-package :odoc-mode)ˆÈ‰º‚É’Ç‰ÁÝ’è‚ð‘‚­"
  (load (merge-pathnames ".odoc-mode" *default-conf-path*)
		:if-does-not-exist :create)
  (setq *odoc-mode-customize* t))

(defun odoc-mode()
  (interactive "p")
  (kill-all-local-variables)
  (setq mode-name "odoc")
  (setq buffer-mode 'odoc-mode)
  (use-syntax-table *odoc-mode-syntax-table*)
  (use-keymap *odoc-mode-map*)
  (make-local-variable 'regexp-keyword-list)
  (or *odoc-mode-customize* (odoc-custum-load))
  (keyword)
  (unless *action-menber*
	(setup-toggle-switch)
	(add-action-list *action-default-member*)
	)
  (setq regexp-keyword-list *odoc-mode-formats*)
  (run-hooks '*odoc-mode-hook*)
  )

(defvar *odoc-mode-map* nil)
(unless *odoc-mode-map*
  (setf *odoc-mode-map*(make-sparse-keymap))
  (define-key *odoc-mode-map* '(#\C-c #\p) 'publish)
  (define-key *odoc-mode-map* '(#\C-c #\i) 'index)
  (define-key *odoc-mode-map* '#\RET 'action)
  )



(defvar *odoc-mode-formats* nil)
(setf *odoc-mode-formats*
	  (compile-regexp-keyword-list
	   '(
		 ;Wiki style
		 ("^\\(-\\{4\\}\\).*$" t  (:color 1 0 :strike-out :line))
		 ("^\\(  \\)*-" t (:color 2 0 :bold))
		 ("^\\(  \\)*\\*" t (:color 2 0 :bold))
		 ("^>.*?$" t (:color 3 0 :underline))
		 ("^:.*?: .*?" t (:color 4 0))
		 ("^\\(|\\)\\(.+\\)\\(|\\)" nil
		  ((1 . (:color 3 0 :bold)) (3 .  (:color 3 0 :bold))))
		 ("^ .*?" t (:color 0 4))
		 ("^=\\{1\\}\\([^=\n].*?\\)[ \t]*$" t (:color 7 14 :line :bold))
		 ("^=\\{2\\}\\([^=\n].*?\\)[ \t]*$" t (:color 7 15 :line :bold))
		 ("^=\\{3\\}\\([^=\n].*?\\)[ \t]*$" t (:color 2 0 :underline ))
		 ("^=\\{4\\}\\([^=\n].*?\\)[ \t]*$" t (:color 0 0 :underline ))
		 ("^=\\{5\\}\\([^=\n].*?\\)[ \t]*$" t (:color 0 0 :bold ))
		 ;;("\\[.+?\\]" t (:color 8 0)) ; omit
		 )))


(provide :odoc/mode/odoc)

