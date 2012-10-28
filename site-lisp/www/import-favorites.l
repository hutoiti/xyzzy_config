; $Id: import-favorites.l,v 1.3 2005/11/24 15:12:27 torihat Exp $
;
; www-favorites.l
;
; お気に入りをブックマークにインポート
;
; by HATTORI Masashi
;
;; Usage:
;; 	M-x load-library
;;	Load-library: www/import-favorites
;; 	M-x www-import-favorites

(require "www/www")

(provide "www/import-favorites")

(defun www-import-favorites ()
  (interactive)
  (www::import-favorites))

(defun www-export-favorites ()
  (interactive)
  (www::export-favorites))

(in-package "www")

(defvar *import-favorites-temp-buffer* " *FAVORITES TEMP*")

(defun favorites-directory ()
  (read-registry "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders"
		 "Favorites"
		 :current-user))

(defun export-favorites ()
  (let ((dir (favorites-directory)))
    (when dir
      (setq dir (map-backslash-to-slash dir)))
    (setq dir (read-directory-name "お気に入りフォルダ: "
				   :default (or dir "C:/Windows/Favorites/")))
    (unless (file-directory-p dir)
      (error "フォルダないっす: ~S" dir))
    (dolist (u *www-bookmark-alist*)
      (catch 'next
	(let* ((folder (car u))
	       (books (cadr u))
	       (outdir (merge-pathnames folder dir)))
	  (if (file-exist-p outdir)
	      (unless (file-directory-p outdir)
		(msgbox "ファイルがあります: ~S" outdir)
		(throw 'next 'foo))
	    (or (create-directory outdir)
		(msgbox "フォルダが作れません: ~S" outdir)))
	  (dolist (book books)
	    (let* ((url (car book))
		   (name (cadr book))
		   (file (merge-pathnames (concat name ".url") outdir)))
	      (with-open-file (os file
				  :direction :output
				  :if-exists :supersede
				  :if-does-not-exist :create)
		(format os "[InternetShortcut]~%URL=~A~%" url)
		(msgbox "~S~%~S" file url)))))))
    ))

(defun import-favorites-file-list (dir)
  (let ((files (directory dir
			  :wild "*.url"
			  :absolute t
			  :recursive t))
	url-list)
    (unless files
      (error "お気に入りはありません"))
    (message "Parsing files in ~A ... " dir)
    (unwind-protect
	(save-excursion
	  (set-buffer (get-buffer-create *import-favorites-temp-buffer*))
	  (dolist (file (sort files #'string-lessp))
	    (let ((folder (car (nreverse (pathname-directory file))))
		  (name (pathname-name file))
		  url)
	      (erase-buffer *import-favorites-temp-buffer*)
	      (insert-file-contents file)
	      (when (scan-buffer "^URL="
				 :regexp t
				 :tail t)
		(setq url (buffer-substring (point)
					    (progn
					      (goto-eol)
					      (point))))
		(let ((temp (nreverse (cdr (assoc folder url-list :test #'equal)))))
		  (if temp
		      (progn
			(push (cons name url) temp)
			(setf (cdr (assoc folder url-list :test #'equal)) temp))
		    (progn
		      (push (cons name url) temp)
		      (push (cons folder temp) url-list))))))))
      (delete-buffer *import-favorites-temp-buffer*)
    )
    (message "Parsing files in ~A ... done." dir)
    (nreverse url-list)
  ))
  
(defun import-favorites ()
  (let ((dir (favorites-directory))
	url-list)
    (when dir
      (setq dir (map-backslash-to-slash dir)))
    (setq dir (read-directory-name "お気に入りフォルダ: "
				   :default (or dir "C:/Windows/Favorites/")))
    (unless (file-directory-p dir)
      (error "フォルダないっす: ~S" dir))
    (setq url-list (import-favorites-file-list dir))
    (when url-list
      (www-bookmark-open)
      (dolist (ulist url-list)
	(let ((group (car ulist)))
	  (dolist (u (cdr ulist))
	    (let ((title (car u))
		  (url (cdr u)))
	      (www-bookmark-add-to-list url title group)))))
      (www-bookmark-write))
  ))

(defun import-favorites-file-list (dir)
  (let ((files (directory dir
			  :wild "*.url"
			  :absolute t
			  :recursive t))
	url-list)
    (unless files
      (error "お気に入りはありません"))
    (message "Parsing files in ~A ... " dir)
    (unwind-protect
	(save-excursion
	  (set-buffer (get-buffer-create *import-favorites-temp-buffer*))
	  (dolist (file (sort files #'string-lessp))
	    (let ((folder (car (nreverse (pathname-directory file))))
		  (name (pathname-name file))
		  url)
	      (erase-buffer *import-favorites-temp-buffer*)
	      (insert-file-contents file)
	      (when (scan-buffer "^URL="
				 :regexp t
				 :tail t)
		(setq url (buffer-substring (point)
					    (progn
					      (goto-eol)
					      (point))))
		(let ((temp (nreverse (cdr (assoc folder url-list :test #'equal)))))
		  (if temp
		      (progn
			(push (cons name url) temp)
			(setf (cdr (assoc folder url-list :test #'equal)) temp))
		    (progn
		      (push (cons name url) temp)
		      (push (cons folder temp) url-list))))))))
      (delete-buffer *import-favorites-temp-buffer*)
    )
    (message "Parsing files in ~A ... done." dir)
    (nreverse url-list)
  ))
