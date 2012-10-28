;;;; -*- mode: lisp; package: hatena-haiku.api -*-
;;;;
;;;; File: hatena-haiku-mode/api/star.l
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
  (require "hatena-haiku-mode/api/http")
  )

(in-package :hatena-haiku.api)

(export '(haiku-star-get-entries-future
          haiku-star-add-star
          ))

(defun haiku-star-get-entries-future (urls)
  (hatena-star-get-entries urls
                           :future t
                           :since (unless *http-get-no-if-modified-since*
                                    *http-get-if-modified-since*)))

(defun haiku-star-add-star (&rest args)
  (apply 'hatena-star-add-star args))


(provide "hatena-haiku-mode/api/star")

;;;; End
