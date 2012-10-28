; $Id: makefile.l,v 1.4 2005/11/24 15:12:27 torihat Exp $
;
; makefile.l
;
;
; by HATTORI Masashi

(provide "www/makefile")

;(in-package "www")

(defvar *www-file-list* '("www.l"
			  "www-url.l"
			  "www-http.l"
			  "www-misc.l"
			  "www-parse.l"
			  "www-view.l"
			  "www-tag.l"
			  "www-form.l"
			  "www-bookmark.l"
			  "www-auth.l"
			  "www-ftp.l"
			  "www-update.l"
			  "import-favorites.l"
			  "overlay.l"
			  "www-w3m.l"
			  "www-cookie.l"
			 ))

(defvar *www-root-directory* (merge-pathnames "site-lisp/www" (si:system-root)))

(defvar *www-buffer-make* "*WWW MAKE*")

(defun www-make ()
  (interactive)
  (let ((files *www-file-list*)
	(path *www-root-directory*)
       )
    (dolist (f files)
      (let ((file (merge-pathnames f path))
	    (filec))
	(setq filec (concat file "c"))
	(if (file-newer-than-file-p file filec)
	    (byte-compile-file file)
	  (message "skipping file: ~A" file))))))

(defun www-make-tags-file ()
  (interactive)
  (let ((path *www-root-directory*))
    (set-default-directory path)
    (make-tags-file path)))

(defun www-make-all ()
  (interactive)
  (www-make)
  (www-make-tags-file))

(defun www-make-clean ()
  (interactive)
  (let ((path *www-root-directory*))
    (set-default-directory path)
    (dolist (f (directory path))
      (when (or (string-match "~$" f)
		(string-match "\.lc" f)
		(string-match "xtags" (string-downcase f)))
	(delete-file f)
	(message "File deleted: ~A" f)))))
