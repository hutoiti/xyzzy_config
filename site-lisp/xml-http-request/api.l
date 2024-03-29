;;;; -*- mode: lisp; package: user -*-
;;;;
;;;; File: xml-http-request/api.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   xml-http-request.l is released under an MIT license.
;;;;   See xml-http-request.l/docs/MIT-LICENSE for full license.
;;;;

(in-package :user)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xml-http-request/request")
  (require "xml-http-request/response")
  )

(provide "xml-http-request/api")

;;;; End
