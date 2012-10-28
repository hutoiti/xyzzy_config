;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: group.l 731 2006-09-01 18:09:41Z torihat $
;
; rss/group.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "rss/defs")
  (require "rss/macro"))

(provide "rss/group")

(in-package "rss")

(defvar *rss-group-clipboard* nil)

(defvar *rss-group-map* (make-sparse-keymap))
(define-key *rss-group-map* #\RET 'rss-open-group)
(define-key *rss-group-map* #\SPC 'rss-open-group)
(define-key *rss-group-map* #\Right 'rss-open-group)
(define-key *rss-group-map* #\TAB 'rss-group-search-next-unread)
(define-key *rss-group-map* #\q 'rss-finish)
(define-key *rss-group-map* #\a 'rss-group-add)
(define-key *rss-group-map* #\d 'rss-group-del)
(define-key *rss-group-map* #\i 'rss-import-opml)
(define-key *rss-group-map* #\o 'rss-export-opml)
(define-key *rss-group-map* #\C-k 'rss-group-cut)
(define-key *rss-group-map* #\C-y 'rss-group-paste)
(define-key *rss-group-map* #\R 'rss-group-update-all)
(define-key *rss-group-map* #\M-t 'rss-toggle-online)
(define-key *rss-group-map* #\b 'rss-open-clip)
(define-key *rss-group-map* #\h 'rss-open-history)

(defun rss-group-mode ()
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
  (set-buffer-fold-width nil)
  (make-local-variable 'mode-line-format)
  (make-local-variable 'title-bar-format)
  (menu-mode-line)
  (use-keymap *rss-group-map*)
  )

(defun rss-set-buffer-group ()
  (set-buffer (get-buffer-create *rss-buffer-group*)))

(defun group-mode-line ()
  (setq mode-line-format (format nil "%b"))
  (setq title-bar-format (format nil "~A" *prog-name*)))

(defun group-mode-line-update ()
  (when (find-buffer *rss-buffer-group*)
    (save-excursion
      (rss-set-buffer-group)
      (rss-group-mode))))

(defun rss-group-menu-file (group)
  (let ((gname (rss-group-name group)))
    (merge-pathnames
     (format nil "rss-menu~@[-~A~].dat"
	     (if gname
		 (substitute-string (si:base64-encode gname)
				    "[\r\n]"
				    "")))
     *rss-directory*)))

(defun rss-group-load ()
  (let (data)
    (when (file-exist-p *rss-group-file*)
      (with-open-file (s
		       *rss-group-file*
		       :direction :input
		       :if-does-not-exist :error)
	(let (tmp)
	  (while (setq tmp (read s nil))
	    (pushnew tmp data :test #'equal)))))
    (unless data
      (setq data *rss-group-list-default*))
    (setq *rss-group-list* (nreverse data))))

(defun rss-group-save ()
  (with-open-file (s
		   *rss-group-file*
		   :direction :output
		   :if-exists :overwrite
		   :if-does-not-exist :create)
    (mapc #'(lambda (x)
	      (when x
		(format s "~S~%" x)))
	  *rss-group-list*))
  t)

(defun rss-group-add (gname)
  (interactive "sGroup: ")
  (let* ((num (current-line-number))
	 (pos (rss-group-line-to-number num)))
    (when (assoc gname *rss-group-list* :test #'equal)
      (error "~Aはすでにあります" gname))
    (rss-group-insert (list gname) pos)
    (rss-group-save)
    (rss-group-print)))

(defun rss-group-del ()
  (interactive)
  (let* ((num (current-line-number))
	 (pos (rss-group-line-to-number num))
	 (group (rss-group-current)))
    (when group
      (when (<= (length *rss-group-list*) 1)
	(error "最後のグループは削除できません。"))
      (save-excursion
	(rss-group-delete pos)
	(rss-delete-group-file group)
	(rss-group-save)
	(rss-group-print))
      (goto-line num))))

(defun rss-delete-group-file (group)
  (let ((file (rss-group-menu-file group)))
    (when (and (file-exist-p file)
	       (yes-or-no-p "グループファイルを削除しますか？"))
      (delete-file file))))

(defun rss-group-current ()
  (let* ((num (current-line-number))
	 (pos (rss-group-line-to-number num)))
    (when (<= 0 pos)
      (nth pos *rss-group-list*))))

(defun rss-group-insert (group &optional pos)
  (let ((len (length *rss-group-list*))
	temp)
    (setq pos (if pos
		  (min pos len)
		len))
    (dotimes (i len)
      (when (= i pos)
	(push group temp))
      (push (nth i *rss-group-list*) temp))
    (when (= pos len)
      (push group temp))
    (setq *rss-group-list* (nreverse temp))))

(defun rss-group-delete (pos)
  (let (temp)
    (dotimes (i (length *rss-group-list*))
      (unless (= i pos)
	(push (nth i *rss-group-list*) temp)))
    (setq *rss-group-list* (nreverse temp))))

(defun rss-group-print ()
  (let ((buffer-read-only nil))
    (declare (special buffer-read-only))
    (erase-buffer (selected-buffer))
    (apply #'set-text-attribute
	   (point)
	   (progn
	     (insert (format nil "~A\n" *rss-group-title*))
	     (point))
	   'rss-group-title
	   *rss-attribute-group-title*)
    (dolist (group *rss-group-list*)
      (let ((name (rss-group-name group))
	    (number-all (rss-group-number-all group))
	    (number-unread (rss-group-number-unread group)))
	(insert " ")
	(apply #'set-text-attribute
	       (point)
	       (progn
		 (insert (format nil "~A~%"
				 (or (rss-group-name group) *rss-group-default-name*)))
		 (point))
	       'rss-group
	       (if (and number-unread
			(< 0 number-unread))
		   *rss-attribute-group-unread*
		 *rss-attribute-group*))))
    (goto-line (rss-group-number-to-line 0))
    ))

(defun rss-group-line-to-number (num)
  (- num 2))

(defun rss-group-number-to-line (pos)
  (+ pos 2))

(defun rss-group-open ()
  (interactive)
  (when (find-buffer *rss-buffer-group*)
    (rss-set-buffer-group)
    (let ((pos (point)))
      (rss-group-print)
      (goto-char pos))
    (return-from rss-group-open))
  (rss-group-load)
  (rss-set-buffer-group)
  (rss-group-mode)
  (rss-group-print)
  )

(defun rss-open-group ()
  (interactive)
  (let ((group (rss-group-current)))
    (when group
      (rss-group-open-1 group))))

(defun rss-group-open-1 (group)
  (setq *rss-group-current* group)
  (setq *rss-menu-file* (rss-group-menu-file *rss-group-current*))
  (setq *rss-menu-data* nil)
  (rss-menu-open)
  )

(defun rss-open-group-next ()
  (interactive)
  (let ((len (length *rss-group-list*))
	(curnum (rss-group-current-number))
	next)
    (when (<= len 1)
      (return-from rss-open-group-next))
    (when curnum
      (rss-group-open-1
       (nth (mod (1+ curnum) len) *rss-group-list*))
      )))

(defun rss-open-group-prev ()
  (interactive)
  (let ((len (length *rss-group-list*))
	(curnum (rss-group-current-number))
	next)
    (when (<= len 1)
      (return-from rss-open-group-prev))
    (when curnum
      (rss-group-open-1
       (nth (if (= curnum 0)
		(1- len)
	      (1- curnum)) *rss-group-list*))
      )))

(defun rss-group-current-number ()
  (dotimes (i (length *rss-group-list*))
    (when (equal (rss-group-name *rss-group-current*)
		 (rss-group-name (nth i *rss-group-list*)))
      (return-from rss-group-current-number i)))
  nil)

(defun rss-group-clipboard-push (group)
  (push group *rss-group-clipboard*))

(defun rss-group-clipboard-pop ()
  (pop *rss-group-clipboard*))

(defun rss-group-cut ()
  (interactive)
  (let* ((num (current-line-number))
	 (pos (rss-group-line-to-number num))
	 (group (rss-group-current)))
    (when group
      (when (<= (length *rss-group-list*) 1)
	(error "最後のグループは切り取りできません。"))
      (save-excursion
	(rss-group-delete pos)
	(rss-group-clipboard-push group)
	(rss-group-save)
	(rss-group-print))
      (goto-line num))))

(defun rss-group-paste ()
  (interactive)
  (let* ((num (current-line-number))
	 (pos (rss-group-line-to-number num))
	 (group (rss-group-clipboard-pop)))
    (when group
      (rss-group-insert group pos)
      (rss-group-save)
      (rss-group-print)
      (goto-line num))))

(defun rss-group-update-all ()
  (interactive)
  (let ((pos (point))
	errors)
    (save-excursion
      (dolist (group *rss-group-list*)
	(rss-group-open-1 group)
	(handler-case
	    (rss-menu-update-all)
	  (error (c)
	    (push (si:*condition-string c) errors)))))
    (rss-group-print)
    (goto-char pos)
    (when errors
      (error "Error: ~%~{~A~}" (nreverse errors)))))

(defun rss-group-search-next-unread ()
  (interactive)
  (let* ((num (current-line-number))
	 (pos (min (rss-group-line-to-number num)))
	 (len (length *rss-group-list*)))
    (dotimes (i len)
      (let* ((jpos (mod (+ i pos) len))
	     (jnum (rss-group-number-to-line jpos))
	     (group (nth jpos *rss-group-list*))
	     (item-number-unread (rss-group-number-unread group)))
	(when (and item-number-unread
		   (< 0 item-number-unread))
	  (goto-line jnum)
	  (rss-open-group)
	  (and (rss-menu-search-next-unread)
	       (return-from rss-group-search-next-unread t)))))
    (goto-line num)
    nil))

(defun rss-group-current-update ()
  (let ((number-all 0)
	(number-unread 0))
    (dolist (menu *rss-menu-data*)
      (let ((all (rss-item-number-all menu))
	    (unread (rss-item-number-unread menu)))
	(incf number-all (if all all 0))
	(incf number-unread (if unread unread 0))))
    (setf (cdr (assoc (rss-group-name *rss-group-current*)
		      *rss-group-list*
		      :test #'equal))
	  (list number-all number-unread))
    (rss-group-save)))

(defun rss-export-opml ()
  (interactive)
  (let ((opml-file (file-name-dialog :title "出力先ファイル"
				     :filter '(("OPML File(*.xml)" . "*.xml")
					       ("すべてのファイル(*.*)" . "*.*"))))
	(group-list (rss-group-load))
	(feed-list))
    (unless opml-file
      (return-from rss-export-opml))
    (dolist (group group-list)
      (let ((*rss-menu-file* (rss-group-menu-file group)))
	(declare (special *rss-menu-file*))
	(push (cons (or (rss-group-name group) *rss-group-default-name*)
		    (rss-menu-load))
	      feed-list)))
    (with-open-file (os opml-file
			:direction :output
			:if-exists :overwrite
			:if-does-not-exist :create)
      (princ
       (convert-encoding-from-internal
	*encoding-utf8n*
	(with-output-to-string (s)
	  (format s "<?xml version=\"1.0\" encoding=\"utf-8\"?>~%")
	  (format s "<opml version=\"1.0\">~%")
	  (format s "<head>~%")
	  (format s "<title>rss-mode</title>~%")
	  (format s "<dateCreated></dateCreated>~%")
	  (format s "<ownerName></ownerName>~%")
	  (format s "</head>~%")
	  (format s "<body>~%")
	  (dolist (group (reverse feed-list))
	    (let ((group-name (car group))
		  (menu-list (cdr group)))
	      (format s "<outline title=\"~A\">~%" (ed::xmlpm-encode-special-chars group-name))
	      (dolist (menu menu-list)
		(let ((url (rss-link menu)))
		  (unless (filter-func url)
		    ; filterをかけるものは除外
		    (format s "<outline title=\"~A\" type=\"rss\" xmlUrl=\"~A\" />~%"
			    (ed::xmlpm-encode-special-chars (rss-title menu))
			    url))))
	      (format s "</outline>~%")))
	  (format s "</body>~%")
	  (format s "</opml>~%"))
	os)))
    (message "~Aに出力しました。" opml-file)
    ))

(defvar *rss-import-opml-tmp* nil)

(defun rss-import-opml ()
  (interactive)
  (let ((opml-file (file-name-dialog :title "インポート元ファイル"
				     :must-exist t
				     :filter '(("OPML File(*.xml)" . "*.xml")
					       ("すべてのファイル(*.*)" . "*.*"))))
	(group-list (rss-group-load))
	opml
	gname
	(buf "*OPML TMP*"))
    (unless opml-file
      (return-from rss-import-opml))
    (setq *rss-import-opml-tmp* nil)
    (save-excursion
      (set-buffer (get-buffer-create buf))
      (erase-buffer (selected-buffer))
      (let ((*expected-fileio-encoding* *encoding-sjis*))
	(declare (special *expected-fileio-encoding*))
	(insert-file-contents opml-file))
      (unwind-protect
	  (setq opml (car (ed::xmlpm-parse)))
	(delete-buffer buf))
      (unless (equal (ed::xmlpm-tag-name opml) "opml")
	(error "Not OPML?: ~S" (ed::xmlpm-tag-name opml)))
      (dolist (tag (ed::xmlpm-tag-contents opml))
	(when (equal (ed::xmlpm-tag-name tag) "body")
	  (dolist (o (ed::xmlpm-tag-contents tag))
	    (when (equal (ed::xmlpm-tag-name o) "outline")
	      (rss-import-opml-parse-outline o nil))))))
    (rss-set-buffer-group)
    (rss-group-print)
    (when *rss-import-opml-tmp*
      (let ((urls (format nil "~{~A~%~}" (reverse *rss-import-opml-tmp*))))
	(copy-to-clipboard urls)
	(msgbox "以下のURLはインポートされませんでした。~%クリップボードにコピーされています。~%~%~A"
		urls)))
    (message "読み込み完了: ~A" opml-file)
    ))

(defun rss-import-opml-parse-outline (outline group-name)
  (let ((opts (ed::xmlpm-tag-opts outline)))
    (if (ed::xmlpm-tag-single-p outline)
	(let ((url (cdr (assoc "xmlUrl" opts :test #'equal))))
	  (when url
	    (unless (equal group-name (rss-group-name *rss-group-current*))
	      (unless (assoc group-name *rss-group-list* :test #'equal)
		(rss-group-open)
		(goto-char (point-max))
		(rss-group-add group-name)))
	    (rss-group-open-1 (list group-name))
	    (unless (rss-menu-exist url)
	      (goto-char (point-max))
	      (refresh-screen)
	      (handler-case
		  (rss-menu-add url)
		(error (c)
		  (msgbox "~S" (si:*condition-string c))
		  (when url
		    (push url *rss-import-opml-tmp*)))))))
      (let ((title (cdr (assoc "title" opts :test #'equal))))
	(dolist (o (ed::xmlpm-tag-contents outline))
	  (rss-import-opml-parse-outline o title))))))
