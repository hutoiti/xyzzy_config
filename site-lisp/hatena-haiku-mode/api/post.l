;;;; -*- mode: lisp; package: hatena-haiku.api -*-
;;;;
;;;; File: hatena-haiku-mode/api/post.l
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
  (require "hatena-haiku-mode/api/about")
  (require "hatena-haiku-mode/api/endpoint")
  (require "hatena-haiku-mode/api/http")
  (require "hatena-haiku-mode/api/account")
  )

(in-package :hatena-haiku.api)

(export '(haiku!
          haiku-reply!
          haiku-delete!
          haiku-relation-add!
          haiku-relation-delete!
          ))

(defun haiku! (word body &key rkm source)
  (haiku-http-post (new-entry-url)
                   `(:word ,word :body ,body
                     :rkm ,(or rkm (hatena-rkm))
                     :source ,source
                     )))

(defun haiku-reply! (reply-to body &key rkm source)
  (haiku-http-post (new-entry-url)
                   `(:reply_to ,reply-to :body ,body
                     :rkm ,(or rkm (hatena-rkm))
                     :source ,source
                     )))

(defun haiku-delete! (entry-id &key rks)
  (let ((r (haiku-http-post (delete-entry-url)
                            `(:entry_id ,entry-id
                              :rks ,(or rks (hatena-rks)))
                            )))
    (string= "Deleted!" r)))

(defun haiku-relation-add! (word1 word2 &key rkm)
  (haiku-http-post (new-relation-url)
                   `(:word1 ,word1 :word2 ,word2
                     :rkm ,(or rkm (hatena-rkm))
                     )))

(defun haiku-relation-delete! (id &key rks)
  (let ((r (haiku-http-post (delete-relation-url)
                            `(:id ,id
                              :rks ,(or rks (hatena-rks))
                              ))))
    (equal (json:json-decode r)
           '(("result" . 1)))))


(provide "hatena-haiku-mode/api/post")

;;;; End
