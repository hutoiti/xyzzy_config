;;;; -*- mode: lisp; package: hatena-star.api -*-
;;;;
;;;; File: hatena-star/api/endpoint.l
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

(export '(*hatena-star-base-uri*
          ))

(defvar *hatena-star-base-uri* "http://s.hatena.ne.jp")
(defvar *hatena-star-format* "json")

(defun hatena-star-uri-blog (uri)
  (format nil "~A/~A" (build-hatena-star-base-uri "blog") uri))

(defun hatena-star-uri-entries (uri-list)
  (build-hatena-star-uri "entries" nil
                         (mapcar #'(lambda (uri)
                                     (list "uri" uri t))
                                 (if (atom uri-list) (list uri-list) uri-list))))

(defun hatena-star-uri-entry (uri)
  (build-hatena-star-uri "entry" uri))

(defun hatena-star-uri-star-add (uri rks &key token title quote location)
  (build-hatena-star-uri "star.add" uri
                         `(("rks" ,rks t)
                           ("token" ,token t)
                           ("title" ,title)
                           ("quote" ,quote)
                           ("location" ,location))))

(defun hatena-star-uri-comment-add (uri rks &key title body)
  (build-hatena-star-uri "comment.add" uri
                         `(("rks" ,rks t)
                           ("title" ,title)
                           ("body" ,body))))

(defun hatena-star-uri-star-deletable (name)
  (build-hatena-star-uri "star.deletable" nil
                         `(("name" ,name))))

(defun hatena-star-uri-star-delete (uri rks &key name quote)
  (build-hatena-star-uri "star.delete" uri
                         `(("rks" ,rks)
                           ("name" ,name)
                           ("quote" ,quote))))


;;;; private

(defun build-hatena-star-uri (method uri-param &optional params)
  (xhr::add-query-string
   (build-hatena-star-base-uri method)
   (encode-params (remove-if-not #'cadr (append1 params (list "uri" uri-param t))))))

(defun build-hatena-star-base-uri (method &optional (format *hatena-star-format*))
  (format nil "~A/~A.~A" (remove-trail-slash *hatena-star-base-uri*) method format))

(defun encode-params (params)
  (xhr::url-join-params
   (mapcar #'(lambda (param) (apply 'encode-param param)) params)))

(defun encode-param (k v &optional asis)
  (xhr::url-join-key-value (xhr::url-encode-value k *encoding-utf8n*)
                           (if asis v (xhr::url-encode-value v *encoding-utf8n*))))


(provide "hatena-star/api/endpoint")

;;;; End
