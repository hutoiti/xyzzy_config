;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: filter.l 731 2006-09-01 18:09:41Z torihat $
;
; rss/filter.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "rss/defs")
  (require "rss/macro"))

(provide "rss/filter")

(in-package "rss")

(defvar *filter-directory* "rss/filters")

(defvar *filter-url-list* nil)

(defun rss-filter-regist (url func)
  (pushnew (cons url func) *filter-url-list*
	   :test #'equal
	   :key #'car))

(defun filter-func (url)
  (cdr (assoc-if #'(lambda (x)
		     (string-match x url))
		 *filter-url-list*)))

(defun rss-load-filters ()
  (let* ((site-dir (merge-pathnames "site-lisp" (si:system-root)))
	 (plugin-dir (merge-pathnames *filter-directory* site-dir))
	 (files))
    (when (and (file-exist-p plugin-dir)
	       (file-directory-p plugin-dir))
      (dolist (file (directory plugin-dir
			       :wild "*.l"
			       :file-only t))
	(let ((name (pathname-name file)))
	  (load-library (format nil "~A/~A" *filter-directory* name)))))))

(defun rss-apply-filter (item file)
  (let* ((url (rss-link item))
	 (func (filter-func url)))
    (when (and func
	       (fboundp func))
      (message "applying filter: ~S ... " func)
      (funcall func item file)
      (message "applying filter: ~S ... done." func))))
