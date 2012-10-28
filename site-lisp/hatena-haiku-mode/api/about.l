;;;; -*- mode: lisp; package: hatena-haiku.api -*-
;;;;
;;;; File: hatena-haiku-mode/api/about.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008-2009 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-haiku-mode/api/package")
  )

(in-package :hatena-haiku.api)

(export '(hatena-haiku-mode-name
          hatena-haiku-mode-version
          hatena-haiku-mode-uri
          hatena-haiku-mode-product
          hatena-haiku-mode-platform
          hatena-haiku-mode-user-agent
          ))

(defconstant +hatena-haiku-mode-name+ "hatena-haiku-mode")
(defconstant +hatena-haiku-mode-version+ "0.3.2")
(defconstant +hatena-haiku-mode-uri+ "http://miyamuko.s56.xrea.com/xyzzy/hatena-haiku-mode.html")

(defun hatena-haiku-mode-name ()
  +hatena-haiku-mode-name+)

(defun hatena-haiku-mode-version ()
  +hatena-haiku-mode-version+)

(defun hatena-haiku-mode-uri ()
  +hatena-haiku-mode-uri+)

(defun hatena-haiku-mode-product ()
  (format nil "~A/~A" +hatena-haiku-mode-name+ +hatena-haiku-mode-version+))

(defun hatena-haiku-mode-platform ()
  (format nil "~A ~A" (software-type) (software-version)))

(defun hatena-haiku-mode-user-agent ()
  (format nil "~A (~A; ~A)"
          (hatena-haiku-mode-product)
          (hatena-haiku-mode-platform)
          +hatena-haiku-mode-uri+
          ))


(provide "hatena-haiku-mode/api/about")

;;;; End
