;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: makefile.l 731 2006-09-01 18:09:41Z torihat $
;
; rss/makefile.l
;
; by HATTORI Masashi

(provide "rss/makefile")

(defvar *rss-make-file-list* '("main.l"
			       "defs.l"
			       "http.l"
			       "macro.l"
			       "menu.l"
			       "group.l"
			       "open.l"
			       "open-www.l"
			       "parse.l"
			       "rss.l"
			       "window.l"
			       "filter.l"
			       "format.l"
			       "clip.l"
			       "history.l"
			       "hyper-estraier.l"
			       "filters/xyzzy-news.l"
			       "filters/lirs.l"
			       "filters/hina-di.l"
			       ))

(defvar *rss-make-root-directory*
  (merge-pathnames "site-lisp/rss" (si:system-root)))

(defvar *rss-make-buffer-make* "*RSS: MAKE")

(defun rss-make ()
  (interactive)
  (let ((files *rss-make-file-list*)
	(path *rss-make-root-directory*))
    (dolist (f files)
      (let ((file (merge-pathnames f path))
	    (filec))
	(setq filec (concat file "c"))
	(if (file-newer-than-file-p file filec)
	    (byte-compile-file file)
	  (message "skipping file: ~A" file))))
    (rss-make-filters)))

(defun rss-make-filters ()
  (interactive)
  (let ((path (merge-pathnames "filters" *rss-make-root-directory*)))
    (dolist (file (directory path
			     :wild "*.l"
			     :absolute t))
      (let ((lc (concat file "c")))
	(if (file-newer-than-file-p file lc)
	    (byte-compile-file file)
	  (message "skipping file: ~A" file))))))

(defun rss-make-tags-file ()
  (interactive)
  (let ((old (default-directory))
	(path *rss-make-root-directory*))
    (set-default-directory path)
    (make-tags-file path 0)
    (set-default-directory old)))

(defun rss-make-all ()
  (interactive)
  (rss-make)
  (rss-make-tags-file))

(defun rss-make-clean ()
  (interactive)
  (let ((path *rss-make-root-directory*))
    (dolist (f (directory path
			  :absolute t
			  :recursive t))
      (when (or (string-match "~$" f)
		(string-match "\.lc" f)
		(string-matchp "xtags" f))
	(delete-file f)
	(message "File deleted: ~A" f)))))
