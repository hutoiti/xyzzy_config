;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: post.l 826 2009-05-15 01:46:49Z torihat $
;
; blog/post.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "blog/defs"))

(provide "blog/post")

(in-package "blog")

(unless *post-map*
  (setq *post-map* (make-sparse-keymap))
  (define-key *post-map* #\RET 'post-cmd-enter)
  (define-key *post-map* #\r 'post-reload)
  (define-key *post-map* #\n 'post-new)
  (define-key *post-map* #\d 'post-del)
  (define-key *post-map* #\a 'post-edit-date)
  (define-key *post-map* #\A 'post-edit-date-current)
  (define-key *post-map* #\t 'post-edit-title)
  (define-key *post-map* #\e 'post-edit-description)
  (define-key *post-map* #\g 'post-edit-mt_excerpt)
  (define-key *post-map* #\k 'post-edit-mt_text_more)
  (define-key *post-map* #\b 'post-edit-mt_tb_ping_urls)
  (define-key *post-map* #\c 'post-category-select)
  (define-key *post-map* #\p 'post-preview)
  (define-key *post-map* #\u 'post-upload-file)
  (define-key *post-map* #\g 'post-send-trackback-ping)
  (define-key *post-map* #\o 'post-open-page)
  (define-key *post-map* '(#\C-x #\C-s) 'post-save)
  (define-key *post-map* '(#\C-c #\C-c) 'post-save-publish)
  (define-key *post-map* #\RBtnUp 'post-popup-menu)
  (define-key *post-map* #\q 'post-close)
)

(defun post-popup-menu ()
  (interactive)
  (let* ((type (blog-blogtype-get *menu-current*))
	 (opts (funcall (blogtype-blogpost_options type)))
	 (menu (create-popup-menu)))
    (add-menu-item menu nil "新規投稿" 'post-new)
    (add-menu-separator menu)
    (add-menu-item menu nil "投稿日時編集" 'post-edit-date)
    (add-menu-item menu nil "投稿日時を現在に" 'post-edit-date-current)
    (add-menu-item menu nil "タイトル編集" 'post-edit-title)
    (add-menu-item menu nil "本文編集" 'post-edit-description)
    (when (blogpost-mt_excerpt opts)
      (add-menu-item menu nil "概要編集" 'post-edit-mt_excerpt))
    (when (blogpost-mt_text_more opts)
      (add-menu-item menu nil "追記編集" 'post-edit-mt_text_more))
    (when (blogpost-mt_tb_ping_urls opts)
      (add-menu-item menu nil "TrackBack送信先編集" 'post-edit-mt_tb_ping_urls))
    (when (blogpost-categories opts)
      (add-menu-item menu nil "カテゴリ選択" 'post-category-select))
    (when (or (blogpost-mt_allow_comments opts)
	      (blogpost-mt_allow_pings opts)
	      (blogpost-mt_convert_breaks opts))
      (add-menu-separator menu))
    (when (blogpost-mt_allow_comments opts)
      (add-menu-item menu nil "コメント許可" 'post-toggle-mt_allow_comments
		     #'(lambda ()
			 (when (and (blogpost-p *post-data*)
				    (blogpost-flag-ok-p (blogpost-mt_allow_comments *post-data*)))
			   :check))))
    (when (blogpost-mt_allow_pings opts)
      (add-menu-item menu nil "TrackBack許可" 'post-toggle-mt_allow_pings
		     #'(lambda ()
			 (when (and (blogpost-p *post-data*)
				    (blogpost-flag-ok-p (blogpost-mt_allow_pings *post-data*)))
			   :check))))
    (when (blogpost-mt_convert_breaks opts)
      (add-menu-item menu nil "改行自動変換" 'post-toggle-mt_convert_breaks
		     #'(lambda ()
			 (when (and (blogpost-p *post-data*)
				    (blogpost-flagstr-ok-p (blogpost-mt_convert_breaks *post-data*)))
			   :check))))
    (add-menu-separator menu)
    (add-menu-item menu nil "ファイルアップロード" 'post-upload-file)
    (add-menu-item menu nil "Ping送信" 'post-send-trackback-ping)
    (add-menu-item menu nil "リロード" 'post-reload)
    (add-menu-separator menu)
    (add-menu-item menu nil "投稿を保存" 'post-save)
    (add-menu-item menu nil "投稿を保存して公開" 'post-save-publish)
    (add-menu-separator menu)
    (add-menu-item menu nil "ページを開く" 'post-open-page
		   #'(lambda ()
		       (if (blogpost-p *post-data*)
			   (if (not (blogpost-link *post-data*))
			       :disable)
			 :disable)))
    (add-menu-item menu nil "閉じる" 'post-close)
    (track-popup-menu menu)))

(defun post-mode ()
  (setq need-not-save t)
  (setq buffer-read-only t)
  (setq kept-undo-information nil)
  (setq auto-save nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-line-number* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-newline* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-eof* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-cursor-line* t)
  (set-local-window-flags (selected-buffer)
			  *window-flag-vscroll-bar* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-ruler* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-just-inverse* t)
  (set-buffer-fold-width t)
  (set-buffer-fileio-encoding *encoding-utf8n*)
  (make-local-variable 'mode-line-format)
  (make-local-variable 'title-bar-format)
  (post-mode-line)
  (use-keymap *post-map*)
  (run-hooks '*blog-post-mode-hook*)
  )

(defun post-window-set ()
  (interactive)
  (when *window-3pain*
    (title-window-split))
  (set-buffer-post))

(defun set-buffer-post ()
  (set-buffer (get-buffer-create *buffer-post*)))

(defun post-mode-line ()
  (menu-mode-line))

(defun post-mode-line-update ()
  (save-excursion
    (set-buffer-post)
    (post-mode-line)))

(defun post-date-format (date)
  (if date
      (format-date-string *post-date-format* date)
    ""))

(defun post-date-parse (datestr)
  (when (string-match "\\([0-9]\\{4\\}\\)[-/]\\([0-9]\\{2\\}\\)[-/]\\([0-9]\\{2\\}\\) \\([0-9]\\{2\\}\\):\\([0-9]\\{2\\}\\):\\([0-9]\\{2\\}\\)"
		      datestr)
    (encode-universal-time (parse-integer (match-string 6))
			   (parse-integer (match-string 5))
			   (parse-integer (match-string 4))
			   (parse-integer (match-string 3))
			   (parse-integer (match-string 2))
			   (parse-integer (match-string 1)))))

(defun post-print ()
  (let* ((type (blog-blogtype-get *menu-current*))
	 (opts (funcall (blogtype-blogpost_options type))))
    (refresh-screen)
    (let ((width (- (window-width) 5)))
      (modify-read-only-buffer
       (erase-buffer (selected-buffer))
       (clear-all-text-attributes)
       (apply #'set-text-attribute
	      (point)
	      (progn
		(insert (format nil "投稿日時：~A" (post-date-format (blogpost-dateCreated *post-data*))))
		(point))
	      'date
	      *attribute-post-date*)
       (insert "\n")
       (apply #'set-text-attribute
	      (point)
	      (progn
		(insert (format nil "タイトル：~@[~A~]" (blogpost-title *post-data*)))
		(point))
	      'title
	      *attribute-post-title*)
       (insert "\n")
       (when (blogpost-categories opts)
	 (apply #'set-text-attribute
		(point)
		(progn
		  (insert (format nil "カテゴリ：~A"
				  (blogcategory-list-string (blogpost-categories *post-data*))))
		  (point))
		'category
		*attribute-post-category*)
	 (insert "\n"))
       (insert "-" width)
       (insert "\n")
       (apply #'set-text-attribute
	      (point)
	      (progn
		(insert (format nil "[本文]~%~@[~A~%~]" (blogpost-description *post-data*)))
		(point))
	      'description
	      *attribute-post-description*)
       (when (blogpost-mt_text_more opts)
	 (insert "-" width)
	 (insert "\n")
	 (apply #'set-text-attribute
		(point)
		(progn
		  (insert (format nil "[追記]~%~@[~A~%~]" (blogpost-mt_text_more *post-data*)))
		  (point))
		'mt_text_more
		*attribute-post-mt_text_more*))
       (when (blogpost-mt_excerpt opts)
	 (insert "-" width)
	 (insert "\n")
	 (apply #'set-text-attribute
		(point)
		(progn
		  (insert (format nil "[概要]~%~@[~A~%~]" (blogpost-mt_excerpt *post-data*)))
		  (point))
		'mt_excerpt
		*attribute-post-mt_excerpt*))
       (when (blogpost-mt_tb_ping_urls opts)
	 (insert "-" width)
	 (insert "\n")
	 (apply #'set-text-attribute
		(point)
		(progn
		  (insert (format nil "[TrackBack送信先URL]~%~{~A~%~}" (blogpost-mt_tb_ping_urls *post-data*)))
		  (point))
		'mt_tb_ping_urls
		*attribute-post-mt_tb_ping_urls*))
       (when (or (blogpost-mt_allow_comments opts)
		 (blogpost-mt_allow_pings opts)
		 (blogpost-mt_convert_breaks opts))
	 (insert "-" width)
	 (insert "\n"))
       (when (blogpost-mt_allow_comments opts)
	 (apply #'set-text-attribute
		(point)
		(progn
		  (insert (format nil "コメント許可：~A~%"
				  (if (blogpost-flag-ok-p (blogpost-mt_allow_comments *post-data*))
				      "する" "しない")))
		  (point))
		'mt_allow_comments
		*attribute-post-options*))
       (when (blogpost-mt_allow_pings opts)
	 (apply #'set-text-attribute
		(point)
		(progn
		  (insert (format nil "TrackBack受入：~A~%"
				  (if (blogpost-flag-ok-p (blogpost-mt_allow_pings *post-data*))
				      "する" "しない")))
		  (point))
		'mt_allow_pings
		*attribute-post-options*))
       (when (blogpost-mt_convert_breaks opts)
	 (apply #'set-text-attribute
		(point)
		(progn
		  (insert (format nil "自動改行変換：~A~%"
				  (if (blogpost-flagstr-ok-p (blogpost-mt_convert_breaks *post-data*))
				      "する" "しない")))
		  (point))
		'mt_convert_breaks
		*attribute-post-options*))
       (insert "-" width)
       (insert "\n")
       (when *debug-mode*
	 (insert (format nil "~S~%" *post-data*)))
       (goto-char (point-min)))))
  (run-hooks '*blog-post-print-hook*))

(defun post-reload ()
  (interactive)
  (post-mode)
  (post-fetch)
  (post-print)
  )

(defun post-del ()
  (interactive)
  (let ((postid (and (blogpost-p *post-data*)
		     (blogpost-postid *post-data*))))
    (when (and postid
	       (yes-or-no-p "~Sを削除しますか？"
			    (blogpost-title *post-data*)))
      (title-delete *post-data*)
      (post-close)
      (title-reload))))

(defun post-show ()
  (interactive)
  (let ((title (title-current)))
    (when title
      (post-open title))
    ))

(defun post-open (title)
  (post-window-set)
  (setq *title-current* title)
  (post-reload)
  (goto-line 1)
  (run-hooks '*blog-post-open-hook*))

(defun post-create ()
  (let ((opts (blog-blog_mode_options *menu-current*)))
    (make-blogpost
     :mt_allow_comments (or (cdr (assoc "mt_allow_comments" opts :test #'equal))
			    *blogpost-flag-ok*)
     :mt_allow_pings (or (cdr (assoc "mt_allow_pings" opts :test #'equal))
			 *blogpost-flag-ok*)
     :mt_convert_breaks (or (cdr (assoc "mt_convert_breaks" opts :test #'equal))
			    *blogpost-flagstr-ng*)
     )))

(defun post-new ()
  (interactive)
  (post-window-set)
  (setq *post-data* (post-create))
  (post-mode)
  (post-print)
  (goto-line 1)
  (run-hooks '*blog-post-new-hook*))

(defun post-fetch ()
  (let ((type (blog-blogtype-get *menu-current*)))
    (setq *post-data* (apply (blogtype-getpost type)
			     (list *menu-current*
				   *title-current*)))
    ))

(defun post-fetch-categories ()
  (let ((type (blog-blogtype-get *menu-current*)))
    (setq *post-category-list* (apply (blogtype-getcategories type)
				      (list *menu-current*)))
    ))

(defun post-close ()
  (interactive)
  (title-window-set))

(defun post-reprint ()
  (let ((pos (point)))
    (post-print)
    (goto-char (min pos (point-max)))))

(defun post-category-add (id name)
  (let* ((current (blogpost-categories *post-data*))
	 (new (make-blogcategory
	       :categoryId id
	       :categoryName name)))
    (setf (blogpost-categories *post-data*) (append current (list new)))
    (post-reprint)))

(defun post-category-del (id)
  (let* ((current (blogpost-categories *post-data*))
	 newlist)
    (dolist (category current)
      (unless (equal id (blogcategory-categoryId category))
	(push category newlist)))
    (setf (blogpost-categories *post-data*) (nreverse newlist))
    (post-reprint)))

(defun post-category-select ()
  (interactive)
  (let* ((menu (create-popup-menu))
	 (categories (post-fetch-categories))
	 (post-category-list (mapcar #'(lambda (x)
					 (cons (blogcategory-categoryId x)
					       (blogcategory-categoryName x)))
				     (blogpost-categories *post-data*))))
    (when categories
      (dolist (category categories)
	(let* ((id (blogcategory-categoryId category))
	       (name (blogcategory-categoryName category))
	       (selected (assoc id post-category-list :test #'equal)))
	  (add-menu-item menu
			 nil
			 name
			 (if selected
			     #'(lambda ()
				 (interactive)
				 (post-category-del id))
			   #'(lambda ()
			       (interactive)
			       (post-category-add id name)))
			 #'(lambda ()
			     (when selected :check)))
	  ))
      (track-popup-menu menu)
      )))

(defun post-edit-title ()
  (interactive)
  (let ((title (read-string "タイトル："
			    :default (blogpost-title *post-data*))))
    (when title
      (setf (blogpost-title *post-data*) title)
      (post-reprint))))

(defun post-edit-date ()
  (interactive)
  (let* ((date (or (blogpost-dateCreated *post-data*)
		   (get-universal-time)))
	 (datestr (read-string "投稿日時："
			       :default (post-date-format date))))
    (when (and datestr
	       (setq date (post-date-parse datestr)))
      (setf (blogpost-dateCreated *post-data*) date)
      (post-reprint))))

(defun post-edit-date-current ()
  (interactive)
  (let* ((date (get-universal-time)))
    (setf (blogpost-dateCreated *post-data*) date)
    (post-reprint)))

(defun post-edit-description (&optional key)
  (interactive)
  (let ((cur (point))
	(pos 0))
    (save-excursion
      (goto-char (point-min))
      (multiple-value-bind (from to tag)
	  (find-text-attribute 'description)
	(setq pos (max 0 (- cur from)))))
    (set-buffer-edit)
    (edit-mode key)
    (save-excursion
      (edit-print key))
    (goto-char pos)))

(defun post-edit-mt_excerpt ()
  (interactive)
  (post-edit-description 'mt_excerpt))

(defun post-edit-mt_text_more ()
  (interactive)
  (post-edit-description 'mt_text_more))

(defun post-edit-mt_tb_ping_urls ()
  (interactive)
  (post-edit-description 'mt_tb_ping_urls))

(defun post-save-publish ()
  (interactive)
  (post-save t))

(defun post-save (&optional publish)
  (interactive)
  (let ((endpoint (blog-endpoint *menu-current*))
	(appkey   (blog-appkey *menu-current*))
	(blogid   (blog-blogid *menu-current*))
	(bloguser (blog-bloguser *menu-current*))
	(blogpass (blog-blogpass *menu-current*))
	(type (blog-blogtype-get *menu-current*))
	(postid (blogpost-postid *post-data*)))
    (if postid
	(if (apply (blogtype-editpost type)
		   (list *menu-current*
			 *post-data*
			 publish ))
	    (progn
	      (when publish
		(post-close))
	      (save-excursion
		(title-reload)))
	  (error "更新エラー"))
      (if (setq postid (apply (blogtype-newpost type)
			      (list *menu-current*
				    *post-data*
				    publish
				    )))
	  (progn
	    (post-close)
	    (title-reload))
	(error "投稿エラー"))
      )))

(defun post-options ()
  (interactive)
  (post-option-mt_allow_comments)
  (post-option-mt_allow_pings)
  (post-option-mt_convert_breaks)
  (post-reprint))

(defun post-read-flag (prompt &optional default)
  (interactive)
  (let* ((flag (or default xmlrpcm::*xmlrpcm-boolean-true*))
	 (reg (format nil "^[~D~D]$"
		      xmlrpcm::*xmlrpcm-boolean-true*
		      xmlrpcm::*xmlrpcm-boolean-false*))
	 str)
    (loop
      (when (and str (string-match reg str))
	(setq flag (parse-integer str))
	(return))
      (setq str (read-string prompt
			     :default (or str (format nil "~D" flag)))))
    flag))

(defun post-toggle-mt_allow_comments ()
  (interactive)
  (let ((flag (blogpost-mt_allow_comments *post-data*)))
    (if (blogpost-flag-ok-p flag)
	(setq flag *blogpost-flag-ng*)
      (setq flag *blogpost-flag-ok*))
    (setf (blogpost-mt_allow_comments *post-data*) flag)
    (post-reprint)))

(defun post-toggle-mt_allow_pings ()
  (interactive)
  (let ((flag (blogpost-mt_allow_pings *post-data*)))
    (if (blogpost-flag-ok-p flag)
	(setq flag *blogpost-flag-ng*)
      (setq flag *blogpost-flag-ok*))
    (setf (blogpost-mt_allow_pings *post-data*) flag)
    (post-reprint)))

(defun post-toggle-mt_convert_breaks ()
  (interactive)
  (let ((flagstr (blogpost-mt_convert_breaks *post-data*)))
    (if (blogpost-flagstr-ok-p flagstr)
	(setq flag *blogpost-flagstr-ng*)
      (setq flag *blogpost-flagstr-ok*))
    (setf (blogpost-mt_convert_breaks *post-data*) flag)
    (post-reprint)))

(defun post-option-mt_allow_comments ()
  (interactive)
  (let ((flag (post-read-flag "コメント許可[1/0]: "
			      (blogpost-mt_allow_comments *post-data*))))
    (when flag
      (setf (blogpost-mt_allow_comments *post-data*) flag))))

(defun post-option-mt_allow_pings ()
  (interactive)
  (let ((flag (post-read-flag "TrackBack受入[1/0]: "
			      (blogpost-mt_allow_pings *post-data*))))
    (when flag
      (setf (blogpost-mt_allow_pings *post-data*) flag))))

(defun post-option-mt_convert_breaks ()
  (interactive)
  (let ((flagstr (blogpost-mt_convert_breaks *post-data*))
	flag)
    (when (and flagstr
	       (setq flag (post-read-flag "自動改行変換[1/0]: " (parse-integer flagstr))))
      (setf (blogpost-mt_convert_breaks *post-data*) (format nil "~D" flag)))))

(defun post-open-page ()
  (interactive)
  (let ((link (blogpost-link *post-data*)))
    (when link
      (open-in-browser link))))

(defun post-cmd-enter ()
  (interactive)
  (let ((pos (point)))
    (multiple-value-bind (from to tag foreground background bold underline strike-out prefix extend)
	(find-text-attribute-point (point))
      (case tag
	('date (post-edit-date))
	('title (post-edit-title))
	('category (post-category-select))
	('description (post-edit-description))
	('mt_excerpt (post-edit-mt_excerpt))
	('mt_text_more (post-edit-mt_text_more))
	('mt_tb_ping_urls (post-edit-mt_tb_ping_urls))
	('mt_allow_comments (post-toggle-mt_allow_comments))
	('mt_allow_pings (post-toggle-mt_allow_pings))
	('mt_convert_breaks (post-toggle-mt_convert_breaks))
	)
      )))

(defun post-upload-file ()
  (interactive)
  (let ((type (blog-blogtype-get *menu-current*)))
    (apply (blogtype-uploadfile type)
	   (list *menu-current*))))

(defun post-upload-file-select ()
  (let ((path (file-name-dialog :title "アープロードファイル選択"
				:must-exist t
				:initial-directory *post-upload-previous-directory*
				:filter '(("すべてのファイル(*.*)" . "*.*")))))
    (when path
      (setq *post-upload-previous-directory*
	    (directory-namestring path)))
    path))

(defun post-preview ()
  (interactive)
  (let* ((type (blog-blogtype-get *menu-current*))
	 (res (apply (blogtype-previewpost type)
		     (list *menu-current*
			   *post-data*))))
    (when res
      (open-in-browser-preview
       (map-slash-to-backslash *preview-tmp-file*)))))

(defun post-preview-save-buffer-to-file ()
  (write-region (point-min)
		(point-max)
		*preview-tmp-file*))

(defun post-preview-convert-list (post)
  (list (cons "title" (blogpost-title post))
	(cons "description" (blogpost-description post))
	(cons "mt_text_more" (blogpost-mt_text_more post))))

(defun post-preview-create (blog post template-file)
  (let (res)
    (unless (file-exist-p template-file)
      (error "テンプレートファイルがありません：~S" template-file))
    (save-excursion
      (set-buffer (get-buffer-create *buffer-template*))
      (erase-buffer (selected-buffer))
      (unwind-protect
	  (let ((params (post-preview-convert-list post)))
	    (insert-file-contents template-file)
	    (dolist (param params)
	      (let ((tag (concat "{" (car param) "}"))
		    (rep (or (cdr param) "")))
		(goto-char (point-min))
		(replace-buffer tag rep)))
	    (when (post-preview-save-buffer-to-file)
	      (setq res t)))
	(delete-buffer *buffer-template*)))
    res))

(defun post-send-trackback-ping (ping-url)
  (interactive "sPing送信先URL：")
  (let ((url (blogpost-permaLink *post-data*))
	(blog_name (blog-blogname *menu-current*))
	(title (blogpost-title *post-data*))
	(excerpt (blogpost-mt_excerpt *post-data*)))
    (unless url
      (error "投稿が保存されていません。"))
    (multiple-value-bind (res error-code error-message)
	(xmlrpcm::trackback-ping-send ping-url
				      url
				      :blog_name blog_name
				      :title title
				      :excerpt excerpt)
      (if res
	  (message "送信完了")
	(error "~S:~S" error-code error-message)))
    ))
