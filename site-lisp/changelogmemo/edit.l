;;; -*- Mode: Lisp; Package: ChangeLogMemo -*-
;;;
;;; changelogmemo/edit.l
;;;
;;; Last updated: "2006-02-23"
;;;

(provide "changelogmemo/edit")

(in-package "changelogmemo")

;;; search-insert-item
(defun search-insert-item ()
  (interactive)
  (insert-item t))

;;; search-buffer-modified-hook

(defvar *cl-show-match-p* nil)

;ダイアログから置換を行う時に、query の判定が分からなかったので苦し紛れに
;ed::show-match を書きかえた。
(in-package "editor")
(defun show-match ()
  (cond (*reverse-match*
	 (reverse-region (match-beginning 0) (match-end 0) t))
	(*select-match*
	 (goto-char (match-end 0))
	 (start-selection 2 t)
	 (goto-char (match-beginning 0))))
  (setq cl::*cl-show-match-p* t))
(in-package "changelogmemo")

(defvar *search-buffer-modified-count* 0)
(defvar *search-buffer-modified-point* 0)
(defvar *search-buffer-modified-number* nil)

(defun search-buffer-modified-hook (buffer operation from to undo-p)
  (when (find buffer-mode `(,'search-mode ,'esearch-mode))
    (handler-case
	(ed::protect-match-data
	  (let ((beg (min from to)) (end (max from to))
		(list modified-date-list)
		(tab (and (eq buffer-mode 'search-mode) t)))
	    (cond ((and (null *cl-show-match-p*)
			(< 50 *search-buffer-modified-count*))
		   ;一括置換する場合、一括置換した後 undo, redo する場合とか
		   ;この後 *post-command-hook* で処理する
		   (if (<= *search-buffer-modified-point* beg)
		       (setq *search-buffer-modified-number* beg)
		     (setq *search-buffer-modified-number* (- beg (point-max))))
		   (enable-post-buffer-modified-hook nil)
		   (make-local-variable '*post-command-hook*)
		   (add-hook '*post-command-hook* 'search-post-command-hook))
		  ((let ((u-date (save-excursion
				   (goto-char beg)
				   (get-date-string)))
			 (d-date (save-excursion
				   (goto-char beg)
				   (get-date-string t))))
		     (and u-date
			  (let ((p (position u-date list :test #'string=)))
			    (and p (string= (nth (1+ p) list) d-date)))
			  (search-buffer-modified-hook-modify-1 u-date tab))))
		  ((eq operation :delete)
		   (search-buffer-modified-hook-delete beg end list tab))
		  ((find operation '(:insert :modify))
		   (search-buffer-modified-hook-modify beg end list tab)))
	    (setq *search-buffer-modified-point* beg)
	    (incf *search-buffer-modified-count*)))
      (error (c)
	(delete-buffer (selected-buffer))
	(error c)))
    ))

(defun search-buffer-modified-hook-modify-1 (date tab)
  (let ((str1 (if tab
		  (get-string-with-notab (get-entry-string))
		(get-entry-string)))
	(str2 (gethash date save-hash-table)))
    (if str2
	(if (string/= str1 str2)
	    (setf (gethash date modified-date-hash-table) str1)
	  (remhash date modified-date-hash-table))
      (setf (gethash date inserted-date-hash-table) str1))
    t))

(defun search-buffer-modified-hook-delete (beg end list tab)
  (let (u-date d-date lt p1 p2)
    (save-excursion
      (goto-char beg)
      (setq u-date (get-date-string))
      (goto-char end)
      (setq d-date (get-date-string t))
      (and u-date (search-buffer-modified-hook-modify-1 u-date tab))
      (if (entry-header-line-p)
	  ;日付行で insert して undo した時対策
	  (progn
	    (goto-bol)
	    (setq lt (list u-date))
	    (if (scan-buffer *date-regexp* :reverse t :no-dup t)
		(progn
		  (setq p1 (position (match-string 1) list :test #'string=))
		  (search-buffer-modified-hook-modify-1 (match-string 1) tab))
	      (setq p1 -1)))
	(if u-date
	    (setq p1 (position u-date list :test #'string=))
	  (setq p1 -1))))
    (if d-date
	(setq p2 (position d-date list :test #'string=))
      (setq p2 (list-length list)))
    (setq modified-date-list (nconc (subseq list 0 (1+ p1))
				    lt (subseq list p2)))
    (dolist (d (subseq list (1+ p1) p2))
      (and (gethash d save-hash-table)
	   (setf (gethash d modified-date-hash-table) ""))
      (remhash d inserted-date-hash-table))
    t))

(defun search-buffer-modified-hook-modify (beg end list tab)
  (let (u-date b e p1 p2 lt f)
    (save-excursion
      (goto-char beg)
      (setq u-date (get-date-string))
      ;日付行で del して undo した時対策
      (when (entry-header-line-p)
	(goto-bol)
	(setq f (bobp)))
      (if (scan-buffer *date-regexp* :reverse t :no-dup t)
	  (progn
	    (setq b (point))
	    (setq p1 (position (match-string 1) list :test #'string=)))
	(progn
	  (goto-char (point-min))
	  (setq b (point))
	  (setq p1 -1)))
      (goto-char end)
      (if (scan-buffer *date-regexp*)
	  (progn
	    (setq e (point))
	    (setq p2 (position (match-string 1) list :test #'string=)))
	(progn
	  (goto-char (point-max))
	  (setq e (point))
	  (setq p2 (list-length list))))
      (dolist (d (subseq list (1+ p1) p2))
	(and (gethash d save-hash-table)
	     (setf (gethash d modified-date-hash-table) ""))
	(remhash d inserted-date-hash-table))
      (save-restriction
	(narrow-to-region b e)
	(goto-char (point-min))
	(let ((no-dup (not f)))
	  (while (scan-buffer *date-regexp* :no-dup no-dup)
	    (let* ((d (match-string 1))
		   (e1 (if tab
			   (get-string-with-notab (get-entry-string))
			 (get-entry-string)))
		   (e2 (gethash d save-hash-table)))
	      (if e2
		  (if (string/= e1 e2)
		      (setf (gethash d modified-date-hash-table) e1)
		    (remhash d modified-date-hash-table))
		(setf (gethash d inserted-date-hash-table) e1))
	      (push d lt))
	    (setq no-dup t))))
      (goto-char b)
      (let ((d (get-date-string)))
	(and d (search-buffer-modified-hook-modify-1 d tab))))
    (setq modified-date-list (nconc (subseq list 0 (1+ p1))
				    (nreverse lt)
				    (subseq list p2)))
    t))

(add-hook 'post-buffer-modified-hook 'search-buffer-modified-hook)

(defun search-post-command-hook ()
  (setq *cl-show-match-p* nil)
  (when *search-buffer-modified-number*
    (undo-boundary)
    (unwind-protect
	(save-window-excursion
	  (set-buffer *buffer-search*);gresreg で一括置換の場合も考えて
	  (handler-case
	      (let* ((num *search-buffer-modified-number*)
		     (p1 (if (minusp num)
			     (save-excursion
			       (goto-char (point-max))
			       (forward-char num)
			       (point))
			   num))
		     (p2 (last-modified-point)))
		(search-buffer-modified-hook-modify
		 (min p1 p2) (max p1 p2)
		 modified-date-list
		 (eq buffer-mode 'search-mode)))
	    (error (c)
	      (delete-buffer (selected-buffer))
	      (error c))))
      (setq *search-buffer-modified-count* 0)
      (setq *search-buffer-modified-point* 0)
      (setq *search-buffer-modified-number* nil))
    (enable-post-buffer-modified-hook t)))

;;; search-save
(defun search-save (&optional notab)
  (interactive)
  (when (plusp (hash-table-count inserted-date-hash-table))
    (error "エントリの追加はできません"))
  (when (< *edided-entry-limit*
	   (hash-table-count modified-date-hash-table))
    (error "編集されたエントリの数が多すぎます。"))
  (when (< search-save-time (file-write-time *cl-file*))
    (if (yes-or-no-p "CLファイルが変更されているため、保存できません。~%画面を更新しますか?")
	(if notab
	    (research-current t)
	  (research-current))
      (return-from search-save nil)))
  (when (= (hash-table-count modified-date-hash-table) 0)
    (if (buffer-modified-p)
	(progn
	  (set-buffer-modified-p nil)
	  (message "保存"))
      (message "保存する必要はありません"))
    (return-from search-save t))
  ;search-hash-table の更新
  (let ((shash search-hash-table)
	(mhash modified-date-hash-table)
	(keys (car current-search-keys-list)))
    (maphash #'(lambda (d s) (if (string-match-keys-p s keys)
				 (setf (gethash d shash) s)
			       (remhash d shash)))
	     mhash)
    (setq search-hash-table shash))
  ;保存
  (let ((shash save-hash-table)
	(mhash modified-date-hash-table))
    (save-window-excursion
      (if *memo-show-p*
	  (set-buffer *buffer-memo*)
	(get-buffer-create-save))
      (let ((mfd (buffer-modified-p)))
	(save-excursion
	  (maphash #'(lambda (d m)
		       (goto-char (point-min))
		       ;save した後、undo すると日付が見つからないこと
		       ;もあり得る
		       (or (scan-buffer (date-regexp d))
			   (insert-entry-2 d))
		       (let ((al (make-title-alist-from-entry
				  (gethash d shash))) s)
			 (multiple-value-bind (b e)
			     (get-entry)
			   (setq s (buffer-substring b e))
			   (delete-region b e)
			   (insert (make-new-entry m s al))))
		       (setf (gethash d shash) m))
		   mhash))
	(if *memo-show-p*
	    (progn
	      (save-buffer)
	      (set-buffer-modified-p mfd))
	  (progn
	    (set-buffer-file-name *cl-file*)
	    (save-buffer)
	    (set-buffer-file-name nil)))))
    (setq save-hash-table shash)
    (setq modified-date-hash-table (make-hash-table :test #'equal))
    (setq search-save-time (file-write-time *cl-file*))
    (set-buffer-modified-p nil))
  (message "保存"))

(defun insert-entry-2 (date)
  (or (scan-buffer (month-regexp date))
      (scan-buffer (year-regexp date)))
  (let ((no-dup nil))
    (unless (while (scan-buffer *date-regexp* :no-dup no-dup)
	      (and (string<= (match-string 1) date) (return t))
	      (setq no-dup t))
      (goto-char (point-max))
      (or (looking-back "\n\n") (insert "\n")))
    (with-output-to-selected-buffer
      (format t "~A~%~%" (make-entry-header date)))
    (forward-char -1)))

(defun make-new-entry (string old-string title-alist)
  (if (string-match *item-regexp* string)
      (make-new-entry-modify string old-string title-alist)
    (make-new-entry-delete string old-string title-alist)))

(defun make-new-entry-modify (string old-string title-alist)
  (let ((str old-string) (b (string-match *item-regexp* string))
	(p1 0) (p2 0) (p3 0) otl oit (f nil))
    (dolist (x title-alist)
      (let* ((tl (car x)) (it (cdr x)) (reg (title-regexp tl)))
	(if (string-match reg string (1+ p1))
	    (progn
	      (setq p1 (match-beginning 0))
	      (when (and f (string-match (regexp-quote oit) str (1+ p2)))
		(setq p2 (match-beginning 0))
		(setq str (concat (substring str 0 p2)
				  (substring string b p1)
				  (substring str (match-end 0))))
		(setq b p1))
	      (setq otl tl oit it)
	      (setq f t))
	  (when (string-match (regexp-quote it) str p3)
	    (setq p3 (match-beginning 0))
	    (setq str (concat (substring str 0 p3)
			      (substring str (match-end 0)))))
	  )))
    (if oit
	(when (string-match (regexp-quote oit) str (1+ p2))
	  (concat (substring str 0 (match-beginning 0))
		  (substring string b)
		  (substring str (match-end 0))))
      (if (string-match *item-regexp* str)
	  (let ((p (match-beginning 0)))
	    (concat (substring str 0 p)
		    (substring string b)
		    (substring str p)))
	(concat str (substring string b))))))

(defun make-new-entry-delete (string old-string title-alist)
  (let ((str old-string) (p 0))
    (dolist (x title-alist str)
      (when (string-match (regexp-quote (cdr x)) str p)
	(setq p (match-beginning 0))
	(setq str (concat (substring str 0 p)
			  (substring str (match-end 0))))))
    (if (and (string= string "")
	     (null (string-match *item-regexp* str)))
	""
      str)))
