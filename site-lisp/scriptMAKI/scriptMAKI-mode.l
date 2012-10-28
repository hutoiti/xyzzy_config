;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is part of xyzzy.
;;;

;;;
;;; ~/.xyzzy ‚© site-lisp/siteinit.l ‚ÉˆÈ‰º‚ð’Ç‰Á
;;;
;;; (require "scriptMAKI/scriptMAKI-mode")
;;; (setq *scriptMAKI-mc-path* "X:/path/to/winamp/sdk/maki/mc.exe")
;;; (pushnew '("\\.m$" . scriptMAKI-mode) *auto-mode-alist*)
;;;
;;; *scriptMAKI-mc-path* ‚ÌƒpƒX‚ÍŠeŽ©‚ÅÝ’è‚µ‚Ä‰º‚³‚¢
;;;

(provide "scriptMAKI-mode")

(in-package "editor")

(export '(
          *scriptMAKI-mode-hook*
          scriptMAKI-indent-level
          scriptMAKI-continued-statement-offset
          scriptMAKI-argdecl-indent
          scriptMAKI-brace-offset
          scriptMAKI-brace-imaginary-offset
          scriptMAKI-label-offset scriptMAKI-comment-indent))

(export '(
          *scriptMAKI-mc-path*
          scriptMAKI-mode
          scriptMAKI-indent-line
          scriptMAKI-newline-and-indent
          scriptMAKI-electriscriptMAKI-insert
          scriptMAKI-electriscriptMAKI-close
          indent-scriptMAKI-directive
          *scriptMAKI-keyword-file*
          *scriptMAKI-indent-tabs-mode*
          *scriptMAKI-tab-always-indent*
          *scriptMAKI-comment-column*
          *scriptMAKI-comment-c++-style*))

(defvar *scriptMAKI-mode-hook* nil)

