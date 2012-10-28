;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: menu.l 590 2006-02-04 20:11:42Z torihat $
;
; blog/menu.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "blog/defs"))

(provide "blog/menu")

(in-package "blog")

(unless *menu-map*
  (setq *menu-map* (make-sparse-keymap))
  (define-key *menu-map* #\RET 'menu-open)
  (define-key *menu-map* #\SPC 'menu-open)
  (define-key *menu-map* #\a 'menu-add)
  (define-key *menu-map* #\d 'menu-del)
  (define-key *menu-map* #\C-k 'menu-cut)
  (define-key *menu-map* #\C-y 'menu-paste)
  (define-key *menu-map* #\o 'menu-open-in-browser)
  (define-key *menu-map* #\p 'menu-property-menu)
  (define-key *menu-map* #\q 'finish)
)

(defun menu-mode ()
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
  (set-buffer-fold-width nil)
  (set-buffer-fileio-encoding *encoding-utf8n*)
  (make-local-variable 'mode-line-format)
  (make-local-variable 'title-bar-format)
  (menu-mode-line)
  (use-keymap *menu-map*)
  (run-hooks '*blog-menu-mode-hook*)
  )

(defun window-split ()
  (split-window-vertically *menu-window-width*)
  (setq *window-menu* (selected-window))
  (other-window 1)
  (setq *window-title* (selected-window)))

(defun menu-window-split ()
  (menu-window-only)
  (window-split))

(defun menu-window-only ()
  (interactive)
  (set-buffer-menu)
  (delete-other-windows))

(defun set-buffer-menu ()
  (set-buffer (get-buffer-create *buffer-menu*)))

(defun menu-mode-line ()
  (setq mode-line-format (format nil "%b"))
  (setq title-bar-format (format nil "%b")))

(defun menu-mode-line-update ()
  (save-excursion
    (set-buffer-menu)
    (menu-mode-line)))

(defun menu-print ()
  (modify-read-only-buffer
   (erase-buffer (selected-buffer))
   (clear-all-text-attributes)
   (apply #'set-text-attribute
	  (point)
	  (progn
	    (insert (format nil "Blogs~%"))
	    (point))
	  'blogs
	  *attribute-menu-title*)
   (dolist (blog *menu-data*)
     (let ((name (blog-blogname blog)))
       (apply #'set-text-attribute
	      (point)
	      (progn
		(insert (format nil " ~A~%" name ))
		(point))
	      'blog
	      *attribute-menu-blog*)))
   (goto-line *menu-line-diff*))
  (run-hooks '*blog-menu-print-hook*))

(defvar *menu-line-diff* 2)

(defun menu-line-to-number (line-number)
  (- line-number *menu-line-diff*))

(defun menu-number-to-line (pos)
  (+ pos *menu-line-diff*))

(defun menu-current ()
  (let ((num (current-line-number)))
    (cond ((= 1 num)
	   nil)
	  ((< 1 num)
	   (nth (menu-line-to-number num) *menu-data*))
	  (t
	   nil))))

(defun menu-delete (pos)
  (let ((len (length *menu-data*))
	temp)
    (when (<= len pos)
      (return-from menu-delete))
    (dotimes (i len)
      (unless (= i pos)
	(push (nth i *menu-data*) temp)))
    (setq *menu-data* (nreverse temp))
    (menu-data-save)))

(defun menu-insert (blog &optional pos)
  (let ((len (length *menu-data*))
	temp)
    (setq pos (if pos
		  (min pos len)
		len))
    (if (= pos len)
	(progn
	  (setq temp (reverse *menu-data*))
	  (push blog temp))
      (dotimes (i len)
	(when (= i pos)
	  (push blog temp))
	(push (nth i *menu-data*) temp)))
    (setq *menu-data* (nreverse temp))
    (menu-data-save)))

(defun blog-exist-p (blog)
  (member blog *menu-data* :test #'blog-equal))

(defun menu-add ()
  (interactive)
  (let* ((num (current-line-number))
	 (pos (menu-line-to-number num))
	 (type (blogtype-select)))
    (unless type
      (error "Blog Typeが選択されていません。"))
    (dolist (blog (apply (blogtype-getblogs type)
			 (list type)))
      (unless (blog-exist-p blog)
	(menu-insert blog (max pos 0))
	(incf pos)))
    (menu-data-save)
    (menu-print)
    (goto-line num)))

(defun menu-del ()
  (interactive)
  (let ((num (current-line-number))
	(pos (menu-line-to-number (current-line-number)))
	(blog (menu-current)))
    (when (and blog
	       (yes-or-no-p "~Sを削除しますか？"
			    (blog-blogname blog)))
      (menu-delete pos)
      (menu-data-save)
      (menu-print)
      (goto-line num))))

(defun menu-cut ()
  (interactive)
  (let* ((num (current-line-number))
	 (pos (menu-line-to-number num))
	 (blog (menu-current)))
    (when blog
      (menu-delete pos)
      (blog-clipboard-push blog)
      (menu-data-load)
      (menu-print)
      (goto-line num))))

(defun menu-paste ()
  (interactive)
  (let* ((num (current-line-number))
	 (pos (menu-line-to-number num))
	 (blog (blog-clipboard-pop)))
    (when blog
      (menu-insert blog pos)
      (menu-data-load)
      (menu-print)
      (goto-line num))))

(defun menu-open ()
  (interactive)
  (let* ((blog (menu-current)))
    (when blog
      (menu-window-split)
      (title-open blog)
      (goto-line 1)
      (run-hooks '*blog-menu-open-hook*))
    ))

(defun menu-open-in-browser ()
  (interactive)
  (let* ((blog (menu-current))
	 (url (blog-blogurl blog)))
    (when url
      (open-in-browser url))))

;;
;; ブログ毎の初期設定等
;; blogtype毎に制御すべきだとは思うがとりあえず・・・
;; 
(defvar *blog-properties*
  '(("mt_allow_comments" . "コメント許可")
    ("mt_allow_pings"    . "TrackBack受入")
    ("mt_convert_breaks" . "自動改行変換")))

(defun menu-property-set (pos key value)
  (let* ((opts (blog-blog_mode_options (nth pos *menu-data*)))
	 (pair (assoc key opts :test #'equal)))
    (if pair
	(setf (cdr (assoc key
			  (blog-blog_mode_options (nth pos *menu-data*))
			  :test #'equal))
	      value)
      (setf (blog-blog_mode_options (nth pos *menu-data*))
	    (append opts (list (cons key value)))))
    (menu-data-save)))

(defun menu-property-menu ()
  (interactive)
  (let* ((line (current-line-number))
	 (pos (menu-line-to-number line))
	 (blog (menu-current))
	 (opts (blog-blog_mode_options blog))
	 options
	 (menu (create-popup-menu)))
    (dolist (opt opts)
      (let ((key (car opt))
	    (val (cdr opt))
	    name)
	(when (setq name (cdr (assoc key *blog-properties* :test #'equal)))
	  (push opt options)
	  (cond ((or (equal key "mt_allow_comments")
		     (equal key "mt_allow_pings"))
		 (let* ((flag-current (if (blogpost-flag-ok-p val)
					  *blogpost-flag-ok*
					*blogpost-flag-ng*))
			(flag-after (if (blogpost-flag-ok-p flag-current)
					*blogpost-flag-ng*
				      *blogpost-flag-ok*)))
		   (add-menu-item menu
				  nil
				  name
				  #'(lambda ()
				      (interactive)
				      (menu-property-set pos
							 key
							 flag-after))
				  #'(lambda ()
				      (when (blogpost-flag-ok-p flag-current)
					:check)))))
		((equal key "mt_convert_breaks")
		 (let* ((flagstr-current (if (blogpost-flagstr-ok-p val)
					     *blogpost-flagstr-ok*
					   *blogpost-flagstr-ng*))
			(flagstr-after (if (blogpost-flagstr-ok-p flagstr-current)
					   *blogpost-flagstr-ng*
					 *blogpost-flagstr-ok*)))
		   (add-menu-item menu
				  nil
				  name
				  #'(lambda ()
				      (interactive)
				      (menu-property-set pos
							 key
							 flagstr-after))
				  #'(lambda ()
				      (when (blogpost-flagstr-ok-p flagstr-current)
					:check)))))
		))))
    (unless options
      (message "設定項目はありません。")
      (return-from menu-property-menu))
    (track-popup-menu menu)
    ))
