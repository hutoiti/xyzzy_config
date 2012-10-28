;;; -*- Mode: Lisp; Package: ChangeLogMemo -*-
;;;
;;; changelogmemo/misc.l
;;;
;;; Last updated: "2006-02-23"
;;;

(provide "changelogmemo/misc")

(in-package "changelogmemo")

;;; 変数をファイルに出力
(defun write-and-variable ()
  (write-variable *and-filename* *and-history-list*))

(defun write-or-variable ()
  (write-variable *or-filename* *or-history-list*))

(defun write-regexp-variable ()
  (write-variable *regexp-filename* *regexp-history-list*))

(defun write-category-variable ()
  (write-variable *category-filename* *category-history-list*))

(defun write-year-variable ()
  (write-variable *year-filename* *year-history-list*))

(defun write-month-variable ()
  (write-variable *month-filename* *month-history-list*))

(defun write-day-variable ()
  (write-variable *day-filename* *day-history-list*))

(defun write-variable (fname his)
  (let* ((dir *cl-history-directory*)
	 (file (merge-pathnames fname dir)))
    (unless (file-directory-p dir)
      (when (yes-or-no-p "~A を作成しますか?" dir)
	(create-directory dir)))
    (with-open-file (s file :direction :output)
      (format s "~S" his))))

;;; buffer を作成
(defun create-new-buffer-temp ()
  (let (buf)
    (set-buffer (setq buf (create-new-buffer *buffer-temp*)))
    buf))

(defun get-buffer-create-search ()
  (let (buf)
    (set-buffer (setq buf (get-buffer-create *buffer-search*)))
    buf))

