;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: livedoor.l 590 2006-02-04 20:11:42Z torihat $
;
; blog/hatena-diary.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "blog/defs"))

(provide "blog/hatena-diary")

(in-package "blog")

(defvar *hatena-diary-blogtype-name* "HatenaDiary")
(defvar *hatena-diary-endpoint* "http://d.hatena.ne.jp/~A/atom")
(defvar *hatena-diary-preview-template*
  (merge-pathnames "hatena-diary.html" *template-directory*))

(defvar *hatena-diary-mt_allow_comments* *blogpost-flag-ok*)
(defvar *hatena-diary-mt_allow_pings*    *blogpost-flag-ok*)
(defvar *hatena-diary-mt_convert_breaks* "0")

(defun hatena-diary-getUsersBlogs (type &optional (appkey "hogehoge"))
  (let* (endpoint
	 (bloguser (read-string "Blog Username: "))
	 (blogpass (read-string "Blog Password: "))
	 titles
	 blogs)
    (unless bloguser
      (error "Usernameが指定されていません。"))
    (unless blogpass
      (error "Passwordが指定されていません。"))
    (setq endpoint (format nil *hatena-diary-endpoint* bloguser))
    (setq titles (atomm::atomm-get-service endpoint bloguser blogpass))
    (dolist (tmp titles)
      (multiple-value-bind (href title accept)
	  (values-list tmp)
	(when (string-match "blog" href)
	  (let* ((blogName title)
		 (url-post href)
		 (url-feed href)
		 (url-categories nil)
		 (endpoint href))
	    (multiple-value-bind (options entries opts)
		(atomm::atomm-get-feed url-feed bloguser blogpass)
	      (let (blogurl
		    blogid)
		(dolist (o options)
		  (let ((name (ed::xmlpm-tag-name o)))
		    (cond ((equal name "link")
			   (let* ((opts (ed::xmlpm-tag-opts o))
				  (rel  (cdr (assoc "rel" opts :test #'equal)))
				  (href (cdr (assoc "href" opts :test #'equal))))
			     (when (equal rel "alternate")
			       (setq blogurl href))))
			  ((equal name "id")
			   (setq blogid (car (ed::xmlpm-tag-contents o)))))))
		(push (make-blog
		       :blogname blogName
		       :blogtype (blogtype-name type)
		       :blogurl  blogurl
		       :appkey   appkey
		       :blogid   blogid
		       :bloguser bloguser
		       :blogpass blogpass
		       :endpoint endpoint
		       :blog_mode_options (list (cons "service.post" url-post)
						(cons "service.feed" url-feed)
						(cons "service.categories" url-categories))
		       ) blogs)
		))))))
    (nreverse blogs)))

(defun hatena-diary-getRecentPostTitles (blog
				    &optional (numberOfPosts *blogtitle-fetch-number*))
  (let* ((boptions (blog-blog_mode_options blog))
	 (endpoint (cdr (assoc "service.feed" boptions :test #'equal)))
	 (bloguser (blog-bloguser blog))
	 (blogpass (blog-blogpass blog))
	 titles)
    (multiple-value-bind (options entries opts)
	(atomm::atomm-get-feed endpoint bloguser blogpass)
      (progn
	(dolist (entry entries)
	  (let ((title (make-blogtitle)))
	    (dolist (p (ed::xmlpm-tag-contents entry))
	      (let ((key (ed::xmlpm-tag-name p)))
		(cond ((or (equal key "issued")
			   (equal key "updated"))
		       (let ((val (car (ed::xmlpm-tag-contents p))))
			 (setf (blogtitle-dateCreated title)
			       (xmlrpcm::xmlrpcm-parse-dateTime val))))
		      ((equal key "link")
		       (let* ((opts (ed::xmlpm-tag-opts p))
			      (rel  (cdr (assoc "rel"  opts :test #'equal)))
			      (href (cdr (assoc "href" opts :test #'equal))))
			 (when (equal rel "edit")
                           ;;; !!! とりあえず postid に EditURIを入れておく
			   (setf (blogtitle-postid title) href))))
		      ((equal key "title")
		       (let ((val (car (ed::xmlpm-tag-contents p))))
			 (setf (blogtitle-title title) val))))))
	    (push title titles)))))
    (nreverse titles)
    ))

(defun hatena-diary-getPost (blog title)
  (let* ((endpoint (blogtitle-postid title))
	 (bloguser (blog-bloguser blog))
	 (blogpass (blog-blogpass blog))
	 (response
	  (atomm::atomm-get-entry endpoint
				  bloguser
				  blogpass))
	 resp-categories
	 (post (make-blogpost))
	 value
	 categories)
    (setq value (ed::xmlpm-tag-contents response))
    (dolist (p value)
      (let* ((key (ed::xmlpm-tag-name p))
	     (val (car (ed::xmlpm-tag-contents p))))
	(cond ((equal key "author")
	       (setf (blogpost-userid post)
		     (car (ed::xmlpm-tag-contents (car (ed::xmlpm-tag-contents p))))))
	      ((equal key "issued")
	       (setf (blogpost-dateCreated post) (xmlrpcm::xmlrpcm-parse-dateTime val)))
	      ((equal key "updated")
	       (setf (blogpost-dateCreated post) (xmlrpcm::xmlrpcm-parse-dateTime val)))
	      ((equal key "link")
	       (let* ((opts (ed::xmlpm-tag-opts p))
		      (rel  (cdr (assoc "rel"  opts :test #'equal)))
		      (href (cdr (assoc "href" opts :test #'equal))))
		 (cond ((equal rel "edit") ;;; !!! とりあえず postid に EditURIを入れておく
			(setf (blogpost-postid post) href))
		       ((equal rel "alternate")
			(setf (blogpost-link post) href)
			(setf (blogpost-permaLink post) href)
			))))
	      ((equal key "hatena:syntax")
	       (let ((content ""))
		 (dolist (c (ed::xmlpm-tag-contents p))
		   (setq content (concat content c)))
		 (setf (blogpost-description post) content)))
	      ((equal key "title")
	       (setf (blogpost-title post) val))
	      ((equal key "summary")
	       (setf (blogpost-mt_excerpt post) val))
	      ((equal key "dc:subject")
	       (when val
		 (push val resp-categories)))
	      ;((equal key "mt_text_more")
	      ; (setf (blogpost-mt_text_more post) val))
	      ;((equal key "mt_allow_comments")
	      ; (setf (blogpost-mt_allow_comments post) val))
	      ;((equal key "mt_allow_pings")
	      ; (setf (blogpost-mt_allow_pings post) val))
	      ;((equal key "mt_convert_breaks")
	      ; (setf (blogpost-mt_convert_breaks post) val))
	      ;((equal key "mt_keywords")
	      ; (setf (blogpost-mt_keywords post) val))
	      )))
    ;;; postのカテゴリを取得
    ;(setq categories (hatena-diary-parseCategories resp-categories))
    ;(setf (blogpost-categories post) categories)
    post
    ))

(defun hatena-diary-create-content (post)
  (let (values)
    (push (list "title" nil (blogpost-title post)) values)
    (push (list "content" (list (cons "type" "text/plain")) (blogpost-description post)) values)
    (push (list "updated" nil (atomm::atomm-formatDateLocal (blogpost-dateCreated post))) values)
;    (push (list "content" (list (cons "mode" "escaped")
;				(cons "type" "text/plain")) (blogpost-description post)) values)
;    (push (list "summary" (list (cons "type" "text/plain")) (blogpost-mt_excerpt post)) values)
;    (dolist (category (blogpost-categories post))
;      (push (list "dc:subject" nil (blogcategory-categoryName category)) values))
    (list (append (list "entry"
			(list (cons "xmlns" "http://purl.org/atom/ns#")
			      ;(cons "xmlns:dc" "http://purl.org/dc/elements/1.1/")
			      )
			)
		  (nreverse values)))))

(defun hatena-diary-newPost (blog
			 post
			 publish)
  (let* ((boptions (blog-blog_mode_options blog))
	 (endpoint (cdr (assoc "service.post" boptions :test #'equal)))
	 (bloguser (blog-bloguser blog))
	 (blogpass (blog-blogpass blog))
	 (entry (hatena-diary-create-content post)))
    (atomm::atomm-post-entry endpoint
			     bloguser
			     blogpass
			     entry)
    ))

(defun hatena-diary-editPost (blog
			 post
			 publish)
  (let* ((endpoint (blogpost-postid post))
	 (bloguser (blog-bloguser blog))
	 (blogpass (blog-blogpass blog))
	 (entry (hatena-diary-create-content post)))
    (atomm::atomm-edit-entry endpoint
			     bloguser
			     blogpass
			     entry)))

(defun hatena-diary-deletePost (blog
			    post
			    publish)
  (let* ((bloguser (blog-bloguser blog))
	 (blogpass (blog-blogpass blog))
	 (endpoint (if (blogpost-p post)
		       (blogpost-postid post)
		     (if (blogtitle-p post)
			 (blogtitle-postid post)))))
    (atomm::atomm-delete-entry endpoint
			       bloguser
			       blogpass)))

(defun hatena-diary-getCategoryList (blog)
  (return-from hatena-diary-getCategoryList)
  (let* ((boptions (blog-blog_mode_options blog))
	 (endpoint (cdr (assoc "service.categories" boptions :test #'equal)))
	 (bloguser (blog-bloguser blog))
	 (blogpass (blog-blogpass blog)))
    (hatena-diary-parseCategories (atomm::atomm-get-categories endpoint
							   bloguser
							   blogpass))))

(defun hatena-diary-parseCategories (resp-categories)
  (return-from hatena-diary-parseCategories)
  (let (categories)
    (dolist (val resp-categories)
      (let ((category (make-blogcategory)))
	(setf (blogcategory-categoryId category) val)
	(setf (blogcategory-categoryName category) val)
	(push category categories)))
    (nreverse categories)))

(defun hatena-diary-uploadFile (blog)
  (error "未サポート"))

(defun hatena-diary-previewPost (blog post)
  (error "未サポート")
  (post-preview-create blog post *hatena-diary-preview-template*))

(defun hatena-diary-blogpostOptions ()
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
		  :name             *hatena-diary-blogtype-name*
		  :endpoint         *hatena-diary-endpoint*
		  :getblogs         'hatena-diary-getUsersBlogs
		  :gettitles        'hatena-diary-getRecentPostTitles
		  :getpost          'hatena-diary-getPost
		  :newpost          'hatena-diary-newPost
		  :editpost         'hatena-diary-editPost
		  :deletepost       'hatena-diary-deletePost
		  :getcategories    'hatena-diary-getCategoryList
		  :uploadfile       'hatena-diary-uploadFile
		  :previewpost      'hatena-diary-previewPost
		  :blogpost_options 'hatena-diary-blogpostOptions
		  ))
