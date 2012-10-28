;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: defs.l 822 2009-05-14 17:04:58Z torihat $
;
; defs.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xmlrpcm/defs")
  (require "atomm/defs"))

(require "xmlrpcm/blogger")
(require "xmlrpcm/metaWeblog")
(require "xmlrpcm/mt")
(require "xmlrpcm/trackback")
(require "xmlrpcm/wikirpc2")

(require "atomm/publish")

(defpackage "blog"
  (:use "lisp" "editor"))

(provide "blog/defs")

(in-package "blog")

(defvar *version* "0.0.0.5")
(defvar *prog-name* "Blog Mode")
(defvar *pframe-name* "Blog")
(defvar *pframe-old* nil)
(defvar *window-3pain* t)
(defvar *debug-mode* nil)

(defvar *buffer-prefix*
  (format nil " *~A " *prog-name*))
(defvar *buffer-menu*
  (concat *buffer-prefix* "Blog*"))
(defvar *buffer-title*
  (concat *buffer-prefix* "Title*"))
(defvar *buffer-post*
  (concat *buffer-prefix* "Post*"))
(defvar *buffer-edit*
  (concat *buffer-prefix* "Edit*"))
(defvar *buffer-template*
  (concat *buffer-prefix* "Tmpl*"))

(defvar *menu-map* nil)
(defvar *menu-mode* nil)
(defvar *menu-window-width* 20)

(defvar *title-map* nil)
(defvar *title-mode* nil)
(defvar *title-window-height* 5)

(defvar *post-map* nil)
(defvar *post-mode* nil)
(defvar *post-upload-previous-directory* nil)

