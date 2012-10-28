;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: clip.l 731 2006-09-01 18:09:41Z torihat $
;
; rss/clip.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "rss/defs")
  (require "rss/macro"))

(require "rss/format")
(require "rss/rss")

(provide "rss/clip")

(in-package "rss")

(defvar *rss-clip-map* (make-sparse-keymap))
(define-key *rss-clip-map* #\RET    'rss-jump)
(define-key *rss-clip-map* #\Right  'rss-jump)
(define-key *rss-clip-map* #\Down   'rss-item-next)
(define-key *rss-clip-map* #\C-n    'rss-item-next)
(define-key *rss-clip-map* #\Up     'rss-item-prev)
(define-key *rss-clip-map* #\C-p    'rss-item-prev)
(define-key *rss-clip-map* #\n      'rss-jump-next)
(define-key *rss-clip-map* #\p      'rss-jump-prev)
(define-key *rss-clip-map* #\d      'rss-item-toggle-description)
(define-key *rss-clip-map* #\D      'rss-clip-delete)
(define-key *rss-clip-map* #\o      'rss-jump-in-other-browser)
(define-key *rss-clip-map* #\q      'rss-clip-close)
(define-key *rss-clip-map* #\c      'rss-close-browser)
(define-key *rss-clip-map* #\SPC    'rss-jump-or-scroll)
(define-key *rss-clip-map* #\C-Down 'rss-browser-scroll-down)
(define-key *rss-clip-map* #\C-Up   'rss-browser-scroll-up)
(define-key *rss-clip-map* #\C-h    'rss-jump-prev-or-scroll-up)
(define-key *rss-clip-map* #\v      'rss-popup-current-item)
(define-key *rss-clip-map* #\V      'rss-popup-current-item-and-copy)
(define-key *rss-clip-map* #\M-t    'rss-toggle-online)

(defun rss-clip-close ()
  (interactive)
  (when (rss-browser-open-p)
    (rss-close-browser))
  ;(delete-other-windows)
  (when *rss-clip-window-conf-backup*
    (set-window-configuration *rss-clip-window-conf-backup*)
    (setq *rss-clip-window-conf-backup* nil)))

(defun rss-clip-mode ()
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
  (use-keymap *rss-clip-map*))

(defun rss-clip-mode-line ()
  (setq mode-line-format (format nil "%b"))
  (setq title-bar-format (format nil "~A" *prog-name*)))

(defun rss-set-buffer-clip ()
  (set-buffer (get-buffer-create *rss-buffer-clip*)))

(defun rss-save-clip ()
  (junk::data-write-to-file *rss-clip-file*
			    *rss-clip-list*))

(defun rss-load-clip ()
  (when (file-exist-p *rss-clip-file*)
    (setq *rss-clip-list*
	  (junk::data-read-from-file *rss-clip-file*))))

(defun rss-open-clip ()
  (interactive)
  (rss-close-browser)
  (setq *rss-clip-window-conf-backup*
	(current-window-configuration))
  (rss-set-buffer-group)
  (delete-other-windows)
  (split-window-vertically *rss-menu-width*)
  (other-window)
  (rss-set-buffer-clip)
  (rss-clip-mode)
  (rss-clip-mode-line)
  (rss-clip-print)
  (goto-char (point-min))
  (rss-item-next))

(defun rss-clip-print ()
  (let ((buffer-read-only nil))
    (declare (special buffer-read-only))
    (setq *rss-channel* *rss-clip-channel*)
    (setq *rss-item-list* (reverse *rss-clip-list*))
    (erase-buffer (selected-buffer))
    (rss-print-items))
  (rss-clip-mode)
  (rss-clip-mode-line))

(defun rss-clip-add (item)
  (let (len)
    (unless (assoc item *rss-clip-list* :test #'equal)
      (push (cons item t) *rss-clip-list*)
      (when (< *rss-clip-max-number*
	       (setq len (length *rss-clip-list*)))
	(setq *rss-clip-list*
	      (nbutlast *rss-clip-list* (- len *rss-clip-max-number*))))
      (rss-save-clip)
      (message "clip: ~A" (rss-title item)))))

(defun rss-clip-delete ()
  (interactive)
  (multiple-value-bind (item flags num)
      (rss-item-current)
    (when item
      (setq *rss-clip-list*
	    (delete item *rss-clip-list* :test #'equal :key #'car))
      (rss-save-clip)
      (rss-clip-print)
      (rss-item-go (min num
			(1- (length *rss-item-list*)))))))
