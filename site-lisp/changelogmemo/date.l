;;; -*- Mode: Lisp; Package: ChangeLogMemo -*-
;;;
;;; changelogmemo/date.l
;;;
;;; Last updated: "2006-02-23"
;;;

(provide "changelogmemo/date")

(in-package "changelogmemo")

;;; Yearåüçı
(defun search-year (&optional notab)
  (interactive)
  (let ((year) (year-list (get-year-list))
	(winconf (current-window-configuration)))
    (let ((*minibuffer-default-history* (get-search-history
					 *year-history-list*)))
      (declare (special *minibuffer-default-history*))
      (setq year (completing-read "yyyy: "
				  year-list
				  :default (car year-list)
				  :case-fold t :must-match t)))
    (long-operation
      (search-year-1 year notab)
      (setq search-winconf winconf))))

(defun search-year-1 (year &optional notab)
  (let ((keys (list (list :year year))) alist)
    (message "Searching \"~A\"[year]..." year)
    (set-and-write-variable (list :year year) :year)
    (setq alist (make-alist-year-search year))
    (unless alist
      (search-error-message :year year))
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
    (message "Searching \"~A\"[year]...done" year)
    ))

(defun make-alist-year-search (year)
  (save-window-excursion
    (let ((regexp (compile-regexp
		   (format nil "^~A-[0-9][0-9]-[0-9][0-9] ([A-Z][a-z][a-z])"
			   year)))
	  buffer beg end alist)
      (unwind-protect
	  (progn
	    (setq buffer (create-new-buffer-temp))
	    (insert-file-contents *cl-file*)
	    (goto-char (point-min))
	    (and (scan-buffer regexp)
		 (setq beg (point)))
	    (goto-char (point-max))
	    (and (scan-buffer regexp :reverse t)
		 (setq end (cadr (multiple-value-list (get-entry)))))
	    (and beg end
		 (save-restriction
		   (narrow-to-region beg end)
		   (goto-char (point-min))
		   (setq alist (make-alist *item-regexp* t)))))
	(delete-buffer buffer))
      alist)))

(defun search-year-2 (year)
  (let ((keys (list (list :year year))) alist)
    (message "Searching \"~A\"[year]..." year)
    (setq alist (make-alist-year-search year))
    (unless alist
      (search-error-message :year year))
    (message "Searching \"~A\"[year]...done" year)
    alist))

;;; Yearåüçı(çiçûÇ›)
(defun research-year (&optional notab)
  (interactive)
  (let ((year) (year-list (get-year-list t)))
    (let ((*minibuffer-default-history* (get-search-history
					 *year-history-list*)))
      (declare (special *minibuffer-default-history*))
      (setq year (completing-read "yyyy(çiçûÇ›): "
				  year-list
				  :default (car year-list)
				  :case-fold t :must-match t)))
    (long-operation
      (research-year-1 year notab))))

(defun research-year-1 (year &optional notab)
  (let ((keys (get-search-keys (list :year year))) alist)
    (message "Searching \"~A\"[year]..." year)
    (set-and-write-variable (list :year year) :year)
    (setq alist (make-alist-year-research-1 year))
    (unless alist
      (search-error-message :year year))
    (search-set-local-variables alist)
    (enable-post-buffer-modified-hook nil)
    (erase-buffer (selected-buffer))
    (research-print keys alist category-alist notab)
    (set-text-attributes-keys keys notab)
    (set-search-keys-list keys)
    (setq search-save-time (get-universal-time))
    (set-buffer-modified-p nil)
    (enable-post-buffer-modified-hook t)
    (message "Searching \"~A\"[year]...done" year)
    ))

