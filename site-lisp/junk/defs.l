;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: defs.l 783 2007-12-23 05:43:51Z torihat $
;
; junk/defs.l
;
; by HATTORI Masashi

(defpackage "junk"
  (:use "lisp" "editor"))

(provide "junk/defs")

(in-package "junk")

(defvar *prog-name* "junk-lib")
(defvar *prog-version* "0.0.0.6")

(defvar *base-directory* "~/.junk")
