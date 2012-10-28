;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: macro.l 731 2006-09-01 18:09:41Z torihat $
;
; rss/macro.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "rss/defs"))

(provide "rss/macro")

(in-package "rss")

(defmacro rss-value (key list)
  `(cdr (assoc ,key ,list :test #'equal)))

(defmacro rss-title (list)
  `(rss-value "title" ,list))
(defmacro rss-link (list)
  `(rss-value "link" ,list))
(defmacro rss-description (list)
  `(rss-value "description" ,list))
(defmacro rss-siteurl (list)
  `(rss-value "url" ,list))
(defmacro rss-id (list)
  `(rss-value "id" ,list))
(defmacro rss-date (list)
  `(rss-value "date" ,list))
(defmacro rss-timestamp (list)
  `(rss-value "timestamp" ,list))
(defmacro rss-item-number-all (list)
  `(rss-value "item-number-all" ,list))
(defmacro rss-item-number-unread (list)
  `(rss-value "item-number-unread" ,list))
(defmacro rss-item-site (list)
  `(rss-value "site" ,list))

(defmacro rss-group-name (group)
  `(car ,group))
(defmacro rss-group-number-all (group)
  `(cadr ,group))
(defmacro rss-group-number-unread (group)
  `(caddr ,group))
