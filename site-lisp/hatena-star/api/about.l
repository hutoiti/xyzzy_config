;;;; -*- mode: lisp; package: hatena-star.api -*-
;;;;
;;;; File: hatena-star/api/about.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-star is released under an MIT license.
;;;;   See hatena-star/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-star/api/package")
  )

(in-package :hatena-star.api)

(export '(hatena-star-version
          ))

(defconstant +hatena-star-version+ "1.1.1")
(defconstant +hatena-star-uri+ "http://miyamuko.s56.xrea.com/xyzzy/hatena-star.html")

(defun hatena-star-version ()
  +hatena-star-version+)

(defun hatena-star-uri ()
  +hatena-star-uri+)

(defun hatena-star-product ()
  (format nil "~A/~A" "hatena-star" +hatena-star-version+))

(defun hatena-star-platform ()
  (format nil "~A ~A" (software-type) (software-version)))

(defun hatena-star-user-agent ()
  (format nil "~A (~A; ~A)"
          (hatena-star-product)
          (hatena-star-platform)
          +hatena-star-uri+
          ))


(provide "hatena-star/api/about")

;;;; End
