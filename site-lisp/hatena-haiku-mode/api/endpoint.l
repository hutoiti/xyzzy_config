;;;; -*- mode: lisp; package: hatena-haiku.api -*-
;;;;
;;;; File: hatena-haiku-mode/api/endpoint.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2008 MIYAMUKO Katsuyuki.
;;;;
;;;;   hatena-haiku-mode is released under an MIT license.
;;;;   See hatena-haiku-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "hatena-haiku-mode/api/package")
  )

(in-package :hatena-haiku.api)

(export '(set-hatena-haiku-base-url
          new-entry-url
          recent-entries-url
          keyword-entries-url
          hot-keyword-list-url
          keyword-list-url
          user-entries-url
          user-entries-following-url
          user-entries-profile-url
          entry-permanent-url
          url-path
          ))

(defparameter *hatena-haiku-base-url-jp* "http://h.hatena.ne.jp")
(defparameter *hatena-haiku-base-url-com* "http://h.hatena.com")
(defparameter *hatena-haiku-base-url* *hatena-haiku-base-url-jp*)


(defparameter *new-entry-path* "/entry")
(defparameter *delete-entry-path* "/entry.delete.json")

(defparameter *new-relation-path* "/relation")
(defparameter *delete-relation-path* "/relation.delete.json")

(defparameter *hot-keyword-list-path* "/hotkeywords")
(defparameter *keyword-list-path* "/keywords")

(defparameter *keyword-path-base* "/keyword/~A")

(defparameter *user-following-path-base* "/~A/following")
(defparameter *user-profile-path-base* "/id/~A")
(defparameter *user-entries-path-base* "/~A/")


(defmacro format-haiku-url (path &rest args)
  `(concat *hatena-haiku-base-url* (format nil ,path ,@args)))

(defun set-hatena-haiku-base-url (url)
  (setf *hatena-haiku-base-url* (remove-trail-slash url)))

(defun new-entry-url ()
  (format-haiku-url *new-entry-path*))

(defun delete-entry-url ()
  (format-haiku-url *delete-entry-path*))


(defun new-relation-url ()
  (format-haiku-url *new-relation-path*))

(defun delete-relation-url ()
  (format-haiku-url *delete-relation-path*))


(defun recent-entries-url (&key page)
  (pagerize (format-haiku-url "/") page))

(defun keyword-entries-url (keyword &key hot page (encode t))
  (let ((url (format-haiku-url *keyword-path-base*
                               (if encode (url-encode-utf8 keyword) keyword))))
    (pagerize (append-mode url hot) page)))

(defun hot-keyword-list-url ()
  (format-haiku-url *hot-keyword-list-path*))

(defun keyword-list-url (&key word page)
  (let ((url (format-haiku-url *keyword-list-path*)))
    (pagerize (if word (join-url url "word" word) url) page)))

(defun user-entries-url (user &key hot page)
  (pagerize
   (append-mode (format-haiku-url *user-entries-path-base* user) hot)
   page))

(defun user-entries-following-url (user &key page)
  (pagerize
   (format-haiku-url *user-following-path-base* user)
   page))

(defun user-entries-profile-url (user &key hot page)
  (pagerize
   (append-mode (format-haiku-url *user-profile-path-base* user) hot)
   page))

(defun entry-permanent-url (permalink)
  (format-haiku-url permalink))

(defun url-path (url)
  (values (substitute-string url "^[a-z]+://[^/]+" "")))

(defun append-mode (url hot)
  (if hot (join-url url "mode" "hot") url))

(defun pagerize (base-url page)
  (if (or (not page)
          (< page 2))
      base-url
    (join-url base-url "page" page)))

(defun join-url (base-url key value)
  (xhr::add-query-params base-url (list key value)
                         :encoding *encoding-utf8n*))


(provide "hatena-haiku-mode/api/endpoint")

;;;; End
