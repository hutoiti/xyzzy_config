;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: metaWeblog.l,v 1.3 2006/01/13 09:27:28 torihat Exp $
;
; xmlrpcm/metaWeblog.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xmlrpcm/defs"))

(provide "xmlrpcm/metaWeblog")

(in-package "xmlrpcm")

(defun metaWeblog-newPost (url blogid bloguser blogpass content publish)
  (let ((req (list "metaWeblog.newPost"
		   (list nil blogid 'string)
		   (list nil bloguser 'string)
		   (list nil blogpass 'string)
		   (list nil content 'struct)
		   (list nil publish 'boolean)
		   )))
    (xmlrpcm-send-request url req)))

(defun metaWeblog-editPost (url postid bloguser blogpass content publish)
  (let ((req (list "metaWeblog.editPost"
		   (list nil postid 'string)
		   (list nil bloguser 'string)
		   (list nil blogpass 'string)
		   (list nil content 'struct)
		   (list nil publish 'boolean)
		   )))
    (xmlrpcm-send-request url req)))

(defun metaWeblog-getPost (url postid bloguser blogpass)
  (let ((req (list "metaWeblog.getPost"
		   (list nil postid 'string)
		   (list nil bloguser 'string)
		   (list nil blogpass 'string)
		   )))
    (xmlrpcm-send-request url req)))

(defun metaWeblog-getRecentPosts (url blogid bloguser blogpass numberOfPosts)
  (let ((req (list "metaWeblog.getPost"
		   (list nil blogid 'string)
		   (list nil bloguser 'string)
		   (list nil blogpass 'string)
		   (list nil numberOfPosts 'int)
		   )))
    (xmlrpcm-send-request url req)))

(defun metaWeblog-newMediaObject (url blogid bloguser blogpass file)
  (let ((req (list "metaWeblog.newMediaObject"
		   (list nil blogid 'string)
		   (list nil bloguser 'string)
		   (list nil blogpass 'string)
		   (list nil file 'struct)
		   )))
    (xmlrpcm-send-request url req)))
