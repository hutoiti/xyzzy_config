;;;; -*- mode: lisp; package: user -*-
;;;;
;;;; File: hatena-star/api/package.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-star is released under an MIT license.
;;;;   See hatena-star/docs/MIT-LICENSE for full license.
;;;;

(in-package :user)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xml-http-request")
  (require "json")

  (unless (find-package :hatena-star.api)
    (defpackage :hatena-star.api
      (:use
       :lisp
       :editor

       :xml-http-request
       :json
       ))))


(provide "hatena-star/api/package")

;;;; End