(defun get-buffer-create-save ()
  (let ((buf (find-buffer *buffer-save*)))
    (if buf
	(set-buffer buf)
      (let ((file *cl-file*))
	(unless (file-exist-p file)
	  (error "~A~%指定されたファイルが見つかりません。" file))
	(setq buf (create-new-buffer *buffer-save*))
	(set-buffer buf)
	(setq auto-save nil)
	(setq need-not-save t)
	(and *kept-old-versions*
	     (ed::set-buffer-local 'kept-old-versions *kept-old-versions*))
	(and *kept-new-versions*
	     (ed::set-buffer-local 'kept-new-versions *kept-new-versions*))
	(ed::find-file-auto-encoding file)
	(insert-file-contents file)))
    buf))

;;; Entry 関係

;;; yyyy-mm-dd の曜日を得る
(defun get-weekday (date)
  (ignore-errors
   (let ((y (parse-integer (substring date 0 4)))
	 (m (parse-integer (substring date 5 7)))
	 (d (parse-integer (substring date 8 10))))
     (format-date-string "%a" (encode-universal-time 0 0 0 d m y)))))

;;; 現在位置の日付を取り出す
(defun get-date-string (&optional downward)
  (let ((regexp *date-regexp*))
    (save-excursion
      (and (scan-buffer regexp
			:reverse (not downward) :no-dup downward)
	   (match-string 1)))))

;;; 日付から entry-header を作る
(defun make-entry-header (date)
  (let ((weekday (get-weekday date)))
    (format nil "~A (~A)  ~A" date weekday *cl-user*)))

;;; 現在位置の entry の開始地点、終了地点
(defun get-entry ()
  (let ((regexp *date-regexp*) beg end)
    (save-excursion
      (and (scan-buffer regexp :reverse t)
	   (setq beg (point)))
      (when beg
	(if (scan-buffer regexp :no-dup t)
	    (setq end (point))
	  (setq end (point-max)))))
    (values beg end)))

;;; 現在位置の entry を取得
(defun get-entry-string ()
  (multiple-value-bind (beg end)
      (get-entry)
    (and beg end (buffer-substring beg end))))

;;; entry-header-line かどうかを判定
(defun entry-header-line-p ()
  (regexp-line-p *date-regexp*))

(defun regexp-line-p (regexp)
  (save-excursion
    (goto-bol)
    (looking-at regexp)))

;;; yyyy-mm <=> yyyymm
(defun yyyymm (date)
  (ignore-errors (concat (substring date 0 4)
			 (substring date 5 7))))

(defun yyyy-mm (yyyymmdd)
  (ignore-errors (format nil "~A-~A"
			 (substring yyyymmdd 0 4)
			 (substring yyyymmdd 4 6))))

;;; yyyy-mm-dd <=> yyyymmdd
(defun yyyymmdd (date)
  (ignore-errors  (concat (substring date 0 4)
			  (substring date 5 7)
			  (substring date 8 10))))

(defun yyyy-mm-dd (yyyymmdd)
  (ignore-errors (format nil "~A-~A-~A"
			 (substring yyyymmdd 0 4)
			 (substring yyyymmdd 4 6)
			 (substring yyyymmdd 6 8))))

;;; 日付から正規表現を作る
(defun date-regexp (date)
  (compile-regexp (format nil "^~A ([A-Z][a-z][a-z])  ~A"
			  date *cl-user*)))

(defun month-regexp (date)
  (compile-regexp (format nil "^~A-[0-9][0-9] ([A-Z][a-z][a-z])  ~A"
			  (substring date 0 7) *cl-user*)))

(defun year-regexp (date)
  (compile-regexp (format nil "^~A-[0-9][0-9]-[0-9][0-9] ([A-Z][a-z][a-z])  ~A"
			  (substring date 0 4) *cl-user*)))

;;; カテゴリから正規表現を作る
(defun category-regexp (category)
  (compile-regexp
   (if (string= category *unclassified-category-name*)
       "^\\* [^][\n]+:\\($\\|[ 　]\\)"
     (format
      nil
      "^\\* .*\\[\\(~A\\)\\]\\(:\\| \\[[^][\n]+\\]:\\| \\[[^][\n]+\\] \\[\\)"
      category))))

;;; entry から (title . item) のリストを作る
(defun make-title-alist-from-entry (entry)
  (unless (string-match *item-regexp* entry)
    (return-from make-title-alist-from-entry nil))
  (let ((b (match-beginning 0)) list)
    (loop ()
      (if (string-match *item-regexp* entry (1+ b))
	  (let ((p (match-beginning 0)) it)
	    (setq it (substring entry b p))
	    (push (cons (get-title-from-item it) it) list)
	    (setq b p))
	(let (it)
	  (setq it (substring entry b))
	  (push (cons (get-title-from-item it) it) list)
	  (return))))
    (nreverse list))
  )

;;; Item 関係

;;; 現在行が item-header-line かどうかを判定
(defun item-header-line-p (&optional tab)
  (if tab
      (regexp-line-p *item-regexp-with-tab*)
    (regexp-line-p *item-regexp*)))

;;; 現在位置の item の開始地点、終了地点
(defun get-item (&optional tab)
  (let* ((reg (if tab
		  "^\t\\(\\* .*:\\)"
		"^\\(\\* .*:\\)"))
	 (regexp (compile-regexp (format nil "~A\\|~A"
					 reg
					 "^\\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\\) ([A-Z][a-z][a-z])")))
	 beg end)
    (save-excursion
      (scan-buffer regexp :reverse t)
      (and (item-header-line-p tab) (setq beg (point)))
      (when beg
	(if (scan-buffer regexp :no-dup t)
	    (setq end (point))
	  (setq end (point-max)))))
    (values beg end)))

;;; その他

;;; title から正規表現を作る
(defun title-regexp (title)
  (compile-regexp (format nil "^\\* \\(p:\\|\\)~A.*:" title)))

;;; item から title を取り出す
(defun get-title-from-item (item)
  (string-match *title-regexp* item)
  (let ((s (match-string 2)))
    (if s (string-trim '(#\SPC) s) nil)))

;;; 現在位置が正規表現にマッチしていたら、マッチした string を返す
(defun regexp-match-values (regexp case-fold bn en)
  (save-excursion
    (let ((pt (point)) (limit (progn (goto-eol) (point))) beg end)
      (or bn (setq bn 0))
      (or en (setq en 0))
      (goto-bol)
      (let (b e (no-dup nil))
	(while (scan-buffer regexp :regexp t
			    :case-fold case-fold :no-dup no-dup
			    :limit limit)
	  (setq b (if (<= 0 bn)
		      (match-beginning bn)
		    (match-end (- bn))))
	  (setq e (if (<= 0 en)
		      (match-end en)
		    (match-beginning (- en))))
	  (setq no-dup t)
	  (and (<= b pt) (<= pt (1- e))
	       (setq beg b end e)
	       (return))))
      (values beg end))))

(defun regexp-match-string (regexp case-fold bn en)
  (multiple-value-bind (beg end)
      (regexp-match-values regexp case-fold bn en)
    (and beg end (buffer-substring beg end))))

;;; タブつき string にする
(defun get-string-with-tab (string)
  (let* ((list (mapcar #'(lambda (x) (if (string/= x "")
					 (concat "\t" x)
				       x))
		       (split-string string "\n" t)))
	 (str (format nil "~{~A~^\n~}" list)))
    (if (string-match ".*\n$" string) (concat str "\n") str)))

;;; タブなし string にする
(defun get-string-with-notab (string)
  (let* ((list (mapcar #'(lambda (x) (if (string-match "^\t" x)
					 (substring x 1)
				       x))
		       (split-string string "\n" t)))
	 (str (format nil "~{~A~^\n~}" list)))
    (if (string-match ".*\n$" string) (concat str "\n") str)))
