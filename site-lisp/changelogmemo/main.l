;;; -*- Mode: Lisp; Package: ChangeLogMemo -*-
;;;
;;; changelogmemo/main.l
;;;
;;; Last updated: "2006-02-23"
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "changelogmemo/defs"))

(require "changelogmemo/draft")
(require "changelogmemo/edit")
(require "changelogmemo/search")
(require "changelogmemo/esearch")
(require "changelogmemo/and")
(require "changelogmemo/regexp")
(require "changelogmemo/or")
(require "changelogmemo/category")
(require "changelogmemo/date")
(require "changelogmemo/complete")
(require "changelogmemo/buffer-info")
(require "changelogmemo/misc")
(require "changelogmemo/convert")

(provide "changelogmemo/main")

(defvar *cl-config-file-alist*
  '(("changelogmemo" . "~/cl/config.l")))

;;; 起動時にすること
(defun cl-start ()
  (cl::load-cl-config-file (cdar *cl-config-file-alist*))
  (cl::cl-init))

(in-package "changelogmemo")

(defun load-cl-config-file (file)
  (let ((lc (if (string= (pathname-type file) "l")
		(concat file "c")
	      (concat file ".lc"))))
    (if (file-exist-p lc)
	(load lc)
      (load file))))

(defun cl-init ()
  (save-window-excursion
    (get-buffer-create-save))
  (read-variables)
  (make-regexps)
  (make-formats))

(defun make-regexps ()
  (let ((dreg (format nil "^\\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\\) ([A-Z][a-z][a-z])  ~A$" *cl-user*))
	(yreg (format nil "^\\([0-9][0-9][0-9][0-9]\\)-[0-9][0-9]-[0-9][0-9] ([A-Z][a-z][a-z])  ~A$" *cl-user*))
	(mreg (format nil "^\\([0-9][0-9][0-9][0-9]-[0-9][0-9]\\)-[0-9][0-9] ([A-Z][a-z][a-z])  ~A$" *cl-user*)))
    (setq *date-regexp* (compile-regexp dreg))
    (setq *year-regexp* (compile-regexp yreg))
    (setq *month-regexp* (compile-regexp mreg))))

(defun make-formats ()
  (setq *memo-format* (memo-format))
  (setq *search-format* (search-format))
  (setq *esearch-format* (esearch-format)))

(defun memo-format ()
  (compile-regexp-keyword-list
   `(,*date-keyword*
     ,*category-keyword*
     ,*link-keyword*
     ,*date-link-keyword*
     ,*url-keyword*
     ,*strong-keyword*
     ,*em-strong-keyword*
     ,*title-keyword*
     ,*private-title-keyword*
     ,*quote-keyword*
     ,*horizon-keyword*)))

(defun search-format ()
  (compile-regexp-keyword-list
   `(,*date-keyword*
     ,*category-keyword*
     ,*link-keyword*
     ,*date-link-keyword*
     ,*url-keyword*
     ,*strong-keyword*
     ,*em-strong-keyword*
     ,*title-keyword-with-tab*
     ,*private-title-keyword-with-tab*
     ,*quote-keyword-with-tab*
     ,*horizon-keyword-with-tab*
     ,*search-category-keyword*
     ,*search-year-month-keyword*
     ,*search-month-day-keyword*)))

(defun esearch-format ()
  (compile-regexp-keyword-list
   `(,*date-keyword*
     ,*category-keyword*
     ,*link-keyword*
     ,*date-link-keyword*
     ,*url-keyword*
     ,*strong-keyword*
     ,*em-strong-keyword*
     ,*title-keyword*
     ,*private-title-keyword*
     ,*quote-keyword*
     ,*horizon-keyword*
     ,*search-category-keyword*
     ,*search-year-month-keyword*
     ,*search-month-day-keyword*)))

;;; 変数をファイルから読む(migegmo.l で上書き)
(defun read-variables ()
  (let ((dir *cl-history-directory*))
    (unless (file-directory-p dir)
      (when (yes-or-no-p "~A を作成しますか?" dir)
	(create-directory dir))))
  (read-and-variable)
  (read-or-variable)
  (read-regexp-variable)
  (read-category-variable)
  (read-year-variable)
  (read-month-variable)
  (read-day-variable))

(defun read-and-variable ()
  (read-variable *and-filename* '*and-history-list*))

(defun read-or-variable ()
  (read-variable *or-filename* '*or-history-list*))

(defun read-regexp-variable ()
  (read-variable *regexp-filename* '*regexp-history-list*))

(defun read-category-variable ()
  (read-variable *category-filename* '*category-history-list*))

(defun read-year-variable ()
  (read-variable *year-filename* '*year-history-list*))

(defun read-month-variable ()
  (read-variable *month-filename* '*month-history-list*))

(defun read-day-variable ()
  (read-variable *day-filename* '*day-history-list*))

(defun read-variable (filename sym)
  (let ((file (merge-pathnames filename *cl-history-directory*)))
    (if (file-exist-p file)
	(set sym (with-open-file (is file :direction :input)
		   (read is)))
      (set sym nil))))

;;; change-clmemo
(defun change-clmemo ()
  (interactive)
  (let ((name) (list user::*cl-config-file-alist*))
    (let ((*minibuffer-default-history* (mapcar #'car list)))
      (declare (special *minibuffer-default-history*))
      (setq name (completing-read "CL: " (mapcar #'car list)
				  :default (caar list)
				  :must-match t)))
    (change-clmemo-1 name list)))

(defun change-clmemo-1 (name config-list)
  (load-cl-config-file (cdr (assoc name config-list :test #'string=)))
  (save-window-excursion
    (let ((memo (find-buffer *buffer-memo*))
	  (search (find-buffer *buffer-search*))
	  (save (find-buffer *buffer-save*)))
      (and memo (kill-buffer memo))
      (and search (delete-buffer search))
      (and save (delete-buffer save)))
    (cl-init))
  (message "~A" name))

;;; kill-buffer 対策

;; *delete-buffer-hook*
(defun delete-memo-buffer (buffer)
  (cond ((and (string= (buffer-name buffer) *buffer-memo*)
	      (eq buffer-mode 'memo-mode))
	 (let ((pframe (find-pseudo-frame memo-pframe)))
	   (and memo-winconf
		(set-window-configuration memo-winconf))
	   (and pframe (select-pseudo-frame pframe))))
	((and (string= (buffer-name buffer) *buffer-search*)
	      (find buffer-mode
		    `(,'search-mode ,'esearch-mode)))
	 (and search-winconf
	      (set-window-configuration search-winconf))))
  t)

