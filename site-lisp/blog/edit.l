;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: edit.l 493 2006-01-09 18:17:36Z torihat $
;
; blog/edit.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "blog/defs"))

(provide "blog/edit")

(in-package "blog")

(defvar *edit-key-list*
  '((nil             . "本文")
    (mt_excerpt      . "概要")
    (mt_text_more    . "追記")
    (mt_tb_ping_urls . "TrackBack送信先URL")))

(unless *edit-map*
  (setq *edit-map* (make-sparse-keymap))
  (define-key *edit-map* '(#\C-c #\q) 'edit-close)
  )

(defun edit-mode (&optional key)
  (setq need-not-save t)
  (setq auto-save nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-line-number* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-newline* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-eof* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-cursor-line* t)
  (set-local-window-flags (selected-buffer)
			  *window-flag-vscroll-bar* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-ruler* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-just-inverse* t)
  (set-buffer-fold-width t)
  (set-buffer-fileio-encoding *encoding-utf8n*)
  (make-local-variable 'mode-line-format)
  (make-local-variable 'title-bar-format)
  (edit-mode-line)
  (set-edit-mode key)
  (cond ((eq key 'mt_tb_ping_urls)
	 (define-key *edit-map* '(#\C-x #\C-s) 'edit-save-mt_tb_ping_urls))
	(t
	 (define-key *edit-map* '(#\C-x #\C-s) #'(lambda ()
						   (interactive)
						   (edit-save key)))))
  (set-minor-mode-map *edit-map*)
  (run-hooks '*blog-edit-mode-hook*)
  )

(defun set-buffer-edit ()
  (set-buffer (get-buffer-create *buffer-edit*)))

(defun set-edit-mode (key)
  (funcall (cond ((eq key 'mt_excerpt)
		  *edit-mt_excerpt-mode*)
		 ((eq key 'mt_text_more)
		  *edit-mt_text_more-mode*)
		 ((eq key 'mt_tb_ping_urls)
		  *edit-mt_tb_ping_urls-mode*)
		 (t
		  *edit-description-mode*))))

(defun edit-mode-line ()
  )

(defun edit-print (&optional key)
  (erase-buffer (selected-buffer))
  (clear-all-text-attributes)
  (insert (format nil "[~@[~A~]]~%" (cdr (assoc key *edit-key-list*))))
  (insert (format nil "~@[~A~]" (cond ((eq key 'mt_excerpt)
				       (blogpost-mt_excerpt *post-data*))
				      ((eq key 'mt_text_more)
				       (blogpost-mt_text_more *post-data*))
				      ((eq key 'mt_tb_ping_urls)
				       (format nil "~{~A~%~}" (blogpost-mt_tb_ping_urls *post-data*)))
				      (t
				       (blogpost-description *post-data*)))))
  (goto-char (point-min))
  (forward-line 1)
  (run-hooks '*blog-edit-print-hook*))

(defun edit-close ()
  (interactive)
  (set-buffer-post))

(defun edit-save (&optional key)
  (interactive)
  (cond ((eq key 'mt_excerpt)
	 (setf (blogpost-mt_excerpt *post-data*)
	       (edit-gettext)))
	((eq key 'mt_text_more)
	 (setf (blogpost-mt_text_more *post-data*)
	       (edit-gettext)))
	(t
	 (setf (blogpost-description *post-data*)
	       (edit-gettext))))
  (edit-close)
  (post-reprint))

(defun edit-save-mt_tb_ping_urls ()
  (interactive)
  (let ((tbstr (edit-gettext)))
    (when tbstr
      (setq trackbacks (split-string tbstr "\n"))
      (setf (blogpost-mt_tb_ping_urls *post-data*) trackbacks)
      (edit-close)
      (post-reprint))))

(defun edit-gettext ()
  (let ((text ""))
    (save-excursion
      (goto-char (point-min))
      (when (forward-line)
	(setq text (buffer-substring (point)
				     (point-max)))))
    text))
