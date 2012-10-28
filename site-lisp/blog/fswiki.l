;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: fswiki.l,v 1.11 2006/01/21 18:24:53 torihat Exp $
;
; blog/fswiki.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "blog/defs"))

(provide "blog/fswiki")

(in-package "blog")

(defvar *fswiki-blogtype-name* "FreeStyleWiki")
(defvar *fswiki-endpoint* nil)
(defvar *fswiki-preview-template*
  (merge-pathnames "fswiki.html" *template-directory*))

(defvar *fswiki-mt_allow_comments* *blogpost-flag-ok*)
(defvar *fswiki-mt_allow_pings*    *blogpost-flag-ok*)
(defvar *fswiki-mt_convert_breaks* *blogpost-flagstr-ng*)

(defvar *fswiki-timestamp-diff* 0)

(defun fswiki-getUsersBlogs (type)
  (let* ((endpoint (read-string "Endpoint URL: "
				:default (blogtype-endpoint type)))
	 (blogname (read-string "Site Name: "))
	 (blogurl (read-string "Site URL: "))
	 blogs)
    (unless endpoint
      (error "Endpointが指定されていません。"))
    (push (make-blog
	   :blogname blogname
	   :blogtype *fswiki-blogtype-name*
	   :blogurl  blogurl
	   :endpoint endpoint
	   ) blogs)
    blogs))

(defun fswiki-getRecentPostTitles (blog
				   &optional (numberOfPosts *blogtitle-fetch-number*))
  (let* ((endpoint (blog-endpoint blog))
	 (response
	  (xmlrpcm::wikirpc2-getAllPages endpoint))
	 titles)
    (dolist (value response)
      (push (make-blogtitle
	     :postid value
	     :title value) titles))
    (nreverse titles)
    ))

(defun fswiki-getPost (blog title)
  (let* ((endpoint (blog-endpoint blog))
	 (postid  (blogtitle-postid title))
	 (body
	  (xmlrpcm::wikirpc2-getPage endpoint postid))
	 (pageinfo
	  (xmlrpcm::wikirpc2-getPageInfo endpoint postid))
	 post)
    (setq post
	  (make-blogpost
	   :userid nil
	   :dateCreated (xmlrpcm::wikirpc2pageinfo-lastModified pageinfo)
	   :postid (blogtitle-title title)
	   :description body
	   :title (blogtitle-title title)))
    post
    ))

(defun fswiki-newPost (blog post publish)
  (let* ((endpoint (blog-endpoint blog))
	 (title (blogpost-title post))
	 (body (blogpost-description post))
	 response
	 postid)
    (setq response
	  (xmlrpcm::wikirpc2-putPage endpoint title body nil))
    title
    ))

(defun fswiki-editPost (blog post publish)
  (fswiki-newPost blog post publish))

(defun fswiki-deletePost (blog post publish)
  (error "サポートされていません。"))

(defun fswiki-getCategoryList (blog)
  (error "サポートされていません。"))

(defun fswiki-uploadFile (blog)
  (let* ((blogid   (blog-blogid blog))
	 (url      (blog-endpoint blog))
	 (path (post-upload-file-select))
	 file
	 bits
	 response
	 uploaded)
    (unless path
      (return-from fswiki-uploadFile))
    (setq file (file-namestring path))
    (with-open-file (s path)
      (set-stream-encoding s :binary)
      (setq bits (si:base64-encode s)))
    (setq response
	  (xmlrpcm::wikirpc2-putAttachment url
					   file
					   bits))
    (msgbox "~S" response)))

(defun fswiki-previewPost (blog post)
  (let* ((url (blog-endpoint blog))
	 (title (blogpost-title post))
	 res)
    ;とりあえずサーバー上のHTMLを取得して表示することにする
    (setq res (xmlrpcm::wikirpc2-getPageHTML url title))
    (when res
      (save-excursion
	(set-buffer (get-buffer-create *buffer-template*))
	(erase-buffer (selected-buffer))
	(insert res)
	(unwind-protect
	    (when (post-preview-save-buffer-to-file)
	      (setq res t)))
	(delete-buffer *buffer-template*)))
    res))

(defun fswiki-blogpostOptions ()
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
		  :name             *fswiki-blogtype-name*
		  :endpoint         *fswiki-endpoint*
		  :getblogs         'fswiki-getUsersBlogs
		  :gettitles        'fswiki-getRecentPostTitles
		  :getpost          'fswiki-getPost
		  :newpost          'fswiki-newPost
		  :editpost         'fswiki-editPost
		  :deletepost       'fswiki-deletePost
		  :getcategories    'fswiki-getCategoryList
		  :uploadfile       'fswiki-uploadFile
		  :previewpost      'fswiki-previewPost
		  :blogpost_options 'fswiki-blogpostOptions
		  ))
