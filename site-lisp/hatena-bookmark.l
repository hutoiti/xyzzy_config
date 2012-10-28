;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: hatena-bookmark.l 820 2009-05-14 03:28:18Z torihat $
;
; hatena-bookmark.l
;
; by HATTORI Masashi
;
;■ hatena-bookmark.l とは？
;
;	はてなブックマークをAtomAPIを利用して参照、投稿、編集、削除を行います。
;
;	はてなブックマークAtomAPI
;	http://d.hatena.ne.jp/keyword/%a4%cf%a4%c6%a4%ca%a5%d6%a5%c3%a5%af%a5%de%a1%bc%a5%afAtomAPI
;
;■ 動作環境
;
;	xyzzy-0.2.2.235 以降のみ動作確認しています。
;
;	以下の拡張が必要です。別途インストールしてください。
;		- atom-modoki
;
;■ インストール
;
;    1. ファイルの展開
;
;	配布アーカイブを system-root 以下に展開してください。
;
;    2. ~/.xyzzy などに設定
;
;	(autoload 'hatena-bookmark "hatena-bookmark" t)
;	(autoload 'hatena-bookmark-add "hatena-bookmark" t)
;	(autoload 'hatena-bookmark-config "hatena-bookmark" t)
;	NetInstaller経由でインストールして ni-autoload を利用している場合には必要ありません。
;
;    3. 動かし方
;
;	M-x hatena-bookmark		起動
;	M-x hatena-bookmark-add		ブックマークを追加
;	M-x hatena-bookmark-config	アカウント設定変更
;
;	※ 初回起動時にはてなのUsername、Passwordを入力してください。
;
;■キーバインド
;
;		Enter	カーソル位置のブックマークを開く
;			もしくはソート・タグ選択メニューを開く
;		Space	同上
;		o	カーソル位置のブックマークのはてな当該ページを開く
;		Tab	次のブックマーク
;		n	同上
;		p	前のブックマーク
;		a	ブックマークを新規登録
;		e	カーソル位置のブックマークを編集
;		d	カーソル位置のブックマークを削除
;		r	一覧を更新
;		f	タグ選択メニューを開く
;		s	ソート選択メニューを開く
;		c	表示項目選択メニューを開く
;		O	はてなブックマークを開く
;		q	終了
;
;■設定例
;
;	★ www-mode で利用する設定例
;
;	=> ~/.hatena/hatenab-config.l に
;
;	(in-package "editor")
;	
;	(require "www/www")
;	
;	(defun hatena-bookmark-mode-open-in-browser (url)
;	  (user::www-open-url url))
;	
;	=> ~/.www に
;
;	(require "hatena-bookmark")
;	
;	;;; ブックマークをはてなに登録
;	(defun www-bookmark-add-hatena ()
;	  (interactive)
;	  (let ((url (read-string "URL: " :default www-url))
;		(summary (read-string "コメント: ")))
;	    (user::hatena-bookmark-add url summary)))
;	
;	(define-key *www-view-mode-map* #\A 'www-bookmark-add-hatena)
;	
;	;;; ブックマークを開く代わりにhatena-bookmarkを開く
;	(define-key *www-view-mode-map* #\B 'user::hatena-bookmark)
;
;■ Changelog
;
;	[2009/05/13]	77 Arashiさんのパッチを元に修正。(__)
;
;	[2006/01/28]	"xyzzy Part13"の484を取り込み。(__)
;
;	[2006/01/14] 	初版
;
;■ License
;
; hatena-bookmark.l
;
; Copyright (C) 2006 Masashi Hattori
; All rights reserved.
; 
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions
; are met:
; 
; 1. Redistributions of source code must retain the above copyright
;    notice, this list of conditions and the following disclaimer.
; 
; 2. Redistributions in binary form must reproduce the above copyright
;    notice, this list of conditions and the following disclaimer in
;    the documentation and/or other materials provided with the
;    distribution.
; 
; 3. The name of the author may not be used to endorse or promote
;    products derived from this software without specific prior
;    written permission.
; 
; THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
; PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
; STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
; ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE!
; POSSIBILITY OF SUCH DAMAGE.

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "atomm/defs")
  (require "junk/lib"))

(require "atomm/publish")

(provide "hatena-bookmark")

(in-package "editor")

(defvar *hatena-bookmark-endpoint-base* "http://b.hatena.ne.jp/")
(defvar *hatena-bookmark-endpoint*      "http://b.hatena.ne.jp/atom")

(defvar *hatena-bookmark-basedir* "~/.hatena")
(defvar *hatena-bookmark-account-file*
  (merge-pathnames "hatenab.acc" *hatena-bookmark-basedir*))
(defvar *hatena-bookmark-data-file*
  (merge-pathnames "hatenab.dat" *hatena-bookmark-basedir*))
(defvar *hatena-bookmark-config-file*
  (merge-pathnames "hatenab-config.l" *hatena-bookmark-basedir*))

(defvar *hatena-bookmark-account* nil)
(defvar *hatena-bookmark-feed* nil)

(defvar *hatena-bookmark-mode-pos-list* nil)
(defvar *hatena-bookmark-mode-filter* nil)
(defvar *hatena-bookmark-mode-sort* nil)

(defvar *hatena-bookmark-mode-sort-list*
  (list (cons nil "なし")
	(cons 'hatena-bookmark-sort-by-title  "タイトル順")
	(cons 'hatena-bookmark-sort-by-issued  "登録した順")
	))

(defvar *hatena-bookmark-mode-column-list*
  (list (list 'column-title   "タイトル"       t)
	(list 'column-url     "URL"            t)
	(list 'column-summary "タグ・コメント" t)))

(defvar *hatena-bookmark-mode-indent-string* "")

(defvar *hatena-bookmark-mode-hook* nil)
(setq *hatena-bookmark-mode-map* nil)
(defvar *hatena-bookmark-mode-buffer* "*Hatena::Bookmark*")

(defvar *hatena-bookmark-attribute-name* '(:bold t))
(defvar *hatena-bookmark-attribute-filter* nil)
(defvar *hatena-bookmark-attribute-sort* nil)
(defvar *hatena-bookmark-attribute-column* nil)
(defvar *hatena-bookmark-attribute-title* '(:bold t))
(defvar *hatena-bookmark-attribute-summary* nil)
(defvar *hatena-bookmark-attribute-related* nil)
(defvar *hatena-bookmark-attribute-tag* nil)

(defvar *hatena-bookmark-hook* nil)
(defvar *hatena-bookmark-add-hook* nil)

(defstruct hatenab_acc
  id
  username
  password
  title
  service.post
  service.feed
  alternate)

(defstruct hatenab_feed
  id
  title
  author
  alternate
  service.post
  service.feed
  next
  prev
  modified
  openSearch_totalResult
  openSearch_startIndex
  openSearch_itemsPerPage
  entries
  tags
  )

(defstruct hatenab_entry
  id
  title
  alternate
  related
  service.edit
  issued
  author
  summary
  dc_subjects
  )

(defun hatena-bookmark-get-root (username password)
 (atomm::atomm-get-root *hatena-bookmark-endpoint*
			username
			password))

(defun hatena-bookmark-post-entry (url summary)
  (let ((entry (list "entry" nil
		     (list "link" (list (cons "rel" "related")
					(cons "type" "text/html")
					(cons "href" url)
					(cons 'ed::single t)))
		     (list "summary" (list (cons "type" "text/plain")) summary))))
    (atomm::atomm-post-entry (hatenab_acc-service.post *hatena-bookmark-account*)
			     (hatenab_acc-username *hatena-bookmark-account*)
			     (hatenab_acc-password *hatena-bookmark-account*)
			     (list entry))))

(defun hatena-bookmark-edit-entry (editurl title summary)
  (let ((entry (list "entry" nil
		     (list "summary" (list (cons "type" "text/plain")) summary)
		     (list "title"  nil title))))
    (atomm::atomm-edit-entry editurl
			     (hatenab_acc-username *hatena-bookmark-account*)
			     (hatenab_acc-password *hatena-bookmark-account*)
			     (list entry))))

(defun hatena-bookmark-delete-entry (deleteurl)
  (atomm::atomm-delete-entry deleteurl
			     (hatenab_acc-username *hatena-bookmark-account*)
			     (hatenab_acc-password *hatena-bookmark-account*)))

(defun hatena-bookmark-account-config (&optional hatenab_acc)
  (let* ((username (read-string "Username: "
				:default (and (hatenab_acc-p hatenab_acc)
					      (hatenab_acc-username hatenab_acc))))
	 (password (read-string "Password: "
				:default (and (hatenab_acc-p hatenab_acc)
					      (hatenab_acc-password hatenab_acc))))
	 (root (hatena-bookmark-get-root username password)))
    (when root
      (setq hatenab_acc (if (hatenab_acc-p hatenab_acc)
			    hatenab_acc
			  (make-hatenab_acc :username username
					    :password password)))
      (let ((title (car (car root)))
	    (links (cdr (car root))))
	(setf (hatenab_acc-title hatenab_acc) title)
	(setf (hatenab_acc-service.post hatenab_acc)
	      (hatena-bookmark-parse-url (cdr (assoc "service.post" links :test #'equal))))
	(setf (hatenab_acc-service.feed hatenab_acc)
	      (hatena-bookmark-parse-url (cdr (assoc "service.feed" links :test #'equal))))
	hatenab_acc))))

(defun hatena-bookmark-parse-url (url)
  (if (stringp url)
      (if (string-match "^https?://" url)
	  url
	(let ((path (substitute-string url "^/+" "")))
	  (concat *hatena-bookmark-endpoint-base* path)))))

(defun hatena-bookmark-account-load ()
  (if *hatena-bookmark-account*
      *hatena-bookmark-account*
    (when (file-exist-p *hatena-bookmark-account-file*)
      (setq *hatena-bookmark-account*
	    (car (junk::data-read-from-file *hatena-bookmark-account-file*))))))

(defun hatena-bookmark-account-save ()
  (junk::data-write-to-file *hatena-bookmark-account-file*
			    (list *hatena-bookmark-account*)))

(defun hatena-bookmark-data-load ()
  (if *hatena-bookmark-feed*
      *hatena-bookmark-feed*
    (when (file-exist-p *hatena-bookmark-data-file*)
      (setq *hatena-bookmark-feed*
	    (car (junk::data-read-from-file *hatena-bookmark-data-file*))))))

(defun hatena-bookmark-data-save ()
  (junk::data-write-to-file *hatena-bookmark-data-file*
			    (list *hatena-bookmark-feed*)))

(defun hatena-bookmark-get-feed (hatenab_acc)
  (atomm::atomm-get-feed (hatenab_acc-service.feed hatenab_acc)
			 (hatenab_acc-username hatenab_acc)
			 (hatenab_acc-password hatenab_acc)))

(defun hatena-bookmark-get-feed-next (hatenab_acc next)
  (atomm::atomm-get-feed next
			 (hatenab_acc-username hatenab_acc)
			 (hatenab_acc-password hatenab_acc)))

(defun hatena-bookmark-get-account-feed (hatenab_acc)
  (multiple-value-bind (feed entries)
      (hatena-bookmark-get-feed hatenab_acc)
    (let ((f (hatena-bookmark-parse-feed feed)))
      (setf (hatenab_acc-alternate hatenab_acc)
	    (hatenab_feed-alternate f))
      (setf (hatenab_acc-id hatenab_acc)
	    (hatenab_feed-id f))
      hatenab_acc)))

(defun hatena-bookmark-parse-feed (feed)
  (let ((ffeed (make-hatenab_feed)))
    (dolist (f (ed::xmlpm-tag-contents feed))
      (let ((key (ed::xmlpm-tag-name f)))
	(cond ((equal key "link")
	       (let* ((opts (ed::xmlpm-tag-opts f))
		      (rel (cdr (assoc "rel" opts :test #'equal)))
		      (href (cdr (assoc "href" opts :test #'equal))))
		 (cond ((equal rel "alternate")
			(setf (hatenab_feed-alternate ffeed) (hatena-bookmark-parse-url href)))
		       ((equal rel "service.feed")
			(setf (hatenab_feed-service.feed ffeed) (hatena-bookmark-parse-url href)))
		       ((equal rel "service.post")
			(setf (hatenab_feed-service.post ffeed) (hatena-bookmark-parse-url href)))
		       ((equal rel "next")
			(setf (hatenab_feed-next ffeed) (hatena-bookmark-parse-url href)))
		       ((equal rel "prev")
			(setf (hatenab_feed-prev ffeed) (hatena-bookmark-parse-url href))))))
	      ((equal key "id")
	       (setf (hatenab_feed-id ffeed)
		     (car (ed::xmlpm-tag-contents f))))
	      ((equal key "title")
	       (setf (hatenab_feed-title ffeed)
		     (car (ed::xmlpm-tag-contents f))))
	      ((equal key "modified")
	       (setf (hatenab_feed-modified ffeed)
		     (atomm::atomm-parseDateLocal (car (ed::xmlpm-tag-contents f)))))
	      ((equal key "author")
	       (let ((cs (ed::xmlpm-tag-contents f)))
		 (setf (hatenab_feed-author ffeed)
		       (car (ed::xmlpm-tag-contents (assoc "name" cs :test #'equal))))))
	      ((equal key "openSearch:totalResults")
	       (setf (hatenab_feed-openSearch_totalResult ffeed)
		     (parse-integer (car (ed::xmlpm-tag-contents f)))))
	      ((equal key "openSearch:startIndex")
	       (setf (hatenab_feed-openSearch_startIndex ffeed)
		     (parse-integer (car (ed::xmlpm-tag-contents f)))))
	      ((equal key "openSearch:itemsPerPage")
	       (setf (hatenab_feed-openSearch_itemsPerPage ffeed)
		     (parse-integer (car (ed::xmlpm-tag-contents f)))))
	      )))
    ffeed))

(defun hatena-bookmark-parse-entry (e)
  (let ((entry (make-hatenab_entry))
	subjects)
    (dolist (content (ed::xmlpm-tag-contents e))
      (let ((key (ed::xmlpm-tag-name content)))
	(cond ((equal key "link")
	       (let* ((opts (ed::xmlpm-tag-opts content))
		      (rel (cdr (assoc "rel" opts :test #'equal)))
		      (href (cdr (assoc "href" opts :test #'equal))))
		 (cond ((equal rel "alternate")
			(setf (hatenab_entry-alternate entry) (hatena-bookmark-parse-url href)))
		       ((equal rel "related")
			(setf (hatenab_entry-related entry) (hatena-bookmark-parse-url href)))
		       ((equal rel "service.edit")
			(setf (hatenab_entry-service.edit entry) (hatena-bookmark-parse-url href))))))
	      ((equal key "id")
	       (setf (hatenab_entry-id entry)
		     (car (ed::xmlpm-tag-contents content))))
	      ((equal key "title")
	       (setf (hatenab_entry-title entry)
		     (car (ed::xmlpm-tag-contents content))))
	      ((equal key "issued")
	       (setf (hatenab_entry-issued entry)
		     (atomm::atomm-parseDateLocal (car (ed::xmlpm-tag-contents content)))))
	      ((equal key "author")
	       (let ((cs (ed::xmlpm-tag-contents content)))
		 (setf (hatenab_entry-author entry)
		       (car (ed::xmlpm-tag-contents (assoc "name" cs :test #'equal))))))
	      ((equal key "dc:subject")
	       (push (car (ed::xmlpm-tag-contents content)) subjects))
	      ((equal key "summary")
	       (setf (hatenab_entry-summary entry)
		     (car (ed::xmlpm-tag-contents content)))))))
    (setf (hatenab_entry-dc_subjects entry) (nreverse subjects))
    entry))

(defun hatena-bookmark-account-create ()
  (interactive)
  (setq *hatena-bookmark-account*
	(hatena-bookmark-account-config *hatena-bookmark-account*))
  (setq *hatena-bookmark-account*
	(hatena-bookmark-get-account-feed *hatena-bookmark-account*))
  (hatena-bookmark-account-save))

(defun hatena-bookmark-get-all-entries (hatenab_acc)
  (let (allfeed
	allentries
	alltags
	feed
	pfeed
	entries)
    (multiple-value-setq (feed entries)
      (hatena-bookmark-get-feed hatenab_acc))
    (setq pfeed (hatena-bookmark-parse-feed feed))
    (setq allfeed pfeed)
    (loop
      (dolist (e entries)
	(let ((ee (hatena-bookmark-parse-entry e)))
	  (push ee allentries)
	  (dolist (tag (hatenab_entry-dc_subjects ee))
	    (pushnew tag alltags :test #'equal))))
      (or (hatenab_feed-next pfeed) (return))
      (multiple-value-setq (feed entries)
	(hatena-bookmark-get-feed-next hatenab_acc (hatenab_feed-next pfeed)))
      (setq pfeed (hatena-bookmark-parse-feed feed)))
    (setf (hatenab_feed-entries allfeed) (nreverse allentries))
    (setf (hatenab_feed-tags allfeed) (sort alltags #'string-lessp))
    allfeed))

(defun hatena-bookmark-get-entries (&optional reload)
  (when (or (not *hatena-bookmark-feed*)
	    reload)
    (setq *hatena-bookmark-feed*
	  (hatena-bookmark-get-all-entries *hatena-bookmark-account*))
    (hatena-bookmark-data-save)))

(defun hatena-bookmark-init ()
  (unless (file-exist-p *hatena-bookmark-basedir*)
    (unless (create-directory *hatena-bookmark-basedir*)
      (error "ディレクトリを作成できません: ~S" *hatena-bookmark-basedir*)))
  (junk::load-config-file *hatena-bookmark-config-file*)
  (unless (hatena-bookmark-account-load)
    (hatena-bookmark-account-create))
  (unless *hatena-bookmark-account*
    (error "アカウントが設定されていません。"))
  (unless (hatena-bookmark-data-load)
    (hatena-bookmark-get-entries)))

;;;
;;; hatena-bookmark-mode
;;;

(unless *hatena-bookmark-mode-map*
  (setq *hatena-bookmark-mode-map* (make-sparse-keymap))
  (define-key *hatena-bookmark-mode-map* #\RET  'hatena-bookmark-mode-open)
  (define-key *hatena-bookmark-mode-map* #\SPC  'hatena-bookmark-mode-open)
  (define-key *hatena-bookmark-mode-map* #\TAB  'hatena-bookmark-mode-next)
  (define-key *hatena-bookmark-mode-map* #\n    'hatena-bookmark-mode-next)
  (define-key *hatena-bookmark-mode-map* #\p    'hatena-bookmark-mode-prev)
  (define-key *hatena-bookmark-mode-map* #\e    'hatena-bookmark-mode-edit)
  (define-key *hatena-bookmark-mode-map* #\d    'hatena-bookmark-mode-delete)
  (define-key *hatena-bookmark-mode-map* #\a    'user::hatena-bookmark-add)
  (define-key *hatena-bookmark-mode-map* #\r    'hatena-bookmark-mode-reload)
  (define-key *hatena-bookmark-mode-map* #\f    'hatena-bookmark-mode-filter-menu)
  (define-key *hatena-bookmark-mode-map* #\s    'hatena-bookmark-mode-sort-menu)
  (define-key *hatena-bookmark-mode-map* #\c    'hatena-bookmark-mode-column-menu)
  (define-key *hatena-bookmark-mode-map* #\o    'hatena-bookmark-mode-open-alternate)
  (define-key *hatena-bookmark-mode-map* #\O    'hatena-bookmark-mode-open-site)
  (define-key *hatena-bookmark-mode-map* #\q    'hatena-bookmark-mode-finish)
)

(defun hatena-bookmark-mode ()
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
  (hatena-bookmark-mode-line)
  (use-keymap *hatena-bookmark-mode-map*)
  (run-hooks '*hatena-bookmark-mode-hook*)
  )

(defun hatena-bookmark-mode-buffer-set ()
  (set-buffer (get-buffer-create *hatena-bookmark-mode-buffer*)))

(defun hatena-bookmark-mode-line ()
  (setq mode-line-format (format nil "%b"))
  (setq title-bar-format (format nil "%b")))

(defun hatena-bookmark-mode-pos-add (pos)
  (setq *hatena-bookmark-mode-pos-list*
	(append *hatena-bookmark-mode-pos-list*
		(list pos))))

(defun hatena-bookmark-print-entry (entry)
  (hatena-bookmark-mode-pos-add (point))
  (when (hatena-bookmark-mode-column-print 'column-title)
    (apply #'set-text-attribute
	   (point)
	   (progn
	     (insert (format nil "~@[~A~]" (hatenab_entry-title entry)))
	     (point))
	   entry
	   *hatena-bookmark-attribute-title*)
    (insert "\n"))
  (when (hatena-bookmark-mode-column-print 'column-url)
    (insert *hatena-bookmark-mode-indent-string*)
    (apply #'set-text-attribute
	   (point)
	   (progn
	     (insert (format nil "~@[~A~]" (hatenab_entry-related entry)))
	     (point))
	   entry
	   *hatena-bookmark-attribute-related*)
    (insert "\n"))
  (when (hatena-bookmark-mode-column-print 'column-summary)
    (insert *hatena-bookmark-mode-indent-string*)
    (dolist (tag (hatenab_entry-dc_subjects entry))
      (apply #'set-text-attribute
	     (point)
	     (progn
	       (insert (format nil "[~A]" tag))
	       (point))
	     tag
	     *hatena-bookmark-attribute-tag*))
    (apply #'set-text-attribute
	   (point)
	   (progn
	     (insert (format nil "~@[~A~]" (hatenab_entry-summary entry)))
	     (point))
	   entry
	   *hatena-bookmark-attribute-summary*)
    (insert "\n"))
  )

(defun hatena-bookmark-print ()
  (let* ((line (current-line-number))
	 (entries-orig (hatenab_feed-entries *hatena-bookmark-feed*))
	 (entries (hatena-bookmark-apply-filter entries-orig)))
    (junk::modify-read-only-buffer
	(progn
	  (erase-buffer (selected-buffer))
	  (clear-all-text-attributes)
	  (setq *hatena-bookmark-mode-pos-list* nil)
	  (hatena-bookmark-mode-pos-add (point))
	  (apply #'set-text-attribute
		 (point)
		 (progn
		   (insert (format nil "~@[~A~]" (hatenab_acc-title *hatena-bookmark-account*)))
		   (point))
		 'hatena-bookmark-title
		 *hatena-bookmark-attribute-name*)
	  (insert "\n")
	  (insert *hatena-bookmark-mode-indent-string*)
	  (hatena-bookmark-mode-pos-add (point))
	  (apply #'set-text-attribute
		 (point)
		 (progn
		   (insert (format nil "タ　グ：[~A]" (if *hatena-bookmark-mode-filter*
							  *hatena-bookmark-mode-filter*
							"指定しない")))
		   (point))
		 'hatena-bookmark-filter
		 *hatena-bookmark-attribute-filter*)
	  (insert "\n")
	  (insert *hatena-bookmark-mode-indent-string*)
	  (hatena-bookmark-mode-pos-add (point))
	  (apply #'set-text-attribute
		 (point)
		 (progn
		   (insert (format nil "ソート：[~A]" (cdr (assoc *hatena-bookmark-mode-sort*
								  *hatena-bookmark-mode-sort-list*))))
		   (point))
		 'hatena-bookmark-sort
		 *hatena-bookmark-attribute-sort*)
	  (insert "\n")
	  (insert *hatena-bookmark-mode-indent-string*)
	  (hatena-bookmark-mode-pos-add (point))
	  (apply #'set-text-attribute
		 (point)
		 (progn
		   (insert (format nil "表　示：~{[~A]~}" (hatena-bookmark-mode-column-list)))
		   (point))
		 'hatena-bookmark-column
		 *hatena-bookmark-attribute-column*)
	  (insert "\n")
	  (insert "\n")
	  (dolist (entry entries)
	    (hatena-bookmark-print-entry entry))
	  (when (< line (current-line-number))
	    (goto-line line))
	  ))))

(defun hatena-bookmark-mode-current ()
  (multiple-value-bind (from to tag foreground background bold underline strike-out prefix extend)
      (find-text-attribute-point (point))
    (progn
      tag)))

(defun hatena-bookmark-mode-open-in-browser (url)
  (shell-execute url t))

(defun hatena-bookmark-mode-open ()
  (interactive)
  (let ((tag (hatena-bookmark-mode-current)))
    ;(msgbox "~S" tag)
    (cond ((hatenab_entry-p tag)
	   (hatena-bookmark-mode-open-related tag))
	  ((stringp tag)
	   (hatena-bookmark-mode-filter-set tag))
	  ((eq tag 'hatena-bookmark-sort)
	   (hatena-bookmark-mode-sort-menu))
	  ((eq tag 'hatena-bookmark-filter)
	   (hatena-bookmark-mode-filter-menu))
	  ((eq tag 'hatena-bookmark-column)
	   (hatena-bookmark-mode-column-menu))
	  ((eq tag 'hatena-bookmark-title)
	   (hatena-bookmark-mode-open-site)))))

(defun hatena-bookmark-mode-open-site ()
  (interactive)
  (let ((url (hatenab_acc-alternate *hatena-bookmark-account*)))
    (when url
      (hatena-bookmark-mode-open-in-browser url))))

(defun hatena-bookmark-mode-open-alternate (&optional tag)
  (interactive)
  (let (url)
    (setq tag (or tag (hatena-bookmark-mode-current)))
    (when (and (hatenab_entry-p tag)
	       (setq url (hatenab_entry-alternate tag)))
      (hatena-bookmark-mode-open-in-browser url))))

(defun hatena-bookmark-mode-open-related (&optional tag)
  (interactive)
  (let (url)
    (setq tag (or tag (hatena-bookmark-mode-current)))
    (when (and (hatenab_entry-p tag)
	       (setq url (hatenab_entry-related tag)))
      (hatena-bookmark-mode-open-in-browser url))))

(defun hatena-bookmark-mode-edit ()
  (interactive)
  (let ((tag (hatena-bookmark-mode-current)))
    (when (hatenab_entry-p tag)
      (let ((title (read-string "タイトル: "
				:default (hatenab_entry-title tag)))
	    (summary (read-string "コメント: "
				  :default (format nil "~{[~A]~}~@[~A~]"
						   (hatenab_entry-dc_subjects tag)
						   (hatenab_entry-summary tag))))
	    (editurl (hatenab_entry-service.edit tag)))
	(when (and editurl title summary)
	  (when (hatena-bookmark-edit-entry editurl title summary)
	    (hatena-bookmark-mode-reload)
	    (message "変更完了")))))))

(defun hatena-bookmark-mode-delete ()
  (interactive)
  (let ((tag (hatena-bookmark-mode-current)))
    (when (hatenab_entry-p tag)
      (let ((editurl (hatenab_entry-service.edit tag)))
	(when (and editurl
		   (yes-or-no-p "~@Aを削除しますか？"
				(hatenab_entry-title tag)))
	  (when (hatena-bookmark-delete-entry editurl)
	    (hatena-bookmark-mode-reload)
	    (message "削除完了")))))))

(defun hatena-bookmark-mode-next ()
  (interactive)
  (let* ((pos (point))
	 (next (find-if #'(lambda (x)
			    (< pos x))
			*hatena-bookmark-mode-pos-list*)))
    (when next
      (goto-char next))))

(defun hatena-bookmark-mode-prev ()
  (interactive)
  (let* ((pos (point))
	 (prev (find-if #'(lambda (x)
			    (> pos x))
			(reverse *hatena-bookmark-mode-pos-list*))))
    (when prev
      (goto-char prev))))

(defun hatena-bookmark-mode-reload ()
  (interactive)
  (hatena-bookmark-get-entries t)
  (hatena-bookmark-print))

(defun hatena-bookmark-mode-finish ()
  (interactive)
  (delete-buffer *hatena-bookmark-mode-buffer*))

(defun hatena-bookmark-sort-by-title (a b)
  (string-lessp (hatenab_entry-title a)
		(hatenab_entry-title b)))

(defun hatena-bookmark-sort-by-issued (a b)
  (< (or (hatenab_entry-issued a) 0)
     (or (hatenab_entry-issued b) 0)))

(defun hatena-bookmark-tag-filter (entries tag)
  (let (matched)
    (mapc #'(lambda (x)
	      (when (member tag (hatenab_entry-dc_subjects x) :test #'equal)
		(push x matched)))
	  entries)
    (nreverse matched)))

(defun hatena-bookmark-apply-filter (entries)
  (let ((parsed (copy-seq entries))
	sorted)
    (when *hatena-bookmark-mode-filter*
      (setq parsed (hatena-bookmark-tag-filter parsed *hatena-bookmark-mode-filter*)))
    (if *hatena-bookmark-mode-sort*
	(setq sorted (sort parsed *hatena-bookmark-mode-sort*))
      (setq sorted parsed))
    sorted))

(defun hatena-bookmark-mode-filter-menu ()
  (interactive)
  (let ((menu (create-popup-menu))
	(tags (hatenab_feed-tags *hatena-bookmark-feed*)))
    (add-menu-item menu
		   nil
		   "指定しない"
		   #'(lambda ()
		       (interactive)
		       (hatena-bookmark-mode-filter-set nil))
		   #'(lambda ()
		       (unless *hatena-bookmark-mode-filter*
			 :check)))
    (dolist (tag tags)
      (let ((tagname tag))
	(add-menu-item menu
		       nil
		       tagname
		       #'(lambda ()
			   (interactive)
			   (hatena-bookmark-mode-filter-set tagname))
		       #'(lambda ()
			   (when (equal *hatena-bookmark-mode-filter*
					tagname)
			     :check)))))
    (track-popup-menu menu)))

(defun hatena-bookmark-mode-filter-set (tag)
  (setq *hatena-bookmark-mode-filter* tag)
  (hatena-bookmark-print))

(defun hatena-bookmark-mode-sort-menu ()
  (interactive)
  (let ((menu (create-popup-menu))
	(tags *hatena-bookmark-mode-sort-list*))
    (dolist (tag tags)
      (let ((func (car tag))
	    (name (cdr tag)))
	(add-menu-item menu
		       nil
		       name
		       #'(lambda ()
			   (interactive)
			   (hatena-bookmark-mode-sort-set func))
		       #'(lambda ()
			   (when (equal *hatena-bookmark-mode-sort*
					func)
			     :check)))))
    (track-popup-menu menu)))

(defun hatena-bookmark-mode-sort-set (tag)
  (setq *hatena-bookmark-mode-sort* tag)
  (hatena-bookmark-print))

(defun hatena-bookmark-mode-column-menu ()
  (interactive)
  (let ((menu (create-popup-menu))
	(cols *hatena-bookmark-mode-column-list*))
    (dolist (col cols)
      (let ((column (car col))
	    (name (cadr col))
	    (opt (caddr col)))
	(add-menu-item menu
		       nil
		       name
		       #'(lambda ()
			   (interactive)
			   (hatena-bookmark-mode-column-set column (not opt)))
		       #'(lambda ()
			   (when opt
			     :check)))))
    (track-popup-menu menu)))

(defun hatena-bookmark-mode-column-print (column)
  (caddr (assoc column *hatena-bookmark-mode-column-list*)))

(defun hatena-bookmark-mode-column-set (column opt)
  (setf (caddr (assoc column *hatena-bookmark-mode-column-list*)) opt)
  (hatena-bookmark-print))

(defun hatena-bookmark-mode-column-list ()
  (let (cols)
    (dolist (col *hatena-bookmark-mode-column-list*)
      (let ((column (car col))
	    (name (cadr col))
	    (opt (caddr col)))
	(when opt
	  (push name cols))))
    (nreverse cols)))

;;
;; User Functions
;;

(defun user::hatena-bookmark ()
  (interactive)
  (when (find-buffer *hatena-bookmark-mode-buffer*)
    (set-buffer *hatena-bookmark-mode-buffer*)
    (return-from user::hatena-bookmark))
  (hatena-bookmark-init)
  (hatena-bookmark-mode-buffer-set)
  (hatena-bookmark-mode)
  (hatena-bookmark-print)
  (run-hooks '*hatena-bookmark-hook*))

(defun user::hatena-bookmark-add (url summary)
  (interactive "sURL: \nsコメント: ")
  (hatena-bookmark-init)
  (when (hatena-bookmark-post-entry url summary)
    (message "登録完了")
    (run-hooks '*hatena-bookmark-add-hook*)))

(defun user::hatena-bookmark-config ()
  (interactive)
  (hatena-bookmark-account-create))
