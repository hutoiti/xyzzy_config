;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: ruby-misc.l,v 1.1.1.1 2005/11/25 13:06:17 torihat Exp $
;
; ruby-mode用マクロとか
;
; by HATTORI Masashi

(require "ruby")

(in-package "editor")

(export '(*ruby-information-command*
	  *ruby-error-popup-ratio*))

(defvar *ruby-information-command* "ri")
(defvar *ruby-error-popup-ratio* 1/3)

(define-key *ruby-mode-map* '(#\C-c #\w) 'ruby-syntax-check)
(define-key *ruby-mode-map* '(#\C-c #\x) 'ruby-run-script)
(define-key *ruby-mode-map* #\S-F1 'ruby-information)

#|
(setq *ruby-prog* (map-slash-to-backslash "C:/cygwin/usr/local/bin/ruby.exe"))
(setq *ruby-information-command*
      (concat *ruby-prog* " " (map-slash-to-backslash "C:/cygwin/usr/local/bin/ri.rb")))
|#

(defun ruby-syntax-check ()
  "スクリプトのエラーチェック"
  (interactive)
  (let (command
	(bufname "*Syntax Check*")
	(file (get-buffer-file-name)))
    (when file
      (when (setq command (read-string "Check: "
				       :default (concat *ruby-prog* " -wc " file)))
	(ruby-error-popup-buffer bufname)
	(execute-shell-command command nil bufname)))))

(defun ruby-error-popup-ratio ()
  (truncate (* (screen-height) *ruby-error-popup-ratio*)))

(defun ruby-error-popup-buffer (bufname)
  (pop-to-buffer (get-buffer-create bufname) (ruby-error-popup-ratio)))

(defun ruby-run-script ()
  "スクリプトを走らせる"
  (interactive)
  (let (command
	(bufname "*Run Script*")
	(file (get-buffer-file-name)))
    (when file
      (when (setq command (read-string "Check: "
				       :default (concat *ruby-prog* " " file)))
	(ruby-error-popup-buffer bufname)
	(execute-shell-command command nil bufname)))))

(defun ruby-information ()
  "riで引く"
  (interactive)
  (let (beg end cmd)
    (save-excursion
      (setq end (progn
		  (or (skip-syntax-spec-forward "w_")
		      (skip-syntax-spec-backward "^w_"))
		  (point)))
      (setq beg (progn
		  (skip-syntax-spec-backward "w_")
		  (point))))
    (setq cmd
	  (read-string "Ruby Information: "
		       :default (format nil "~A ~A"
					*ruby-information-command*
					(or (buffer-substring beg end) ""))))
    (pipe-command cmd)))
