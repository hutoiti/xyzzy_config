;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: mail-view.l 779 2007-12-23 05:14:06Z torihat $
;
; junk/mail-view.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "junk/defs")
  (require "junk/macro"))

(require "junk/lib")
(require "junk/mail")

(provide "junk/mail-view")

(in-package "junk")

(defvar *mail-view-buffer*   "*Junk: Message View*")
(defvar *mail-view-source-buffer* "*Junk: Message Source*")

(defvar *mail-view-attachment-directory*
  (map-backslash-to-slash (get-special-folder-location :personal)))

(defvar *mail-view-mode-name* "MailMessage")
(defvar *mail-draft-mode-name* "MailMessage")
(defvar *mail-view-mode-hook* nil)

(defvar *mail-view-file-current* nil)
(defvar-local *mail-view-structure* nil)

(defvar *mail-view-attribute-header*
  (list
   (cons "date"     (cons (list :bold t :foreground 9)
			  (list :bold t :foreground 10)))
   (cons "from"     (cons (list :bold t :foreground 9)
			  (list :bold t :foreground 11)))
   (cons "to"       (cons (list :bold t :foreground 9)
			  (list :bold t :foreground 12)))
   (cons "cc"       (cons (list :bold t :foreground 9)
			  (list :bold t :foreground 13)))
   (cons "subject"  (cons (list :bold t :foreground 9)
			  (list :bold t :foreground 14)))
   (cons "reply-to" (cons (list :bold t :foreground 9)
			  (list :bold t :foreground 11)))
   ))

(defvar *mail-view-attribute-header-default*
  (cons (list :foreground 9)
	(list :foreground 15)))

(defvar *mail-view-attribute-part*
  (list :foreground 1))

(defvar *mail-view-header-field-list*
  '("date"
    "from"
    "subject"
    "to"
    "cc"
    "reply-to"
    "x-mailer"
    "user-agent"))

(defvar *mail-view-attribute-quote*
  (list (list :foreground 9)
	(list :foreground 10)
	(list :foreground 11)
	(list :foreground 12)))

;den8view.lより
(defvar *mail-view-regexp-quote* "^\\([ \t　]*[|>＞》]+\\|[A-Za-z0-9]+>\\)[ \t　|>＞》]*")
(defvar *mail-view-scroll-ratio* 2/3)

