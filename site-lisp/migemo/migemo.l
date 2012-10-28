;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: migemo.l,v 1.5 2002/03/13 16:53:02 hattori Exp $
;
; migemo.l
;
; by Masashi Hattori <gyo@he.mirai.ne.jp>

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "foreign"))

(require "isearch")

(provide "migemo")

(in-package "editor")

(export '(*migemo-dict-file*
	  *migemo-init-hook*
	  migemo-toggle))

(defvar *migemo-dll* "migemo.dll")
(defvar *migemo-dict-file*
  (merge-pathnames "dict/migemo-dict" (si:system-root)))

(defvar *migemo-init-hook* nil)

(defvar *migemo-on* nil)
(defvar *migemo-session* nil)
(defvar *migemo-query-buf* (* 1024 8 8 8)) ; ←めっさ適当

; for migemo_load
(defconstant *migemo-dictid-invalid* 0)
(defconstant *migemo-dictid-migemo* 1)
(defconstant *migemo-dictid-roma2hira* 2)
(defconstant *migemo-dictid-hira2kata* 3)
(defconstant *migemo-dictid-han2zen* 4)

; for migemo-set|get-operator
(defconstant *migemo-opindex-or* 0)
(defconstant *migemo-opindex-nest-in* 1)
(defconstant *migemo-opindex-nest-out* 2)
(defconstant *migemo-opindex-select-in* 3)
(defconstant *migemo-opindex-select-out* 4)
(defconstant *migemo-opindex-newline* 5)

(defconstant *migemo-set-operator-success* 0)
(defconstant *migemo-is-not-enabled* 0)

(defvar *migemo-opindex*
  (list (cons *migemo-opindex-or* "\\|")
	(cons *migemo-opindex-nest-in* "\\(")
	(cons *migemo-opindex-nest-out* "\\)")
	(cons *migemo-opindex-newline* "[ \t\n]*")))

(c:define-dll-entry
  (c:void *) migemo-open-func ((c:char *)) *migemo-dll* "migemo_open")
(c:define-dll-entry
  c:void migemo-close-func ((c:void *)) *migemo-dll* "migemo_close")
(c:define-dll-entry
  (c:u_char *) migemo-query-func ((c:void *)
				  (c:u_char *)) *migemo-dll* "migemo_query")
(c:define-dll-entry
  c:void migemo-release-func ((c:void *)
			      (c:u_char *)) *migemo-dll* "migemo_release")
(c:define-dll-entry
  c:int migemo-set-operator-func ((c:void *)
				  c:int
				  (c:u_char *)) *migemo-dll* "migemo_set_operator")
(c:define-dll-entry
  (c:u_char *) migemo-get-operator-func ((c:void *)
					 c:int) *migemo-dll* "migemo_get_operator")
(c:define-dll-entry
  c:int migemo-is-enable-func ((c:void *)) *migemo-dll* "migemo_is_enable")

(defvar *migemo-saved-hook* nil)

(defun migemo-toggle (&optional (arg nil sv))
  (interactive "p")
  (toggle-mode '*migemo-on* arg sv)
  (if *migemo-on*
      (progn
	(setq *migemo-saved-hook* *isearch-scanner-hook*)
	(setq *isearch-scanner-hook* #'migemo-query))
    (setq *isearch-scanner-hook* *migemo-saved-hook*))
  (migemo-message (if *migemo-on* "on." "off.")))

(defun migemo-open ()
  (interactive)
  (unless *migemo-session*
    (migemo-message "loading ...")
    (unless *migemo-dict-file*
      (migemo-error "辞書ファイルが設定されていません。"))
    (unless (file-exist-p *migemo-dict-file*)
      (migemo-error (format nil "辞書ファイルがありません: ~S" *migemo-dict-file*)))
    (setq *migemo-session*
	  (migemo-open-func (si:make-string-chunk
			     (map-slash-to-backslash *migemo-dict-file*))))
    (unless (migemo-is-enable-p *migemo-session*)
      (migemo-error "辞書が読み込めません"))
    (migemo-init)
    (migemo-message "loading ... done.")
    (add-hook '*kill-xyzzy-hook* 'migemo-close)))

(defun migemo-message (msg)
  (message "Migemo: ~A" msg))

(defun migemo-error (msg)
  (migemo-close)
  (error "Migemo: ~A" msg))

(defun migemo-is-enable-p (sess)
  (not (equal *migemo-is-not-enabled*
	      (migemo-is-enable-func sess))))

(defun migemo-init ()
  (dolist (op *migemo-opindex*)
    (let ((index (car op))
	  (regex (cdr op))
	  result)
      (setq result
	    (migemo-set-operator-func *migemo-session*
				      index
				      (si:make-string-chunk regex)))
      (unless (eq *migemo-set-operator-success* result)
	(migemo-error (format nil "メタ文字指定エラー: ~S:~S" index result)))))
  (run-hooks '*migemo-init-hook*))

(defun migemo-query (query)
  (let (result
	regexp)
    (setq *isearch-regexp* *migemo-on*)
    (migemo-open)
    (unwind-protect
	(progn
	  (migemo-message "converting ...")
	  (setq result (migemo-query-func *migemo-session*
					  (si:make-string-chunk query)))
	  (setq regexp (si:unpack-string
			(si:make-chunk nil *migemo-query-buf* nil result)
			0))
	  (migemo-message "converting ... done."))
      (when result
	(migemo-release-func *migemo-session* result)))
    regexp))

(defun migemo-close ()
  (interactive)
  (when *migemo-session*
    (migemo-message "closing ...")
    (migemo-close-func *migemo-session*)
    (migemo-message "closing ... done.")
    (setq *migemo-session* nil)))

(global-set-key '(#\C-c #\m #\t) 'migemo-toggle)
(global-set-key '(#\C-c #\m #\o) 'migemo-open)
(global-set-key '(#\C-c #\m #\c) 'migemo-close)
