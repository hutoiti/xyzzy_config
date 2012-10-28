;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: cocolog.l 590 2006-02-04 20:11:42Z torihat $
;
; blog/cocolog.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "blog/defs"))

(provide "blog/cocolog")

(in-package "blog")

(defvar *cocolog-blogtype-name* "Cocolog")
(defvar *cocolog-endpoint* "http://app.cocolog-nifty.com/t/api")
(defvar *cocolog-preview-template*
  (merge-pathnames "cocolog.html" *template-directory*))

(defvar *cocolog-mt_allow_comments* *blogpost-flag-ok*)
(defvar *cocolog-mt_allow_pings*    *blogpost-flag-ok*)
(defvar *cocolog-mt_convert_breaks* *blogpost-flagstr-ng*)

(defvar *cocolog-timestamp-diff* (* 60 60 9))

(defun cocolog-getUsersBlogs (type &optional (appkey "hogehoge"))
  (let* ((endpoint (read-string "Endpoint URL: "
				:default (blogtype-endpoint type)))
	 (bloguser (read-string "Blog Username: "))
	 (blogpass (read-string "Blog Password: "))
	 response
	 blogs)
    (unless endpoint
      (error "Endpointが指定されていません。"))
    (unless bloguser
      (error "Usernameが指定されていません。"))
    (unless blogpass
      (error "Passwordが指定されていません。"))
    (setq response (xmlrpcm::blogger-getUsersBlogs endpoint appkey bloguser blogpass))
    (dolist (value (xmlrpcm::xmlrpcm-param-value (car response)))
      ;; structのarray
      (let* ((param (xmlrpcm::xmlrpcm-param-value value))
	     (blogurl  (xmlrpcm::xmlrpcm-param-value (assoc "url"      param :test #'equal)))
	     (blogid   (xmlrpcm::xmlrpcm-param-value (assoc "blogid"   param :test #'equal)))
	     (blogName (xmlrpcm::xmlrpcm-param-value (assoc "blogName" param :test #'equal))))
	(push (make-blog
	       :blogname blogName
	       :blogtype (blogtype-name type)
	       :blogurl  blogurl
	       :appkey   appkey
	       :blogid   blogid
	       :bloguser bloguser
	       :blogpass blogpass
	       :endpoint endpoint
	       :blog_mode_options (list (cons "mt_allow_comments" *cocolog-mt_allow_comments*)
					(cons "mt_allow_pings"    *cocolog-mt_allow_pings*)
					(cons "mt_convert_breaks" *cocolog-mt_convert_breaks*))
	       ) blogs)
	))
    (nreverse blogs)))

(defun cocolog-getRecentPostTitles (blog
				    &optional (numberOfPosts *blogtitle-fetch-number*))
  (let* ((endpoint (blog-endpoint blog))
	 (blogid (blog-blogid blog))
	 (bloguser (blog-bloguser blog))
	 (blogpass (blog-blogpass blog))
	 (response
	  (xmlrpcm::mt-getRecentPostTitles endpoint
					   blogid
					   bloguser
					   blogpass
					   numberOfPosts))
	 titles)
    (dolist (value (xmlrpcm::xmlrpcm-param-value (car response)))
      ;; structのarray
      (let* ((param (xmlrpcm::xmlrpcm-param-value value))
	     (title (make-blogtitle)))
	(dolist (p param)
	  (let* ((key (xmlrpcm::xmlrpcm-param-name p))
		 (val (xmlrpcm::xmlrpcm-param-value p)))
	    (cond ((equal key "dateCreated")
		   (setf (blogtitle-dateCreated title) (+ val *cocolog-timestamp-diff*)))
		  ((equal key "userid")
		   (setf (blogtitle-userid title) val))
		  ((equal key "postid")
		   (setf (blogtitle-postid title) val))
		  ((equal key "title")
		   (setf (blogtitle-title title) val)))))
	(push title titles)))
    (nreverse titles)
    ))

(defun cocolog-getPost (blog title)
  (let* ((endpoint (blog-endpoint blog))
	 (bloguser (blog-bloguser blog))
	 (blogpass (blog-blogpass blog))
	 (postid  (blogtitle-postid title))
	 (response
	  (xmlrpcm::metaWeblog-getPost endpoint
				       postid
				       bloguser
				       blogpass))
	 (resp-categories
	  (xmlrpcm::mt-getPostCategories endpoint
					 postid
					 bloguser
					 blogpass))
	 (post (make-blogpost))
	 value
	 categories)
    (setq value (xmlrpcm::xmlrpcm-param-value (car response)))
    ;; struct
    (dolist (p value)
      (let* ((key (xmlrpcm::xmlrpcm-param-name p))
	     (val (xmlrpcm::xmlrpcm-param-value p)))
	(cond ((equal key "userid")
	       (setf (blogpost-userid post) val))
	      ((equal key "dateCreated")
	       (setf (blogpost-dateCreated post) (+ val *cocolog-timestamp-diff*)))
	      ((equal key "postid")
	       (setf (blogpost-postid post) val))
	      ((equal key "description")
	       (setf (blogpost-description post) val))
	      ((equal key "title")
	       (setf (blogpost-title post) val))
	      ((equal key "link")
	       (setf (blogpost-link post) val))
	      ((equal key "permaLink")
	       (setf (blogpost-permaLink post) val))
	      ((equal key "mt_excerpt")
	       (setf (blogpost-mt_excerpt post) val))
	      ((equal key "mt_text_more")
	       (setf (blogpost-mt_text_more post) val))
	      ((equal key "mt_allow_comments")
	       (setf (blogpost-mt_allow_comments post) val))
	      ((equal key "mt_allow_pings")
	       (setf (blogpost-mt_allow_pings post) val))
	      ((equal key "mt_convert_breaks")
	       (setf (blogpost-mt_convert_breaks post) val))
	      ((equal key "mt_keywords")
	       (setf (blogpost-mt_keywords post) val))
	      )))
    ;;; postのカテゴリを取得
    (setq categories (cocolog-parseCategories resp-categories))
    (setf (blogpost-categories post) categories)
    post
    ))

(defun cocolog-newPost (blog
			post
			publish)
  (let* ((endpoint (blog-endpoint blog))
	 (blogid   (blog-blogid blog))
	 (bloguser (blog-bloguser blog))
	 (blogpass (blog-blogpass blog))
	 (response
	  (xmlrpcm::metaWeblog-newPost endpoint
				       blogid
				       bloguser
				       blogpass
				       (cocolog-create-content post)
				       (if publish
					   xmlrpcm::*xmlrpcm-boolean-true*
					 xmlrpcm::*xmlrpcm-boolean-false*)
				       ))
	 (categories (blogpost-categories post))
	 postid)
    (setq postid (xmlrpcm::xmlrpcm-param-value (car response)))
    (when postid
      (cocolog-setPostCategories endpoint
				 postid
				 bloguser
				 blogpass
				 post))
    postid
    ))

(defun cocolog-category-xmlrpcm (category)
  (list nil
	(list (list "categoryId"
		    (blogcategory-categoryId category)
		    'xmlrpcm::string)
	      (list "isPrimary"
		    (if (blogcategory-isPrimary category) xmlrpcm::*xmlrpcm-boolean-true* xmlrpcm::*xmlrpcm-boolean-false*)
		    'xmlrpcm::boolean))
	'xmlrpcm::struct))

(defun cocolog-categories-xmlrpcm (categories)
  (mapcar #'(lambda (c)
	      (cocolog-category-xmlrpcm c))
	  categories))

(defun cocolog-setPostCategories (endpoint
				  postid
				  bloguser
				  blogpass
				  post)
  (let (response
	(categories (blogpost-categories post)))
    (setq response
	  (xmlrpcm::mt-setPostCategories endpoint
					 postid
					 bloguser
					 blogpass
					 (cocolog-categories-xmlrpcm categories)))
    (eq (xmlrpcm::xmlrpcm-param-value (car response))
	xmlrpcm::*xmlrpcm-boolean-true*)))

(defun cocolog-editPost (blog
			 post
			 publish)
  (let* ((endpoint (blog-endpoint blog))
	 (bloguser (blog-bloguser blog))
	 (blogpass (blog-blogpass blog))
	 (postid (blogpost-postid post))
	 (response
	  (xmlrpcm::metaWeblog-editPost endpoint
					postid
					bloguser
					blogpass
					(cocolog-create-content post)
					(if publish
					    xmlrpcm::*xmlrpcm-boolean-true*
					  xmlrpcm::*xmlrpcm-boolean-false*)
					))
	 result)
    (setq result (eq (xmlrpcm::xmlrpcm-param-value (car response))
		     xmlrpcm::*xmlrpcm-boolean-true*))
    (when result
      (cocolog-setPostCategories endpoint
				 postid
				 bloguser
				 blogpass
				 post))
    result))

(defun cocolog-deletePost (blog
			   post
			   publish)
  (let* ((endpoint (blog-endpoint blog))
	 (bloguser (blog-bloguser blog))
	 (blogpass (blog-blogpass blog))
	 (postid (if (blogpost-p post)
		     (blogpost-postid post)
		   (if (blogtitle-p post)
		       (blogtitle-postid post))))
	 (response
	  (xmlrpcm::blogger-deletePost endpoint
				       ""
				       postid
				       bloguser
				       blogpass
				       (if publish
					   xmlrpcm::*xmlrpcm-boolean-true*
					 xmlrpcm::*xmlrpcm-boolean-false*)
				       )))
    (eq (xmlrpcm::xmlrpcm-param-value (car response))
	xmlrpcm::*xmlrpcm-boolean-true*)))

(defun cocolog-create-content (post)
  (let ((content (list (list "title"
			     (or (blogpost-title post) "")
			     'xmlrpcm::string)
		       (list "description"
			     (or (blogpost-description post) "")
			     'xmlrpcm::string)
		       (list "dateCreated"
			     (- (or (blogpost-dateCreated post) (get-universal-time)) *cocolog-timestamp-diff*)
			     'xmlrpcm::dateTime)
		       (list "mt_allow_comments"
			     (or (blogpost-mt_allow_comments post) *cocolog-mt_allow_comments*)
			     'xmlrpcm::int)
		       (list "mt_allow_pings"
			     (or (blogpost-mt_allow_pings post) *cocolog-mt_allow_pings*)
			     'xmlrpcm::int)
		       (list "mt_convert_breaks"
			     (or (blogpost-mt_convert_breaks post) *cocolog-mt_convert_breaks*)
			     'xmlrpcm::string)
		       (list "mt_text_more"
			     (or (blogpost-mt_text_more post) "")
			     'xmlrpcm::string)
		       (list "mt_excerpt"
			     (or (blogpost-mt_excerpt post) "")
			     'xmlrpcm::string)
		       (list "mt_keywords"
			     (or (blogpost-mt_keywords post) "")
			     'xmlrpcm::string)
		       )))
    (when (blogpost-mt_tb_ping_urls post)
      (setq content (append content (list
				     (list "mt_tb_ping_urls"
					   (mapcar #'(lambda (x) (list nil x 'string))
						   (blogpost-mt_tb_ping_urls post))
					   'xmlrpcm::array)))))
    content))

(defun cocolog-getCategoryList (blog)
  (let* ((endpoint (blog-endpoint blog))
	 (blogid   (blog-blogid blog))
	 (bloguser (blog-bloguser blog))
	 (blogpass (blog-blogpass blog))
	 (resp-categories
	  (xmlrpcm::mt-getCategoryList endpoint
				       blogid
				       bloguser
				       blogpass)))
    (cocolog-parseCategories resp-categories)))

(defun cocolog-parseCategories (resp-categories)
  (let (categories)
    (dolist (val (xmlrpcm::xmlrpcm-param-value (car resp-categories)))
      ;; structのarray
      (let ((category (make-blogcategory)))
	(dolist (p (xmlrpcm::xmlrpcm-param-value val))
	  (let* ((key (xmlrpcm::xmlrpcm-param-name p))
		 (val (xmlrpcm::xmlrpcm-param-value p)))
	    (cond ((equal key "categoryId")
		   (setf (blogcategory-categoryId category) val))
		  ((equal key "categoryName")
		   (setf (blogcategory-categoryName category) val)))))
	(push category categories)))
    (nreverse categories)))

(defun cocolog-uploadFile (blog)
  (let* ((blogid   (blog-blogid blog))
	 (url      (blog-endpoint blog))
	 (bloguser (blog-bloguser blog))
	 (blogpass (blog-blogpass blog))
	 (path (post-upload-file-select))
	 file
	 bits
	 response
	 uploaded)
    (unless path
      (return-from cocolog-uploadFile))
    (setq file (read-string "サーバー上でのファイル名: " :default (file-namestring path)))
    (with-open-file (s path)
      (set-stream-encoding s :binary)
      (setq bits (si:base64-encode s)))
    (setq response
	  (xmlrpcm::metaWeblog-newMediaObject url
					      blogid
					      bloguser
					      blogpass
					      (list (list "bits" bits 'xmlrpcm::base64)
						    (list "name" file 'xmlrpcm::string))))
    (if (setq uploaded (xmlrpcm::xmlrpcm-param-value
			(assoc "url" (xmlrpcm::xmlrpcm-param-value (car response))
			       :test #'equal)))
	(message "アップロード完了: ~A" uploaded)
      (error "アップロード失敗"))))

(defun cocolog-previewPost (blog post)
  (post-preview-create blog post *cocolog-preview-template*))

(defun cocolog-blogpostOptions ()
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
		  :name             *cocolog-blogtype-name*
		  :endpoint         *cocolog-endpoint*
		  :getblogs         'cocolog-getUsersBlogs
		  :gettitles        'cocolog-getRecentPostTitles
		  :getpost          'cocolog-getPost
		  :newpost          'cocolog-newPost
		  :editpost         'cocolog-editPost
		  :deletepost       'cocolog-deletePost
		  :getcategories    'cocolog-getCategoryList
		  :uploadfile       'cocolog-uploadFile
		  :previewpost      'cocolog-previewPost
		  :blogpost_options 'cocolog-blogpostOptions
		  ))
