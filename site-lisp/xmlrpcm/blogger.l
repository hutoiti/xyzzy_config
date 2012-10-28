;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: blogger.l,v 1.1.1.1 2006/01/05 09:40:00 torihat Exp $
;
; xmlrpcm/blogger.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xmlrpcm/defs"))

(provide "xmlrpcm/blogger")

(in-package "xmlrpcm")

(defun blogger-newPost (url appkey blogid bloguser blogpass content publish)
  (let ((req (list "blogger.newPost"
		   (list nil appkey 'string)
		   (list nil blogid 'string)
		   (list nil bloguser 'string)
		   (list nil blogpass 'string)
		   (list nil content 'string)
		   (list nil publish 'boolean)
		   )))
    (xmlrpcm-send-request url req)))

(defun blogger-editPost (url appkey postid bloguser blogpass content publish)
  (let ((req (list "blogger.editPost"
		   (list nil appkey 'string)
		   (list nil postid 'string)
		   (list nil bloguser 'string)
		   (list nil blogpass 'string)
		   (list nil content 'string)
		   (list nil publish 'boolean)
		   )))
    (xmlrpcm-send-request url req)))

(defun blogger-deletePost (url appkey postid bloguser blogpass publish)
  (let ((req (list "blogger.deletePost"
		   (list nil appkey 'string)
		   (list nil postid 'string)
		   (list nil bloguser 'string)
		   (list nil blogpass 'string)
		   (list nil publish 'boolean)
		   )))
    (xmlrpcm-send-request url req)))

(defun blogger-getUsersBlogs (url appkey bloguser blogpass)
  (let ((req (list "blogger.getUsersBlogs"
		   (list nil appkey 'string)
		   (list nil bloguser 'string)
		   (list nil blogpass 'string))))
    (xmlrpcm-send-request url req)))

(defun blogger-getUserInfo (url appkey bloguser blogpass)
  (let ((req (list "blogger.getUserInfo"
		   (list nil appkey 'string)
		   (list nil bloguser 'string)
		   (list nil blogpass 'string))))
    (xmlrpcm-send-request url req)))

(defun blogger-getRecentPosts (url appkey blogid bloguser blogpass numberOfPosts)
  (let ((req (list "blogger.getRecentPosts"
		   (list nil appkey 'string)
		   (list nil blogid 'string)
		   (list nil bloguser 'string)
		   (list nil blogpass 'string)
		   (list nil numberOfPosts 'int))))
    (xmlrpcm-send-request url req)))
