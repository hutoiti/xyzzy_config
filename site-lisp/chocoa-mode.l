;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; chocoa-mode.l chocoa-script mode.
;;;

;;;
;;; $HeadURL: file:///G:/repo/xyzzy/site-lisp/chocoa-mode/tags/release/0.0.0.1/chocoa-mode.l $
;;;
;;; $LastChangedDate: 2004-04-29 11:23:29 +0900 (Thu, 29 Apr 2004) $
;;;
;;; $LastChangedRevision: 5 $
;;;
;;; LKPTeam <ykaltenative@mue.biglobe.ne.jp>
;;;

;;; Žg‚¢•û
;;;
;;; .xyzzy‚ÉˆÈ‰º‚ð’Ç‰Á
;;;
;;; (require "chocoa-mode")
;;; (pushnew '("\\.csf$" . chocoa-mode) *auto-mode-alist* :test 'equal)
;;;

(provide "chocoa-mode")

(export '(*chocoa-mode-hook*
          *chocoa-indent-column*
          *chocoa-tab-always-indent*
          ))

(defvar *chocoa-mode-hook* nil)
(defvar *chocoa-tab-always-indent* nil)
(defvar *chocoa-indent-column* 4)
(defvar *chocoa-keyword-hash-table* nil)
(defvar *chocoa-keyword-file* "CHOCOA")

(defvar *chocoa-mode-syntax-table* nil)
(unless *chocoa-mode-syntax-table*
  (setq *chocoa-mode-syntax-table* (make-syntax-table))
  (do ((x #x21 (1+ x))) ((>= x #x7f))
	(let ((c (code-char x)))
	  (unless (alphanumericp c)
		(set-syntax-punctuation *chocoa-mode-syntax-table* c))))
  (set-syntax-string *chocoa-mode-syntax-table* #\")
  (set-syntax-string *chocoa-mode-syntax-table* #\')
  (set-syntax-escape *chocoa-mode-syntax-table* #\\)
  (set-syntax-match *chocoa-mode-syntax-table* #\{ #\})
  (set-syntax-match *chocoa-mode-syntax-table* #\( #\))
  (set-syntax-symbol-prefix *chocoa-mode-syntax-table* #\%)
  (set-syntax-symbol-prefix *chocoa-mode-syntax-table* #\@)
  (set-syntax-symbol-prefix *chocoa-mode-syntax-table* #\$)
  (set-syntax-symbol-prefix *chocoa-mode-syntax-table* #\/)
  (set-syntax-word *chocoa-mode-syntax-table* #\_)
  (set-syntax-start-comment *chocoa-mode-syntax-table* #\;)
  (set-syntax-end-comment *chocoa-mode-syntax-table* #\LFD))

(defvar *chocoa-mode-map* nil)
(unless *chocoa-mode-map*
  (setq *chocoa-mode-map* (make-sparse-keymap))
  (define-key *chocoa-mode-map* #\TAB 'chocoa-indent-line)
  (define-key *chocoa-mode-map* #\RET 'chocoa-newline-and-indent)
  (define-key *chocoa-mode-map* #\{ 'chocoa-electric-insert)
  (define-key *chocoa-mode-map* #\} 'chocoa-electric-close)
  )

(defvar *chocoa-variables-regexp*
  (compile-regexp-keyword-list
     `(
         ("$\\+" t (:keyword 0 :bold) t)
         ("$[0-9#]" t (:keyword 0 :bold) t)
         ("/timer[0-9]+" t (:keyword 0 :bold) t)
         ("@[\#a-zA-Z0-9_]+" t (:keyword 1) nil)
         ("%[\#a-zA-Z0-9_]+" t (:keyword 1) nil)
         ("@[\#a-zA-Z0-9_]+" t (:keyword 0) :string)
         ("%[\#a-zA-Z0-9_]+" t (:keyword 0) :string)
         (" \\(\\[ +[^ ]+ +\\]\\) ?" t (:color 8 3) nil 1 1)
         (" \\(\\[ +[^ ]+ +\\]\\) ?" t (:color 8 3) :string 1 1)
         )))

(defun chocoa-mode ()
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "chocoa-script")
  (setq buffer-mode 'chocoa-mode)
  (use-keymap *chocoa-mode-map*)
  (use-syntax-table *chocoa-mode-syntax-table*)
  (and *chocoa-keyword-file*
	   (null *chocoa-keyword-hash-table*)
	   (setq *chocoa-keyword-hash-table*
			 (load-keyword-file *chocoa-keyword-file* t)))
  (when *chocoa-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *chocoa-keyword-hash-table*))
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *chocoa-variables-regexp*)
  (run-hooks '*chocoa-mode-hook*))

(defun chocoa-previous-line ()
  (while (forward-line -1)
    (unless (save-excursion
              (goto-bol)
              (looking-at "[ \t]*$"))
      (return-from chocoa-previous-line t))
    ))
      
(defun calc-chocoa-indent ()
  (let ((column 0) (curp (point)))
    (save-excursion
      (when (chocoa-previous-line)
        (goto-bol)
        (skip-chars-forward " \t")
        (setq column (current-column)))
      (save-restriction
        (narrow-to-region (progn (goto-eol) (point))
                          (progn (goto-bol) (point)))
        (skip-chars-forward " \t")
        (cond
           ((and (scan-buffer "\{" :regexp t) (not (scan-buffer "\}" :regexp t)))
            (setq column (+ column *chocoa-indent-column*)))
           )))
    (save-excursion
      (save-restriction
        (narrow-to-region (progn (goto-eol) (point))
                          (progn (goto-bol) (point)))
        (goto-bol)
        (skip-chars-forward " \t")
        (cond
           ((looking-at "\}")
            (setq column (- column *chocoa-indent-column*)))
           )))
    column
    ))
  
(defun chocoa-indent-line ()
  (interactive "*")
  (if (or (not (interactive-p))
          *chocoa-tab-always-indent*
          (save-excursion
            (skip-chars-backward " \t")
            (bolp)))
      (case (save-excursion
              (goto-bol)
              (parse-point-syntax))
        (:string)
        (:comment)
        (t
           (let ((column (calc-chocoa-indent)))
             (when (integerp column)
               (smart-indentation column)))))
    (insert "\t"))
  t)

(defun chocoa-newline-and-indent (&optional (arg 1))
  (interactive "*p")
  (delete-trailing-spaces)
  (insert #\LFD arg)
  (chocoa-indent-line))

(defun chocoa-electric-insert (&optional (arg 1))
  (interactive "*p")
  (unless (prog1
	      (parse-point-syntax)
	    (self-insert-command arg))
    (chocoa-indent-line))
  t)

(defun chocoa-electric-close (&optional (arg 1))
  (interactive "*p")
  (unless (prog1
	      (parse-point-syntax)
	    (self-insert-command arg))
    (chocoa-indent-line))
  (save-excursion
    (forward-char -1)
    (and (goto-matched-parenthesis)
	 (show-matched-parenthesis)))
  t)

(defun chocoa-create-template ()
  (interactive)
  (save-excursion
    (insert "/Service SERVICE_NAME\n{\n/Function\n{\n}\n/Event\n{\n}\n/Access\n{\n}\n/PopupMain\n{\n}\n/PopupUser\n{\n}\n/PopupChannel\n{\n}\n}\n/Var\n{\n}")
    ))