(defvar *mail-view-map* nil)
(unless *mail-view-map*
  (setq *mail-view-map* (make-sparse-keymap))
  (define-key *mail-view-map* #\SPC 'mail-view-scroll-forward)
  (define-key *mail-view-map* #\C-h 'mail-view-scroll-backward)
  (define-key *mail-view-map* #\s   'mail-view-save-attachment-select)
  (define-key *mail-view-map* #\x   'mail-view-save-execute-attachment-select)
  (define-key *mail-view-map* #\c   'mail-view-create)
  (define-key *mail-view-map* #\r   'mail-view-reply)
  (define-key *mail-view-map* #\a   'mail-view-reply-all)
  (define-key *mail-view-map* #\f   'mail-view-forward)
  (define-key *mail-view-map* #\F   'mail-view-forward-as-attachment)
  (define-key *mail-view-map* #\q   'mail-view-close)
  )

(defun mail-view-buffer-set ()
  (set-buffer (get-buffer-create *mail-view-buffer*)))

(defun mail-view-buffer-clear ()
  (let ((bufs (list *mail-view-buffer*
		    *mail-view-source-buffer*)))
    (dolist (buf bufs)
      (when (find-buffer buf)
	(delete-buffer buf)))))

#|
(defun mail-view-window-get ()
  (and (find-buffer *mail-view-buffer*)
       (get-buffer-window *mail-view-buffer*)))

(defun mail-view-window-set ()
  (let ((win (mail-view-window-get)))
    (if win
	(set-window win)
      (progn
	(summary-window-set)
	(split-window *summary-window-height*)
	(other-window 1)
	(mail-view-buffer-set)))))
|#

(defun mail-view-mode ()
  (interactive)
  (kill-all-local-variables)
  (setq mode-name *mail-view-mode-name*)
  (setq buffer-read-only t)
  (setq need-not-save t)
  (setq kept-undo-information nil)
  (setq auto-save nil)
  (toggle-ime nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-line-number* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-newline* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-eof* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-cursor-line* t)
  (set-buffer-fold-width t)
  (use-keymap *mail-view-map*)
  (run-hooks '*mail-view-mode-hook*))

(defun mail-view-source-buffer-set ()
  (set-buffer (get-buffer-create *mail-view-source-buffer*))
  (setq need-not-save t))

(defun mail-view-show (file)
  ;(mail-view-window-set)
  (setq *mail-view-file-current* file)
  (let (structure)
    (mail-view-source-buffer-set)
    (erase-buffer (selected-buffer))
    (insert-file-noconv file)
    (setq structure (mail-parse))
    (mail-view-buffer-set)
    (mail-view-mode)
    (setq *mail-view-structure* structure)
    (modify-read-only-buffer
      (erase-buffer (selected-buffer))
      (mail-view-print structure)
      (goto-char (point-min)))
    structure))

(defun mail-view-close ()
  (interactive)
  (mail-view-buffer-clear))

(defun mail-view-print (structure)
  (let ((header (mailstructure-headers structure)))
    (mail-view-print-header header)
    (mail-view-print-body structure)))

(defun mail-view-header-attribute (key)
  (cdr (assoc key *mail-view-attribute-header* :test #'equal)))

(defun mail-view-print-header (header)
  (dolist (field *mail-view-header-field-list*)
    (let* ((attrs (mail-view-header-attribute field))
	   (attr-field (car (or attrs *mail-view-attribute-header-default*)))
	   (attr-value (cdr (or attrs *mail-view-attribute-header-default*)))
	   (value (mail-get-header-value field header)))
      (when value
	(when (listp value)
	  (setq value (car value)))
	(apply #'set-text-attribute
	       (point)
	       (progn
		 (insert (format nil "~A: " (string-capitalize field)))
		 (point))
	       field
	       attr-field)
	(apply #'set-text-attribute
	       (point)
	       (progn
		 (if (listp value)
		     (insert (string-join value ", "))
		   (insert value))
		 (point))
	       field
	       attr-value)
	(insert "\n"))))
  (insert "\n"))

(defun mail-view-print-part (number header)
  (let* ((content-type (mail-get-header-content "content-type" header))
	 (mime-type (mail-get-content-mime-type content-type))
	 (charset (mail-get-content-charset content-type))
	 (encoding (mail-get-transfer-encoding header))
	 (filename (mail-get-filename header)))
    (apply #'set-text-attribute
	   (point)
	   (progn
	     (insert (format nil "[~@[~A:~]~@[ ~A~]~@[ <~A>~]~@[ [~A]~]~@[ (~A)~]]~%"
			     number
			     filename
			     mime-type
			     charset
			     encoding))
	     (point))
	   number
	   *mail-view-attribute-part*)))

(defun mail-view-print-body (structure &optional (print-part t))
  (let ((header (mailstructure-headers structure)))
    (if (mail-multipart-p header)
	(let ((childs (mailstructure-structure structure)))
	  (dolist (child childs)
	    (mail-view-print-body child print-part)))
      (let ((number (mailstructure-number structure))
	    (beg (mailstructure-beg structure))
	    (end (mailstructure-end structure))
	    (inline-p (mail-inline-p header))
	    cur
	    body)
	(when (and print-part
		   (or number
		       (not inline-p)))
	  (mail-view-print-part number header))
	(when inline-p
	  (setq cur (point))
	  (insert-buffer-substring *mail-view-source-buffer* beg end)
	  (mail-decode-encoding header cur (point))
	  (mail-view-quote cur (point-max))
	  )))
    ))

(defun mail-view-scroll-forward (&optional backward)
  (interactive "p")
  (refresh-screen)
  (if (if backward
	  (pos-visible-in-window-p (point-min))
	(pos-visible-in-window-p (point-max)))
      t
    (let ((nlines (max (truncate (* (window-height)
				    *mail-view-scroll-ratio*))
		       1)))
      (scroll-window (if backward
			 (- nlines)
		       nlines))
      nil)))

(defun mail-view-scroll-backward ()
  (interactive)
  (mail-view-scroll-forward t))

(defun mail-view-attribute-quote (num)
  (when *mail-view-attribute-quote*
    (let* ((len (list-length *mail-view-attribute-quote*))
	   (cur (mod num len)))
      (nth cur *mail-view-attribute-quote*))))

(defun mail-view-quote (beg end)
  (let (quotes)
    (save-excursion
      (save-restriction
	(goto-char beg)
	(narrow-to-region beg end)
	(while (scan-buffer *mail-view-regexp-quote* :regexp t :tail nil)
	  (let ((str (match-string 0))
		num
		tmp
		attr)
	    (setq str (string-trim " 　\t" str))
	    (if (setq tmp (member str quotes :test #'equal))
		(setq num (- (list-length quotes) (list-length tmp)))
	      (progn
		(setq num (list-length quotes))
		(setq quotes (append quotes (list str)))))
	    (when (setq attr (mail-view-attribute-quote num))
	      (apply #'set-text-attribute
		     (point)
		     (progn
		       (goto-eol)
		       (point))
		     nil
		     attr))))))))

(defun mail-view-save-execute-attachment-select ()
  (interactive)
  (mail-view-save-attachment-select t))

(defun mail-view-save-attachment-select (&optional execute)
  (interactive "p")
  (let ((attachments (mail-view-get-attachments)))
    (if attachments
	(let ((menu (create-popup-menu)))
	  (dolist (attach attachments)
	    (let ((number (car attach))
		  (filename (cdr attach))
		  (exec execute))
	      (add-menu-item menu
			     number
			     (concat number " " filename)
			     #'(lambda ()
				 (interactive)
				 (mail-view-save-attachment number exec)))))
	  (track-popup-menu menu))
      (junk-message "No attachments."))))

(defun mail-view-save-dialog (&optional filename)
  (let ((savefile (file-name-dialog
		   :title "ファイルの保存"
		   :default (and filename (merge-pathnames filename *mail-view-attachment-directory*))
		   :initial-directory *mail-view-attachment-directory*
		   :filter '(("すべてのファイル(*.*)" . "*.*")))))
    (when savefile
      (setq *mail-view-attachment-directory*
	    (directory-namestring savefile)))
    savefile))

(defun mail-view-save-attachment (part &optional execute savefile)
  (unless (mailstructure-p *mail-view-structure*)
    (return-from mail-view-save-attachment))
  (let ((structure (mail-view-get-part *mail-view-structure* part)))
    (if (mailstructure-p structure)
	(let* ((header (mailstructure-headers structure)))
	  (setq savefile
		(or savefile
		    (mail-view-save-dialog (mail-get-filename header))))
	  (when (and savefile
		     (mail-view-save-part structure savefile))
	    (junk-message "saved: ~A" savefile)
	    (when (and execute
		       (no-or-yes-p "ファイルを実行しますか？\n~A" savefile))
	      (shell-execute savefile nil))))
      (junk-error "part not found: ~S" part))))

(defun mail-view-save-part (structure file)
  (let* ((header (mailstructure-headers structure))
	 (beg (mailstructure-beg structure))
	 (end (mailstructure-end structure))
	 (encoding (mail-get-transfer-encoding header)))
    (save-excursion
      (mail-view-source-buffer-set)
      (cond ((equalp encoding "quoted-printable")
	     (quoted-printable-decode-region-to-file file beg end))
	    ((equalp encoding "base64")
	     (base64-decode-region-to-file file beg end))
	    (t
	     (write-region beg end file nil *encoding-sjis*))))))

(defun mail-view-get-part (structure part)
  (let ((number (mailstructure-number structure)))
    (if (equal number part)
	structure
      (let ((structures (mailstructure-structure structure)))
	(dolist (st structures)
	  (let ((stchild (mail-view-get-part st part)))
	    (when (mailstructure-p stchild)
	      (return-from mail-view-get-part stchild))))))))

(defun mail-view-get-attachments ()
  (unless (mailstructure-p *mail-view-structure*)
    (return-from mail-view-get-attachments))
  (mail-view-get-attachment-list *mail-view-structure*))

(defun mail-view-get-attachment-list (structure)
  (let ((header (mailstructure-headers structure))
	attachments)
    (if (mail-multipart-p header)
	(let ((childs (mailstructure-structure structure)))
	  (dolist (child childs)
	    (setq attachments
		  (append attachments (mail-view-get-attachment-list child)))))
      (let ((number (mailstructure-number structure))
	    (beg (mailstructure-beg structure))
	    (end (mailstructure-end structure))
	    (inline-p (mail-inline-p header))
	    cur
	    body)
	(when (and number
		   (not inline-p))
	  (push (cons number
		      (mail-view-part-filename header)) attachments))
	))
    attachments))

(defun mail-view-part-filename (header)
  (let* ((content-type (mail-get-header-content "content-type" header))
	 (mime-type (mail-get-content-mime-type content-type))
	 (charset (mail-get-content-charset content-type))
	 (encoding (mail-get-transfer-encoding header))
	 (filename (mail-get-filename header)))
    (or filename mime-type)))

(defun mail-view-get-body (structure)
  (let ((buf " *Junk: Body Temp*")
	body)
    (save-excursion
      (set-buffer (get-buffer-create buf))
      (erase-buffer (selected-buffer))
      (mail-view-print-body structure nil)
      (setq body (buffer-substring (point-min) (point-max))))
    (delete-buffer buf)
    body))

(defun mail-view-reply (&optional all)
  (interactive "p")
  (mail-draft-create-reply *mail-view-structure* all))

(defun mail-view-reply-all ()
  (interactive)
  (mail-draft-create-reply-all *mail-view-structure*))

(defun mail-view-forward ()
  (interactive)
  (let ((attachments (mail-view-autosave-attachments *mail-view-file-current*
						     *mail-view-structure*)))
    (mail-draft-create-forward *mail-view-structure*
			       attachments)))

(defun mail-view-forward-as-attachment ()
  (interactive)
  (mail-draft-create-forward-as-attachment *mail-view-structure*
					   *mail-view-file-current*))

(defvar *message-autosave-directory-suffix* "-attach")

(defun mail-view-autosave-directory (filename)
  (concat filename *message-autosave-directory-suffix*))

(defun mail-view-autosave-attachments (file structure)
  (let ((dir (mail-view-autosave-directory file))
	(as (mail-view-get-attachment-list structure))
	attachments)
    (when (and dir as)
      (create-directory-if dir)
      (dolist (a as)
	(let ((number (car a))
	      (file   (cdr a))
	      path)
	  (when (and file
		     (not (string-match "/" file)))
	    (setq path (merge-pathnames file dir))
	    (mail-view-save-attachment number nil path)
	    (push path attachments))))
      (nreverse attachments))))

(defun mail-view-cleanup-attachments (file)
  (let ((dir (mail-view-autosave-directory file))
	files)
    (unless (and (file-exist-p dir)
		 (file-directory-p dir))
      (return-from mail-view-cleanup-attachments))
    (setq files (directory dir
			   :file-only t
			   :absolute t))
    (when files
      (mapc #'(lambda (x)
		(delete-file x)
		(do-events)) files))
    (delete-directory dir)))

(defvar user::*test-mail-file* nil)

(defun user::test-mail-view-show ()
  (interactive)
  (let ((file (read-file-name "Mail: " :default user::*test-mail-file*)))
    (mail-view-show file)
    ))
