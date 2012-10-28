;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: open-www.l 731 2006-09-01 18:09:41Z torihat $
;
; rss/open-www.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "rss/defs")
  (require "rss/macro")
  (require "www/www"))

(require "rss/open")

(provide "rss/open-www")

(in-package "rss")

(defvar *rss-www-open-p* nil)

(defun rss-open-url (url)
  (rss-jump-split-window)
  (let ((www::*www-pframe-name* *pframe-name*))
    (declare (special www::*www-pframe-name*))
    (www::www-init)
    (refresh-screen)
    (www::www-open url)
    (rss-jump-mode))
  (rss-select-window-channel)
  (setq *rss-www-open-p* t))

(defun rss-jump-mode ()
  (set-local-window-flags (selected-buffer)
			  *window-flag-line-number* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-newline* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-eof* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-cursor-line* t)
  (set-buffer-fold-width nil))

(defun rss-browser-open-p ()
  *rss-www-open-p*)

(defun rss-close-browser ()
  (interactive)
  (clear-reverse-region)
  (rss-menu-split-window)
  (setq *rss-www-open-p* nil))

(defun rss-browser-scroll-down ()
  (interactive)
  (rss-select-window-browser)
  (if (pos-visible-in-window-p (point-max))
      (progn
	(rss-select-window-channel)
	(rss-close-browser)
	(forward-line 1))
    (progn
      (next-page)
      (rss-select-window-channel))))

(defun rss-browser-scroll-up ()
  (interactive)
  (rss-select-window-browser)
  (if (pos-visible-in-window-p (point-min))
      (progn
	(rss-select-window-channel)
	(rss-close-browser))
    (progn
      (previous-page)
      (rss-select-window-channel))))

(defun rss-close ()
  (interactive)
  (if (rss-browser-open-p)
      (rss-close-browser)
    (progn
      (clear-reverse-region)
      (rss-menu-only))))

;(add-hook '*rss-finish-hook* 'www::www-exit)
