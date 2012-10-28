;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: movable-type.l 590 2006-02-04 20:11:42Z torihat $
;
; blog/movable-type.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "blog/defs"))

(require "blog/cocolog")

(provide "blog/movable-type")

(in-package "blog")

(defvar *movable-type-blogtype-name* "MovableType")
(defvar *movable-type-endpoint* "")
(defvar *movable-type-preview-template*
  (merge-pathnames "movable-type.html" *template-directory*))

(defvar *movable-type-mt_allow_comments* *blogpost-flag-ok*)
(defvar *movable-type-mt_allow_pings*    *blogpost-flag-ok*)
(defvar *movable-type-mt_convert_breaks* *blogpost-flagstr-ng*)

(defvar *movable-type-timestamp-diff* 0)

(defun movable-type-getUsersBlogs (type &optional (appkey "hogehoge"))
  (let ((*cocolog-mt_allow_comments* *movable-type-mt_allow_comments*)
	(*cocolog-mt_allow_pings*    *movable-type-mt_allow_pings*)
	(*cocolog-mt_convert_breaks* *movable-type-mt_convert_breaks*))
    (declare (special *cocolog-mt_allow_comments*
		      *cocolog-mt_allow_pings*
		      *cocolog-mt_convert_breaks*))
    (cocolog-getUsersBlogs type appkey)))

(defun movable-type-getRecentPostTitles (blog
					 &optional (numberOfPosts *blogtitle-fetch-number*))
  (let ((*cocolog-timestamp-diff* *movable-type-timestamp-diff*))
    (declare (special *cocolog-timestamp-diff*))
    (cocolog-getRecentPostTitles blog numberOfPosts)))

(defun movable-type-getPost (blog title)
  (let ((*cocolog-timestamp-diff* *movable-type-timestamp-diff*))
    (declare (special *cocolog-timestamp-diff*))
    (cocolog-getPost blog title)))

(defun movable-type-newPost (blog
			     post
			     publish)
  (let ((*cocolog-timestamp-diff* *movable-type-timestamp-diff*))
    (declare (special *cocolog-timestamp-diff*))
    (cocolog-newPost blog post publish)))

(defun movable-type-editPost (blog
			      post
			      publish)
  (let ((*cocolog-timestamp-diff* *movable-type-timestamp-diff*))
    (declare (special *cocolog-timestamp-diff*))
    (cocolog-editPost blog post publish)))

(defun movable-type-deletePost (blog
				post
				publish)
  (cocolog-deletePost blog post publish))

(defun movable-type-getCategoryList (blog)
  (cocolog-getCategoryList blog))

(defun movable-type-uploadFile (blog)
  (cocolog-uploadFile blog))

(defun movable-type-previewPost (blog post)
  (post-preview-create blog post *movable-type-preview-template*))

(defun movable-type-blogpostOptions ()
  (make-blogpost
   :userid            t
   :dateCreated       t
   :postid            t
   :description       t
   :title             t
   :link              t
   :permaLink         t
   :mt_excerpt        t
   :mt_text_more      t
   :mt_allow_comments t
   :mt_allow_pings    t
   :mt_convert_breaks t
   :mt_keywords       t
   :mt_tb_ping_urls   t
   :categories        t
   ))

(blogtype-regist (make-blogtype
		  :name             *movable-type-blogtype-name*
		  :endpoint         *movable-type-endpoint*
		  :getblogs         'movable-type-getUsersBlogs
		  :gettitles        'movable-type-getRecentPostTitles
		  :getpost          'movable-type-getPost
		  :newpost          'movable-type-newPost
		  :editpost         'movable-type-editPost
		  :deletepost       'movable-type-deletePost
		  :getcategories    'movable-type-getCategoryList
		  :uploadfile       'movable-type-uploadFile
		  :previewpost      'movable-type-previewPost
		  :blogpost_options 'movable-type-blogpostOptions
		  ))
