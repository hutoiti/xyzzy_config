;;;; -*- mode: lisp; package: hatena-haiku.api -*-
;;;;
;;;; File: hatena-haiku-mode/api/entry.l
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
  (require "hatena-haiku-mode/api/endpoint")
  (require "hatena-haiku-mode/api/http")
  (require "hatena-haiku-mode/api/scraper")
  (require "hatena-haiku-mode/api/keywords")
  )

(in-package :hatena-haiku.api)

(export '(recent-entries
          keyword-entries
          user-entries
          user-entries-following
          user-entries-profile

          entry-page-title
          entry-page-subtitle
          entry-page-entries

          entry-keyword
          entry-keyword-uri
          entry-body
          entry-permalink
          entry-username
          entry-timestamp
          entry-source
          entry-source-uri

          user-text
          user-keyword
          ))

(defparameter *entries-title* "<h1><a href=\".*?\">\\(.+?\\)</a></h1>")
(defparameter *entries-subtitle* '("</h1>" :sp "<p>\\(.*?\\)</p>"))
(defparameter *entries-scrape-rule*
  (define-scraper
   (scrape (*entries-title*)
           (group 1 :title))
   (scrape (*entries-subtitle* :multiline t)
           (group 1 :subtitle))))

(defparameter *entry-start-tag* "<div class=\"entry\">")
(defparameter *entry-end-tag* '("</div>" :sp "</div>" :sp "</div>"))
;(defparameter *entry-end-tag* "<div class=\"entry")
(defparameter *entry-username-regexp* "<span class=\"username\">by <a href=\".*?\">\\(.*?\\)</a></span>")
(defparameter *entry-permalink-and-timestamp-regexp* "<span class=\"timestamp\"><a href=\"\\(.*?\\)\">\\(.*?\\)</a></span>")
(defparameter *entry-source-regexp* "from <span class=\"source\"><a href=\"\\(.+?\\)\">\\(.+?\\)</a></span>")
(defparameter *entry-title-regexp* '("<h2 class=\"title\">" :tag*
                                     "<a href=\"\\(.+?\\)\">\\([^<>]+\\)</a>"
                                     "</h2>"))

(defparameter *entry-body-regexp* '("<div class=\"body\">" "\\(.+?\\)" "</div>" :sp "<div class=\"info\">"))
(defparameter *entry-scrape-rule*
  (define-scraper
   (scrape (*entry-username-regexp*)
           (group 1 :username))
   (scrape (*entry-permalink-and-timestamp-regexp*)
           (group 1 :permalink)
           (group 2 :timestamp))
   (scrape (*entry-source-regexp*)
           (group 1 :source-uri)
           (group 2 :source))
   (scrape (*entry-title-regexp*)
           (group 1 :keyword-uri)
           (group 2 :keyword))
   (scrape (*entry-body-regexp* :multiline t)
           (group 1 :body))))

(defparameter *entry-keyword-start-tag* "<ul class=\"list-keyword\">")
(defparameter *entry-keyword-end-tag* "</ul>")

(defparameter *entry-friends-start-tag* "<ul class=\"list-user\">")
(defparameter *entry-friends-end-tag* "</ul>")
(defparameter *entry-friends-user-regexp* "<div class=\"list-image\"><a href=\"/\\(.+?\\)/\">")
(defparameter *entry-friends-keyword-regexp* *keywords-keyword-regexp*)

(defparameter *entry-friends-scrape-rule*
  (define-scraper
   (scrape (*entry-friends-user-regexp*)
           (group 1 :user))
   (scrape (*entry-friends-keyword-regexp*)
           (group 1 :keyword-uri)
           (group 2 :keyword))))


(defparameter *entry-users-start-tag* "<ul class=\"list-image\">")
(defparameter *entry-users-end-tag* "</ul>")
(defparameter *entry-users-regexp* "<li><a href=\"/\\(.+?\\)/\"><img")
(defparameter *entry-users-scrape-rule*
  (define-scraper
   (scrape (*entry-users-regexp*)
           (group 1 :user))))

(defun entry-page-title (e)
  ($ e :title))
(defun entry-page-subtitle (e)
  ($ e :subtitle))
(defun entry-page-entries (e)
  ($ e :entries))

(defun entry-keyword (e)
  ($ e :keyword))
(defun entry-keyword-uri (e)
  ($ e :keyword-uri))
(defun entry-body (e)
  ($ e :body))
(defun entry-permalink (e)
  ($ e :permalink))
(defun entry-username (e)
  ($ e :username))
(defun entry-timestamp (e)
  ($ e :timestamp))
(defun entry-source (e)
  ($ e :source))
(defun entry-source-uri (e)
  ($ e :source-uri))

(defun user-text (e)
  ($ e :user))
(defun user-keyword (e)
  ($ e :keyword))


(defun recent-entries (&key page entries-only)
  (scrape-entries-users-and-keywords (recent-entries-url :page page) entries-only))

(defun scrape-entries-users-and-keywords (url entries-only)
  (let ((contents (delay (haiku-http-get url))))
    (if entries-only
        (scrape-entries contents)
      (values
       (scrape-entries contents)
       (scrape-users (extract-one contents *entry-users-start-tag* *entry-users-end-tag*))
       (scrape-keyword-list (extract-one contents *entry-keyword-start-tag* *entry-keyword-end-tag*))))))


(defun keyword-entries (keyword &key hot page entries-only)
  (let ((contents (delay (haiku-http-get (keyword-entries-url keyword :hot hot :page page)))))
    (if entries-only
        (scrape-entries contents)
      (values
       (scrape-entries contents)
       (scrape-friends (extract-one contents *entry-friends-start-tag* *entry-friends-end-tag*))
       (scrape-keyword-list (extract-one contents *entry-keyword-start-tag* *entry-keyword-end-tag*))))))


(defun user-entries (user &key hot page entries-only)
  (scrape-entries-friends-and-keywords
   (user-entries-url user :hot hot :page page)
   entries-only))

(defun user-entries-following (user &key page entries-only)
  (scrape-entries-friends-and-keywords
   (user-entries-following-url user :page page)
   entries-only))

(defun user-entries-profile (user &key hot page entries-only)
  (scrape-entries-friends-and-keywords
   (user-entries-profile-url user :hot hot :page page)
   entries-only))

(defun scrape-entries-friends-and-keywords (url entries-only)
  (let ((contents (delay (haiku-http-get url))))
    (if entries-only
        (scrape-entries contents)
      (values
       (scrape-entries contents)
       (scrape-friends (extract-one contents *entry-friends-start-tag* *entry-friends-end-tag*))
       (scrape-keyword-list (extract-one contents *entry-keyword-start-tag* *entry-keyword-end-tag*))))))


;;;; private

(defun scrape-entries (contents)
  (append1
   (scrape-one contents *entries-scrape-rule*)
   (cons :entries (parse-entries (extract contents *entry-start-tag* *entry-end-tag*)))))

(defun parse-entries (entries)
  (compact (mapcar #'parse-entry entries)))

(defun parse-entry (entry)
  (scrape-one entry *entry-scrape-rule*))

(defun scrape-friends (contents)
  (scrape contents *entry-friends-scrape-rule*))

(defun scrape-users (contents)
  (scrape contents *entry-users-scrape-rule*))


(provide "hatena-haiku-mode/api/entry")

;;;; End
