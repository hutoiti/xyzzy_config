;;; -*- Mode: Lisp; Package: ChangeLogMemo -*-
;;;
;;; changelogmemo/category.l
;;;
;;; Last updated: "2006-02-14"
;;;

(provide "changelogmemo/category")

(in-package "changelogmemo")

;;; ÉJÉeÉSÉäåüçı
(defun search-category (&optional notab)
  (interactive)
  (let ((category) (winconf (current-window-configuration)))
    (let ((*minibuffer-default-history* (get-search-history
					 *category-history-list*)))
      (declare (special *minibuffer-default-history*))
      (setq category (completing-read "Category: "
				      (get-category-list t)
				      :case-fold t :must-match t)))
    (long-operation
      (search-category-1 category notab)
      (setq search-winconf winconf))))

(defun search-category-1 (category &optional notab)
  (let ((keys (list (list :category category))) alist)
    (message "Searching \"~A\"[category]..." category)
    (set-and-write-variable (list :category category) :category)
    (setq alist (make-alist-category-search category))
    (unless alist
      (search-error-message :category category))
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
    (message "Searching \"~A\"[category]...done" category)
    ))

(defun make-alist-category-search (category)
  (let ((regexp (category-regexp category)))
    (make-alist-regexp-search regexp)))

(defun search-category-2 (category)
  (let ((keys (list (list :category category))) alist)
    (message "Searching \"~A\"[category]..." category)
    (setq alist (make-alist-category-search category))
    (unless alist
      (search-error-message :category category))
    (message "Searching \"~A\"[category]...done" category)
    alist))

;;; ÉJÉeÉSÉäåüçı(çiçûÇ›)
(defun research-category (&optional notab)
  (interactive)
  (let (category)
    (let ((*minibuffer-default-history* (get-search-history
					 *category-history-list*)))
      (declare (special *minibuffer-default-history*))
      (setq category (completing-read "Category(çiçûÇ›): "
				      (mapcar #'car category-alist)
				      :case-fold t
				      :must-match t)))
    (long-operation
      (research-category-1 category notab))))

(defun research-category-1 (category &optional notab)
  (let ((keys (get-search-keys (list :category category))) alist)
    (message "Searching \"~A\"[category]..." category)
    (set-and-write-variable (list :category category) :category)
    (setq alist (make-alist-category-research-1 category))
    (unless alist
      (search-error-message :category category))
    (search-set-local-variables alist)
    (enable-post-buffer-modified-hook nil)
    (erase-buffer (selected-buffer))
    (research-print keys alist category-alist notab)
    (set-text-attributes-keys keys notab)
    (set-search-keys-list keys)
    (setq search-save-time (get-universal-time))
    (set-buffer-modified-p nil)
    (enable-post-buffer-modified-hook t)
    (message "Searching \"~A\"[category]...done" category)
    ))

(defun make-alist-category-research-1 (category)
  (let ((regexp (category-regexp category)))
    (make-alist-regexp-research-1 regexp)))

(defun research-category-2 (category item-alist)
  (let ((keys (get-search-keys (list :category category))) alist)
    (message "Searching \"~A\"[category]..." category)
    (setq alist (make-alist-category-research-2 category item-alist))
    (unless alist
      (search-error-message :category category))
    (message "Searching \"~A\"[category]...done" category)
    alist))

(defun make-alist-category-research-2 (category item-alist)
  (let ((regexp (category-regexp category)))
    (make-alist-regexp-research-2 regexp item-alist)))

;;; esearch
(defun esearch-category ()
  (interactive)
  (search-category t))

(defun re-esearch-category ()
  (interactive)
  (research-category t))
