;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: main.l 731 2006-09-01 18:09:41Z torihat $
;
; rss/main.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "rss/defs")
  (require "rss/macro"))

(require "rss/parse")
(require "rss/menu")
(require "rss/group")
(require "rss/http")
(require "rss/window")
(require "rss/open")
(require "rss/rss")
(require "rss/filter")
(require "rss/format")
(require "rss/clip")
(require "rss/history")

(provide "rss/main")

(in-package "rss")

(defun load-config ()
  (junk::load-config-file *rss-config-file*))

(defun frame-set ()
  (setq *pframe-old* (ed::pseudo-frame-name (selected-pseudo-frame)))
  (new-pseudo-frame *pframe-name*))

(defun frame-get ()
  (find-pseudo-frame *pframe-name*))

(defun hide ()
  (interactive)
  (let ((old (find-pseudo-frame *pframe-old*)))
    (when old
      (select-pseudo-frame old))))

(defun rss-buffer-p (bufname)
  (string-match (concat "^" (regexp-quote *rss-buffer-prefix*)) bufname))

(defun rss-buffer-visible-some ()
  (some
   (lambda (x)
     (rss-buffer-p (buffer-name (cadr x))))
   (caddr (current-window-configuration))))

(defun register-pframe-selected-fn ()
  (setf (ed::pseudo-frame-selected-fn (find-pseudo-frame *pframe-name*))
	(lambda ()
	  (unless (rss-buffer-visible-some)
	    (delete-other-windows)
	    (if (find-buffer *rss-buffer-group*)
		(set-buffer *rss-buffer-group*)
	      (progn
		(delete-pseudo-frame (frame-get))
		(user::rss)))))))

(defun restore ()
  (interactive)
  (let ((frame (frame-get)))
    (if frame
	(select-pseudo-frame frame)
      (user::rss))))

(defun rss-finish ()
  (interactive)
  (let ((frame (frame-get)))
    (rss-menu-only)
    (dolist (buf (buffer-list))
      (let ((bufname (buffer-name buf)))
	(when (rss-buffer-p bufname)
	  (delete-buffer buf))))
    (when frame
      (delete-pseudo-frame frame)))
  (run-hooks '*rss-finish-hook*))

(defun rss-toggle-online (&optional arg sv)
  (interactive)
  (ed::toggle-mode '*online* arg sv)
  (menu-mode-line-update)
  (group-mode-line-update))

(defun user::rss-add-feed (url)
  (interactive "sURL: " :default0 (let ((data (get-clipboard-data)))
				    (when (string-match "^http://[^ \t\n]+" data)
				      (match-string 0))))
  (user::rss)
  (let* ((gname (completing-read "Group: "
				 (mapcar #'(lambda (x)
					     (rss-group-name x))
					 *rss-group-list*)
				 :must-match t))
	 (group (assoc gname *rss-group-list* :test #'equal)))
    (when (and group
	       (find-buffer *rss-buffer-group*))
      (rss-group-open)
      (delete-other-windows)
      (rss-group-open-1 group)
      (goto-char (point-max))
      (rss-menu-add url))))

(defun user::rss-toggle ()
  (interactive)
  (if (equal *pframe-name*
	     (ed::pseudo-frame-name (selected-pseudo-frame)))
      (hide)
    (restore)))

(defun user::rss ()
  (interactive)
  (when (frame-get)
    (restore)
    (return-from user::rss))
  (frame-set)
  (rss-load-filters)
  (load-config)
  (rss-load-clip)
  (rss-load-history)
  (rss-group-open)
  (register-pframe-selected-fn)
  (run-hooks '*rss-start-hook*))
