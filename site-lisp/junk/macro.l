;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: macro.l 769 2007-12-14 19:18:39Z torihat $
;
; junk/macro.l
;
; by HATTORI Masashi

(require "junk/defs")

(provide "junk/macro")

(in-package "junk")

(setf (get 'modify-read-only-buffer 'lisp-indent-hook) 1)

(defmacro modify-read-only-buffer (&body body)
  `(let ((buffer-read-only nil))
     (declare (special buffer-read-only))
     ,@body))

(setf (get 'interval-message 'lisp-indent-hook) 1)

(defmacro interval-message ((interval) &body body)
  `(let ((#1=#:last-tick (+ (get-internal-real-time) ,interval))
	 (#2=#:tick))
     (flet ((message (&rest args)
	      (setq #2# (get-internal-real-time))
	      (when (> #2# #1#)
		(setq #1# (+ #2# ,interval))
		(apply #'message args))))
       ,@body)))
