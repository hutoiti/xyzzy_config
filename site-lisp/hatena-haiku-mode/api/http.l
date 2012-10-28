;;;; -*- mode: lisp; package: hatena-haiku.api -*-
;;;;
;;;; File: hatena-haiku-mode/api/http.l
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
  (require "hatena-haiku-mode/api/package")
  (require "hatena-haiku-mode/api/if-modified-since")
  )

(in-package :hatena-haiku.api)

(defparameter *haiku-encoding* *encoding-utf8n*)

(defun haiku-http-headers ()
  `(:User-Agent ,(hatena-haiku-mode-user-agent)))

(defun haiku-http-get (url)
  (xhr-get url :key 'xhr-response-text
           :since (unless *http-get-no-if-modified-since*
                    *http-get-if-modified-since*)
           :headers (haiku-http-headers)
           ))

(defun haiku-http-post (url data)
  (xhr-post url data :key 'xhr-response-text
            :encoding *haiku-encoding*
            :headers (haiku-http-headers)
            ))


(provide "hatena-haiku-mode/api/http")

;;;; End
