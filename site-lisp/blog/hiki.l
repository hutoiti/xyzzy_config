;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: hiki.l,v 1.11 2006/01/21 18:24:53 torihat Exp $
;
; blog/hiki.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "blog/defs"))

(require "blog/fswiki")

(provide "blog/hiki")

(in-package "blog")

(defvar *hiki-blogtype-name* "Hiki")
(defvar *hiki-endpoint* nil)
(defvar *hiki-preview-template*
  (merge-pathnames "hiki.html" *template-directory*))

(defvar *hiki-mt_allow_comments* *blogpost-flag-ok*)
(defvar *hiki-mt_allow_pings*    *blogpost-flag-ok*)
(defvar *hiki-mt_convert_breaks* *blogpost-flagstr-ng*)

(defvar *hiki-timestamp-diff* 0)

(defun hiki-getUsersBlogs (type)
  (let* ((endpoint (read-string "Endpoint URL: "
				:default (blogtype-endpoint type)))
	 (blogname (read-string "Site Name: "))
	 (blogurl (read-string "Site URL: "))
	 blogs)
    (unless endpoint
      (error "Endpointが指定されていません。"))
    (push (make-blog
	   :blogname blogname
	   :blogtype *hiki-blogtype-name*
	   :blogurl  blogurl
	   :endpoint endpoint
	   ) blogs)
    blogs))

(defun hiki-getRecentPostTitles (blog
				 &optional (numberOfPosts *blogtitle-fetch-number*))
  (fswiki-getRecentPostTitles blog numberOfPosts))

(defun hiki-getPost (blog title)
  (fswiki-getPost blog title))

(defun hiki-newPost (blog post publish)
  (fswiki-newPost blog post publish))

(defun hiki-editPost (blog post publish)
  (fswiki-editPost blog post publish))

(defun hiki-deletePost (blog post publish)
  (error "サポートされていません。"))

(defun hiki-getCategoryList (blog)
  (error "サポートされていません。"))

(defun hiki-uploadFile (blog)
  (error "サポートされていません。"))

(defun hiki-previewPost (blog post)
  (error "サポートされていません。"))

(defun hiki-blogpostOptions ()
  (make-blogpost
   :userid            t
   :dateCreated       t
   :postid            t
   :description       t
   :title             t
   :link              t
   :permaLink         t
   :mt_excerpt        nil
   :mt_text_more      nil
   :mt_allow_comments nil
   :mt_allow_pings    nil
   :mt_convert_breaks nil
   :mt_keywords       nil
   :mt_tb_ping_urls   nil
   :categories        nil
   ))

(blogtype-regist (make-blogtype
		  :name             *hiki-blogtype-name*
		  :endpoint         *hiki-endpoint*
		  :getblogs         'hiki-getUsersBlogs
		  :gettitles        'hiki-getRecentPostTitles
		  :getpost          'hiki-getPost
		  :newpost          'hiki-newPost
		  :editpost         'hiki-editPost
		  :deletepost       'hiki-deletePost
		  :getcategories    'hiki-getCategoryList
		  :uploadfile       'hiki-uploadFile
		  :previewpost      'hiki-previewPost
		  :blogpost_options 'hiki-blogpostOptions
		  ))
