;;; -*- Mode: Lisp; Package: ChangeLogMemo -*-
;;;
;;; changelogmemo/or.l
;;;
;;; Last updated: "2006-02-14"
;;;

(provide "changelogmemo/or")

(in-package "changelogmemo")

;;; Oråüçı
(defun search-or (&optional notab)
  (interactive)
  (let ((string) (winconf (current-window-configuration)))
    (let ((*minibuffer-default-history* (get-search-history
					 *or-history-list*)))
      (declare (special *minibuffer-default-history*))
      (setq string (read-string "Or: ")))
    (long-operation
      (search-or-1 (split-string string #\SPC) notab)
      (setq search-winconf winconf))))

(defun search-or-1 (string-list &optional notab)
  (let ((str (format nil "~{~A~^ + ~}" string-list))
	(keys (list (cons :or string-list))) alist)
    (message "Searching \"~A\"[or]..." str)
    (set-and-write-variable (cons :or string-list) :or)
    (setq alist (make-alist-or-search string-list))
    (unless alist
      (search-error-message :or str))
    (get-buffer-create-search)
    (if notab
	(or (eq buffer-mode 'esearch-mode) (esearch-mode))
      (or (eq buffer-mode 'search-mode) (search-mode)))
    (search-set-local-variables alist)
    (erase-buffer (selected-buffer))
    (enable-post-buffer-modified-hook nil)
    (search-print keys alist category-alist notab)
    (set-text-attributes-keys keys notab)
    (set-search-keys-list keys)
    (setq search-save-time (get-universal-time))
    (set-buffer-modified-p nil)
    (enable-post-buffer-modified-hook t)
    (message "Searching \"~A\"[or]...done" str)
    ))

(defun make-alist-or-search (string-list)
  (let ((regexp (format nil "~{~A~^\\|~}"
			(mapcar #'regexp-quote string-list))))
    (make-alist-regexp-search regexp)))

(defun search-or-2 (string-list)
  (let ((str (format nil "~{~A~^ + ~}" string-list))
	(keys (list (cons :or string-list))) alist)
    (message "Searching \"~A\"[or]..." str)
    (setq alist (make-alist-or-search string-list))
    (unless alist
      (search-error-message :or str))
    (message "Searching \"~A\"[or]...done" str)
    alist))

;;; Oråüçı(çiçûÇ›)
(defun research-or (&optional notab)
  (interactive)
  (let (string)
    (let ((*minibuffer-default-history* (get-search-history
					 *or-history-list*)))
      (declare (special *minibuffer-default-history*))
      (setq string (read-string "Or(çiçûÇ›): ")))
    (long-operation
      (research-or-1 (split-string string #\SPC) notab))))

(defun research-or-1 (string-list &optional notab)
  (let ((str (format nil "~{~A~^ + ~}" string-list))
	(keys (get-search-keys (cons :or string-list)))
	alist)
    (message "Searching \"~A\"[or]..." str)
    (set-and-write-variable (cons :or string-list) :or)
    (setq alist (make-alist-or-research-1 string-list))
    (unless alist
      (search-error-message :or str))
    (search-set-local-variables alist)
    (enable-post-buffer-modified-hook nil)
    (erase-buffer (selected-buffer))
    (research-print keys alist category-alist notab)
    (set-text-attributes-keys keys notab)
    (set-search-keys-list keys)
    (setq search-save-time (get-universal-time))
    (set-buffer-modified-p nil)
    (enable-post-buffer-modified-hook t)
    (message "Searching \"~A\"[or]...done" str)
    ))

(defun make-alist-or-research-1 (string-list)
  (let ((regexp (format nil "~{~A~^\\|~}"
			(mapcar #'regexp-quote string-list))))
    (make-alist-regexp-research-1 regexp)))

(defun research-or-2 (string-list item-alist)
  (let ((str (format nil "~{~A~^ + ~}" string-list))
	(keys (get-search-keys (cons :or string-list)))
	alist)
    (message "Searching \"~A\"[or]..." str)
    (setq alist (make-alist-or-research-2 string-list item-alist))
    (unless alist
      (search-error-message :or str))
    (message "Searching \"~A\"[or]...done" str)
    alist))

(defun make-alist-or-research-2 (string-list item-alist)
  (let ((regexp (format nil "~{~A~^\\|~}"
			(mapcar #'regexp-quote string-list))))
    (make-alist-regexp-research-2 regexp item-alist)))

;;; esearch

(defun esearch-or ()
  (interactive)
  (search-or t))

(defun re-esearch-or ()
  (interactive)
  (research-or t))
