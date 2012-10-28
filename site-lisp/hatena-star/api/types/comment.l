;;;; -*- mode: lisp; package: hatena-star.api -*-
;;;;
;;;; File: hatena-star/api/types/comment.l
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

(export '(hatena-star-comment-values
          hatena-star-comment-name
          hatena-star-comment-body
          ))

(defmacro comment-name (comment) `(car ,comment))
(defmacro comment-body (comment) `(cdr ,comment))

(defun hatena-star-comment-values (comment)
  (values (comment-name comment)
          (comment-body comment)))

(defun hatena-star-comment-name (comment)
  (comment-name comment))

(defun hatena-star-comment-body (comment)
  (comment-body comment))


(defun comments-json->lisp-value (json)
  (mapcar #'comment-json->lisp-value json))

(defun comment-json->lisp-value (json)
  (cons ($ json "name") ($ json "body")))


(provide "hatena-star/api/types/comment")

;;;; End
