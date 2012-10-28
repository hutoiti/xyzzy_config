;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: defs.l 569 2006-01-27 17:56:30Z torihat $
;
; defs.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xml-parser-modoki")
  (require "junk/lib"))

(defpackage "atomm"
  (:use "lisp" "editor"))

(provide "atomm/defs")

(in-package "atomm")

(defvar *debug-mode* nil)

(defvar *atomm-buffer-temp* "*ATOMM TEMP*")

(defun atomm-set-buffer-temp ()
  (set-buffer (get-buffer-create *atomm-buffer-temp*))
  (erase-buffer (selected-buffer)))

(defun atomm-delete-buffer-temp ()
  (delete-buffer *atomm-buffer-temp*))

(defun atomm-formatDateLocal (timestamp)
  (junk::iso8601-format-datetime timestamp))

(defun atomm-parseDateLocal (str)
  (junk::iso8601-parse-datetime str))
