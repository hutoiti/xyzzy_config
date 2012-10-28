;;;; -*- mode: lisp; package: hatena-star.api -*-
;;;;
;;;; File: hatena-star/api/types/bool.l
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

(defun to-bool (json-value)
  (when (and json-value (numberp json-value))
    (not (zerop json-value))))

(defun result->bool (json)
  (to-bool ($N json "result")))

(defun can-comment->bool (json)
  (to-bool ($N json "can_comment")))


(provide "hatena-star/api/types/bool")

;;;; End
