;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: title.l 590 2006-02-04 20:11:42Z torihat $
;
; blog/title.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "blog/defs"))

(provide "blog/title")

(in-package "blog")

(unless *title-map*
  (setq *title-map* (make-sparse-keymap))
  (define-key *title-map* #\RET 'post-show)
  (define-key *title-map* #\SPC 'post-show)
  (define-key *title-map* #\n 'post-new)
  (define-key *title-map* #\d 'title-del)
  (define-key *title-map* #\r 'title-reload)
  (define-key *title-map* #\q 'title-close)
)

(defun title-mode ()
  (setq need-not-save t)
  (setq buffer-read-only t)
  (setq kept-undo-information nil)
  (setq auto-save nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-line-number* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-newline* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-eof* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-cursor-line* t)
;  (set-local-window-flags (selected-buffer)
;			  *window-flag-vscroll-bar* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-ruler* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-just-inverse* t)
  (set-buffer-fold-width nil)
  (set-buffer-fileio-encoding *encoding-utf8n*)
  (make-local-variable 'mode-line-format)
  (make-local-variable 'title-bar-format)
  (title-mode-line)
  (use-keymap *title-map*)
  (run-hooks '*blog-title-mode-hook*)
  )

(defun title-window-split ()
  (title-window-set)
  (split-window *title-window-height*)
  (other-window 1))

(defun title-window-set ()
  (interactive)
  (menu-window-split)
  (set-buffer-title))

(defun set-buffer-title ()
  (set-buffer (get-buffer-create *buffer-title*)))

(defun title-mode-line ()
  (menu-mode-line))

(defun title-mode-line-update ()
  (save-excursion
    (set-buffer-title)
    (title-mode-line)))

(defun title-date-format (date)
  (format-date-string *title-date-format* date))

(defun title-print ()
  (modify-read-only-buffer
   (erase-buffer (selected-buffer))
   (clear-all-text-attributes)
   (dolist (title *title-data*)
     (let ((dateCreated (blogtitle-dateCreated title))
	   (title (blogtitle-title title)))
       (when dateCreated
	 (apply #'set-text-attribute
		(point)
		(progn
		  (insert (format nil " ~A" (title-date-format dateCreated)))
		  (point))
		'title
		*attribute-title-date*))
       (apply #'set-text-attribute
	      (point)
	      (progn
		(insert (format nil " ~A"
				(substitute-string title
						   "[\r\n]"
						   " ")))
		(point))
	      'title
	      *attribute-title-title*)
       (insert "\n")))
   (goto-char (point-min)))
  (run-hooks '*blog-title-print-hook*))

(defvar *title-line-diff* 1)

(defun title-line-to-number (line-number)
  (- line-number *title-line-diff*))

(defun title-number-to-line (pos)
  (+ pos *title-line-diff*))

(defun title-current ()
  (let ((num (current-line-number)))
    (cond ((<= 1 num)
	   (nth (title-line-to-number num) *title-data*))
	  (t
	   nil))))

(defun title-delete (post)
  (let ((type (blog-blogtype-get *menu-current*)))
    (apply (blogtype-deletepost type)
	   (list *menu-current*
		 post
		 t))))

(defun title-reload ()
  (interactive)
  (set-buffer-title)
  (save-excursion
    (title-fetch)
    (title-print)))

(defun title-del ()
  (interactive)
  (let ((num (current-line-number))
	(pos (title-line-to-number (current-line-number)))
	(title (title-current)))
    (when (and title
	       (yes-or-no-p "~S‚ðíœ‚µ‚Ü‚·‚©H"
			    (blogtitle-title title)))
      (title-delete title)
      (title-reload)
      (goto-line num))))

(defun title-open (blog)
  (title-window-set)
  (unless (equal blog *menu-current*)
    (setq *menu-current* blog)
    (title-mode)
    (title-fetch)
    (title-print)
    (goto-line 1))
  (run-hooks '*blog-title-open-hook*))

(defun title-fetch ()
  (let ((type (blog-blogtype-get *menu-current*)))
    (setq *title-data* (apply (blogtype-gettitles type)
			      (list *menu-current*)))
    ))

(defun title-close ()
  (interactive)
  (menu-window-only))