(defun make-alist-year-research-1 (year)
  (save-window-excursion
    (let ((regexp (compile-regexp
		   (format nil "^~A-[0-9][0-9]-[0-9][0-9] ([A-Z][a-z][a-z])"
			   year)))
	  (hash search-hash-table) buffer beg end alist)
      (unwind-protect
	  (progn
	    (setq buffer (create-new-buffer-temp))
	    (print-hash-table hash)
	    (goto-char (point-min))
	    (and (scan-buffer regexp)
		 (setq beg (point)))
	    (goto-char (point-max))
	    (and (scan-buffer regexp :reverse t)
		 (setq end (cadr (multiple-value-list (get-entry)))))
	    (and beg end
		 (save-restriction
		   (narrow-to-region beg end)
		   (goto-char (point-min))
		   (setq alist (make-alist *item-regexp* t)))))
	(delete-buffer buffer))
      alist)))

(defun research-year-2 (year item-alist)
  (let ((keys (get-search-keys (list :year year))) alist)
    (message "Searching \"~A\"[year]..." year)
    (setq alist (make-alist-year-research-2 year item-alist))
    (unless alist
      (search-error-message :year year))
    (message "Searching \"~A\"[year]...done" year)
    alist))

(defun make-alist-year-research-2 (year item-alist)
  (save-window-excursion
    (let ((regexp (compile-regexp
		   (format nil "^~A-[0-9][0-9]-[0-9][0-9] ([A-Z][a-z][a-z])"
			   year)))
	  buffer beg end alist)
      (unwind-protect
	  (progn
	    (setq buffer (create-new-buffer-temp))
	    (print-alist item-alist)
	    (goto-char (point-min))
	    (and (scan-buffer regexp)
		 (setq beg (point)))
	    (goto-char (point-max))
	    (and (scan-buffer regexp :reverse t)
		 (setq end (cadr (multiple-value-list (get-entry)))))
	    (and beg end
		 (save-restriction
		   (narrow-to-region beg end)
		   (goto-char (point-min))
		   (setq alist (make-alist *item-regexp* t)))))
	(delete-buffer buffer))
      alist)))

