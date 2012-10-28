;;;; -*- mode: lisp; package: user -*-
;;;;
;;;; File: hatena-haiku-mode/util/package.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package :hatena-haiku.util)
    (defpackage :hatena-haiku.util
      (:use
       :lisp
       :editor
       ))))

(provide "hatena-haiku-mode/util/package")

;;;; End
