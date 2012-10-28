;;; -*- Mode: Lisp; Package: ChangeLogMemo -*-
;;;
;;; changelogmemo/search.l
;;;
;;; Last updated: "2006-02-21"
;;;

(provide "changelogmemo/search")

(in-package "changelogmemo")

;;; search-mode

(defvar *search-mode-hook* nil)

(defvar *search-mode-map* nil)

(unless *search-mode-map*
  (setq *search-mode-map* (make-sparse-keymap))
  (define-key *search-mode-map* #\M-/ 'research-and)
  (define-key *search-mode-map* #\M-o 'research-or)
  (define-key *search-mode-map* #\M-g 'research-regexp)
  (define-key *search-mode-map* #\M-c 'research-category)
  (define-key *search-mode-map* #\M-y 'research-year)
  (define-key *search-mode-map* #\M-m 'research-month)
  (define-key *search-mode-map* #\M-d 'research-day)
  (define-key *search-mode-map* #\M-Right 'research-next)
  (define-key *search-mode-map* #\M-Left 'research-previous)
  (define-key *search-mode-map* #\M-r 'research-current)
  (define-key *search-mode-map* #\M-f 'search-date-forward)
  (define-key *search-mode-map* #\M-b 'search-date-backward)
  (define-key *search-mode-map* #\M-Down 'search-next-entry)
  (define-key *search-mode-map* #\M-Up 'search-previous-entry)
  (define-key *search-mode-map* #\M-n 'search-next-link)
  (define-key *search-mode-map* #\M-p 'search-previous-link)
  (define-key *search-mode-map* #\TAB 'search-rotate-category)
  (define-key *search-mode-map* #\RET 'search-newline)
  (define-key *search-mode-map* #\M-RET 'search-newline-new)
  (define-key *search-mode-map* #\C-\. 'complete-category)
  (define-key *search-mode-map* #\C-j 'search-insert-item)
  (define-key *search-mode-map* '(#\C-x #\C-s) 'search-save))

;; textmode.l の *text-mode-syntax-table* より借用
(defvar *search-mode-syntax-table* nil)
(unless *search-mode-syntax-table*
  (setq *search-mode-syntax-table* (make-syntax-table))
  (set-syntax-symbol *search-mode-syntax-table* #\&)
  (set-syntax-symbol *search-mode-syntax-table* #\*)
  (set-syntax-symbol *search-mode-syntax-table* #\+)
  (set-syntax-symbol *search-mode-syntax-table* #\-)
  (set-syntax-symbol *search-mode-syntax-table* #\/)
  (set-syntax-symbol *search-mode-syntax-table* #\<)
  (set-syntax-symbol *search-mode-syntax-table* #\=)
  (set-syntax-symbol *search-mode-syntax-table* #\>)
  (set-syntax-symbol *search-mode-syntax-table* #\_)
  (set-syntax-symbol *search-mode-syntax-table* #\|))

(defvar *search-mode-abbrev-table* nil)
(unless *search-mode-abbrev-table*
  (define-abbrev-table '*search-mode-abbrev-table*))

(defun search-mode ()
  (interactive)
  (kill-all-local-variables)
  (setq buffer-mode 'search-mode)
  (setq mode-name "CL Search")
  (setq need-not-save t)
  (setq auto-save nil)
  (make-local-variable 'search-winconf)
  (make-local-variable 'search-keys-list)
  (make-local-variable 'current-search-keys-list)
  (make-local-variable 'category-alist)
  (make-local-variable 'search-hash-table)
  (setq search-hash-table (make-hash-table :test #'equal))
  (make-local-variable 'save-hash-table)
  (setq save-hash-table (make-hash-table :test #'equal))
  (make-local-variable 'modified-date-list)
  (make-local-variable 'modified-date-hash-table)
  (setq modified-date-hash-table (make-hash-table :test #'equal))
  (make-local-variable 'inserted-date-hash-table)
  (setq inserted-date-hash-table (make-hash-table :test #'equal))
  (make-local-variable 'search-save-time)
  (make-local-variable '*scroll-margin*)
  (setq *scroll-margin* *search-scroll-margin*)
  (use-keymap *search-mode-map*)
  (set-local-window-flags (selected-buffer) *window-flag-tab*
			  *search-window-flag-tab*)
  (set-local-window-flags (selected-buffer) *window-flag-newline*
			  *search-window-flag-newline*)
  (and *search-fold-width* (set-buffer-fold-width *search-fold-width*))
  (and *search-fill-column* (setq fill-column *search-fill-column*))
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *search-format*)
  (use-syntax-table *search-mode-syntax-table*)
  (setq *local-abbrev-table* *search-mode-abbrev-table*)
  (run-hooks '*search-mode-hook*))

;;; make-alist
(defun make-alist (string &optional regexp)
  (let (reg list)
    (if regexp
	(setq reg (compile-regexp string *cl-case-fold-search*))
      (setq reg string))
    (when reg
      (let (ob (no-dup nil))
	(while (scan-buffer reg
			    :case-fold *cl-case-fold-search*
			    :no-dup no-dup)
	  (let (date)
	    (multiple-value-bind (b e)
		(get-item)
	      (and b e ;entry-header でマッチした場合が除外される
		   (not (eq b ob))
		   (setq date (get-date-string))
		   (push (cons date (buffer-substring b e)) list)
		   (setq ob b))))
	  (setq no-dup t))))
    (nreverse list)))

;;; print-hash-table
(defun print-hash-table (hash-table)
  (let (list)
    (maphash #'(lambda (d e) (push (list e d) list)) hash-table)
    (with-output-to-selected-buffer
      (format t "~:{~A~:^~}" (sort list #'string>= :key #'cadr)))))

;;; エラーメッセージ(migegmo.l で上書き)
(defun search-error-message (method string)
  (case method
    (:and
     (plain-error (format nil "\"~A\" が見つかりません" string)))
    (:reg
     (plain-error
      (format nil "正規表現 \"~A\" が見つかりません" string)))
    (:or
     (plain-error
      (format nil "Or検索で \"~A\" が見つかりません" string)))
    (:category
     (plain-error
      (format nil "カテゴリ \"~A\" が見つかりません" string)))
    (:year
     (plain-error (format nil "\"~A\" が見つかりません" string)))
    (:month
     (plain-error (format nil "\"~A\" が見つかりません" string)))
    (:day
     (plain-error (format nil "\"~A\" が見つかりません" string)))))

;;; category-alist, search-hash-table, save-hash-table, modified-date-list
;;; をセット
;;; + modified(inserted)-date-hash-table を初期化
(defun search-set-local-variables (item-alist)
  (setq modified-date-hash-table (make-hash-table :test #'equal))
  (setq inserted-date-hash-table (make-hash-table :test #'equal))
  (let ((name *unclassified-category-name*) (alist item-alist)
	(chash (make-hash-table :test #'equal))
	(shash1 (make-hash-table :test #'equal))
	(shash2 (make-hash-table :test #'equal))
	dlist)
    (let (str date)
      (loop ()
	(and alist (add-to-category-hash-table (cdar alist) chash))
	(let ((day (caar alist)) (item (cdar alist)))
	  (if (equal day date)
	      (setq str (concat str item))
	    (progn
	      (when str
		(setf (gethash date shash1) str)
		(setf (gethash date shash2) str))
	      (or day (return))
	      (push day dlist)
	      (setq str (format nil "~A~%~%~A"
				(make-entry-header day) item))
	      (setq date day))))
	(setq alist (cdr alist))))
    (let ((num (gethash name chash)) list)
      (and num (remhash name chash))
      (maphash #'(lambda (c n) (push (list c n) list)) chash)
      (if num
	  (setq category-alist (nconc (sort list #'string<= :key #'car)
				      (list (list name num))))
	(setq category-alist (sort list #'string<= :key #'car))))
    (setq search-hash-table shash1)
    (setq save-hash-table shash2)
    (setq modified-date-list (nreverse dlist))))

(defun add-to-category-hash-table (item hash)
  (string-match *item-regexp* item)
  (let ((s (match-string 1)) (f nil))
    (while (string-match *category-regexp* s)
      (setq s (substring s (match-end 1)))
      (let* ((c (match-string 1)) (n (gethash c hash)))
	(if n
	    (setf (gethash c hash) (1+ n))
	  (setf (gethash c hash) 1)))
      (setq f t))
    (unless f
      (let* ((c *unclassified-category-name*) (n (gethash c hash)))
	(if n
	    (setf (gethash c hash) (1+ n))
	  (setf (gethash c hash) 1)))))
  )

;;; search-print
(defun search-print (keys item-alist category-alist &optional notab)
  (save-excursion
    (let ((kept-undo-information nil))
      (declare (special kept-undo-information))
      (print-category category-alist)
      (search-print-header keys)
      (print-alist item-alist (not notab)))))

(defun print-category (category-alist)
  (with-output-to-selected-buffer ()
    (format t "カテゴリ:~:{ [~A](~D)~^ ~}:(~D)~%"
	    category-alist
	    (apply '+ (mapcar #'cadr category-alist)))))

;migegmo.l で上書き
(defun search-print-header (keys)
  (with-output-to-selected-buffer ()
    (case (caar keys)
      (:and (format t "検索: ~{~A~^ + ~}~%~%" (cdar keys)))
      (:reg (format t "検索(regexp): ~A~%~%" (cadar keys)))
      (:or (format t "検索(or): ~{~A~^ + ~}~%~%" (cdar keys)))
      (:category (format t "検索(category): ~A~%~%" (cadar keys)))
      (:year
       (format t "検索(year): ~A~%~%" (cadar keys))
       (format-year-month)
       (format t "~%~%"))
      (:month
       (format t "検索(month): ~A~%~%" (cadar keys))
       (format-year-month)
       (format t "~%~%"))
      (:day
       (format t "検索(day): ~A~%~%" (cadar keys))
       (let ((month (substring (cadar keys) 0 7)) list)
	 (mapc #'(lambda (d) (and (string= (substring d 0 7) month)
				  (push (substring d 8 10) list)))
	       (get-date-list))
	 (format t "~A / ~{~A~^ ~}" month list))
       (format t "~%~%")))))

(defun format-year-month ()
  (let* ((month-list (get-month-list))
	 (year-list (get-substring-list month-list 0 4)) list)
    (dolist (y year-list)
      (let (mlist)
	(mapc #'(lambda (m) (and (string= (substring m 0 4) y)
				 (push (substring m 5 7) mlist)))
	      month-list)
	(push (cons (concat y ":") mlist) list)))
    (format t "~{~{~A~^ ~}~^~%~}" (nreverse list))))

(defun print-alist (item-alist &optional tab)
  (when item-alist
    (with-output-to-selected-buffer ()
      (let (date)
	(dolist (x item-alist)
	  (let ((day (car x)) item)
	    (if tab
		(setq item (get-string-with-tab (cdr x)))
	      (setq item (cdr x)))
	    (if (string= day date)
		(format t "~A" item)
	      (progn
		(setq date day)
		(format t "~A~%~%~A" (make-entry-header day) item))))))
      )))

;;; research-print
(defun research-print (keys item-alist category-alist &optional notab)
  (save-excursion
    (let ((kept-undo-information nil))
      (declare (special kept-undo-information))
      (print-category category-alist)
      (research-print-header keys)
      (print-alist item-alist (not notab)))))

;migegmo.l で上書き
(defun research-print-header (keys)
  (with-output-to-selected-buffer ()
    (dolist (x (reverse keys))
      (case (car x)
	(:and (format t "検索: ~{~A~^ + ~}~%" (cdr x)))
	(:reg (format t "検索(regexp): ~A~%" (cadr x)))
	(:or (format t "検索(or): ~{~A~^ + ~}~%" (cdr x)))
	(:category (format t "検索(category): ~A~%" (cadr x)))
	(:year (format t "検索(year): ~A~%" (cadr x)))
	(:month (format t "検索(month): ~A~%" (cadr x)))
	(:day (format t "検索(day): ~A~%" (cadr x)))))
    (format t "~%")))

;;; search-keys-list, current-search-keys-list をセット
(defun set-search-keys-list (keys)
  (push keys current-search-keys-list)
  (setf search-keys-list current-search-keys-list))

(defun get-search-keys (key)
  (let ((keys (car (copy-alist current-search-keys-list))))
    (cons key keys)))

;;; 変数をセットし、出力(migegmo.l で上書き)
(defun set-and-write-variable (mem method)
  (case method
    (:and
     (set-and-write-variable-1 mem
			       '*and-history-list*
			       'write-and-variable))
    (:reg
     (set-and-write-variable-1 mem
			       '*regexp-history-list*
			       'write-regexp-variable))
    (:or
     (set-and-write-variable-1 mem
			       '*or-history-list*
			       'write-or-variable))
    (:category
     (set-and-write-variable-1 mem
			       '*category-history-list*
			       'write-category-variable))
    (:year
     (set-and-write-variable-1 mem
			       '*year-history-list*
			       'write-year-variable))
    (:month
     (set-and-write-variable-1 mem
			       '*month-history-list*
			       'write-month-variable))
    (:day
     (set-and-write-variable-1 mem
			       '*day-history-list*
			       'write-day-variable))))

(defun set-and-write-variable-1 (mem var func)
  (setf (symbol-value var)
	(add-list mem (symbol-value var) *cl-save-history*))
  (funcall func))

(defun add-list (mem list num)
  (unless (plusp num)
    (return-from add-list nil))
  (let ((ln (1+ (- (list-length list) num))))
    (if (plusp ln)
	(cons mem (butlast list ln))
      (cons mem list))))

;;; 色づけ

;migegmo.l で上書き
(defun set-text-attributes-keys (keys &optional notab)
  (let ((and-keys (keys-method :and keys))
	(regexp-keys (keys-method :reg keys))
	(or-keys (keys-method :or keys)))
    (set-text-attributes-keys-1 keys)
    (when and-keys
      (dolist (x and-keys)
	(dolist (s (cdr x))
	  (cond ((string-match "^\".*\"$" s)
		 (set-text-attributes-string (substring s 1 -1)))
		((string= s "-" :end1 1))
		(t
		 (set-text-attributes-string s))))))
    (when regexp-keys
      (dolist (x regexp-keys)
	(let ((r (if notab
		     (cadr x)
		   (substitute-string (cadr x)
				      "\\(^\\|[^[\\]\\)\\^" "\\0\t"))))
	  ;タブをつけた後に色づけするのでsubstitute してごまかした
	  (set-text-attributes-string (decode-escape-sequence r t) t))))
    (when or-keys
      (dolist (x or-keys)
	(dolist (s (cdr x))
	  (set-text-attributes-string s))))
    (when (= (list-length keys) 1)
      (cond ((eq (caar keys) :year)
	     (set-text-attributes-year (cadar keys)))
	    ((eq (caar keys) :month)
	     (set-text-attributes-month (cadar keys)))
	    ((eq (caar keys) :day)
	     (set-text-attributes-day (cadar keys)))))
    t))

(defun keys-method (method keys)
  (delete nil (mapcar
	       #'(lambda (x) (if (eq (car x) method) x))
	       keys))
  )

(defun set-text-attributes-keys-1 (keys)
  (save-excursion
    (goto-char (point-min))
    (let ((list (apply #'append (mapcar #'cdr keys)))
	  (limit (save-excursion
		   (if (scan-buffer (compile-regexp
				     (format nil "~A\\|^$"
					     *date-regexp*)))
		       (1- (point))
		     (return-from set-text-attributes-keys-1 nil)))))
      (scan-buffer (compile-regexp "^検索"))
      (dolist (s list)
	(while (<= (point) limit)
	  (scan-buffer (compile-regexp "[^ ]:"))
	  (let ((lt (save-excursion (goto-eol) (point))))
	    (while (scan-buffer s :no-dup t :limit (min lt limit))
	      (let ((b (match-beginning 0)) (e (match-end 0)))
		(apply #'set-text-attribute (append (list b e 'clsearch)
						    *search-attribute*)))))
	  (forward-line))
	(goto-char (point-min))
	(scan-buffer (compile-regexp "^検索")))
      )))

(defun set-text-attributes-string (string &optional regexp)
  (save-excursion
    (goto-char (point-min))
    (let ((str (if regexp
		   (compile-regexp string *cl-case-fold-search*)
		 string)))
      (scan-buffer (compile-regexp *date-regexp*))
      (while (scan-buffer str
			  :case-fold *cl-case-fold-search*
			  :no-dup t)
	(let ((b (match-beginning 0)) (e (match-end 0)))
	  (unless (entry-header-line-p)
	    (apply #'set-text-attribute (append (list b e 'clsearch)
						*search-attribute*)))))
      )))

(defun set-text-attributes-year (year)
  (save-excursion
    (goto-char (point-min))
    (let ((limit (save-excursion
		   (scan-buffer (compile-regexp *date-regexp*))
		   (point))))
      (when (scan-buffer (compile-regexp (format nil "^\\(~A\\): " year))
			 :limit limit)
	(set-text-attribute (match-beginning 1) (match-end 1)
			    'clsearch :underline t))
      )))

(defun set-text-attributes-month (month)
  (save-excursion
    (goto-char (point-min))
    (let ((year (substring month 0 4)) (month (substring month 5 7))
	  (limit (save-excursion
		   (scan-buffer (compile-regexp *date-regexp*))
		   (point))))
      (when (scan-buffer (compile-regexp
			  (format nil "^~A: .*\\(~A\\)" year month))
			 :limit limit)
	(set-text-attribute (match-beginning 1) (match-end 1)
			    'clsearch :underline t))
      )))

(defun set-text-attributes-day (date)
  (save-excursion
    (goto-char (point-min))
    (let ((month (substring date 0 7)) (day (substring date 8 10))
	  (limit (save-excursion
		   (scan-buffer (compile-regexp *date-regexp*))
		   (point))))
      (when (scan-buffer (compile-regexp (format nil "^~A / .*\\(~A\\)"
						 month day))
			 :limit limit)
	(set-text-attribute (match-beginning 1) (match-end 1)
			    'clsearch :underline t))
      )))

;;; string-match-keys-p
(defun string-match-keys-p (string search-keys)
  (dolist (key search-keys t)
    (unless (string-match-key-p string key)
      (return))))

;migegmo.l で上書き
(defun string-match-key-p (string key)
  (let ((method (car key)))
    (flet ((match (r s) (if *cl-case-fold-search*
			    (string-matchp r s)
			  (string-match r s))))
      (case method
	(:and
	 (dolist (s (cdr key) t)
	   (cond ((string-match "^\".*\"$" s)
		  (unless (match (regexp-quote (substring s 1 -1)) string)
		    (return)))
		 ((string= s "-" :end1 1)
		  (when (match (regexp-quote (substring s 1)) string)
		    (return)))
		 (t
		  (unless (match (regexp-quote s) string)
		    (return))))))
	(:reg
	 (and (match (cadr key) string) t))
	(:or
	 (dolist (s (cdr key) nil)
	   (when (match (regexp-quote s) string)
	     (return t))))
	(:category
	 (and (match (category-regexp (cadr key)) string) t))
	(:year
	 (and (match (year-regexp (cadr key)) string) t))
	(:month
	 (and (match (month-regexp (cadr key)) string) t))
	(:day
	 (and (match (date-regexp (cadr key)) string) t)))
      )))

;;; research-next, previous, current

;migegmo.l で上書き
(defun research-keys (search-keys &optional notab)
  (let ((keys (reverse search-keys)) alist)
    (case (caar keys)
      (:and (setq alist (search-and-2 (cdar keys))))
      (:reg (setq alist (search-regexp-2 (cadar keys))))
      (:or (setq alist (search-or-2 (cdar keys))))
      (:category (setq alist (search-category-2 (cadar keys))))
      (:year (setq alist (search-year-2 (cadar keys))))
      (:month (setq alist (search-month-2 (cadar keys))))
      (:day (setq alist (search-day-2 (cadar keys)))))
    (dolist (key (cdr keys))
      (case (car key)
	(:and (setq alist (research-and-2 (cdr key) alist)))
	(:reg (setq alist (research-regexp-2 (cadr key) alist)))
	(:or (setq alist (research-or-2 (cdr key) alist)))
	(:category (setq alist (research-category-2 (cadr key) alist)))
	(:year (setq alist (research-year-2 (cadr key) alist)))
	(:month (setq alist (research-month-2 (cadr key) alist)))
	(:day (setq alist (research-day-2 (cadr key) alist)))))
    (search-set-local-variables alist)
    (enable-post-buffer-modified-hook nil)
    (erase-buffer (selected-buffer))
    (cond ((= (list-length keys) 1)
	   (search-print search-keys alist category-alist notab))
	  ((< 1 (list-length keys))
	   (research-print search-keys alist category-alist notab)))
    (set-text-attributes-keys search-keys)
    (setq search-save-time (get-universal-time))
    (set-buffer-modified-p nil)
    (enable-post-buffer-modified-hook t)
    ))

(defun research-next (&optional notab)
  (interactive)
  (long-operation
    (let ((ckeys-list current-search-keys-list)
	  (keys-list search-keys-list))
      (and (<= (list-length keys-list) (list-length ckeys-list))
	   (plain-error "先の検索はありません"))
      (setf current-search-keys-list (last keys-list
					   (1+ (list-length ckeys-list))))
      (research-keys (car current-search-keys-list) notab))))

(defun research-previous (&optional notab)
  (interactive)
  (long-operation
    (let ((ckeys-list current-search-keys-list))
      (and (<= (list-length ckeys-list) 1)
	   (plain-error "前の検索はありません"))
      (setf current-search-keys-list (cdr ckeys-list))
      (research-keys (car current-search-keys-list) notab))))

(defun research-current (&optional notab)
  (interactive)
  (long-operation
    (research-keys (car current-search-keys-list) notab)))

;;; search-next-entry, search-previous-entry
(defun search-next-entry ()
  (interactive)
  (if (scan-buffer (compile-regexp *date-regexp*) :no-dup t)
      (recenter *search-scroll-margin*)
    (plain-error "次のはありません")))

(defun search-previous-entry ()
  (interactive)
  (if (scan-buffer (compile-regexp *date-regexp*) :no-dup t :reverse t)
      (recenter *search-scroll-margin*)
    (if (bobp)
	(plain-error "前のはありません")
      (goto-char (point-min)))))

;;; search-next-link, search-previous-link
(defun search-next-link (&optional notab)
  (interactive)
  (when (or (looking-at *category-regexp*)
	    (looking-at *search-category-regexp*))
    (forward-char 1)
    (return-from search-next-link t))
  (if (get-entry)
      (let ((reg (make-link-regexp (not notab))) (pt (point)))
	(if (scan-buffer reg :no-dup t)
	    (and (looking-at "\\(http\\|ftp\\)://[-a-zA-Z0-9_/~.#@%?&=;+(),'$!*:]+")
		 (regexp-match-values "\\[\\[.+\\]\\]" nil nil nil)
		 (unless (scan-buffer reg :no-dup t)
		   (goto-char pt)
		   (plain-error "次のはありません")))
	  (plain-error "次のはありません"))
	(when (or (looking-at *category-regexp*)
		  (looking-at *item-regexp-with-tab*))
	  (forward-char 1)))
    (cond ((regexp-line-p "^[0-9][0-9][0-9][0-9]:")
	   (or (scan-buffer (compile-regexp
			     "[0-9][0-9]\\( [0-9]\\|$\\)")
			    :no-dup t
			    :limit (save-excursion (goto-eol) (point)))
	       (scan-buffer (compile-regexp
			     "^[0-9][0-9][0-9][0-9]:")
			    :no-dup t)
	       (scan-buffer *date-regexp* :no-dup t)
	       (plain-error "次のはありません")))
	  ((regexp-line-p "^[0-9][0-9][0-9][0-9]-[0-9][0-9] /")
	   (or (scan-buffer (compile-regexp
			     "[0-9][0-9]\\( [0-9]\\|$\\)")
			    :no-dup t
			    :limit (save-excursion (goto-eol) (point)))
	       (scan-buffer (compile-regexp
			     "^[0-9][0-9][0-9][0-9]-[0-9][0-9] /")
			    :no-dup t)
	       (scan-buffer *date-regexp* :no-dup t)
	       (plain-error "次のはありません")))
	  (t
	   (and (or (scan-buffer *search-category-regexp* :no-dup t)
		    (scan-buffer (compile-regexp
				  "^[0-9][0-9][0-9][0-9]:")
				 :no-dup t)
		    (scan-buffer (compile-regexp
				  "^[0-9][0-9][0-9][0-9]-[0-9][0-9] /")
				 :no-dup t)
		    (scan-buffer *date-regexp* :no-dup t)
		    (plain-error "次のはありません"))
		(looking-at *search-category-regexp*)
		(forward-char 1)))))
  t)

(defun make-link-regexp (tab)
  (let ((dreg "^\\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\\) ([A-Z][a-z][a-z])")
	(ireg (if tab "^\t\\(\\* .*:\\)" "^\\(\\* .*:\\)"))
	(creg "\\[\\([^][\n]+\\)\\]\\(:\\| \\[[^][\n]+\\]:\\| \\[[^][\n]+\\] \\[\\)")
	(lreg "\\[\\[.+\\]\\]\\|\\[[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\\]\\|\\(http\\|ftp\\)://[-a-zA-Z0-9_/~.#@%?&=;+(),'$!*:]+"))
    (compile-regexp (format nil "~A\\|~A\\|~A\\|~A" dreg ireg creg lreg))))

(defun search-previous-link (&optional notab)
  (interactive)
  (let ((pt (point)))
    (if (save-excursion (forward-char -1) (get-entry))
	(let ((reg (make-link-regexp (not notab)))
	      (ci (save-excursion
		    (forward-char -1)
		    (or (looking-at *category-regexp*)
			(looking-at *item-regexp-with-tab*)))))
	  (and ci (forward-char -1))
	  (if (scan-buffer reg :no-dup t :reverse t)
	      (and (looking-at "\\(http\\|ftp\\)://[-a-zA-Z0-9_/~.#@%?&=;+(),'$!*:]+")
		   (regexp-match-values "\\[\\[.+\\]\\]" nil nil nil)
		   (unless (scan-buffer reg :no-dup t :reverse t)
		     (goto-char pt)
		     (plain-error "前のはありません")))
	    (progn
	      (goto-char pt)
	      (plain-error "前のはありません")))
	  (when (or (looking-at *category-regexp*)
		    (looking-at *item-regexp-with-tab*))
	    (forward-char 1)))
      (let ((s (save-excursion
		 (forward-char -1)
		 (looking-at *search-category-regexp*))))
	(and s (forward-char -1))
	(cond ((regexp-line-p "^[0-9][0-9][0-9][0-9]:")
	       (or (and (bolp)
			(scan-buffer (compile-regexp
				      "^[0-9][0-9][0-9][0-9]:.*\\([0-9][0-9]\\)$")
				     :no-dup t :reverse t)
			(goto-char (match-beginning 1)))
		   (scan-buffer (compile-regexp
				 "[0-9][0-9]\\( [0-9]\\|$\\)")
				:no-dup t :reverse t
				:limit (save-excursion (goto-bol) (point)))
		   (scan-buffer (compile-regexp
				 "^[0-9][0-9][0-9][0-9]:")
				:no-dup t :reverse t)
		   (and (scan-buffer *search-category-regexp*
				     :no-dup t :reverse t)
			(forward-char 1))
		   (progn
		     (goto-char pt)
		     (plain-error "前のはありません"))))
	      ((regexp-line-p "^[0-9][0-9][0-9][0-9]-[0-9][0-9] /")
	       (or (and (bolp)
			(scan-buffer (compile-regexp
				      "^[0-9][0-9][0-9][0-9]-[0-9][0-9] /.*\\([0-9][0-9]\\)$")
				     :no-dup t :reverse t)
			(goto-char (match-beginning 1)))
		   (scan-buffer (compile-regexp
				 "[0-9][0-9]\\( [0-9]\\|$\\)")
				:no-dup t :reverse t
				:limit (save-excursion (goto-bol) (point)))
		   (scan-buffer (compile-regexp
				 "^[0-9][0-9][0-9][0-9]-[0-9][0-9] /")
				:no-dup t :reverse t)
		   (and (scan-buffer *search-category-regexp*
				     :no-dup t :reverse t)
			(forward-char 1))
		   (progn
		     (goto-char pt)
		     (plain-error "前のはありません"))))
	      (t
	       (and (or (and (scan-buffer (compile-regexp
					   "^[0-9][0-9][0-9][0-9]:.*\\([0-9][0-9]\\)$")
					  :no-dup t :reverse t)
			     (goto-char (match-beginning 1)))
			(and (scan-buffer (compile-regexp
					   "^[0-9][0-9][0-9][0-9]-[0-9][0-9] /.*\\([0-9][0-9]\\)$")
					  :no-dup t :reverse t)
			     (goto-char (match-beginning 1)))
			(scan-buffer *search-category-regexp*
				     :no-dup t :reverse t)
			(progn
			  (goto-char pt)
			  (plain-error "前のはありません")))
		    (looking-at *search-category-regexp*)
		    (forward-char 1)))))
      );if
    t))

;;; search-rotate-category
(defun search-rotate-category ()
  (interactive)
  (when (or (looking-at *category-regexp*)
	    (looking-at *search-category-regexp*))
    (forward-char 1)
    (return-from search-rotate-category t))
  (let ((pt (point)))
    (multiple-value-bind (beg end)
	(get-entry)
      (if (and beg end)
	  (if (scan-buffer *category-regexp* :no-dup t :limit end)
	      (forward-char 1)
	    (progn
	      (goto-char beg)
	      (if (scan-buffer *category-regexp* :no-dup t :limit end)
		  (forward-char 1)
		(goto-char pt))))
	(let ((limit (save-excursion
		       (if (scan-buffer *date-regexp*)
			   (point)
			 (point-max)))))
	  (if (scan-buffer *search-category-regexp*
			   :no-dup t :limit limit)
	      (forward-char 1)
	    (progn
	      (goto-char (point-min))
	      (if (scan-buffer *search-category-regexp*
			       :no-dup t :limit limit)
		  (forward-char 1)
		(goto-char pt)))))
	))
    t))

;;; search-newline, search-newline-new
;・ RET の挙動
;[entry 内]
;(1) 日付行で
;(2) カテゴリ上で
;(3) 日付リンクの上で
;(4) http://www.yahoo.co.jp/ とかで、url上で飛ぶ。(shell-execute)
;(5) それ以外の場所、newline-and-indent
;[entry 外]
;(1) search カテゴリ上で
;(2) "検索:" 行の上で
;(3) entry 外 2004-05 を クリックすることで、month 検索へ。etc
;(4) それ以外の場所、newline

(defun search-newline (&optional new notab)
  (interactive)
  (let (str)
    (if (get-entry)
	(cond ((and (entry-header-line-p) (not (eolp)))
	       (save-excursion
		 (goto-bol)
		 (setq str (regexp-match-string *date-regexp* nil 1 1)))
	       (long-operation (search-day-1 str notab)))
	      ((setq str (regexp-match-string *category-regexp* nil 1 1))
	       (long-operation
		 (if new
		     (search-category-1 str notab)
		   (research-category-1 str notab))))
	      ((setq str (regexp-match-string "\\[[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\\]" nil nil nil))
	       (long-operation (search-day-1 (substring str 1 -1) notab)))
	      ((setq str (regexp-match-string "\\(http\\|ftp\\)://[-a-zA-Z0-9_/~.#@%?&=;+(),'$!*:]+" nil nil nil))
	       (shell-execute str t))
	      (t
	       (if notab
		   (newline)
		 (newline-and-indent))))
      (cond ((setq str (regexp-match-string *search-category-regexp*
					    nil 1 1))
	     (long-operation
	       (if new
		   (search-category-1 str notab)
		 (research-category-1 str notab))))
	    ((regexp-line-p "^検索")
	     (let (b e n (ckeys-list current-search-keys-list))
	       (save-excursion
		 (goto-eol)
		 (setq b (point))
		 (if (scan-buffer *date-regexp*)
		     (setq e (point))
		   (setq e (point-max)))
		 (save-restriction
		   (narrow-to-region b e)
		   (goto-char (point-min))
		   (setq n (ed::count-matches "^検索" nil t))))
	       (setq current-search-keys-list
		     (last ckeys-list (- (list-length ckeys-list) n)))
	       (long-operation
		 (research-keys (car current-search-keys-list) notab))))
	    ((regexp-line-p "^[0-9][0-9][0-9][0-9]:")
	     (cond ((setq str (regexp-match-string
			       "^\\([0-9][0-9][0-9][0-9]\\):"
			       nil 1 1))
		    (long-operation (search-year-1 str notab)))
		   ((setq str (regexp-match-string
			       "\\([0-9][0-9]\\)\\( [0-9]\\|$\\)"
			       nil 1 1))
		    (let (y)
		      (save-excursion
			(goto-bol)
			(setq y (buffer-substring (point) (+ (point) 4))))
		      (long-operation
			(search-month-1 (concat y "-" str) notab))))))
	    ((regexp-line-p "^[0-9][0-9][0-9][0-9]-[0-9][0-9] /")
	     (cond ((setq str (regexp-match-string
			       "^\\([0-9][0-9][0-9][0-9]-[0-9][0-9]\\) /"
			       nil 1 1))
		    (long-operation (search-month-1 str notab)))
		   ((setq str (regexp-match-string
			       "\\([0-9][0-9]\\)\\( [0-9]\\|$\\)"
			       nil 1 1))
		    (let (m)
		      (save-excursion
			(goto-bol)
			(setq m (buffer-substring (point) (+ (point) 7))))
		      (long-operation
			(search-day-1 (concat m "-" str) notab))))))
	    (t
	     (newline)))
      )
    t))

(defun search-newline-new ()
  (interactive)
  (search-newline t))

;;; ミニバッファ
(defun get-search-history (history)
  (let* ((len (- (length history) *cl-minibuffer-maximum-history-count*))
	 (num (if (plusp len) len 0)))
    (nbutlast
     (mapcar #'(lambda (x) (cond ((eq (car x) :month)
				  (format nil "~A~A"
					  (substring (cadr x) 0 4)
					  (substring (cadr x) 5 7)))
				 ((eq (car x) :day)
				  (format nil "~A~A~A"
					  (substring (cadr x) 0 4)
					  (substring (cadr x) 5 7)
					  (substring (cadr x) 8 10)))
				 (t
				  (format nil "~{~A~^ ~}" (cdr x)))))
	     history)
     num)))
