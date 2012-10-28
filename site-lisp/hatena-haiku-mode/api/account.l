;;;; -*- mode: lisp; package: hatena-haiku.api -*-
;;;;
;;;; File: hatena-haiku-mode/api/account.l
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

(export '(hatena-rkm
          hatena-username
          hatena-rks
          store-rks
          hatena-welcome-message
          parse-hatena-id
          make-hatena-id
          ))

(defparameter *username* nil)
(defparameter *rkm* nil)
(defparameter *rks* nil)

(defparameter *rkm-regexp* "<input type=\"hidden\" name=\"rkm\" value=\"\\(.+?\\)\" />")
(defparameter *username-regexp* "<p class=\"username\">‚æ‚¤‚±‚» <a href=\".*?\">\\(.+?\\)</a> ‚³‚ñ</p>")
(defparameter *login-scrape-rule*
  (define-scraper
   (scrape (*username-regexp*)
           (group 1 :username))
   (scrape (*rkm-regexp*)
           (group 1 :rkm))))

(defun refresh-login-info ()
  (store-login-info (delay (with-if-modified-since-unix-epoch
                             (haiku-http-get (recent-entries-url)))))
  (list *username* *rkm*))

(defun store-login-info (contents)
  (let ((info (scrape-one contents *login-scrape-rule*)))
    (setf *username* ($ info :username)
          *rkm* ($ info :rkm))))

(defun hatena-rkm ()
  (or *rkm*
      (cadr (refresh-login-info))
      (login-hatena 'hatena-rkm)))

(defun hatena-username ()
  (or *username*
      (car (refresh-login-info))
      (login-hatena 'hatena-username)))

(defun login-hatena (callback)
  (plain-error "IE ‚Å‚Í‚Ä‚È‚ÉƒƒOƒCƒ“‚µ‚Ä‚­‚¾‚³‚¢"))

(defun store-rks (rks)
  (when rks
    (setf *rks* rks)))

(defun hatena-rks ()
  (or *rks*
      (login-hatena nil)))


(defun hatena-welcome-message ()
  (format nil "‚æ‚¤‚±‚» ~A ‚³‚ñ" (hatena-username)))


(defun parse-hatena-id (str)
  ;; http://d.hatena.ne.jp/keyword/%A4%CF%A4%C6%A4%CAID
  (when (string-match "^id:\\([a-zA-Z][a-zA-Z0-9_-]\\{1,30\\}[a-zA-Z0-9]\\)$" str)
    (match-string 1)))

(defun make-hatena-id (str)
  (concat "id:" (or (parse-hatena-id str) str)))


(provide "hatena-haiku-mode/api/account")

;;;; End
