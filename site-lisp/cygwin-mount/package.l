;;;; -*- mode: lisp; package: user -*-
;;;;
;;;; File: cygwin-mount/package.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   cygwin-mount is released under an MIT license.
;;;;   See cygwin-mount/docs/MIT-LICENSE for full license.
;;;;

(unless (find-package :cygwin-mount)
  (defpackage :cygwin-mount
    (:nicknames :cygmount)
    (:use
     :lisp
     :editor ;; registry ŠÖ˜A‚Æ‚©
     )))


(provide "cygwin-mount/package")

;;;; End
