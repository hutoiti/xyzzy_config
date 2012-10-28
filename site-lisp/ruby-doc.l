;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: ruby-doc.l,v 1.1.1.1 2005/11/25 13:06:17 torihat Exp $
;
; ruby-doc.l
;
; by HATTORI Masashi

(provide "ruby-doc")

(require "ruby")

(in-package "editor")

(export '(*ruby-doc-mode-hook*
	  *ruby-doc-mode-map*
	  ruby-doc-minor-mode
	  ruby-doc-quit
	 ))

(defvar-local *ruby-doc-mode* nil)
(defvar *ruby-doc-mode-hook* nil)
(defvar *ruby-doc-indent-column* 2)

(define-key *ruby-mode-map* '(#\C-c #\d) 'ruby-doc-minor-mode)

(defvar *ruby-doc-mode-map* nil)
;(unless *ruby-doc-mode-map*
   (setq *ruby-doc-mode-map* (make-sparse-keymap))
   (define-key *ruby-doc-mode-map* #\RET 'ruby-doc-newline-and-indent)
   (define-key *ruby-doc-mode-map* #\TAB 'ruby-doc-indent-line)
   (define-key *ruby-doc-mode-map* #\M-Left 'ruby-doc-indent-down)
   (define-key *ruby-doc-mode-map* #\M-Right 'ruby-doc-indent-up)
   (define-key *ruby-doc-mode-map* '(#\C-c #\f #\e) 'ruby-doc-insert-emphasis)
   (define-key *ruby-doc-mode-map* '(#\C-c #\f #\c) 'ruby-doc-insert-code)
   (define-key *ruby-doc-mode-map* '(#\C-c #\f #\v) 'ruby-doc-insert-var)
   (define-key *ruby-doc-mode-map* '(#\C-c #\f #\k) 'ruby-doc-insert-keyboard)
   (define-key *ruby-doc-mode-map* '(#\C-c #\f #\i) 'ruby-doc-insert-index)
   (define-key *ruby-doc-mode-map* '(#\C-c #\f #\r) 'ruby-doc-insert-reference)
   (define-key *ruby-doc-mode-map* '(#\C-c #\f #\u) 'ruby-doc-insert-url)
   (define-key *ruby-doc-mode-map* '(#\C-c #\f #\f) 'ruby-doc-insert-footnote)
   (define-key *ruby-doc-mode-map* '(#\C-c #\f #\b) 'ruby-doc-insert-verb)
;)

(defun ruby-doc-minor-mode (&optional (arg nil sv))
  (interactive "p")
  (toggle-mode '*ruby-doc-mode* arg sv)
  (update-mode-line t)
  (if *ruby-doc-mode*
      (set-minor-mode-map *ruby-doc-mode-map*)
    (unset-minor-mode-map *ruby-doc-mode-map*))
  t)

(pushnew '(*ruby-doc-mode* . "RD") *minor-mode-alist* :key #'car)

(defun ruby-doc-in-range-p ()
  (save-excursion
    (and (scan-buffer "^=\\(begin\\|end\\)" :regexp t :reverse t :no-dup t)
	 (equal (match-string 1) "begin"))))

(defun ruby-doc-check-range ()
  (unless (ruby-doc-in-range-p)
    (error "RD書くとこじゃないっす")))

(defun ruby-doc-newline-and-indent (&optional (arg 1))
  (interactive "*p")
  (ruby-doc-check-range)
  ;(delete-trailing-spaces)
  (insert #\LFD arg)
  (ruby-doc-indent-line))

(defun ruby-doc-indent-line ()
  (interactive "*")
  (when (interactive-p)
    (ruby-doc-check-range))
  (let ((column (calc-ruby-doc-indent)))
    (when (integerp column)
      (ruby-doc-indent-to column)))
  t)

(defun ruby-doc-indent-to (column)
  (save-excursion
    (goto-bol)
    (delete-region (point)
		   (progn
		     (skip-chars-forward " \t")
		     (point)))
    (indent-to column))
  (when (and (bolp) column)
    (skip-chars-forward " \t")))

(defun ruby-doc-current-indent ()
  (save-excursion
    (goto-bol)
    (skip-chars-forward " \t")
    (current-column)))

(defun ruby-doc-indent-up ()
  (interactive "*")
  (ruby-doc-indent-to (+ (ruby-doc-current-indent)
			 *ruby-doc-indent-column*)))

(defun ruby-doc-indent-down ()
  (interactive "*")
  (ruby-doc-indent-to (max
		       (- (ruby-doc-current-indent)
			  *ruby-doc-indent-column*)
		       0)))

;;空行じゃない行まで戻る
(defun ruby-doc-previous-line ()
  (while (forward-line -1)
    (unless (ruby-space-line)
      (return-from ruby-doc-previous-line t))))

;;インデントする数を数える
(defun calc-ruby-doc-indent ()
  (let ((column 0)
	(add 0)
	(plus 0)
	(curp (point)))
    (save-excursion
      ;前の行を調べる
      (when (ruby-previous-line)
	(goto-bol)
	(skip-chars-forward " \t")
	(setq column (current-column))
	(cond ((looking-at "[=]+ ")
	       nil)
	      ((looking-at "[\+]+ ")
	       nil)
	      ((looking-at "<<< ")
	       nil)
	      ((looking-at "\* ")
	       (setq add 2))
	      ((looking-at "([0-9]+) ")
	       (setq add (length (match-string 0))))
	      ((looking-at ": ")
	       (setq add 2)
	       (incf plus *ruby-doc-indent-column*))
	      ((looking-at "--- ")
	       (setq add 4)
	       (incf plus *ruby-doc-indent-column*))
	)
	;(message-box (format nil "~D:~D:~D" column add plus))
      ))
    ; 現在の行を調べる
    (save-excursion
      (goto-bol)
      (skip-chars-forward " \t")
      ; 閉じものがあればインデント数を減らす
      (cond ((looking-at "^=\\(begin\\|end\\)")
	     (setq column 0))
	    ((looking-at "[=]+")
	     (setq column 0))
	    ((looking-at "[\+]+")
	     (setq column 0))
	    ((looking-at "\*")
	     (incf column plus))
	    ((looking-at "([0-9]+)")
	     (incf column plus))
	    ((looking-at ":")
	     (incf column plus))
	    ((looking-at "---")
	     (incf column plus))
	    (t
	     (setq column (+ column add plus)))
      ))
    (max column 0)
  ))

(defun ruby-doc-insert-command (form &optional str (back 3))
  (insert form)
  (backward-char back)
  (when str
    (insert str)))

(defun ruby-doc-insert-emphasis (&optional str)
  (interactive "*")
  (ruby-doc-insert-command "((**))" str))

(defun ruby-doc-insert-code (&optional str)
  (interactive "*")
  (ruby-doc-insert-command "(({}))" str))

(defun ruby-doc-insert-var (&optional str)
  (interactive "*")
  (ruby-doc-insert-command "((||))" str))

(defun ruby-doc-insert-keyboard (&optional str)
  (interactive "*")
  (ruby-doc-insert-command "((%%))" str))

(defun ruby-doc-insert-index (&optional str)
  (interactive "*")
  (ruby-doc-insert-command "((::))" str))

(defun ruby-doc-insert-reference (&optional str)
  (interactive "*")
  (ruby-doc-insert-command "((<>))" str))

(defun ruby-doc-insert-url (&optional str)
  (interactive "*")
  (ruby-doc-insert-command "((<URL:>))" str))

(defun ruby-doc-insert-footnote (&optional str)
  (interactive "*")
  (ruby-doc-insert-command "((--))" str))

(defun ruby-doc-insert-verb (&optional str)
  (interactive "*")
  (ruby-doc-insert-command "((''))" str))