(unless (boundp 'scriptMAKI-indent-level)
  (setq scriptMAKI-indent-level 2)
  (setq scriptMAKI-continued-statement-offset 2)
  (setq scriptMAKI-argdecl-indent 5)
  (setq scriptMAKI-brace-offset 0)
  (setq scriptMAKI-brace-imaginary-offset 0)
  (setq scriptMAKI-label-offset -2)
  (setq scriptMAKI-comment-indent 2))

(defvar *scriptMAKI-tab-always-indent* t)

(defvar *scriptMAKI-indent-tabs-mode* nil)
(defvar *scriptMAKI-comment-column* nil)
(defvar *scriptMAKI-comment-c++-style* nil)

(defvar *scriptMAKI-keyword-hash-table* nil)
(defvar *scriptMAKI-keyword-file* "scriptMAKI")

(defvar *scriptMAKI-mc-path* nil)

(defvar *scriptMAKI-mode-syntax-table* nil)
(unless *scriptMAKI-mode-syntax-table*
  (setq *scriptMAKI-mode-syntax-table* (make-syntax-table))
  (do ((x #x21 (1+ x)))((>= x #x7f))
    (let ((c (code-char x)))
      (unless (alphanumericp c)
	(set-syntax-punctuation *scriptMAKI-mode-syntax-table* c))))
  (set-syntax-option *scriptMAKI-mode-syntax-table*
		     *syntax-option-c-preprocessor*)
  (set-syntax-string *scriptMAKI-mode-syntax-table* #\")
  (set-syntax-string *scriptMAKI-mode-syntax-table* #\')
  (set-syntax-escape *scriptMAKI-mode-syntax-table* #\\)
  (set-syntax-symbol *scriptMAKI-mode-syntax-table* #\_)
  (set-syntax-symbol *scriptMAKI-mode-syntax-table* #\#)
  (set-syntax-match *scriptMAKI-mode-syntax-table* #\( #\))
  (set-syntax-match *scriptMAKI-mode-syntax-table* #\{ #\})
  (set-syntax-match *scriptMAKI-mode-syntax-table* #\[ #\])
  (set-syntax-start-multi-comment *scriptMAKI-mode-syntax-table* "/*")
  (set-syntax-end-multi-comment *scriptMAKI-mode-syntax-table* "*/")
  (set-syntax-start-c++-comment *scriptMAKI-mode-syntax-table* #\/)
  (set-syntax-end-c++-comment *scriptMAKI-mode-syntax-table* #\LFD))

(defvar *scriptMAKI-mode-map* nil)
(unless *scriptMAKI-mode-map*
  (setq *scriptMAKI-mode-map* (make-sparse-keymap))
  (define-key *scriptMAKI-mode-map* #\{ 'scriptMAKI-electriscriptMAKI-insert)
  (define-key *scriptMAKI-mode-map* #\: 'scriptMAKI-electriscriptMAKI-insert)
  (define-key *scriptMAKI-mode-map* #\# 'scriptMAKI-electriscriptMAKI-insert)
  (define-key *scriptMAKI-mode-map* #\} 'scriptMAKI-electriscriptMAKI-close)
  (define-key *scriptMAKI-mode-map* #\C-h 'backward-delete-char-untabify-or-selection)
  (define-key *scriptMAKI-mode-map* #\TAB 'scriptMAKI-indent-line)
  (define-key *scriptMAKI-mode-map* #\C-M-q 'indent-sexp)
  (define-key *scriptMAKI-mode-map* #\RET 'scriptMAKI-newline-and-indent)
  (define-key *scriptMAKI-mode-map* '(#\C-c #\c) 'scriptMAKI-compile-current-file)
  )

(defvar *scriptMAKI-mode-abbrev-table* nil)
(unless *scriptMAKI-mode-abbrev-table*
  (define-abbrev-table '*scriptMAKI-mode-abbrev-table*))

(defun scriptMAKI-indent-line ()
  (interactive "*")
  (if (or (not (interactive-p))
	  *scriptMAKI-tab-always-indent*
	  (save-excursion
	    (skip-chars-backward " \t")
	    (bolp)))
      (case (save-excursion
	      (goto-bol)
	      (parse-point-syntax))
	(:string)
	(:comment
	 (let ((column (calc-scriptMAKI-comment-indent)))
	   (when (integerp column)
	     (smart-indentation column))))
	(t
	 (let ((column (calc-scriptMAKI-indent)))
	   (when (integerp column)
	     (smart-indentation column)))))
    (insert "\t"))
  t)

(defun scriptMAKI-compile-current-file ()
  (interactive)
  (if *scriptMAKI-mc-path*
      (progn
        (let ((curfile (get-buffer-file-name))
              (outbuf (get-buffer-create "* Compile Result *")))
          (execute-shell-command (concat *scriptMAKI-mc-path* " " curfile) :output outbuf))
        )
    (message "mc.exe's path is not set.")
    ))
    
(defun scriptMAKI-newline-and-indent (&optional (arg 1))
  (interactive "*p")
  (delete-trailing-spaces)
  (insert #\LFD arg)
  (scriptMAKI-indent-line))

(defun scriptMAKI-electriscriptMAKI-insert (&optional (arg 1))
  (interactive "*p")
  (unless (prog1
	      (parse-point-syntax)
	    (self-insert-command arg))
    (scriptMAKI-indent-line))
  t)

(defun scriptMAKI-electriscriptMAKI-close (&optional (arg 1))
  (interactive "*p")
  (unless (prog1
	      (parse-point-syntax)
	    (self-insert-command arg))
    (scriptMAKI-indent-line))
  (save-excursion
    (forward-char -1)
    (and (goto-matched-parenthesis)
	 (show-matched-parenthesis)))
  t)

(defun scriptMAKI-indent-to (to)
  (skip-chars-forward " \t")
  (when (/= to (current-column))
    (delete-horizontal-spaces)
    (indent-to to)))

(defun indent-scriptMAKI-directive ()
  (interactive)
  (save-excursion
    (let ((column 1))
      (goto-char (point-min))
      (while (scan-buffer "^#" :regexp t)
	(forward-char 1)
	(cond ((looking-at "[ \t]*if")
	       (scriptMAKI-indent-to column)
	       (setq column (1+ column)))
	      ((looking-at "[ \t]*el\\(se\\|if\\)")
	       (scriptMAKI-indent-to (1- column)))
	      ((looking-at "[ \t]*endif")
	       (setq column (1- column))
	       (when (zerop column)
		 (error "Unmatched \"#endif\" at line ~d" (current-line-number)))
	       (scriptMAKI-indent-to column))
	      (t (scriptMAKI-indent-to column)
		 (if (looking-for "define")
		     (while (and (progn
				   (goto-eol)
				   (forward-char -1)
				   (looking-for "\\"))
				 (forward-line 1))
		       (scriptMAKI-indent-line))))))
      (when (/= column 1)
	(error "Unmatched \"#if\" or \"#ifdef\""))))
  t)

(defun scriptMAKI-comment-indent ()
  (save-excursion
    (let ((opoint (point)))
      (goto-bol)
      (cond ((looking-at "/\\*\\|//")
	     0)
	    (t
	     (skip-chars-forward " \t")
	     (cond ((looking-at "}[ \t]*\\($\\|/\\*\\|//\\)")
		    (+ (current-column) 2))
		   ((looking-at "#[ \t]*\\(endif\\|else\\)\\>")
		    (goto-char (match-end 1))
		    (+ (current-column) 2))
		   ((or (looking-at "/\\*\\|//")
			(eolp))
		    (calc-scriptMAKI-indent))
		   ((zerop comment-column)
		    0)
		   (t
		    (goto-char opoint)
		    (skip-chars-backward " \t")
		    (max (1+ (current-column)) comment-column))))))))

(defvar-local scriptMAKI-comment-indent-variable 'scriptMAKI-comment-indent)

(defun calc-scriptMAKI-comment-indent ()
  (save-excursion
    (goto-bol)
    (skip-chars-forward " \t")
    (let ((eolp (eolp)))
      (when (and (or eolp (looking-for "*"))
		 (scan-buffer "/*" :reverse t))
	(while (and (eq (parse-point-syntax) ':comment)
		    (scan-buffer "/*" :reverse t :no-dup t)))
	(+ (current-column)
	   (if eolp
	       (if (symbolp scriptMAKI-comment-indent-variable)
		   (symbol-value scriptMAKI-comment-indent-variable)
		 0)
	     1))))))

(autoload 'scriptMAKI-build-summary-of-functions "cfns" nil)
(autoload 'scriptMAKI-maketags "cfns")
(pushnew '(scriptMAKI-maketags "*.m")
	 *maketags-list* :key #'car)

(defun scriptMAKI-tags-find-target ()
  (let* ((opoint (point))
	 (tail (progn
		 (skip-chars-forward "a-zA-Z0-9_")
		 (point)))
	 (name (buffer-substring tail
				 (progn
				   (skip-chars-backward "a-zA-Z0-9_")
				   (when (or (looking-back "::~")
					     (looking-back "->~")
					     (looking-back ".~"))
				     (forward-char -1))
				   (point))))
	 class)
    (cond ((looking-back "::")
	   (forward-char -2)
	   (let ((point (point)))
	     (when (looking-back ">")
	       (let ((depth 1))
		 (loop
		   (forward-char -1)
		   (skip-chars-backward "^<>")
		   (cond ((looking-back ">")
			  (incf depth))
			 ((looking-back "<")
			  (decf depth)
			  (when (zerop depth)
			    (forward-char -1)
			    (return)))
			 (t
			  (return)))))
	       (skip-chars-backward " \t\n\f")
	       (setq point (point)))
	     (setq class (buffer-substring point
					   (progn
					     (skip-chars-backward "a-zA-Z0-9_")
					     (point))))))
	  (t
	   (goto-char tail)
	   (when (looking-for "::")
	     (forward-char 2)
	     (setq class name)
	     (setq name (buffer-substring
			 (point)
			 (progn
			   (skip-chars-forward "a-zA-Z0-9_")
			   (point)))))))
    (goto-char opoint)
    (values class name '(function structure))))

(defun scriptMAKI-tags-find-point-1 (re start reverse structurep lgoal)
  (let* ((limit (if reverse
		    (- start *jump-tag-limit*)
		  (+ start *jump-tag-limit*)))
	 (goal (progn
		 (goto-char start)
		 (while (scan-buffer re :regexp t :limit limit :tail t :reverse reverse)
		   (let ((opoint (point))
			 (point0 (match-beginning 0))
			 (start (match-end 1)))
		     (unless structurep
		       (forward-char -1)
		       (forward-sexp 1 t))
		     (skip-white-forward)
		     (unless (looking-for ";")
		       (return start))
		     (goto-char (if reverse (1- point0) opoint)))))))
    (if lgoal
	(if goal
	    (if (< (abs (- lgoal start)) (abs (- goal start)))
		lgoal goal)
	  lgoal)
      goal)))

(defun scriptMAKI-tags-find-point (class name type point)
  (let* ((structurep (eq type 'structure))
	 (re (compile-regexp (if structurep
				 (concat "\\_<\\(?:struct\\|class\\|interface\\)[ \t\n\f]+\\("
					 name "\\)\\_>")
			       (concat "\\_<\\(" name "\\)[ \t\n\f]*("))))
	 goal)
    (setq goal (scriptMAKI-tags-find-point-1 re point t structurep nil))
    (setq goal (scriptMAKI-tags-find-point-1 re point nil structurep goal))
    goal))

(defun scriptMAKI-mode ()
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "scriptMAKI")
  (setq buffer-mode 'scriptMAKI-mode)
  (use-syntax-table *scriptMAKI-mode-syntax-table*)
  (use-keymap *scriptMAKI-mode-map*)
  (make-local-variable 'mode-specifiscriptMAKI-indent-command)
  (setq mode-specifiscriptMAKI-indent-command 'scriptMAKI-indent-line)
  (make-local-variable 'paragraph-start)
  (setq paragraph-start "^$\\|\f")
  (make-local-variable 'paragraph-separate)
  (setq paragraph-separate paragraph-start)
  (make-local-variable 'indent-tabs-mode)
  (setq indent-tabs-mode *scriptMAKI-indent-tabs-mode*)
  (make-local-variable 'tags-find-target)
  (setq tags-find-target #'scriptMAKI-tags-find-target)
  (make-local-variable 'tags-find-point)
  (setq tags-find-point #'scriptMAKI-tags-find-point)
  (make-local-variable 'build-summary-function)
  (setq build-summary-function 'scriptMAKI-build-summary-of-functions)
  (and *scriptMAKI-keyword-file*
       (null *scriptMAKI-keyword-hash-table*)
       (setq *scriptMAKI-keyword-hash-table*
	     (load-keyword-file *scriptMAKI-keyword-file*)))
  (when *scriptMAKI-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *scriptMAKI-keyword-hash-table*))
  (setq *local-abbrev-table* *scriptMAKI-mode-abbrev-table*)
  (if *scriptMAKI-comment-c++-style*
      (setq comment-start "// " comment-end "")
    (setq comment-start "/* " comment-end " */"))
  (setq comment-start-skip "/\\(\\*+\\|/\\)[ \t]*")
  (setq comment-indent-function 'scriptMAKI-comment-indent)
  (when *scriptMAKI-comment-column*
    (setq comment-column *scriptMAKI-comment-column*))
  (run-hooks '*scriptMAKI-mode-hook*))
