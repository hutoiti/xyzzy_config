;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: menu.l 731 2006-09-01 18:09:41Z torihat $
;
; rss/menu.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "rss/defs")
  (require "rss/macro"))

(provide "rss/menu")

(in-package "rss")

(defvar *rss-menu-clipboard* nil)

(defvar *rss-menu-map* (make-sparse-keymap))
(define-key *rss-menu-map* #\RET 'rss-open)
(define-key *rss-menu-map* #\SPC 'rss-open)
(define-key *rss-menu-map* #\Right 'rss-open)
(define-key *rss-menu-map* #\TAB 'rss-menu-search-next-unread)
(define-key *rss-menu-map* #\r 'rss-open-and-reload)
(define-key *rss-menu-map* #\n 'rss-menu-next)
(define-key *rss-menu-map* #\p 'rss-menu-prev)
(define-key *rss-menu-map* #\q 'rss-group-open)
(define-key *rss-menu-map* #\Left 'rss-group-open)
(define-key *rss-menu-map* #\a 'rss-menu-add)
(define-key *rss-menu-map* #\d 'rss-menu-del)
(define-key *rss-menu-map* #\C-k 'rss-menu-cut)
(define-key *rss-menu-map* #\C-y 'rss-menu-paste)
(define-key *rss-menu-map* #\o 'rss-open-site)
(define-key *rss-menu-map* #\m 'rss-menu-update)
(define-key *rss-menu-map* #\R 'rss-menu-update-all)
(define-key *rss-menu-map* #\v 'rss-popup-current-menu)
(define-key *rss-menu-map* #\V 'rss-popup-current-menu-and-copy)
(define-key *rss-menu-map* #\M-Right 'rss-open-group-next)
(define-key *rss-menu-map* #\M-Left 'rss-open-group-prev)
(define-key *rss-menu-map* #\M-t 'rss-toggle-online)
(define-key *rss-menu-map* #\b 'rss-open-clip)
(define-key *rss-menu-map* #\h 'rss-open-history)

(defun rss-menu-mode ()
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
  (set-local-window-flags (selected-buffer)
			  *window-flag-vscroll-bar* nil)
  (set-buffer-fold-width nil)
  (make-local-variable 'mode-line-format)
  (make-local-variable 'title-bar-format)
  (menu-mode-line)
  (use-keymap *rss-menu-map*)
  )

(defun rss-set-buffer-menu ()
  (set-buffer (get-buffer-create *rss-buffer-menu*)))

(defun menu-mode-line ()
  (setq mode-line-format (format nil "%b (~:[OFF~;ON~]LINE)" *online*))
  (setq title-bar-format (format nil "~A" *prog-name*)))

(defun menu-mode-line-update ()
  (when (find-buffer *rss-buffer-menu*)
    (save-excursion
      (rss-set-buffer-menu)
      (rss-menu-mode))))

(defun rss-menu-load ()
  (let (data)
    (unless (file-exist-p *rss-menu-file*)
      (return-from rss-menu-load))
    (with-open-file (s
		     *rss-menu-file*
		     :direction :input
		     :if-does-not-exist :error)
      (let (tmp)
	(while (setq tmp (read s nil))
	  (push tmp data))))
    (setq *rss-menu-data* (nreverse data))))

(defun rss-menu-save ()
  (with-open-file (s
		   *rss-menu-file*
		   :direction :output
		   :if-exists :overwrite
		   :if-does-not-exist :create)
    (format s "~{~S~%~}" *rss-menu-data*))
  t)

(defun rss-menu-print ()
  (let ((buffer-read-only nil))
    (declare (special buffer-read-only))
    (erase-buffer (selected-buffer))
    (apply #'set-text-attribute
	   (point)
	   (progn
	     (insert (format nil "~A~%"
			     (or (rss-group-name *rss-group-current*) *rss-group-default-name*)))
	     (point))
	   'rss-menu-title
	   *rss-attribute-menu-title*)
    (dolist (menu *rss-menu-data*)
      (insert " ")
      (let ((title (rss-title menu))
	    (number-all (rss-item-number-all menu))
	    (number-unread (rss-item-number-unread menu)))
	(apply #'set-text-attribute
	       (point)
	       (progn
		 (insert (format nil "~A~A~%" title
				 (if (and number-all number-unread)
				     (format nil " [~D/~D]"
					     number-unread
					     number-all)
				   "")))
		 (point))
	       'rss-menu
	       (if (and number-unread
			(< 0 number-unread))
		   *rss-attribute-menu-unread*
		 *rss-attribute-menu*))))
    (goto-line (rss-menu-number-to-line 0))))

(defun rss-menu-line-to-number (line-number)
  (- line-number 2))

(defun rss-menu-number-to-line (pos)
  (+ pos 2))

(defun rss-menu-current ()
  (let* ((num (current-line-number))
	 (pos (rss-menu-line-to-number num)))
    (when (<= 0 pos)
      (nth pos *rss-menu-data*))))

(defun rss-menu-delete (pos)
  (let ((len (length *rss-menu-data*))
	temp)
    (when (<= len pos)
      (return-from rss-menu-delete))
    (dotimes (i len)
      (unless (= i pos)
	(push (nth i *rss-menu-data*) temp)))
    (setq *rss-menu-data* (nreverse temp))))

(defun rss-delete-data-file (url &optional (delete-cache t))
  (let* ((file (rss-url-to-file url))
	 (cache (rss-file-to-cache file)))
    (when (and (or (file-exist-p file)
		   (file-exist-p cache))
	       (yes-or-no-p "Žæ“¾‚µ‚½ƒtƒ@ƒCƒ‹‚ðíœ‚µ‚Ü‚·‚©H"))
      (and (file-exist-p file)
	   (delete-file file))
      (and (file-exist-p cache)
	   delete-cache
	   (delete-file cache)))))

(defun rss-menu-insert (item &optional pos)
  (let ((len (length *rss-menu-data*))
	temp)
    (setq pos (if pos
		  (min pos len)
		len))
    (dotimes (i len)
      (when (= i pos)
	(push item temp))
      (push (nth i *rss-menu-data*) temp))
    (when (= pos len)
      (push item temp))
    (setq *rss-menu-data* (nreverse temp))))

(defun rss-item-create (url title &optional description siteurl item-number-all item-number-unread)
  (list (cons "link" url)
	(cons "title" title)
	(cons "description" description)
	(cons "url" siteurl)
	(cons "item-number-all" item-number-all)
	(cons "item-number-unread" item-number-unread)))

(defun rss-menu-exist (url)
  (member url *rss-menu-data* :test #'equal :key #'(lambda (x)
						     (rss-link x))))

(defvar *rss-menu-temp-buffer-suffix* "TEMPORARY")

(defun rss-menu-parse ()
  (let* (title
	 description
	 siteurl
	 items
	 (item-number-all 0)
	 (item-number-unread 0))
    (setq title (rss-title *rss-channel*))
    (setq description (rss-description *rss-channel*))
    (setq siteurl (rss-link *rss-channel*))
    (setq items *rss-item-list*)
    (setq item-number-all (length *rss-item-list*))
    (dolist (tmp *rss-item-list*)
      (let ((flags (cdr tmp)))
	(when (equal flags *rss-item-flags-unread*)
	  (incf item-number-unread))))
    (values title description siteurl items item-number-all item-number-unread)))

(defun rss-menu-add (url)
  (interactive "sURL: ")
  (let* ((item (rss-item-create url *rss-menu-temp-buffer-suffix*))
	 (num (current-line-number))
	 (pos (rss-menu-line-to-number num))
	 (buf (selected-buffer)))
    (when (rss-menu-exist url)
      (error "Šù‚É“o˜^‚³‚ê‚Ä‚¢‚Ü‚·: ~A" url))
    (save-excursion
      (rss-open-rss item)
      (multiple-value-bind (title
			    description
			    siteurl
			    items
			    item-number-all
			    item-number-unread)
	  (rss-menu-parse)
	(progn
	  (setq item (rss-item-create url title description siteurl item-number-all item-number-unread))
	  (delete-buffer (selected-buffer))
	  (rss-menu-insert item pos)
	  (rss-menu-save))))
    (set-buffer buf)
    (rss-menu-print)
    (goto-line num)))

(defun rss-menu-del ()
  (interactive)
  (let ((num (current-line-number))
	(pos (rss-menu-line-to-number (current-line-number)))
	(menu (rss-menu-current)))
    (save-excursion
      (rss-menu-delete pos)
      (rss-delete-data-file (rss-link menu))
      (rss-menu-save)
      (rss-menu-print))
    (goto-line num)))

(defun rss-clipboard-push (item)
  (push item *rss-menu-clipboard*))

(defun rss-clipboard-pop ()
  (pop *rss-menu-clipboard*))

(defun rss-menu-cut ()
  (interactive)
  (let* ((num (current-line-number))
	 (pos (rss-menu-line-to-number num))
	 (item (rss-menu-current)))
    (when item
      (rss-menu-delete pos)
      (rss-clipboard-push item)
      (rss-menu-save)
      (rss-menu-print)
      (goto-line num))))

(defun rss-menu-paste ()
  (interactive)
  (let* ((num (current-line-number))
	 (pos (rss-menu-line-to-number num))
	 (item (rss-clipboard-pop)))
    (when item
      (rss-menu-insert item pos)
      (rss-menu-print)
      (rss-menu-save)
      (goto-line num))))

(defun rss-reverse-menu ()
  (clear-reverse-region)
  (reverse-region (progn (goto-eol) (point))
		  (progn (goto-bol) (point))))

(defun rss-menu-update-all ()
  (interactive)
  (let ((num (current-line-number))
	(cur (selected-buffer))
	errors)
    (dotimes (i (length *rss-menu-data*))
      (let ((line (rss-menu-number-to-line i)))
	(goto-line line)
	(rss-reverse-menu)
	(refresh-screen)
	(let ((buf (concat *rss-buffer-prefix* "UPDATEALLTEMP*")))
	  (save-excursion
	    (set-buffer (get-buffer-create buf))
	    (erase-buffer (selected-buffer))
	    (unwind-protect
		(handler-case
		    (let* ((item (nth i *rss-menu-data*))
			   (obuf (rss-buffer-title (rss-title item))))
		      (rss-fetch-data item t)
		      (when (find-buffer obuf)
			(delete-buffer obuf))
		      )
		  (error (c)
		    (push (format nil "Error: ~S:~%~A"
				  (rss-title (nth i *rss-menu-data*))
				  (si:*condition-string c))
			  errors)))
	      (delete-buffer buf)
	      )))
	(set-buffer cur)	; ‚±‚¤‚µ‚È‚¢‚Æ–ß‚Á‚Ä‚±‚ê‚È‚¢H
	))
    (clear-reverse-region)
    (goto-line num)
    (when errors
      (error "~{-- ~%~A~%~}" (nreverse errors)))))

(defun rss-menu-search-next-unread ()
  (interactive)
  (let* ((num (current-line-number))
	 (pos (min (rss-menu-line-to-number num)) 0)
	 (len (length *rss-menu-data*))
	 (start (rss-menu-number-to-line 0)))
    (dotimes (i len)
      (let* ((jpos (mod (+ i pos) len))
	     (jnum (rss-menu-number-to-line jpos))
	     (item (nth jpos *rss-menu-data*))
	     (item-number-unread (rss-item-number-unread item)))
	(when (and item-number-unread
		   (< 0 item-number-unread))
	  (goto-line jnum)
	  (rss-reverse-menu)
	  (refresh-screen)
	  (rss-open)
	  (and (rss-search-next-unread)
	       (return-from rss-menu-search-next-unread t)))))
    (clear-reverse-region)
    (goto-line num)
    (rss-group-open)
    ;;; interactive‚ÉŒÄ‚Î‚ê‚½ê‡‚ÍŽŸ‚ð’T‚·
    (if (and (interactive-p)
	     *rss-search-next-unread-group*)
	(call-interactively 'rss-group-search-next-unread)
      nil)))

(defun rss-open (&optional force)
  (interactive "p")
  (let ((item (rss-menu-current)))
    (unless item
      (return-from rss-open))
    (rss-reverse-menu)
    (rss-menu-split-window)
    (setq *rss-current-channel* item)
    (rss-open-rss item (or force *online*))))

(defun rss-open-and-reload ()
  (interactive)
  (rss-open t))

(defun rss-open-site ()
  (interactive)
  (let* ((item (rss-menu-current))
	 (siteurl (rss-siteurl item)))
    (unless siteurl
      (return-from rss-open-site))
    (rss-open-url-in-other-browser siteurl)))

(defun rss-menu-update ()
  (interactive)
  (let* ((item (rss-menu-current))
	 (num (current-line-number))
	 (pos (rss-menu-line-to-number num))
	 (url (rss-link item)))
    (unless url
      (return-from rss-menu-update))
    (save-excursion
      (rss-open-rss item)
      (multiple-value-bind (title
			    description
			    siteurl
			    items
			    item-number-all
			    item-number-unread)
	  (rss-menu-parse)
	(progn
	  (setq item (rss-item-create url
				      (or title (rss-title item))
				      (or description (rss-delete-data-file item))
				      (or siteurl (rss-siteurl item))
				      item-number-all
				      item-number-unread))
	  (setf (nth pos *rss-menu-data*) item)
	  (rss-menu-save)))
      (delete-buffer (selected-buffer))
      (rss-group-current-update))
    (rss-menu-print)
    (goto-line num)))

(defun rss-menu-rewrite ()
  (save-excursion
    (rss-set-buffer-menu)
    (let ((pos (point)))
      (rss-menu-print)
      (goto-char pos))))

(defun rss-menu-replace (item)
  (let ((url (rss-link item)))
    (dotimes (i (length *rss-menu-data*))
      (when (equal url
		   (rss-link (nth i *rss-menu-data*)))
	(setf (nth i *rss-menu-data*) item)
	(return)))
    (rss-menu-save)))

(defun rss-menu-next (&optional (arg 1))
  (interactive)
  (or (forward-line arg) (return-from rss-menu-next))
  (let ((item (rss-menu-current)))
    (if item
	(rss-open)
      (progn
	(rss-reverse-menu)
	(rss-menu-only)))))

(defun rss-menu-prev ()
  (interactive)
  (rss-menu-next -1))

(defun rss-menu-open ()
  (rss-menu-load)
  (rss-set-buffer-menu)
  (rss-menu-mode)
  (rss-menu-print))
