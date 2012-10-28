;;;; -*- mode: lisp; package: user -*-
;;;;
;;;; File: hatena-haiku-mode/ui/package.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-haiku-mode/util")
  (require "hatena-haiku-mode/api")

  (require "hatena-star/api")
  (require "hatena-star/ui")

  (unless (find-package :hatena-haiku.ui)
    (defpackage :hatena-haiku.ui
      (:use
       :lisp
       :editor

       :hatena-haiku.util
       :hatena-haiku.api

       :hatena-star.api
       :hatena-star.ui
       ))))

(provide "hatena-haiku-mode/ui/package")

;;;; End
