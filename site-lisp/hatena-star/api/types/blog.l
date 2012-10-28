;;;; -*- mode: lisp; package: hatena-star.api -*-
;;;;
;;;; File: hatena-star/api/types/blog.l
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
  (require "hatena-star/api/util")
  )

(in-package :hatena-star.api)

(export '(hatena-star-blog-p
          hatena-star-blog-title
          hatena-star-blog-uri
          hatena-star-blog-star-count
          ))

(defstruct hatena-star-blog
  title uri star-count)

(defun blog-json->lisp-value (json)
  (make-hatena-star-blog
   :title ($ json "title")
   :uri ($ json "uri")
   :star-count ($N json "star_count")))


(provide "hatena-star/api/types/blog")

;;;; End
