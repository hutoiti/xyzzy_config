;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: parser.l 532 2006-01-14 15:34:45Z torihat $
;
; parser.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "atomm/defs"))

(provide "atomm/parser")

(in-package "atomm")

(defun atomm-parse-feed (feed)
  (let ((contents (ed::xmlpm-tag-contents feed))
	(opts  (ed::xmlpm-tag-opts feed))
	options
	entries)
    (dolist (content contents)
      (if (equal "entry" (ed::xmlpm-tag-name content))
	  (push (atomm-parse-entry content) entries)
	(push content options)))
    (values options (nreverse entries) opts)))

(defun atomm-parse-entry (entry)
  entry)
