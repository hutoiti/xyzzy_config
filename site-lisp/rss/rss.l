;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: rss.l 731 2006-09-01 18:09:41Z torihat $
;
; rss/rss.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "rss/defs")
  (require "rss/macro"))

(provide "rss/rss")

(in-package "rss")

(defvar *rss-mode-map* (make-sparse-keymap))
(define-key *rss-mode-map* #\RET    'rss-jump)
(define-key *rss-mode-map* #\Right  'rss-jump)
(define-key *rss-mode-map* #\@      'rss-clip-current-item)
(define-key *rss-mode-map* #\TAB    'rss-search-next-unread)
(define-key *rss-mode-map* #\Down   'rss-item-next)
(define-key *rss-mode-map* #\C-n    'rss-item-next)
(define-key *rss-mode-map* #\Up     'rss-item-prev)
(define-key *rss-mode-map* #\C-p    'rss-item-prev)
(define-key *rss-mode-map* #\n      'rss-jump-next)
(define-key *rss-mode-map* #\p      'rss-jump-prev)
(define-key *rss-mode-map* #\t      'rss-item-toggle-unread)
(define-key *rss-mode-map* #\T      'rss-item-all-read)
(define-key *rss-mode-map* #\d      'rss-item-toggle-description)
(define-key *rss-mode-map* #\o      'rss-jump-in-other-browser)
(define-key *rss-mode-map* #\q      'rss-close)
(define-key *rss-mode-map* #\Left   'rss-close)
(define-key *rss-mode-map* #\r      'rss-reload)
(define-key *rss-mode-map* #\R      'rss-refetch)
(define-key *rss-mode-map* #\c      'rss-close-browser)
(define-key *rss-mode-map* #\M-Down 'rss-close-and-next-menu)
(define-key *rss-mode-map* #\M-Up   'rss-close-and-prev-menu)
(define-key *rss-mode-map* #\SPC    'rss-jump-or-scroll)
(define-key *rss-mode-map* #\C-Down 'rss-browser-scroll-down)
(define-key *rss-mode-map* #\C-Up   'rss-browser-scroll-up)
(define-key *rss-mode-map* #\C-h    'rss-jump-prev-or-scroll-up)
(define-key *rss-mode-map* #\v      'rss-popup-current-item)
(define-key *rss-mode-map* #\V      'rss-popup-current-item-and-copy)
(define-key *rss-mode-map* #\M-t    'rss-toggle-online)
(define-key *rss-mode-map* #\b      'rss-open-clip)
(define-key *rss-mode-map* #\h      'rss-open-history)

(defun rss-mode ()
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
			  *window-flag-tab* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-just-inverse* t)
  (set-buffer-fold-width t)
  (make-local-variable 'mode-line-format)
  (make-local-variable 'title-bar-format)
  (use-keymap *rss-mode-map*))

(defun rss-mode-line ()
  (setq mode-line-format (format nil "%b - ~A" (rss-link *rss-current-channel*)))
  (setq title-bar-format (format nil "~A" *prog-name*)))

(defun rss-set-buffer (name)
  (set-buffer (get-buffer-create name)))

(defun rss-pos-list-add (pos)
  (setq *rss-pos-list*
	(append *rss-pos-list*
		(list pos))))

(defun rss-item-next ()
  (interactive)
  (let* ((pos (point))
	 (next (find-if #'(lambda (x)
			    (< pos x))
			*rss-pos-list*)))
    (when next
      (clear-reverse-region)
      (goto-char next)
      (recenter *rss-recenter-param*))))

(defun rss-item-prev ()
  (interactive)
  (let* ((pos (point))
	 (prev (find-if #'(lambda (x)
			    (> pos x))
			(reverse *rss-pos-list*))))
    (when prev
      (clear-reverse-region)
      (goto-char prev)
      (recenter *rss-recenter-param*))))

(defun rss-print-channel ()
  (rss-pos-list-add (point))
  (apply #'set-text-attribute
	 (point)
	 (progn
	   (insert (format nil "~@[~A~]~%"
			   (rss-title *rss-channel*)))
	   (point))
	 'rss-channel
	 *rss-attribute-channel-title*)
  ;(insert "\t")
  (apply #'set-text-attribute
	 (point)
	 (progn
	   (insert (string-trim " \t\n\r" (format nil "~@[~A~]" (rss-description *rss-channel*))))
	   (insert "\n")
	   (point))
	 'rss-channel
	 *rss-attribute-channel-description*)
  )

(defun rss-print-item (item-cons num)
  (let* ((item (car item-cons))
	 (flags (cdr item-cons))
	 title
	 description
	 (site (rss-item-site item))
	 (title-attribute (if flags
			      *rss-attribute-item-title*
			    *rss-attribute-item-title-unread*)))
    (setq title (string-trim " \t\r\n"
			     (format nil "~@[[~A] ~]~@[~A~]"
				     (rss-date item)
				     (rss-title item)
				     )))
    (rss-pos-list-add (point))
    (apply #'set-text-attribute
	   (point)
	   (progn
	     (insert title)
	     (insert "\n")
	     (point))
	   num
	   title-attribute)
    (when *rss-item-show-description*
      (setq description (string-trim " \t\r\n" (format nil "~@[~A~]" (rss-description item))))
      (apply #'set-text-attribute
	     (point)
	     (progn
	       (insert description)
	       (insert "\n")
	       (point))
	     num
	     *rss-attribute-item-description*))
    (when site
      (apply #'set-text-attribute
	     (point)
	     (progn
	       (insert (format nil "[~A]~%" site))
	       (point))
	     num
	     *rss-attribute-item-site*))
    ))

(defun rss-print-items ()
  (let ((len (length *rss-item-list*))
	(width 0))
    (setq *rss-pos-list* nil)
    (refresh-screen)
    (setq width (- (window-width) 3))
    (rss-print-channel)
    (insert "=" width)
    (insert "\n")
    (dotimes (i len)
      (let ((j (- len 1 i)))
	(rss-print-item (nth j *rss-item-list*) j)
	(insert "-" width)
	(insert "\n")))))

(defun rss-url-http-p (url)
  (string-match "^http://" url))

(defun rss-url-local-p (url)
  (or (string-match "^[a-zA-Z]:/" url)
      (string-match "^//" url)))

(defun rss-url-to-file (url)
  (cond ((or (rss-url-http-p url)
	     (rss-url-local-p url))
	 (merge-pathnames
	  (concat (substitute-string
		   (substitute-string
		    (string-trim " \n" (si:base64-encode url))
		    "\n"
		    "")
		   "/"
		   "_")
		  ".rss")
	  *rss-directory*))))

(defun rss-file-to-cache (file)
  (concat file ".cache"))

(defun rss-popup-current-menu-and-copy ()
  (interactive)
  (rss-popup-current-menu t))

(defun rss-popup-current-menu (&optional copy-p)
  (interactive "p")
  (let ((item (rss-menu-current))
	text)
    (when item
      (setq text (rss-item-text-format item))
      (when copy-p
	(copy-to-clipboard text))
      (popup-string text (point)))))

(defun rss-refetch ()
  (interactive)
  (rss-delete-data-file (rss-link *rss-current-channel*) nil)
  (rss-reload))

(defun rss-reload ()
  (interactive)
  (rss-open-rss *rss-current-channel* t))

(defun rss-buffer-title (title)
  (concat *rss-buffer-prefix* title))

(defun rss-save-cache (file channel item-list)
  (junk::data-write-to-file file
			    (list channel item-list)))

(defun rss-load-cache (file)
  (values-list (junk::data-read-from-file file)))

(defun rss-item-equal (a b)
  (if *rss-search-unread-with-updated*
      (rss-item-equal-all a b)
    (rss-item-equal-id a b)))

(defun rss-item-equal-id (a b)
  (let ((id (rss-id a)))
    (if id
	(equal id (rss-id b))
      (equal (rss-link a)
	     (rss-link b)))))

(defun rss-item-equal-all (a b)
  (equal a b))

(defun rss-fetch-data (item force)
  (let* ((url (rss-link item))
	 (title (rss-title item))
	 (file (rss-url-to-file url))
	 (cache (rss-file-to-cache file))
	 xml
	 old-channel
	 old-item-list)
    (save-excursion
      (when (file-exist-p cache)
	(multiple-value-setq (old-channel old-item-list)
	  (rss-load-cache cache)))
      (if (or (rss-fetch item force)
	      (not (file-exist-p cache)))
	  (progn
	    (setq xml (xmlpm-parse-file file))
	    (setq *rss-channel* nil)
	    (setq *rss-item-list* nil)
	    (rss-parse xml)
	    (when old-item-list
	      ;; ä˘ì«èÓïÒÇà⁄ÇµïœÇ¶
	      (dotimes (i (length *rss-item-list*))
		(let* ((temp (car (nth i *rss-item-list*)))
		       (old (assoc temp old-item-list :test #'rss-item-equal)))
		  (when (cdr old)
		    (setf (cdr (nth i *rss-item-list*)) *rss-item-flags-read*))))
	      ;; *rss-cache-max-number* Ç‹Ç≈ï€ë∂
	      (let ((olist old-item-list))
		(dolist (tempitem (reverse old-item-list))
		  (unless (< (length *rss-item-list*) *rss-cache-max-number*)
		    (return))
		  (let ((temp (car tempitem)))
		    (unless (assoc temp *rss-item-list* :test #'rss-item-equal-id)
		      (push tempitem *rss-item-list*))))
		))
	    (rss-save-cache cache *rss-channel* *rss-item-list*)
	    (rss-item-update-menu item)
	    (run-hooks '*rss-fetch-data-hook*))
	(when (and old-channel old-item-list)
	  (setq *rss-channel* old-channel)
	  (setq *rss-item-list* old-item-list))))))

(defun rss-item-update-menu (item)
  (multiple-value-bind (title
			description
			siteurl
			items
			item-number-all
			item-number-unread)
      (rss-menu-parse)
    (progn
      (setq item
	    (rss-item-create (rss-link item)
			     (or title (rss-title item))
			     (or description (rss-description item))
			     (or siteurl (rss-siteurl item))
			     item-number-all
			     item-number-unread))
      (rss-menu-replace item)
      (rss-menu-rewrite)
      (rss-group-current-update))))

(defun rss-open-rss (item &optional force)
  (let* ((url (rss-link item))
	 (title (rss-title item))
	 (file (rss-url-to-file url))
	 (cache (rss-file-to-cache file))
	 (buf (rss-buffer-title title))
	 (buf-exist (find-buffer buf))
	 res)
    (rss-set-buffer (rss-buffer-title title))
    (when (and buf-exist
	       (not force))
      (return-from rss-open-rss))
    (unwind-protect
	(let ((buffer-read-only nil))
	  (declare (special buffer-read-only))
	  (rss-fetch-data item force)
	  (unless (and *rss-channel*
		       *rss-item-list*)
	    (error "could not load data"))
	  (erase-buffer (selected-buffer))
	  (rss-print-items))
      (progn
	(rss-mode)
	;(setq *rss-current-channel* item)
	(rss-mode-line)
	(goto-char (point-min))
	(run-hooks '*rss-open-rss-hook*)
	(rss-item-next))
      )))

(defun rss-rewrite ()
  (let ((buffer-read-only nil))
    (declare (special buffer-read-only))
    (erase-buffer (selected-buffer))
    (rss-print-items)))

(defun rss-in-channel-p ()
  (<= (current-line-number) 3))

(defun rss-item-current ()
  (let (item flags num)
    (multiple-value-bind (from to tag foreground background bold underline strike-out prefix extend)
	(find-text-attribute-point (point))
      (cond ((numberp tag)
	     (let ((targ (nth tag *rss-item-list*)))
	       (setq item (car targ))
	       (setq flags (cdr targ))
	       (setq num tag)))
	    ((equal tag 'rss-channel)
	     (setq item *rss-channel*))
	    (t
	     )))
    (values item flags num)))

(defun rss-popup-current-item-and-copy ()
  (interactive)
  (rss-popup-current-item t))

(defun rss-popup-current-item (&optional copy-p)
  (interactive "p")
  (let ((item (rss-item-current))
	text)
    (when item
      (setq text (rss-item-text-format item))
      (when copy-p
	(copy-to-clipboard text))
      (popup-string text (point)))))

(defun rss-item-text-format (item)
  (format nil "~A~@[~%~A~]~@[~%~%~A~]"
	  (rss-title item)
	  (rss-link item)
	  (rss-description item)))

(defun rss-item-go (num)
  (let (pos)
    (save-excursion
      (goto-char (point-min))
      (multiple-value-bind (from to tag)
	  (find-text-attribute num)
	(setq pos from)))
    (when pos
      (goto-char pos)
      (recenter *rss-recenter-param*))))

(defun rss-item-toggle-unread ()
  (interactive)
  (multiple-value-bind (item flags num)
      (rss-item-current)
    (when (and item num)
      (rss-item-set-flag num (not flags))
      (rss-rewrite)
      (rss-item-update-menu *rss-current-channel*)
      (rss-item-go num))))

(defun rss-item-all-read (&optional reverse)
  (interactive "p")
  (rss-item-set-flag-all (if reverse
			     *rss-item-flags-unread*
			   *rss-item-flags-read*))
  (multiple-value-bind (item flags num)
      (rss-item-current)
    (progn
      (rss-rewrite)
      (rss-item-update-menu *rss-current-channel*)
      (rss-item-go (or num
		       (1- (length *rss-item-list*)))))))

(defun rss-item-toggle-description ()
  (interactive)
  (setq *rss-item-show-description*
	(not *rss-item-show-description*))
  (multiple-value-bind (item flags num)
      (rss-item-current)
    (progn
      (rss-rewrite)
      (rss-item-go (or num
		       (1- (length *rss-item-list*)))))))

(defun rss-search-next-unread ()
  (interactive)
  (multiple-value-bind (curitem flags num)
      (rss-item-current)
    (let ((len (length *rss-item-list*))
	  nth)
      (when (< 0 len)
	(or num (setq num (1- len)))
	(dotimes (i len)
	  (let ((j (mod (+ (- len i) num) len)))
	    (when (rss-item-flags-unread-p (cdr (nth j *rss-item-list*)))
	      (rss-item-go j)
	      (when *rss-search-next-unread-open*
		(rss-jump))
	      (return-from rss-search-next-unread t)))))
      ;;; åªç›ÇÃchannelÇ≈ÇÕå©Ç¬Ç©ÇÁÇ»Ç©Ç¡ÇΩ
      (rss-close-browser)
      (rss-close)
      ;;; interactiveÇ…åƒÇŒÇÍÇΩèÍçáÇÕéüÇíTÇ∑
      (if (and (interactive-p)
	       *rss-search-next-unread-menu*)
	  (call-interactively 'rss-menu-search-next-unread)
	nil))))

(defun rss-item-flags-read-if ()
  (multiple-value-bind (item flags num)
      (rss-item-current)
    (when (and item
	       num
	       (rss-item-flags-unread-p flags))
      (rss-item-set-flag num *rss-item-flags-read*)
      (rss-rewrite)
      (rss-item-update-menu *rss-current-channel*)
      (rss-item-go num))))

(defun rss-item-flags-unread-p (flags)
  (equal flags *rss-item-flags-unread*))

(defun rss-item-flags-read-p (flags)
  (equal flags *rss-item-flags-read*))

(defun rss-item-set-flag (num flags &optional (save-cache t))
  (setf (cdr (nth num *rss-item-list*)) flags)
  (when save-cache
    (rss-save-current-channel)))

(defun rss-item-set-flag-all (flags &optional (save-cache t))
  (dotimes (num (length *rss-item-list*))
    (setf (cdr (nth num *rss-item-list*)) flags))
  (when save-cache
    (rss-save-current-channel)))

(defun rss-save-current-channel ()
  (let ((cache (rss-file-to-cache (rss-url-to-file (rss-link *rss-current-channel*)))))
    (when cache
      (rss-save-cache cache *rss-channel* *rss-item-list*))
    cache))

(defun rss-jump ()
  (interactive)
  (let ((targ (rss-item-current))
	link)
    (when targ
      (rss-item-flags-read-if)
      (unless (assoc "site" targ :test #'equal)
	(push (cons "site" (rss-title *rss-channel*)) targ))
      (rss-history-add targ)
      (if (setq link (rss-link targ))
	  (rss-open-url link)
	(message "No URL."))
      (recenter *rss-recenter-param*)
      (run-hooks '*rss-jump-hook*))))

(defun rss-jump-in-other-browser ()
  (interactive)
  (let ((targ (rss-item-current))
	link)
    (when targ
      (rss-item-flags-read-if)
      (when (setq link (rss-link targ))
	(rss-open-url-in-other-browser link)))))

(defun rss-open-url-in-other-browser (url)
  (when url
    (shell-execute url t)))

(defun rss-line-to-number (num)
  (- num 4))

(defun rss-reverse-item ()
  (let* ((pos (point))
	 (beg (find-if #'(lambda (x)
			   (<= x  pos))
		       (reverse *rss-pos-list*))))
    (when beg
      (multiple-value-bind (from to tag foreground background bold underline strike-out prefix extend)
	  (find-text-attribute-point beg)
	(progn
	  (clear-reverse-region)
	  (reverse-region from to))))))

(defun rss-jump-or-scroll ()
  (interactive)
  (if (rss-browser-open-p)
      (rss-browser-scroll-down)
    (rss-jump)))

(defun rss-jump-prev-or-scroll-up ()
  (interactive)
  (if (rss-browser-open-p)
      (rss-browser-scroll-up)
    (rss-jump-prev)))

(defun rss-jump-next ()
  (interactive)
  (let ((pos (point)))
    (rss-item-next)
    (unless (equal pos (point))
      (rss-jump))))

(defun rss-jump-prev ()
  (interactive)
  (let ((pos (point)))
    (rss-item-prev)
    (unless (equal pos (point))
      (rss-jump))))

(defun rss-close-and-next-menu ()
  (interactive)
  (rss-close)
  (rss-menu-next))

(defun rss-close-and-prev-menu ()
  (interactive)
  (rss-close)
  (rss-menu-prev))

(defun rss-clip-current-item ()
  (interactive)
  (let ((item (rss-item-current)))
    (when item
      (push (cons "site" (rss-title *rss-channel*)) item)
      (rss-clip-add item))))
