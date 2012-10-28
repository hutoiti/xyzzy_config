;;;; -*- mode: lisp; package: user -*-
;;;;
;;;; File: hatena-haiku-mode/api/package.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xml-http-request")
  (require "json")
  (require "hatena-star/api")
  (require "hatena-haiku-mode/util")

  (unless (find-package :hatena-haiku.api)
    (defpackage :hatena-haiku.api
      (:use
       :lisp
       :editor

       :json
       :xml-http-request
       :hatena-star.api
       :hatena-haiku.util
       ))))

(provide "hatena-haiku-mode/api/package")

;;;; End