(add-hook '*delete-buffer-hook* 'delete-memo-buffer)

;; *query-kill-buffer-hook*
(defun kill-memo-buffer (&optional noask)
  (let ((buffer (selected-buffer)))
    (if (and (equal (buffer-name buffer) *buffer-memo*)
	     (eq buffer-mode 'memo-mode))
	(if buffer-info
	    (let ((pframe (find-pseudo-frame memo-pframe))
		  (winconf memo-winconf) (info buffer-info))
	      (and (not noask)
		   (need-buffer-save-p buffer)
		   (not (no-or-yes-p
			 "~sは変更されています。変更内容を破棄しますか?"
			 buffer))
		   (return-from kill-memo-buffer nil))
	      ;*buffer-save* を更新
	      (get-buffer-create-save)
	      (erase-buffer (selected-buffer))
	      (insert-file-contents *cl-file*)
	      ;*scratch* のポイント位置を保存するため↓
	      (set-window-configuration winconf)
	      (let ((buf (selected-buffer)))
		(set-buffer *buffer-memo*)
		(restore-buffer-info info)
		(rename-buffer *cl-buffer*)
		(set-buffer buf))
	      ;こうした↑(よく分かっていない)
	      (and pframe (select-pseudo-frame pframe))
	      (setq *memo-show-p* nil))
	  (progn
	    (setq *memo-show-p* nil)
	    t))
      t)
    ))

(add-hook '*query-kill-buffer-hook* 'kill-memo-buffer)

;; close-session を上書き
(in-package "editor")
(defun close-session (&optional noask (create-new t) (fn #'write-file))
  (interactive "p")
  (save-some-buffers (not noask) fn)
  (auto-save-session-file)
  (let ((scratch (find-buffer "*scratch*"))
	(clsave (find-buffer cl::*buffer-save*))
	(clmemo (find-buffer cl::*buffer-memo*)))
    (dolist (buffer (buffer-list))
      (or (eq buffer scratch)
	  (eq buffer clsave)
	  (and (eq buffer clmemo)
	       (set-buffer buffer)
	       (not (cl::kill-memo-buffer t)))
	  (delete-buffer buffer))))
  (delete-all-pseudo-frames create-new)
  (delete-other-windows)
  (setq *current-session-file-name* nil)
  (clear-message))
(in-package "changelogmemo")

;; kill-clmemo-buffer (*scratch* を終了時に保存している場合のための設定に使う)
(defun kill-clmemo-buffer ()
  (let ((buf (find-buffer *buffer-memo*)))
    (and buf (kill-buffer buf))))
