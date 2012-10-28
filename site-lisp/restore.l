;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; restore.l
;;;
;;; Last updated: "2006-07-27"
;;;

(provide "restore")

(require "session")
(require "gmark")

(in-package "editor")

(export '(*restore-directory* *restore-exceptional-tag-list*))

(defvar *restore-directory* "~/restore")

(defvar *restore-exceptional-tag-list* nil)

(defvar *restore-before-resume-hook* nil)
(defvar *restore-after-resume-hook* nil)

(defstruct restore
  information attributes global-mark)

(defvar-local restore-info (make-restore))

;backup.l より借用(↓)
(defun restore-directory (file)
  (let ((dir (directory-namestring file))
	(restore-dir *restore-directory*))
    (when (prog1
	      (find #\/ restore-dir)
	    (setq restore-dir (append-trail-slash (merge-pathnames restore-dir
								   dir))))
      (setq restore-dir (format nil "~A~{~A/~}"
				restore-dir (split-string dir "/:"))))
    restore-dir));(↑)

(defun restore-make-file (file dir)
  (merge-pathnames (concat (file-namestring file) ".rtr") dir))

(defun restore-file (file)
  (restore-make-file file (restore-directory file)))

(defun restore-make-info ()
  (let ((info (make-restore)))
    (setf (restore-information info) (restore-list-buffer-information))
    (setf (restore-attributes info)
	  (delete nil
		  (mapcar
		   #'(lambda (x)
		       (if (find (caddr x) *restore-exceptional-tag-list*)
			   nil
			 x))
		   (list-text-attributes))))
    (setf (restore-global-mark info)
	  (delete nil (mapcar #'(lambda (m)
				  (and (eq (marker-buffer m) (selected-buffer))
				       (marker-point m)))
			      *global-mark-list*)))
    info))

;seesion.l より借用(↓)
(defun restore-list-buffer-information ()
  (list (point)
	(get-window-line)
	(cons buffer-mode
	      (mapcan #'(lambda (mode)
			  (let ((var (and (consp mode) (car mode))))
			    (and (symbolp var)
				 (boundp var)
				 (symbol-value var)
				 (list var))))
		      *minor-mode-alist*))
	(mapcar #'(lambda (var)
		    (and (symbolp var)
			 (local-variable-p var)
			 (cons var (symbol-value var))))
		*buffer-info-variable-list*)));(↑)

(defun restore-write (info)
  (let ((rdir *restore-directory*))
    (unless (file-directory-p *restore-directory*)
      (unless (yes-or-no-p "~A を作成しますか?" rdir)
	(return-from restore-write))
      (create-directory rdir)
      (message "~A を作成しました" rdir)))
  (let* ((file (get-buffer-file-name)) (dir (restore-directory file)))
    (create-directory dir :if-exists :skip)
    (with-open-file (s (restore-make-file file dir) :direction :output)
      (format s "~S" info)))
  )

(defun restore-delete-buffer-hook (buffer)
  (save-window-excursion
    (set-buffer buffer)
    (when (and (file-visited-p)
	       (file-exist-p (restore-file (get-buffer-file-name))))
      (unless (buffer-modified-p)
	(setf restore-info (restore-make-info)))
      (restore-write restore-info)))
  t)

(add-hook '*before-delete-buffer-hook* 'restore-delete-buffer-hook)

(defun restore-after-save-buffer-hook ()
  (when (and (file-visited-p)
	     (file-exist-p (restore-file (get-buffer-file-name))))
    (setf restore-info (restore-make-info))
    (restore-write restore-info))
  t)

(add-hook '*after-save-buffer-hook* 'restore-after-save-buffer-hook)

(defun restore-resume ()
  (run-hooks '*restore-before-resume-hook*)
  (let ((f (restore-file (get-buffer-file-name))))
    (when (file-exist-p f)
      (handler-case
	  (progn
	    (with-open-file (is f :direction :input)
	      (setq restore-info (read is)))
	    (let ((info restore-info))
	      (restore-resume-buffer-information (restore-information info))
	      (mapc #'(lambda (x) (apply #'set-text-attribute x))
		    (restore-attributes info))
	      (mapc #'(lambda (p)
			(save-excursion
			  (goto-char p)
			  (global-mark-add)))
		    (restore-global-mark info))))
	(error ()
	  (goto-char (point-min))
	  (recenter 0)
	  (clear-all-text-attributes)
	  (let ((cur (selected-buffer)))
	    (dolist (marker *global-mark-list*)
	      (when (eq (marker-buffer marker) cur)
		(delete-marker marker))))
	  (delete-file f)))))
  (run-hooks '*restore-after-resume-hook*)
  t)

;seesion.l より借用(↓)
(defun restore-resume-buffer-information (information)
  (let ((point (car information))
	(window-line (cadr information))
	(mode (caddr information))
	(minor nil))
    (when (listp mode)
      (setq minor (cdr mode))
      (setq mode (car mode)))
    (funcall mode)
    (goto-char point)
    (recenter window-line)
    (mapc #'(lambda (f) (and (fboundp f) (funcall f))) minor)
    (mapc #'(lambda (x)
	      (when (and (car x) (symbolp (car x)))
		(make-local-variable (car x))
		(set (car x) (cdr x))))
	  (cadddr information))
    ));(↑)

(add-hook '*find-file-hooks* 'restore-resume)

(defun restore-add-menu-item ()
  (let ((menu (get-menu *app-menu* 'view)))
    (add-menu-separator menu)
    (add-menu-item menu 'restore "リストア(&R)"
		   #'(lambda ()
		       (interactive)
		       (let ((file (restore-file (get-buffer-file-name))))
			 (if (file-exist-p file)
			     (delete-file file)
			   (progn
			     (setf restore-info (restore-make-info))
			     (restore-write restore-info)))))
		   #'(lambda ()
		       (if (file-visited-p)
			   (and (file-exist-p (restore-file
					       (get-buffer-file-name)))
				:check)
			 :disable)))))

(add-hook '*init-app-menus-hook* 'restore-add-menu-item)

;;;
