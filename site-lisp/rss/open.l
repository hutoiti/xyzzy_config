;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: open.l 731 2006-09-01 18:09:41Z torihat $
;
; rss/open.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "rss/defs")
  (require "rss/macro"))

(require "browserex")

(provide "rss/open")

(in-package "rss")

(defvar *rss-browser-position* bx::XPIS_BOTTOM)
(defvar *rss-browser-height* 400)

(defun rss-browser-open-p ()
  (bx::browser-open-p))

(defun rss-open-url (url)
  (bx::navigate url
		:position *rss-browser-position*
		:size *rss-browser-height*))

(defun rss-close-browser ()
  (interactive)
  (bx::close-browser))

(defun rss-browser-scroll-down ()
  (interactive)
  (bx::browserex-scroll-down))

(defun rss-browser-scroll-up ()
  (interactive)
  (bx::browserex-scroll-up))

(defun rss-close ()
  (interactive)
  (if (rss-browser-open-p)
      (rss-close-browser)
    (progn
      (clear-reverse-region)
      (rss-menu-only)
      (rss-close-browser))))
