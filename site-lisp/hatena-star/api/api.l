;;;; -*- mode: lisp; package: hatena-star.api -*-
;;;;
;;;; File: hatena-star/api/api.l
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
  (require "hatena-star/api/types")
  (require "hatena-star/api/endpoint")
  (require "hatena-star/api/http")
  )

(in-package :hatena-star.api)

(export '(hatena-star-get-blog
          hatena-star-get-entries
          hatena-star-get-entry
          hatena-star-add-star
          hatena-star-add-comment
          hatena-star-deletable-p
          hatena-star-delete-star
          ))

(defun hatena-star-get-blog (blog-uri &key since nomsg callback future)
  (check-type blog-uri string)
  (hatena-star-request (hatena-star-uri-blog blog-uri)
                       callback future
                       'blog-json->lisp-value
                       since nomsg))

(defun hatena-star-get-entries (permalink-list &key since nomsg callback future)
  (unless (or (stringp permalink-list) (listp permalink-list))
    (type-error permalink-list '(or string list)))
  (hatena-star-request (hatena-star-uri-entries permalink-list)
                       callback future
                       (if (stringp permalink-list)
                           'entries1/rks-json->lisp-values
                         'entries/rks-json->lisp-values)
                       since nomsg))

(defun hatena-star-get-entry (permalink-or-entry &key since nomsg callback future)
  (hatena-star-request (hatena-star-uri-entry (->link permalink-or-entry))
                       callback future
                       'entries1-json->lisp-value
                       since nomsg))


(defun hatena-star-add-star (permalink-or-entry rks &key nomsg callback future token title quote)
  (check-type rks string)
  (hatena-star-request (hatena-star-uri-star-add (->link permalink-or-entry)
                                                 rks :token token :title title :quote quote)
                       callback future
                       'star-json->lisp-value
                       :epoch nomsg))

(defun hatena-star-add-comment (permalink-or-entry rks &key nomsg callback future title body)
  (check-type rks string)
  (hatena-star-request (hatena-star-uri-comment-add (->link permalink-or-entry)
                                                    rks :title title :body body)
                       callback future
                       'comment-json->lisp-value
                       :epoch nomsg))

(defun hatena-star-deletable-p (name-or-star &key nomsg callback future)
  (hatena-star-request (hatena-star-uri-star-deletable (->name name-or-star))
                       callback future
                       'result->bool
                       :epoch nomsg))

(defun hatena-star-delete-star (permalink-or-entry rks &key nomsg callback future star name quote)
  (check-type rks string)
  (when star
    (if (starp star)
        (multiple-value-setq (name quote) (hatena-star-star-values star))
      (type-error star "malformed star")))
  (hatena-star-request (hatena-star-uri-star-delete (->link permalink-or-entry)
                                                    rks :name name :quote quote)
                       callback future
                       'result->bool
                       :epoch nomsg))


;;;; private

(defun ->name (name-or-star)
  (cond ((stringp name-or-star)
         name-or-star)
        ((starp name-or-star)
         (star-name name-or-star))
        (t
         (type-error name-or-entry "star or name"))))

(defun ->link (permalink-or-entry)
  (cond ((stringp permalink-or-entry)
         permalink-or-entry)
        ((hatena-star-entry-p permalink-or-entry)
         (hatena-star-entry-uri permalink-or-entry))
        (t
         (type-error permalink-or-entry "entry or permalink"))))

(defun hatena-star-request (uri callback future filter since nomsg)
  (hatena-star-get-json uri
                        :future future
                        :async (not (null callback))
                        :filter filter
                        :callback callback
                        :since since
                        :nomsg nomsg
                        ))


(provide "hatena-star/api/api")

;;;; End