;;; Monthåüçı
(defun search-month (&optional notab)
  (interactive)
  (let ((month) (month-list (get-month-list))
	(winconf (current-window-configuration)))
    (let ((*minibuffer-default-history* (get-search-history
					 *month-history-list*)))
      (declare (special *minibuffer-default-history*))
      (setq month (completing-read "yyyymm: "
				   (mapcar #'yyyymm month-list)
				   :default (yyyymm (car month-list))
				   :case-fold t :must-match t)))
    (long-operation
      (search-month-1 (yyyy-mm month) notab)
      (setq search-winconf winconf))))

(defun search-month-1 (month &optional notab)
  (let ((keys (list (list :month month))) alist)
    (message "Searching \"~A\"[month]..." month)
    (set-and-write-variable (list :month month) :month)
    (setq alist (make-alist-month-search month))
    (unless alist
      (search-error-message :month month))
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
    (message "Searching \"~A\"[month]...done" month)
    ))

(defun make-alist-month-search (month)
  (save-window-excursion
    (let ((regexp (compile-regexp
		   (format nil "^~A-[0-9][0-9] ([A-Z][a-z][a-z])"
			   month)))
	  buffer beg end alist)
      (unwind-protect
	  (progn
	    (setq buffer (create-new-buffer-temp))
	    (insert-file-contents *cl-file*)
	    (goto-char (point-min))
	    (and (scan-buffer regexp)
		 (setq beg (point)))
	    (goto-char (point-max))
	    (and (scan-buffer regexp :reverse t)
		 (setq end (cadr (multiple-value-list (get-entry)))))
	    (and beg end
		 (save-restriction
		   (narrow-to-region beg end)
		   (goto-char (point-min))
		   (setq alist (make-alist *item-regexp* t)))))
	(delete-buffer buffer))
      alist)))

(defun search-month-2 (month)
  (let ((keys (list (list :month month))) alist)
    (message "Searching \"~A\"[month]..." month)
    (setq alist (make-alist-month-search month))
    (unless alist
      (search-error-message :month month))
    (message "Searching \"~A\"[month]...done" month)
    alist))

;;; Monthåüçı(çiçûÇ›)
(defun research-month (&optional notab)
  (interactive)
  (let ((month) (month-list (get-month-list t)))
    (let ((*minibuffer-default-history* (get-search-history
					 *month-history-list*)))
      (declare (special *minibuffer-default-history*))
      (setq month (completing-read "yyyymm(çiçûÇ›): "
				   (mapcar #'yyyymm month-list)
				   :default (yyyymm (car month-list))
				   :case-fold t :must-match t)))
    (long-operation
      (research-month-1 (yyyy-mm month) notab))))

(defun research-month-1 (month &optional notab)
  (let ((keys (get-search-keys (list :month month))) alist)
    (message "Searching \"~A\"[month]..." month)
    (set-and-write-variable (list :month month) :month)
    (setq alist (make-alist-month-research-1 month))
    (unless alist
      (search-error-message :month month))
    (search-set-local-variables alist)
    (enable-post-buffer-modified-hook nil)
    (erase-buffer (selected-buffer))
    (research-print keys alist category-alist notab)
    (set-text-attributes-keys keys notab)
    (set-search-keys-list keys)
    (setq search-save-time (get-universal-time))
    (set-buffer-modified-p nil)
    (enable-post-buffer-modified-hook t)
    (message "Searching \"~A\"[month]...done" month)
    ))

(defun make-alist-month-research-1 (month)
  (save-window-excursion
    (let ((regexp (compile-regexp
		   (format nil "^~A-[0-9][0-9] ([A-Z][a-z][a-z])"
			   month)))
	  (hash search-hash-table) buffer beg end alist)
      (unwind-protect
	  (progn
	    (setq buffer (create-new-buffer-temp))
	    (print-hash-table hash)
	    (goto-char (point-min))
	    (and (scan-buffer regexp)
		 (setq beg (point)))
	    (goto-char (point-max))
	    (and (scan-buffer regexp :reverse t)
		 (setq end (cadr (multiple-value-list (get-entry)))))
	    (and beg end
		 (save-restriction
		   (narrow-to-region beg end)
		   (goto-char (point-min))
		   (setq alist (make-alist *item-regexp* t)))))
	(delete-buffer buffer))
      alist)))

(defun research-month-2 (month item-alist)
  (let ((keys (get-search-keys (list :month month))) alist)
    (message "Searching \"~A\"[month]..." month)
    (setq alist (make-alist-month-research-2 month item-alist))
    (unless alist
      (search-error-message :month month))
    (message "Searching \"~A\"[month]...done" month)
    alist))

(defun make-alist-month-research-2 (month item-alist)
  (save-window-excursion
    (let ((regexp (compile-regexp
		   (format nil "^~A-[0-9][0-9] ([A-Z][a-z][a-z])"
			   month)))
	  buffer beg end alist)
      (unwind-protect
	  (progn
	    (setq buffer (create-new-buffer-temp))
	    (print-alist item-alist)
	    (goto-char (point-min))
	    (and (scan-buffer regexp)
		 (setq beg (point)))
	    (goto-char (point-max))
	    (and (scan-buffer regexp :reverse t)
		 (setq end (cadr (multiple-value-list (get-entry)))))
	    (and beg end
		 (save-restriction
		   (narrow-to-region beg end)
		   (goto-char (point-min))
		   (setq alist (make-alist *item-regexp* t)))))
	(delete-buffer buffer))
      alist)))

;;; Dayåüçı
(defun search-day (&optional notab)
  (interactive)
  (let ((day) (date-list (get-date-list))
	(winconf (current-window-configuration)))
    (let ((*minibuffer-default-history* (get-search-history
					 *day-history-list*)))
      (declare (special *minibuffer-default-history*))
      (setq day (completing-read "yyyymmdd: "
				 (mapcar #'yyyymmdd date-list)
				 :default (yyyymmdd (car date-list))
				 :case-fold t :must-match t)))
    (long-operation
      (search-day-1 (yyyy-mm-dd day) notab)
      (setq search-winconf winconf))))

(defun search-day-1 (day &optional notab)
  (let ((keys (list (list :day day))) alist)
    (message "Searching \"~A\"[day]..." day)
    (set-and-write-variable (list :day day) :day)
    (setq alist (make-alist-day-search day))
    (unless alist
      (search-error-message :day day))
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
    (message "Searching \"~A\"[day]...done" day)
    ))

(defun make-alist-day-search (day)
  (save-window-excursion
    (let ((regexp (date-regexp day)) buffer alist)
      (unwind-protect
	  (progn
	    (setq buffer (create-new-buffer-temp))
	    (insert-file-contents *cl-file*)
	    (goto-char (point-min))
	    (and (scan-buffer regexp)
		 (multiple-value-bind (beg end)
		     (get-entry)
		   (save-restriction
		     (narrow-to-region beg end)
		     (goto-char (point-min))
		     (setq alist (make-alist *item-regexp* t))))))
	(delete-buffer buffer))
      alist)))

(defun search-day-2 (day)
  (let ((keys (list (list :day day))) alist)
    (message "Searching \"~A\"[day]..." day)
    (setq alist (make-alist-day-search day))
    (unless alist
      (search-error-message :day day))
    (message "Searching \"~A\"[day]...done" day)
    alist))

;;; Dayåüçı(çiçûÇ›)
(defun research-day (&optional notab)
  (interactive)
  (let ((day) (date-list (get-date-list t)))
    (let ((*minibuffer-default-history* (get-search-history
					 *day-history-list*)))
      (declare (special *minibuffer-default-history*))
      (setq day (completing-read "yyyymmdd(çiçûÇ›): "
				 (mapcar #'yyyymmdd date-list)
				 :default (yyyymmdd (car date-list))
				 :case-fold t :must-match t)))
    (long-operation
      (research-day-1 (yyyy-mm-dd day) notab))))

(defun research-day-1 (day &optional notab)
  (let ((keys (get-search-keys (list :day day))) alist)
    (message "Searching \"~A\"[day]..." day)
    (set-and-write-variable (list :day day) :day)
    (setq alist (make-alist-day-research-1 day))
    (unless alist
      (search-error-message :day day))
    (search-set-local-variables alist)
    (enable-post-buffer-modified-hook nil)
    (erase-buffer (selected-buffer))
    (research-print keys alist category-alist notab)
    (set-text-attributes-keys keys notab)
    (set-search-keys-list keys)
    (setq search-save-time (get-universal-time))
    (set-buffer-modified-p nil)
    (enable-post-buffer-modified-hook t)
    (message "Searching \"~A\"[day]...done" day)
    ))

(defun make-alist-day-research-1 (day)
  (save-window-excursion
    (let ((regexp (date-regexp day)) (hash search-hash-table)
	  buffer alist)
      (unwind-protect
	  (progn
	    (setq buffer (create-new-buffer-temp))
	    (print-hash-table hash)
	    (goto-char (point-min))
	    (and (scan-buffer regexp)
		 (multiple-value-bind (beg end)
		     (get-entry)
		   (save-restriction
		     (narrow-to-region beg end)
		     (goto-char (point-min))
		     (setq alist (make-alist *item-regexp* t))))))
	(delete-buffer buffer))
      alist)))

(defun research-day-2 (day item-alist)
  (let ((keys (get-search-keys (list :day day))) alist)
    (message "Searching \"~A\"[day]..." day)
    (setq alist (make-alist-day-research-2 day item-alist))
    (unless alist
      (search-error-message :day day))
    (message "Searching \"~A\"[day]...done" day)
    alist))

(defun make-alist-day-research-2 (day item-alist)
  (save-window-excursion
    (let ((regexp (date-regexp day)) buffer alist)
      (unwind-protect
	  (progn
	    (setq buffer (create-new-buffer-temp))
	    (print-alist item-alist)
	    (goto-char (point-min))
	    (and (scan-buffer regexp)
		 (multiple-value-bind (beg end)
		     (get-entry)
		   (save-restriction
		     (narrow-to-region beg end)
		     (goto-char (point-min))
		     (setq alist (make-alist *item-regexp* t))))))
	(delete-buffer buffer))
      alist)))

;;; esearch
(defun esearch-year ()
  (interactive)
  (search-year t))

(defun re-esearch-year ()
  (interactive)
  (research-year t))

(defun esearch-month ()
  (interactive)
  (search-month t))

(defun re-esearch-month ()
  (interactive)
  (research-month t))

(defun esearch-day ()
  (interactive)
  (search-day t))

(defun re-esearch-day ()
  (interactive)
  (research-day t))

;;; search-date-forward, search-date-backward
(defun search-date-forward ()
  (interactive)
  (let ((method (caaar current-search-keys-list)))
    (case method
      (:year (search-year-forward))
      (:month (search-month-forward))
      (:day (search-day-forward)))))

(defun search-date-backward ()
  (interactive)
  (let ((method (caaar current-search-keys-list)))
    (case method
      (:year (search-year-backward))
      (:month (search-month-backward))
      (:day (search-day-backward)))))

(defun search-year-forward (&optional notab)
  (let* ((year (cadaar current-search-keys-list))
	 (year-list (get-year-list))
	 (pos (position year year-list :test #'string=)))
    (when (<= pos 0)
      (plain-error "êÊÇÃîNÇÕÇ†ÇËÇ‹ÇπÇÒ"))
    (search-year-1 (nth (1- pos) year-list) notab)))

(defun search-year-backward (&optional notab)
  (let* ((year (cadaar current-search-keys-list))
	 (year-list (get-year-list))
	 (pos (position year year-list :test #'string=)))
    (when (<= (1- (list-length year-list)) pos)
      (plain-error "ëOÇÃîNÇÕÇ†ÇËÇ‹ÇπÇÒ"))
    (search-year-1 (nth (1+ pos) year-list) notab)))

(defun search-month-forward (&optional notab)
  (let* ((month (cadaar current-search-keys-list))
	 (month-list (get-month-list))
	 (pos (position month month-list :test #'string=)))
    (when (<= pos 0)
      (plain-error "êÊÇÃåéÇÕÇ†ÇËÇ‹ÇπÇÒ"))
    (search-month-1 (nth (1- pos) month-list) notab)))

(defun search-month-backward (&optional notab)
  (let* ((month (cadaar current-search-keys-list))
	 (month-list (get-month-list))
	 (pos (position month month-list :test #'string=)))
    (when (<= (1- (list-length month-list)) pos)
      (plain-error "ëOÇÃåéÇÕÇ†ÇËÇ‹ÇπÇÒ"))
    (search-month-1 (nth (1+ pos) month-list) notab)))

(defun search-day-forward (&optional notab)
  (let* ((day (cadaar current-search-keys-list))
	 (date-list (get-date-list))
	 (pos (position day date-list :test #'string=)))
    (when (<= pos 0)
      (plain-error "êÊÇÃì˙ÇÕÇ†ÇËÇ‹ÇπÇÒ"))
    (search-day-1 (nth (1- pos) date-list) notab)))

(defun search-day-backward (&optional notab)
  (let* ((day (cadaar current-search-keys-list))
	 (date-list (get-date-list))
	 (pos (position day date-list :test #'string=)))
    (when (<= (1- (list-length date-list)) pos)
      (plain-error "ëOÇÃì˙ÇÕÇ†ÇËÇ‹ÇπÇÒ"))
    (search-day-1 (nth (1+ pos) date-list) notab)))

;;; esearch-date-forward, esearch-date-backward
(defun esearch-date-forward ()
  (interactive)
  (let ((method (caaar current-search-keys-list)))
    (case method
      (:year (search-year-forward t))
      (:month (search-month-forward t))
      (:day (search-day-forward t)))))

(defun esearch-date-backward ()
  (interactive)
  (let ((method (caaar current-search-keys-list)))
    (case method
      (:year (search-year-backward t))
      (:month (search-month-backward t))
      (:day (search-day-backward t)))))
