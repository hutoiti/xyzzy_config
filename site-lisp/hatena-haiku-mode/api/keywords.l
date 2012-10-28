;;;; -*- mode: lisp; package: hatena-haiku.api -*-
;;;;
;;;; File: hatena-haiku-mode/api/keywords.l
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
  (require "hatena-haiku-mode/api/endpoint")
  (require "hatena-haiku-mode/api/http")
  (require "hatena-haiku-mode/api/scraper")
  )

(in-package :hatena-haiku.api)

(export '(hot-keyword-list
          keyword-list

          keyword-cloud
          keyword-text
          keyword-uri
          keyword-entry-count
          ))

(defparameter *keyword-regexp-base* "<a href=\"\\(.+?\\)\" class=\"keyword\">\\(.+?\\)</a>")

(defparameter *hot-keywords-regexp* `("<li class=\"cloud\\([0-9]+\\)\">"
                                      ,*keyword-regexp-base* "</li>"))
(defparameter *hot-keywords-scrape-rule*
  (define-scraper
   (scrape (*hot-keywords-regexp*)
           (group 1 :cloud :filter 'parse-integer)
           (group 2 :keyword-uri)
           (group 3 :keyword))))

(defparameter *keywords-keyword-regexp* `(,*keyword-regexp-base*
                                          "\\(?:<span class=\"entry-count\">(\\(.+?\\))</span>\\)?"))
(defparameter *keywords-scrape-rule*
  (define-scraper
   (scrape (*keywords-keyword-regexp*)
           (group 1 :keyword-uri)
           (group 2 :keyword)
           (group 3 :entry-count :filter 'parse-integer))))

(defun keyword-cloud (e)
  ($ e :cloud))
(defun keyword-text (e)
  ($ e :keyword))
(defun keyword-uri (e)
  ($ e :keyword-uri))
(defun keyword-entry-count (e)
  ($ e :entry-count))

(defun hot-keyword-list ()
  (scrape (delay (haiku-http-get (hot-keyword-list-url)))
          *hot-keywords-scrape-rule*))

(defun keyword-list (&key word page)
  (keyword-list0 :word word :page page))

(defun keyword-list0 (&key word page)
  (scrape-keyword-list (delay (haiku-http-get (keyword-list-url :word word :page page)))))

(defun scrape-keyword-list (contents)
  (scrape contents *keywords-scrape-rule*))


(provide "hatena-haiku-mode/api/keywords")


;;;; End
