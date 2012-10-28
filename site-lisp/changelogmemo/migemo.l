;;; -*- Mode: Lisp; Package: ChangeLogMemo -*-
;;;
;;; changelogmemo/migemo.l
;;;
;;; Last updated: "2006-02-23"
;;;

(provide "changelogmemo/migemo")

(require "migemo")

(in-package "changelogmemo")

(defvar *migemo-history-list* nil)

(defvar *migemo-filename* "migemo")

;;; MigemoŒŸõ
(defun search-migemo (&optional notab)
  (interactive)
  (let ((string) (winconf (current-window-configuration)))
    (let ((*minibuffer-default-history* (get-search-history
					 *migemo-history-list*)))
      (declare (special *minibuffer-default-history*))
      (setq string (read-string "Migemo: ")))
    (long-operation
      (search-migemo-1 string notab)
      (setq search-winconf winconf))))

(defun search-migemo-1 (string &optional notab)
  (let ((keys (list (list :migemo string))) alist)
    (message "Searching \"~A\"[migemo]..." string)
    (set-and-write-variable (list :migemo string) :migemo)
    (setq alist (make-alist-migemo-search string))
    (unless alist
      (search-error-message :migemo string))
    (get-buffer-create-search)
    (if notab
	(or (eq buffer-mode 'esearch-mode) (esearch-mode))
      (or (eq buffer-mode 'search-mode) (search-mode)))
    (search-set-local-variables alist)
    (enable-post-buffer-modified-hook nil)
    (erase-buffer (selected-buffer))
    (search-print keys alist category-alist notab)
    (set-text-attributes-keys keys notab)
    (set-search-keys-list keys)
    (setq search-save-time (get-universal-time))
    (set-buffer-modified-p nil)
    (enable-post-buffer-modified-hook t)
    (message "Searching \"~A\"[migemo]...done" string)
    ))

(defun make-alist-migemo-search (string)
  (let ((regexp (ed::migemo-query string)))
    (make-alist-regexp-search regexp)))

(defun search-migemo-2 (string)
  (let ((keys (list (list :migemo string))) alist)
    (message "Searching \"~A\"[migemo]..." string)
    (setq alist (make-alist-migemo-search string))
    (unless alist
      (search-error-message :migemo string))
    (message "Searching \"~A\"[migemo]...done" string)
    alist))

;;; MigemoŒŸõ(i‚İ)
(defun research-migemo (&optional notab)
  (interactive)
  (let (string)
    (let ((*minibuffer-default-history* (get-search-history
					 *migemo-history-list*)))
      (declare (special *minibuffer-default-history*))
      (setq string (read-string "Migemo(i‚İ): ")))
    (long-operation
      (research-migemo-1 string notab))))

(defun research-migemo-1 (string &optional notab)
  (let ((keys (get-search-keys (list :migemo string))) alist)
    (message "Searching \"~A\"[migemo]..." string)
    (set-and-write-variable (list :migemo string) :migemo)
    (setq alist (make-alist-migemo-research-1 string))
    (unless alist
      (search-error-message :migemo string))
    (search-set-local-variables alist)
    (enable-post-buffer-modified-hook nil)
    (erase-buffer (selected-buffer))
    (research-print keys alist category-alist notab)
    (set-text-attributes-keys keys notab)
    (set-search-keys-list keys)
    (setq search-save-time (get-universal-time))
    (set-buffer-modified-p nil)
    (enable-post-buffer-modified-hook t)
    (message "Searching \"~A\"[migemo]...done" string)
    ))

(defun make-alist-migemo-research-1 (string)
  (let ((regexp (ed::migemo-query string)))
    (make-alist-regexp-research-1 regexp)))

(defun research-migemo-2 (string item-alist)
  (let ((keys (get-search-keys (list :migemo string))) alist)
    (message "Searching \"~A\"[migemo]..." string)
    (setq alist (make-alist-migemo-research-2 string item-alist))
    (unless alist
      (search-error-message :migemo string))
    (message "Searching \"~A\"[migemo]...done" string)
    alist))

(defun make-alist-migemo-research-2 (string item-alist)
  (let ((regexp (ed::migemo-query string)))
    (make-alist-regexp-research-2 regexp item-alist)))

;;; esearch
(defun esearch-migemo ()
  (interactive)
  (search-migemo t))

(defun re-esearch-migemo ()
  (interactive)
  (research-migemo t))

;;; ã‘‚«(main.l, misc.l)
(defun read-variables ()
  (let ((dir *cl-history-directory*))
    (unless (file-directory-p dir)
      (when (yes-or-no-p "~A ‚ğì¬‚µ‚Ü‚·‚©?" dir)
	(create-directory dir))))
  (read-and-variable)
  (read-or-variable)
  (read-regexp-variable)
  (read-migemo-variable)
  (read-category-variable)
  (read-year-variable)
  (read-month-variable)
  (read-day-variable))

(defun read-migemo-variable ()
  (read-variable *migemo-filename* '*migemo-history-list*))

(defun write-migemo-variable ()
  (write-variable *migemo-filename* *migemo-history-list*))

;;; ã‘‚«(search.l)

(define-key *search-mode-map* #\M-j 'research-migemo)

(defun search-error-message (method string)
  (case method
    (:and
     (plain-error (format nil "\"~A\" ‚ªŒ©‚Â‚©‚è‚Ü‚¹‚ñ" string)))
    (:reg
     (plain-error
      (format nil "³‹K•\Œ» \"~A\" ‚ªŒ©‚Â‚©‚è‚Ü‚¹‚ñ" string)))
    (:or
     (plain-error
      (format nil "OrŒŸõ‚Å \"~A\" ‚ªŒ©‚Â‚©‚è‚Ü‚¹‚ñ" string)))
    (:migemo
     (plain-error
      (format nil "migemo ‚Å \"~A\" ‚ªŒ©‚Â‚©‚è‚Ü‚¹‚ñ" string)))
    (:category
     (plain-error
      (format nil "ƒJƒeƒSƒŠ \"~A\" ‚ªŒ©‚Â‚©‚è‚Ü‚¹‚ñ" string)))
    (:year
     (plain-error (format nil "\"~A\" ‚ªŒ©‚Â‚©‚è‚Ü‚¹‚ñ" string)))
    (:month
     (plain-error (format nil "\"~A\" ‚ªŒ©‚Â‚©‚è‚Ü‚¹‚ñ" string)))
    (:day
     (plain-error (format nil "\"~A\" ‚ªŒ©‚Â‚©‚è‚Ü‚¹‚ñ" string)))))

(defun search-print-header (keys)
  (with-output-to-selected-buffer ()
    (case (caar keys)
      (:and (format t "ŒŸõ: ~{~A~^ + ~}~%~%" (cdar keys)))
      (:reg (format t "ŒŸõ(regexp): ~A~%~%" (cadar keys)))
      (:or (format t "ŒŸõ(or): ~{~A~^ + ~}~%~%" (cdar keys)))
      (:migemo (format t "ŒŸõ(migemo): ~A~%~%" (cadar keys)))
      (:category (format t "ŒŸõ(category): ~A~%~%" (cadar keys)))
      (:year
       (format t "ŒŸõ(year): ~A~%~%" (cadar keys))
       (format-year-month)
       (format t "~%~%"))
      (:month
       (format t "ŒŸõ(month): ~A~%~%" (cadar keys))
       (format-year-month)
       (format t "~%~%"))
      (:day
       (format t "ŒŸõ(day): ~A~%~%" (cadar keys))
       (let ((month (substring (cadar keys) 0 7)) list)
	 (mapc #'(lambda (d) (and (string= (substring d 0 7) month)
				  (push (substring d 8 10) list)))
	       (get-date-list))
	 (format t "~A / ~{~A~^ ~}" month list))
       (format t "~%~%")))))

(defun research-print-header (keys)
  (with-output-to-selected-buffer ()
    (dolist (x (reverse keys))
      (case (car x)
	(:and (format t "ŒŸõ: ~{~A~^ + ~}~%" (cdr x)))
	(:reg (format t "ŒŸõ(regexp): ~A~%" (cadr x)))
	(:or (format t "ŒŸõ(or): ~{~A~^ + ~}~%" (cdr x)))
	(:migemo (format t "ŒŸõ(migemo): ~A~%" (cadr x)))
	(:category (format t "ŒŸõ(category): ~A~%" (cadr x)))
	(:year (format t "ŒŸõ(year): ~A~%" (cadr x)))
	(:month (format t "ŒŸõ(month): ~A~%" (cadr x)))
	(:day (format t "ŒŸõ(day): ~A~%" (cadr x)))))
    (format t "~%")))

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
    (:migemo
     (set-and-write-variable-1 mem
			       '*migemo-history-list*
			       'write-migemo-variable))
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

(defun set-text-attributes-keys (keys &optional notab)
  (let ((and-keys (keys-method :and keys))
	(regexp-keys (keys-method :reg keys))
	(or-keys (keys-method :or keys))
	(migemo-keys (keys-method :migemo keys)))
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
	  ;ƒ^ƒu‚ğ‚Â‚¯‚½Œã‚ÉF‚Ã‚¯‚·‚é‚Ì‚Åsubstitute ‚µ‚Ä‚²‚Ü‚©‚µ‚½
	  (set-text-attributes-string (decode-escape-sequence r t) t))))
    (when or-keys
      (dolist (x or-keys)
	(dolist (s (cdr x))
	  (set-text-attributes-string s))))
    (when migemo-keys
      (dolist (x migemo-keys)
	(set-text-attributes-string (ed::migemo-query (cadr x)) t)))
    (when (= (list-length keys) 1)
      (cond ((eq (caar keys) :year)
	     (set-text-attributes-year (cadar keys)))
	    ((eq (caar keys) :month)
	     (set-text-attributes-month (cadar keys)))
	    ((eq (caar keys) :day)
	     (set-text-attributes-day (cadar keys)))))
    t))

(defun research-keys (search-keys &optional notab)
  (let ((keys (reverse search-keys)) alist)
    (case (caar keys)
      (:and (setq alist (search-and-2 (cdar keys))))
      (:reg (setq alist (search-regexp-2 (cadar keys))))
      (:or (setq alist (search-or-2 (cdar keys))))
      (:migemo (setq alist (search-migemo-2 (cadar keys))))
      (:category (setq alist (search-category-2 (cadar keys))))
      (:year (setq alist (search-year-2 (cadar keys))))
      (:month (setq alist (search-month-2 (cadar keys))))
      (:day (setq alist (search-day-2 (cadar keys)))))
    (dolist (key (cdr keys))
      (case (car key)
	(:and (setq alist (research-and-2 (cdr key) alist)))
	(:reg (setq alist (research-regexp-2 (cadr key) alist)))
	(:or (setq alist (research-or-2 (cdr key) alist)))
	(:migemo (setq alist (research-migemo-2 (cadr key) alist)))
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
	(:migemo
	 (and (match (ed::migemo-query (cadr key)) string) t))
	(:category
	 (and (match (category-regexp (cadr key)) string) t))
	(:year
	 (and (match (year-regexp (cadr key)) string) t))
	(:month
	 (and (match (month-regexp (cadr key)) string) t))
	(:day
	 (and (match (date-regexp (cadr key)) string) t)))
      )))

;;; ã‘‚«(esearch.l)

(define-key *esearch-mode-map* #\M-j 're-esearch-migemo)
