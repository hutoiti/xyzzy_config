;;; -*- Mode: Lisp -*-
;;;
;;; makefile.l
;;;
;;; Last updated: "2006-02-22"
;;;

(provide "changelogmemo/makefile")

(defvar *cl-file-list* '("defs.l"
			 "main.l"
			 "draft.l"
			 "edit.l"
			 "search.l"
			 "esearch.l"
			 "and.l"
			 "regexp.l"
			 "or.l"
			 "category.l"
			 "date.l"
			 "complete.l"
			 "buffer-info.l"
			 "misc.l"
			 "convert.l"
			 "migemo.l"))

(defvar *cl-root* "site-lisp/changelogmemo")

(defun cl-make ()
  (interactive)
  (let ((files *cl-file-list*)
	(path (merge-pathnames *cl-root* (si:system-root))))
    (dolist (f files)
      (let ((file (merge-pathnames f path)) (filec))
	(setq filec (concat file "c"))
	(if (file-newer-than-file-p file filec)
	    (byte-compile-file file)
	  (message "skipping file: ~A" file))))))

(defun cl-make-tags-file ()
  (interactive)
  (let ((path (merge-pathnames *cl-root* (si:system-root))))
    (set-default-directory path)
    (make-tags-file path)))

(defun cl-make-all ()
  (interactive)
  (cl-make)
  (cl-make-tags-file))

(defun cl-make-clean ()
  (interactive)
  (let ((path (merge-pathnames *cl-root* (si:system-root))))
    (set-default-directory path)
    (dolist (f (directory path))
      (when (or (string-match "~$" f)
		(string-match "\.lc" f)
		(string-match "xtags" (string-downcase f)))
	(delete-file f)
	(message "File deleted: ~A" f)))))
