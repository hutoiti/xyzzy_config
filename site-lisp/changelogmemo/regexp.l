;;; -*- Mode: Lisp; Package: ChangeLogMemo -*-
;;;
;;; changelogmemo/regexp.l
;;;
;;; Last updated: "2006-02-14"
;;;

(provide "changelogmemo/regexp")

(in-package "changelogmemo")

;;; ê≥ãKï\åªåüçı
(defun search-regexp (&optional notab)
  (interactive)
  (let ((regexp) (winconf (current-window-configuration)))
    (let ((*minibuffer-default-history* (get-search-history
					 *regexp-history-list*)))
      (declare (special *minibuffer-default-history*))
      (setq regexp (read-string "Regexp: ")))
    (long-operation
      (search-regexp-1 regexp notab)
      (setq search-winconf winconf))))

(defun search-regexp-1 (regexp &optional notab)
  (let ((keys (list (list :reg regexp))) alist)
    (message "Searching \"~A\"[regexp]..." regexp)
    (set-and-write-variable (list :reg regexp) :reg)
    (setq alist (make-alist-regexp-search (decode-escape-sequence
					   regexp t)))
    (unless alist
      (search-error-message :reg regexp))
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
    (message "Searching \"~A\"[regexp]...done" regexp)
    ))

(defun make-alist-regexp-search (regexp)
  (save-window-excursion
    (let (buffer alist)
      (unwind-protect
	  (progn
	    (setq buffer (create-new-buffer-temp))
	    (insert-file-contents *cl-file*)
	    (goto-char (point-min))
	    (setq alist (make-alist regexp t)))
	(delete-buffer buffer))
      alist)))

(defun search-regexp-2 (regexp)
  (let ((keys (list (list :reg regexp))) alist)
    (message "Searching \"~A\"[regexp]..." regexp)
    (setq alist (make-alist-regexp-search (decode-escape-sequence
					   regexp t)))
    (unless alist
      (search-error-message :reg regexp))
    (message "Searching \"~A\"[regexp]...done" regexp)
    alist))

;;; ê≥ãKï\åªåüçı(çiçûÇ›)
(defun research-regexp (&optional notab)
  (interactive)
  (let (regexp)
    (let ((*minibuffer-default-history* (get-search-history
					 *regexp-history-list*)))
      (declare (special *minibuffer-default-history*))
      (setq regexp (read-string "Regexp(çiçûÇ›): ")))
    (long-operation
      (research-regexp-1 regexp notab))))

(defun research-regexp-1 (regexp &optional notab)
  (let ((keys (get-search-keys (list :reg regexp))) alist)
    (message "Searching \"~A\"[regexp]..." regexp)
    (set-and-write-variable (list :reg regexp) :reg)
    (setq alist (make-alist-regexp-research-1 (decode-escape-sequence
					       regexp t)))
    (unless alist
      (search-error-message :reg regexp))
    (search-set-local-variables alist)
    (enable-post-buffer-modified-hook nil)
    (erase-buffer (selected-buffer))
    (research-print keys alist category-alist notab)
    (set-text-attributes-keys keys notab)
    (set-search-keys-list keys)
    (setq search-save-time (get-universal-time))
    (set-buffer-modified-p nil)
    (enable-post-buffer-modified-hook t)
    (message "Searching \"~A\"[regexp]...done" regexp)
    ))

(defun make-alist-regexp-research-1 (regexp)
  (save-window-excursion
    (let ((hash search-hash-table) buffer alist)
      (unwind-protect
	  (progn
	    (setq buffer (create-new-buffer-temp))
	    (print-hash-table hash)
	    (goto-char (point-min))
	    (setq alist (make-alist regexp t)))
	(delete-buffer buffer))
      alist)))

(defun research-regexp-2 (regexp item-alist)
  (let ((keys (get-search-keys (list :reg regexp))) alist)
    (message "Searching \"~A\"[regexp]..." regexp)
    (setq alist (make-alist-regexp-research-2 (decode-escape-sequence
					       regexp t)
					      item-alist))
    (unless alist
      (search-error-message :reg regexp))
    (message "Searching \"~A\"[regexp]...done" regexp)
    alist))

(defun make-alist-regexp-research-2 (regexp item-alist)
  (save-window-excursion
    (let (buffer alist)
      (unwind-protect
	  (progn
	    (setq buffer (create-new-buffer-temp))
	    (print-alist item-alist)
	    (goto-char (point-min))
	    (setq alist (make-alist regexp t)))
	(delete-buffer buffer))
      alist)))

;;; esearch
(defun esearch-regexp ()
  (interactive)
  (search-regexp t))

(defun re-esearch-regexp ()
  (interactive)
  (research-regexp t))
