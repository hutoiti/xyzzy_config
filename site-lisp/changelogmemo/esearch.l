;;; -*- Mode: Lisp; Package: ChangeLogMemo -*-
;;;
;;; changelogmemo/esearch.l
;;;
;;; Last updated: "2006-02-14"
;;;

(provide "changelogmemo/esearch")

(require "changelogmemo/search")

(in-package "changelogmemo")

;;; esearch-mode

(defvar *esearch-mode-hook* nil)

(defvar *esearch-mode-map* nil)

(unless *esearch-mode-map*
  (setq *esearch-mode-map* (make-sparse-keymap))
  (define-key *esearch-mode-map* #\M-/ 're-esearch-and)
  (define-key *esearch-mode-map* #\M-o 're-esearch-or)
  (define-key *esearch-mode-map* #\M-g 're-esearch-regexp)
  (define-key *esearch-mode-map* #\M-c 're-esearch-category)
  (define-key *esearch-mode-map* #\M-y 're-esearch-year)
  (define-key *esearch-mode-map* #\M-m 're-esearch-month)
  (define-key *esearch-mode-map* #\M-d 're-esearch-day)
  (define-key *esearch-mode-map* #\M-Right 're-esearch-next)
  (define-key *esearch-mode-map* #\M-Left 're-esearch-previous)
  (define-key *esearch-mode-map* #\M-r 're-esearch-current)
  (define-key *esearch-mode-map* #\M-f 'esearch-date-forward)
  (define-key *esearch-mode-map* #\M-b 'esearch-date-backward)
  (define-key *esearch-mode-map* #\M-Down 'search-next-entry)
  (define-key *esearch-mode-map* #\M-Up 'search-previous-entry)
  (define-key *esearch-mode-map* #\M-n 'esearch-next-link)
  (define-key *esearch-mode-map* #\M-p 'esearch-previous-link)
  (define-key *esearch-mode-map* #\TAB 'search-rotate-category)
  (define-key *esearch-mode-map* #\RET 'esearch-newline)
  (define-key *esearch-mode-map* #\M-RET 'esearch-newline-new)
  (define-key *esearch-mode-map* #\C-\. 'complete-category)
  (define-key *esearch-mode-map* #\C-j 'insert-item)
  (define-key *esearch-mode-map* '(#\C-x #\C-s) 'esearch-save))

(defvar *esearch-mode-syntax-table* nil)
(unless *esearch-mode-syntax-table*
  (setq *esearch-mode-syntax-table* *search-mode-syntax-table*))

(defvar *esearch-mode-abbrev-table* nil)
(unless *esearch-mode-abbrev-table*
  (define-abbrev-table '*esearch-mode-abbrev-table*))

(defun esearch-mode ()
  (interactive)
  (kill-all-local-variables)
  (setq buffer-mode 'esearch-mode)
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
  (use-keymap *esearch-mode-map*)
  (set-local-window-flags (selected-buffer) *window-flag-tab*
			  *esearch-window-flag-tab*)
  (set-local-window-flags (selected-buffer) *window-flag-newline*
			  *esearch-window-flag-newline*)
  (and *esearch-fold-width* (set-buffer-fold-width *esearch-fold-width*))
  (and *esearch-fill-column* (setq fill-column *esearch-fill-column*))
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *esearch-format*)
  (use-syntax-table *esearch-mode-syntax-table*)
  (setq *local-abbrev-table* *esearch-mode-abbrev-table*)
  (run-hooks '*esearch-mode-hook*))

;;; re-esearch-next, previous, current
(defun re-esearch-next ()
  (interactive)
  (research-next t))

(defun re-esearch-previous ()
  (interactive)
  (research-previous t))

(defun re-esearch-current ()
  (interactive)
  (research-current t))

;;; esearch-next-link, esearch-previous-link
(defun esearch-next-link ()
  (interactive)
  (search-next-link t))

(defun esearch-previous-link ()
  (interactive)
  (search-previous-link t))

;;; esearch-newline, esearch-newline-new
(defun esearch-newline ()
  (interactive)
  (search-newline nil t))

(defun esearch-newline-new ()
  (interactive)
  (search-newline t t))

;;; esearch-save
(defun esearch-save ()
  (interactive)
  (search-save t))
