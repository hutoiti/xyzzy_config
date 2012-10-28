;;;; -*- mode: lisp; package: hatena-haiku.ui -*-
;;;;
;;;; File: hatena-haiku-mode/ui/color.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-haiku-mode/ui/package")
  (require "hatena-haiku-mode/ui/config")
  )

(in-package :hatena-haiku.ui)

(export '(haiku-set-hot-keyword-color
          ))

(defun hot-keyword-color (cloud)
  (when (< 0 cloud (1+ (length *haiku-hot-keyword-color-list*)))
    (nth (1- cloud) *haiku-hot-keyword-color-list*)))

(defun haiku-set-hot-keyword-color (cloud &rest color)
  (when (< 0 cloud (1+ (length *haiku-hot-keyword-color-list*)))
    (setf (nth (1- cloud) *haiku-hot-keyword-color-list*) color)))

(defun haiku-set-text-attribute (from to tag text-attributes)
  (if *haiku-disable-color*
      (apply 'set-text-attribute from to tag nil)
    (apply 'set-text-attribute from to tag text-attributes)))


(provide "hatena-haiku-mode/ui/color")

;;;; End
