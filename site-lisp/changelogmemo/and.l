;;; -*- Mode: Lisp; Package: ChangeLogMemo -*-
;;;
;;; changelogmemo/and.l
;;;
;;; Last updated: "2006-02-14"
;;;

(provide "changelogmemo/and")

(in-package "changelogmemo")

;;; Andåüçı
(defun search-and (&optional notab)
  (interactive)
  (let ((string) (winconf (current-window-configuration)))
    (let ((*minibuffer-default-history* (get-search-history
					 *and-history-list*)))
      (declare (special *minibuffer-default-history*))
      (setq string (read-string "Search: ")))
    (long-operation
      (search-and-1 (and-list string) notab)
      (setq search-winconf winconf))))

(defun and-list (string)
  (let ((str (string-left-trim " " string)) list)
    (while (string/= str "")
      (cond ((string-match "^\\([^ \"]+\\) +" str)
	     (push (match-string 1) list)
	     (setq str (substring str (match-end 0))))
	    ((string-match "^\\(\"[^\"]+\"\\) +" str)
	     (push (match-string 1) list)
	     (setq str (substring str (match-end 0))))
	    ((string-match "^[^ \"]+$" str)
	     (push (match-string 0) list)
	     (setq str ""))
	    ((string-match "^\"[^\"]+\"$" str)
	     (push (match-string 0) list)
	     (setq str ""))
	    (t
	     (return-from and-list nil))))
    (nreverse list)))

(defun search-and-1 (string-list &optional notab)
  (let ((str (format nil "~{~A~^ + ~}" string-list))
	(keys (list (cons :and string-list))) alist)
    (message "Searching \"~A\"..." str)
    (set-and-write-variable (cons :and string-list) :and)
    (setq alist (make-alist-and-search string-list))
    (unless alist
      (search-error-message :and str))
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
    (message "Searching \"~A\"...done" str)
    ))

(defun make-alist-and-search (string-list)
  (save-window-excursion
    (let (buffer alist)
      (unwind-protect
	  (progn
	    (setq buffer (create-new-buffer-temp))
	    (insert-file-contents *cl-file*)
	    (dolist (s string-list)
	      (goto-char (point-min))
	      (cond ((string-match "^\".*\"$" s)
		     (setq alist (make-alist (substring s 1 -1))))
		    ((string= s "-" :end1 1)
		     (setq alist (make-nomatch-alist (substring s 1))))
		    (t
		     (setq alist (make-alist s))))
	      (if alist
		  (progn
		    (erase-buffer buffer)
		    (print-alist alist))
		(return))))
	(delete-buffer buffer))
      alist)))

(defun make-nomatch-alist (string)
  (let (list)
    (let ((no-dup nil))
      (while (scan-buffer *item-regexp* :no-dup no-dup)
	(let (date)
	  (multiple-value-bind (b e)
	      (get-item)
	    (and b
		 (not (scan-buffer string
				   :case-fold *cl-case-fold-search*
				   :limit e))
		 (setq date (get-date-string))
		 (push (cons date (buffer-substring b e)) list))))
	(setq no-dup t)))
    (nreverse list)))

(defun search-and-2 (string-list)
  (let ((str (format nil "~{~A~^ + ~}" string-list))
	(keys (list (cons :and string-list))) alist)
    (message "Searching \"~A\"..." str)
    (setq alist (make-alist-and-search string-list))
    (unless alist
      (search-error-message :and str))
    (message "Searching \"~A\"...done" str)
    alist))

;;; Andåüçı(çiçûÇ›)
(defun research-and (&optional notab)
  (interactive)
  (let (string)
    (let ((*minibuffer-default-history* (get-search-history
					 *and-history-list*)))
      (declare (special *minibuffer-default-history*))
      (setq string (read-string "Search(çiçûÇ›): ")))
    (long-operation
      (research-and-1 (and-list string) notab))))

(defun research-and-1 (string-list &optional notab)
  (let ((str (format nil "~{~A~^ + ~}" string-list))
	(keys (get-search-keys (cons :and string-list)))
	alist)
    (message "Searching \"~A\"..." str)
    (set-and-write-variable (cons :and string-list) :and)
    (setq alist (make-alist-and-research-1 string-list))
    (unless alist
      (search-error-message :and str))
    (search-set-local-variables alist)
    (enable-post-buffer-modified-hook nil)
    (erase-buffer (selected-buffer))
    (research-print keys alist category-alist notab)
    (set-text-attributes-keys keys notab)
    (set-search-keys-list keys)
    (setq search-save-time (get-universal-time))
    (set-buffer-modified-p nil)
    (enable-post-buffer-modified-hook t)
    (message "Searching \"~A\"...done" str)
    ))

(defun make-alist-and-research-1 (string-list)
  (save-window-excursion
    (let ((hash search-hash-table) buffer alist)
      (unwind-protect
	  (progn
	    (setq buffer (create-new-buffer-temp))
	    (print-hash-table hash)
	    (dolist (s string-list)
	      (goto-char (point-min))
	      (cond ((string-match "^\".*\"$" s)
		     (setq alist (make-alist (substring s 1 -1))))
		    ((string= s "-" :end1 1)
		     (setq alist (make-nomatch-alist (substring s 1))))
		    (t
		     (setq alist (make-alist s))))
	      (if alist
		  (progn
		    (erase-buffer buffer)
		    (print-alist alist))
		(return))))
	(delete-buffer buffer))
      alist)))

(defun research-and-2 (string-list item-alist)
  (let ((str (format nil "~{~A~^ + ~}" string-list))
	(keys (get-search-keys (cons :and string-list)))
	alist)
    (message "Searching \"~A\"..." str)
    (setq alist (make-alist-and-research-2 string-list item-alist))
    (unless alist
      (search-error-message :and str))
    (message "Searching \"~A\"...done" str)
    alist))

(defun make-alist-and-research-2 (string-list item-alist)
  (save-window-excursion
    (let (buffer alist)
      (unwind-protect
	  (progn
	    (setq buffer (create-new-buffer-temp))
	    (print-alist item-alist)
	    (dolist (s string-list)
	      (goto-char (point-min))
	      (cond ((string-match "^\".*\"$" s)
		     (setq alist (make-alist (substring s 1 -1))))
		    ((string= s "-" :end1 1)
		     (setq alist (make-nomatch-alist (substring s 1))))
		    (t
		     (setq alist (make-alist s))))
	      (if alist
		  (progn
		    (erase-buffer buffer)
		    (print-alist alist))
		(return))))
	(delete-buffer buffer))
      alist)))

;;; esearch
(defun esearch-and ()
  (interactive)
  (search-and t))

(defun re-esearch-and ()
  (interactive)
  (research-and t))
