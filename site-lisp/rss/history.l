;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: history.l 731 2006-09-01 18:09:41Z torihat $
;
; rss/history.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "rss/defs")
  (require "rss/macro"))

(require "rss/format")
(require "rss/rss")

(provide "rss/history")

(in-package "rss")

(defvar *rss-history-map* (make-sparse-keymap))
(define-key *rss-history-map* #\RET    'rss-jump)
(define-key *rss-history-map* #\Right  'rss-jump)
(define-key *rss-history-map* #\@      'rss-history-clip)
(define-key *rss-history-map* #\Down   'rss-item-next)
(define-key *rss-history-map* #\C-n    'rss-item-next)
(define-key *rss-history-map* #\Up     'rss-item-prev)
(define-key *rss-history-map* #\C-p    'rss-item-prev)
(define-key *rss-history-map* #\n      'rss-jump-next)
(define-key *rss-history-map* #\p      'rss-jump-prev)
(define-key *rss-history-map* #\d      'rss-item-toggle-description)
(define-key *rss-history-map* #\o      'rss-jump-in-other-browser)
(define-key *rss-history-map* #\q      'rss-history-close)
(define-key *rss-history-map* #\c      'rss-close-browser)
(define-key *rss-history-map* #\SPC    'rss-jump-or-scroll)
(define-key *rss-history-map* #\C-Down 'rss-browser-scroll-down)
(define-key *rss-history-map* #\C-Up   'rss-browser-scroll-up)
(define-key *rss-history-map* #\C-h    'rss-jump-prev-or-scroll-up)
(define-key *rss-history-map* #\v      'rss-popup-current-item)
(define-key *rss-history-map* #\V      'rss-popup-current-item-and-copy)
(define-key *rss-history-map* #\M-t    'rss-toggle-online)

(defun rss-history-close ()
  (interactive)
  (rss-clip-close))

(defun rss-history-mode ()
  (setq need-not-save t)
  (setq buffer-read-only t)
  (setq kept-undo-information nil)
  (setq auto-save nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-line-number* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-newline* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-eof* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-cursor-line* t)
;  (set-local-window-flags (selected-buffer)
;			  *window-flag-vscroll-bar* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-tab* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-just-inverse* t)
  (set-buffer-fold-width t)
  (make-local-variable 'mode-line-format)
  (make-local-variable 'title-bar-format)
  (use-keymap *rss-history-map*))

(defun rss-history-mode-line ()
  (rss-clip-mode-line))

(defun rss-set-buffer-history ()
  (set-buffer (get-buffer-create *rss-buffer-history*)))

(defun rss-save-history ()
  (junk::data-write-to-file *rss-history-file*
			    *rss-history-list*))

(defun rss-load-history ()
  (when (file-exist-p *rss-history-file*)
    (setq *rss-history-list*
	  (junk::data-read-from-file *rss-history-file*))))

(defun rss-open-history ()
  (interactive)
  (rss-close-browser)
  (setq *rss-clip-window-conf-backup*
	(current-window-configuration))
  (rss-set-buffer-group)
  (delete-other-windows)
  (split-window-vertically *rss-menu-width*)
  (other-window)
  (rss-set-buffer-history)
  (rss-history-mode)
  (rss-history-mode-line)
  (rss-history-print)
  (goto-char (point-min))
  (rss-item-next))

(defun rss-history-print ()
  (let ((buffer-read-only nil))
    (declare (special buffer-read-only))
    (setq *rss-channel* *rss-history-channel*)
    (setq *rss-item-list* (reverse *rss-history-list*))
    (erase-buffer (selected-buffer))
    (rss-print-items))
  (rss-history-mode)
  (rss-history-mode-line))

(defun rss-history-add (item)
  (let (len)
    (setq *rss-history-list*
	  (delete item *rss-history-list* :test #'equal :key #'car))
    (push (cons item t) *rss-history-list*)
    (when (< *rss-history-max-number*
	     (setq len (length *rss-history-list*)))
      (setq *rss-history-list*
	    (nbutlast *rss-history-list* (- len *rss-history-max-number*))))
    (rss-save-history)))

(defun rss-history-clip ()
  (interactive)
  (multiple-value-bind (item flags num)
      (rss-item-current)
    (when item
      (rss-clip-add item))))
