;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: mt.l,v 1.1.1.1 2006/01/05 09:40:00 torihat Exp $
;
; xmlrpcm/mt.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xmlrpcm/defs"))

(provide "xmlrpcm/mt")

(in-package "xmlrpcm")

(defun mt-getRecentPostTitles (url blogid bloguser blogpass numberOfPosts)
  (let ((req (list "mt.getRecentPostTitles"
		   (list nil blogid 'string)
		   (list nil bloguser 'string)
		   (list nil blogpass 'string)
		   (list nil numberOfPosts 'int)
		   )))
    (xmlrpcm-send-request url req)))

(defun mt-getCategoryList (url blogid bloguser blogpass)
  (let ((req (list "mt.getCategoryList"
		   (list nil blogid 'string)
		   (list nil bloguser 'string)
		   (list nil blogpass 'string))))
    (xmlrpcm-send-request url req)))

(defun mt-getPostCategories (url postid bloguser blogpass)
  (let ((req (list "mt.getPostCategories"
		   (list nil postid 'string)
		   (list nil bloguser 'string)
		   (list nil blogpass 'string))))
    (xmlrpcm-send-request url req)))

(defun mt-setPostCategories (url postid bloguser blogpass categories)
  (let ((req (list "mt.setPostCategories"
		   (list nil postid 'string)
		   (list nil bloguser 'string)
		   (list nil blogpass 'string)
		   (list nil categories 'array)
		   )))
    (xmlrpcm-send-request url req)))

(defun mt-supportedMethods (url)
  (let ((req (list "mt.supportedMethods")))
    (xmlrpcm-send-request url req)))

(defun mt-supportedTextFilters (url)
  (let ((req (list "mt.supportedMethods")))
    (xmlrpcm-send-request url req)))

(defun mt-getTrackbackPings (url postid)
  (let ((req (list "mt.getTrackbackPings"
		   (list nil postid 'string)
		   )))
    (xmlrpcm-send-request url req)))

(defun mt-publishPost (url postid bloguser blogpass)
  (let ((req (list "mt.publishPost"
		   (list nil postid 'string)
		   (list nil bloguser 'string)
		   (list nil blogpass 'string))))
    (xmlrpcm-send-request url req)))

(defun mt-setNextScheduledPost (url postid bloguser blogpass)
  (let ((req (list "mt.setNextScheduledPost"
		   )))
    (error "Not supported.")
    (xmlrpcm-send-request url req)))