(defvar *edit-map* nil)
(defvar *edit-description-mode* 'text-mode)
(defvar *edit-mt_excerpt-mode* 'text-mode)
(defvar *edit-mt_text_more-mode* 'text-mode)
(defvar *edit-mt_tb_ping_urls-mode* 'text-mode)

(defvar *title-date-format* "%y/%m/%d %H:%M")
(defvar *post-date-format* "%Y/%m/%d %H:%M:%S")

(defvar *window-menu* nil)
(defvar *window-title* nil)

(defvar *attribute-menu-title* '(:bold t))
(defvar *attribute-menu-blog* nil)
(defvar *attribute-title-date* nil)
(defvar *attribute-title-title* nil)
(defvar *attribute-post-date* nil)
(defvar *attribute-post-title* nil)
(defvar *attribute-post-category* nil)
(defvar *attribute-post-description* nil)
(defvar *attribute-post-mt_excerpt* nil)
(defvar *attribute-post-mt_text_more* nil)
(defvar *attribute-post-mt_keywords* nil)
(defvar *attribute-post-mt_tb_ping_urls* nil)
(defvar *attribute-post-options* nil)

(defvar *base-directory* "~/.blog")
(defvar *lisp-directory*
  (merge-pathnames "site-lisp/blog" (si:system-root)))

(defvar *cache-directory*
  (merge-pathnames "cache" *base-directory*))
(defvar *template-directory*
  (merge-pathnames "tmpl" *lisp-directory*))

(defvar *menu-file*
  (merge-pathnames "menu.dat" *base-directory*))
(defvar *config-file*
  (merge-pathnames "config.l" *base-directory*))
(defvar *preview-tmp-file*
  (merge-pathnames "tmp.html" *base-directory*))

(defvar *blog-clipboard* nil)

(defun blog-clipboard-push (blog)
  (push blog *blog-clipboard*))

(defun blog-clipboard-pop ()
  (pop *blog-clipboard*))

(defvar *menu-data* nil)
(defvar *menu-current* nil)
(defvar *title-data* nil)
(defvar *title-current* nil)
(defvar *post-data* nil)
(defvar *post-category-list* nil)

(defvar *blog-start-hook* nil)
(defvar *blog-init-hook* nil)
(defvar *blog-finish-hook* nil)
(defvar *blog-menu-mode-hook* nil)
(defvar *blog-menu-print-hook* nil)
(defvar *blog-menu-open-hook* nil)
(defvar *blog-title-mode-hook* nil)
(defvar *blog-title-print-hook* nil)
(defvar *blog-title-open-hook* nil)
(defvar *blog-post-mode-hook* nil)
(defvar *blog-post-print-hook* nil)
(defvar *blog-post-open-hook* nil)
(defvar *blog-post-new-hook* nil)
(defvar *blog-edit-mode-hook* nil)
(defvar *blog-edit-print-hook* nil)

;;;
;;; Blog
;;;
(defstruct blog
  blogname
  blogtype
  blogurl
  appkey
  blogid
  bloguser
  blogpass
  endpoint
  blog_mode_options)

(defun blog-equal (a b)
  (and (equal (blog-endpoint a)
	      (blog-endpoint b))
       (equal (blog-blogid a)
	      (blog-blogid b))
       (equal (blog-bloguser a)
	      (blog-bloguser b))))

;;;
;;; Blog Type
;;;
(defvar *blog-type* nil)

(defstruct blogtype
  name
  endpoint
  getblogs
  gettitles
  getpost
  newpost
  editpost
  deletepost
  getcategories
  uploadfile
  previewpost
  blogpost_options
  )

(defun blogtype-select (&optional default)
  (let ((name (completing-read "Blog Type: "
			       (mapcar #'blogtype-name *blog-type*)
			       :default default
			       :must-match t)))
    (when name
      (blogtype-get name))))

(defun blogtype-get (name)
  (car (member-if #'(lambda (x)
		      (equal name (blogtype-name x)))
		  *blog-type*)))

(defun blogtype-equal (a b)
  (equal (blogtype-name a)
	 (blogtype-name b)))

(defun blogtype-regist (type)
  (pushnew type *blog-type* :test #'blogtype-equal))

(defun blog-blogtype-get (blog)
  (blogtype-get (blog-blogtype blog)))

;;;
;;; Blog Title
;;;
(defstruct blogtitle
  dateCreated
  userid
  postid
  title)

(defvar *blogtitle-fetch-number* 30)

;;;
;;; Blog Post
;;;
(defstruct blogpost
  userid
  dateCreated
  postid
  description
  title
  link
  permaLink
  mt_excerpt
  mt_text_more
  mt_allow_comments
  mt_allow_pings
  mt_convert_breaks
  mt_keywords
  mt_tb_ping_urls
  categories
  )

(defvar *blogpost-flag-ok* 1)
(defvar *blogpost-flag-ng* 0)
(defvar *blogpost-flagstr-ok* "1")
(defvar *blogpost-flagstr-ng* "0")

#|
(defmacro blogpost-flag-ok-p (flag)
  `(eq ,flag ,*blogpost-flag-ok*))
|#
(defun blogpost-flag-ok-p (flag)
  (eq flag *blogpost-flag-ok*))

(defun blogpost-flagstr-ok-p (flag)
  (equal flag *blogpost-flagstr-ok*))

;;;
;;; Blog Category
;;;
(defstruct blogcategory
  categoryId
  categoryName
  isPrimary)

(defun blogcategory-list-string (categories)
  (let ((str "")
	(names (mapcar #'blogcategory-categoryName
		       categories)))
    (when names
      (setq str (format nil "~A~{/~A~}"
			(car names)
			(cdr names))))
    str))

;;;
;;;
;;;
(defmacro modify-read-only-buffer (&body body)
  `(let ((buffer-read-only nil))
     (declare (special buffer-read-only))
     ,@body))

(setf (get 'modify-read-only-buffer 'lisp-indent-hook) 1)

(defun data-read-from-file (file)
  (let (data)
    (with-open-file (s
		     file
		     :direction :input
		     :if-does-not-exist :error)
      (let (tmp)
	(while (setq tmp (read s nil))
	  (push tmp data))))
    (nreverse data)))

(defun data-write-to-file (file data)
  (with-open-file (s
		   file
		   :direction :output
		   :if-exists :overwrite
		   :if-does-not-exist :create)
    (format s "~{~S~%~}" data))
  t)

(defun open-in-browser (url)
  (shell-execute url t))

(defun open-in-browser-preview (url)
  (shell-execute url t))

;;;
;;; Functions
;;;
(defun init ()
  (unless (file-exist-p *base-directory*)
    (create-directory *base-directory*))
  (unless (file-exist-p *cache-directory*)
    (create-directory *cache-directory*))
  (run-hooks '*blog-init-hook*))

(defun load-config ()
  (let ((lc (concat *config-file* "c")))
    (if (file-exist-p lc)
	(load lc)
      (when (file-exist-p *config-file*)
	(load *config-file*)))))

(defun frame-set ()
  (setq *pframe-old* (ed::pseudo-frame-name (selected-pseudo-frame)))
  (new-pseudo-frame *pframe-name*))

(defun frame-get ()
  (find-pseudo-frame *pframe-name*))

(defun hide ()
  (interactive)
  (let ((old (find-pseudo-frame *pframe-old*)))
    (when old
      (select-pseudo-frame old))))

(defun restore ()
  (interactive)
  (let ((frame (frame-get)))
    (if frame
	(progn
	  (select-pseudo-frame frame)
	  (when (and (not (string-match (concat "^" (regexp-quote *buffer-prefix*)) (buffer-name (selected-buffer))))
		     (find-buffer *buffer-menu*))
	    (menu-window-only)))
      (user::blog-mode))))

(defun finish ()
  (interactive)
  (let ((frame (frame-get)))
    (menu-window-only)
    (menu-data-save)
    (dolist (buf (buffer-list))
      (let ((bufname (buffer-name buf)))
	(when (string-match (concat "^" (regexp-quote *buffer-prefix*)) bufname)
	  (delete-buffer buf))))
    (when frame
      (delete-pseudo-frame frame)))
  (run-hooks '*blog-finish-hook*))

(defun menu-data-load ()
  (setq *menu-data* nil)
  (when (file-exist-p *menu-file*)
    (setq *menu-data*
	  (data-read-from-file *menu-file*))))

(defun menu-data-save ()
  (data-write-to-file *menu-file* *menu-data*))

(defun user::blog-toggle ()
  (interactive)
  (if (equal *pframe-name*
	     (ed::pseudo-frame-name (selected-pseudo-frame)))
      (hide)
    (restore)))

(defun user::blog-mode ()
  (interactive)
  (load-config)
  (when (frame-get)
    (restore)
    (return-from user::blog-mode))
  (frame-set)
  (init)
  (menu-window-only)
  (menu-mode)
  (menu-data-load)
  (menu-print)
  (run-hooks '*blog-start-hook*))

;;;
;;; Load Libraries
;;;
(require "blog/menu")
(require "blog/title")
(require "blog/post")
(require "blog/edit")

(require "blog/cocolog")
(require "blog/movable-type")
(require "blog/livedoor")
(require "blog/hatena-diary")

(require "blog/fswiki")
(require "blog/hiki")
