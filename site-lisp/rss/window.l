;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: window.l 731 2006-09-01 18:09:41Z torihat $
;
; rss/window.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "rss/defs")
  (require "rss/macro"))

(provide "rss/window")

(in-package "rss")

(defvar *rss-window-menu* nil)
(defvar *rss-window-channel* nil)
(defvar *rss-window-browser* nil)

(defun rss-select-window-menu ()
  (set-window *rss-window-menu*))

(defun rss-select-window-channel ()
  (set-window *rss-window-channel*))

(defun rss-select-window-browser ()
  (set-window *rss-window-browser*))

(defun rss-menu-only ()
  (rss-set-buffer-menu)
  (delete-other-windows))

(defun rss-menu-split-window ()
  (let ((cur (buffer-name (selected-buffer))))
    (rss-set-buffer-menu)
    (delete-other-windows)
    (split-window-vertically *rss-menu-width*)
    (other-window 1)
    (setq *rss-window-channel* (selected-window))
    (set-buffer cur)))

(defun rss-jump-split-window ()
  (let ((cur (buffer-name (selected-buffer))))
    (rss-menu-split-window)
    (set-buffer cur)
    (when *rss-item-window-height*
      (split-window *rss-item-window-height*)
      (other-window 1))
    (setq *rss-window-browser* (selected-window))))
