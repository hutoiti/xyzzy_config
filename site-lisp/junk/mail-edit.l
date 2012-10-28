;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: mail-edit.l 779 2007-12-23 05:14:06Z torihat $
;
; junk/mail-edit.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "junk/defs")
  (require "junk/macro"))

(require "junk/lib")
(require "junk/mail")

(require "junk/mail-view")
(require "junk/mail-address")
(require "junk/mail-signature")

(provide "junk/mail-edit")

(in-package "junk")

(defstruct maildraft
  header
  body
  body-header
  attachments
  boundary
  )

(defvar *mail-draft-buffer*      "*Junk: Message Draft*")
(defvar *mail-draft-temp-buffer* "*Junk: Message Draft Temp*")
(defvar *mail-edit-buffer*       "*Junk: Message Edit*")
(defvar *mail-save-buffer*       "*Junk: Message Save*")

(defvar *mail-draft-attachment-directory*
  (map-backslash-to-slash (get-special-folder-location :personal)))

(defvar *mail-draft-mode-name* "MailDraft")
(defvar *mail-draft-mode-hook* nil)

(defvar-local *mail-draft-file-name* nil)

(defvar *mail-draft-content-type-default* "text/plain; charset=iso-2022-jp")
(defvar *mail-draft-mime-version-default* "1.0")

(defvar *mail-draft-attachment-encoding* "base64")

(defvar *mail-draft-header-default-fields*
  '("from" "to" "subject"))

(defvar *mail-draft-header-default-values*
  (list (cons "content-type" *mail-draft-content-type-default*)
	(cons "mime-version" *mail-draft-mime-version-default*)))

(defvar *mail-draft-current* nil)

(defvar *mail-draft-winconf* nil)

(defvar *mail-draft-quote-string* "> ")
(defvar *mail-draft-subject-reply-prefix* "Re: ")
(defvar *mail-draft-subject-forward-prefix* "Fw: ")
(defvar *mail-draft-body-reply-prefix* "-- \n")

(defvar *mail-draft-create-pre-hook* nil)
(defvar *mail-draft-create-post-hook* nil)

(defvar *mail-draft-header-field-list*
  '("from" "to" "cc" "bcc" "subject"))

(defvar *mail-draft-header-field-list-quote*
  '("date" "from" "to" "cc" "subject"))

(defvar *mail-draft-line-string* "-")

(defvar *mail-draft-edit-window-height-adjust* 2)

(defvar *mail-draft-attribute-body* nil)

(defvar *mail-draft-map* nil)
(unless *mail-draft-map*
  (setq *mail-draft-map* (make-sparse-keymap))
  (define-key *mail-draft-map* #\RET          'mail-draft-edit-current)
  (define-key *mail-draft-map* #\d            'mail-draft-delete-current)
  (define-key *mail-draft-map* #\s            'mail-draft-edit-subject)
  (define-key *mail-draft-map* #\f            'mail-draft-edit-from)
  (define-key *mail-draft-map* #\e            'mail-draft-edit-body)
  (define-key *mail-draft-map* #\t            'mail-draft-add-to)
  (define-key *mail-draft-map* #\T            'mail-draft-add-to-dialog)
  (define-key *mail-draft-map* #\c            'mail-draft-add-cc)
  (define-key *mail-draft-map* #\C            'mail-draft-add-cc-dialog)
  (define-key *mail-draft-map* #\b            'mail-draft-add-bcc)
  (define-key *mail-draft-map* #\B            'mail-draft-add-bcc-dialog)
  (define-key *mail-draft-map* #\m            'mail-draft-edit-content-type)
  (define-key *mail-draft-map* #\a            'mail-draft-add-attachments)
  (define-key *mail-draft-map* #\A            'mail-draft-add-attachment-directory)
  ;(define-key *mail-draft-map* '(#\C-c #\C-c) 'mail-draft-send)
  ;(define-key *mail-draft-map* '(#\C-x #\C-s) 'mail-draft-save)
  (define-key *mail-draft-map* #\q            'mail-draft-close)
  )

(defun mail-draft-buffer-set ()
  (set-buffer (get-buffer-create *mail-draft-buffer*)))

(defun mail-draft-temp-buffer-set ()
  (set-buffer (get-buffer-create *mail-draft-temp-buffer*))
  (setq need-not-save t))

(defun mail-draft-header-set (header field value)
  (let (old)
    (if (setq old (mail-get-header-value field header))
	(setf (mail-get-header-value field header)
	      (if (listp old)
		  (append old (list value))
		(list old value)))
      (push (cons field value) header))
    header))

(defun mail-draft-header-add-or-replace (header field value)
  (let (old)
    (if (setq old (mail-get-header-value field header))
	(setf (mail-get-header-value field header) value)
      (push (cons field value) header))
    header))

(defun mail-draft-body-quote (body)
  (unless (stringp body)
    (return-from mail-draft-body-quote))
  (with-output-to-string (s)
    (let ((lines (split-string body "\n" t)))
      (dolist (line lines)
	(format s "~A~A~%"
		*mail-draft-quote-string*
		line)))))

(defun mail-draft-mode ()
  (interactive)
  (kill-all-local-variables)
  (setq mode-name *mail-draft-mode-name*)
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
  (use-keymap *mail-draft-map*)
  (make-local-variable 'mode-line-format)
  (run-hooks '*mail-draft-mode-hook*))

(defun mail-draft-mode-line ()
  (setq mode-line-format (format nil "%b: ~@[~A~]" *mail-draft-file-name*)))

(defun mail-draft-boundary-string ()
  (format nil "~A_~8,'0X~8,'0X.~8,'0X"
	  *mail-draft-mode-name*
	  (get-universal-time)
	  (random #x7fffffff)
	  (get-internal-real-time)))

(defun mail-draft-set-default-values (draft)
  (let ((header (maildraft-header draft)))
    (dolist (h *mail-draft-header-default-values*)
      (let ((field (car h))
	    (value (cdr h)))
	(setq header (mail-draft-header-add-or-replace header field value))))
    (dolist (field *mail-draft-header-default-fields*)
      (unless (mail-get-header-value field header)
	(setq header (mail-draft-header-add-or-replace header field nil))))
    (setf (maildraft-header draft) header)
    draft))

(defun mail-draft-winconf-save ()
  (setq *mail-draft-winconf*
	(current-window-configuration)))

(defun mail-draft-winconf-restore ()
  (when *mail-draft-winconf*
    (set-window-configuration *mail-draft-winconf*)
    (setq *mail-draft-winconf* nil)))

(defun mail-draft-from-message (file &optional structure attachments)
  (let (parsed)
    (unless structure
      (setq structure (mail-view-show file))
      (setq attachments
	    (mail-view-autosave-attachments file structure)))
    (let (header
	  body)
      (when structure
	(setq header (mailstructure-headers structure))
	(setq body (mail-view-get-body structure)))
      (mail-draft-create (make-maildraft
			  :header header
			  :body body))
      (when attachments
	(dolist (a attachments)
	  (mail-draft-add-attachment a))
	(mail-draft-refresh))
      )))

(defun mail-draft-make-default ()
  (let ((header (list (cons "from" (mail-draft-from-default)))))
    (make-maildraft :header header)))

(defun mail-draft-create (&optional draft)
  (interactive)
  (mail-draft-winconf-save)
  (if draft
      (setq *mail-draft-current* draft)
    (setq *mail-draft-current* (mail-draft-make-default)))
  (setq *mail-draft-current*
	(mail-draft-set-default-values *mail-draft-current*))
  (run-hooks '*mail-draft-create-pre-hook*)
  (mail-draft-buffer-set)
  (mail-draft-mode)
  (mail-draft-print)
  (run-hooks '*mail-draft-create-post-hook*))

(defun mail-draft-save ()
  (interactive)
  )

(defun mail-draft-refresh ()
  (let ((line (current-line-number)))
    (mail-draft-print)
    (goto-line line)))

(defun mail-draft-print ()
  (refresh-screen)
  (let ((width (- (window-width) 10))
	(header (maildraft-header *mail-draft-current*))
	(body (maildraft-body *mail-draft-current*))
	(attachments (maildraft-attachments *mail-draft-current*)))
    (modify-read-only-buffer
      (erase-buffer (selected-buffer))
      (mail-draft-print-header header)
      (insert *mail-draft-line-string* width)
      (insert "\n")
      (when attachments
	(mail-draft-print-attachments attachments)
	(insert *mail-draft-line-string* width)
	(insert "\n"))
      (when body
	(let ((cur (point)))
	  (apply #'set-text-attribute
		 (point)
		 (progn
		   (insert body)
		   (point))
		 'body
		 *mail-draft-attribute-body*)
	  (goto-char cur)))
      (mail-draft-mode-line)
      )))

(defun mail-draft-print-attachments (attachments)
  (mail-draft-print-header-line "attachments"
			   (mapcar #'car attachments)))

(defun mail-draft-print-header (header)
  (dolist (field *mail-draft-header-field-list*)
    (let* ((value (mail-get-header-value field header)))
      (mail-draft-print-header-line field value))))

(defun mail-draft-print-header-line (field value)
  (let* ((attrs (mail-view-header-attribute field))
	 (attr-field (car (or attrs *mail-view-attribute-header-default*)))
	 (attr-value (cdr (or attrs *mail-view-attribute-header-default*))))
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
	     (when value
	       (if (listp value)
		   (let ((delim (concat "\n"
					(substitute-string field "." " ")
					"  ")))
		     (insert (string-join value delim)))
		 (insert (format nil "~@[~A~]" value))))
	     (point))
	   field
	   attr-value)
    (insert "\n")))

(defun mail-draft-body-start-point ()
  (multiple-value-bind (from to tag)
      (find-text-attribute 'body)
    (or from
	(point-max))))

(defun mail-draft-body-current-point ()
  (let ((cur (point))
	(beg 0))
    (multiple-value-bind (from to tag)
	(find-text-attribute 'body)
      (setq beg (or from
		    (point-max))))
    (max 0
	 (- cur beg))))

(defun mail-draft-body-start-line ()
  (let ((pos (mail-draft-body-start-point)))
    (when pos
      (save-excursion
	(goto-char pos)
	(current-line-number)))))

(defun mail-draft-print-header-quote (header)
  (dolist (field *mail-draft-header-field-list-quote*)
    (let* ((value (mail-get-header-value field header)))
      (when value
	(mail-draft-print-header-line field value)))))

(defun mail-draft-get-forward-body (structure)
  (mail-draft-get-reply-body structure nil))

(defun mail-draft-get-reply-body (structure &optional (quote-p t))
  (let* ((header (mailstructure-headers structure))
	 (body (mail-view-get-body structure))
	 (buf " *Junk: Reply Temp*")
	 str)
    (unwind-protect
	(save-excursion
	  (set-buffer (get-buffer-create buf))
	  (erase-buffer (selected-buffer))
	  (insert *mail-draft-body-reply-prefix*)
	  (mail-draft-print-header-quote header)
	  (insert "\n")
	  (when body
	    (insert (if quote-p
			(mail-draft-body-quote body)
		      body)))
	  (setq str (buffer-substring (point-min) (point-max))))
      (delete-buffer buf))
    str))

(defun mail-draft-subject-reply (subject)
  (setq subject (or subject ""))
  (unless (string-matchp "^re:" subject)
    (setq subject (concat *mail-draft-subject-reply-prefix* subject)))
  subject)

(defun mail-draft-subject-forward (subject)
  (setq subject (or subject ""))
  (unless (string-matchp "^fw:" subject)
    (setq subject (concat *mail-draft-subject-forward-prefix* subject)))
  subject)

(defun mail-draft-from-default ()
  (let ((addr (cond ((listp *mail-from-address*)
		     (if (consp (car *mail-from-address*))
			 (car *mail-from-address*)
		       *mail-from-address*))
		    (t
		     nil))))
    (when addr
      (format-address (car addr) (cdr addr)))))

(defun mail-draft-create-reply-all (structure)
  (mail-draft-create-reply structure t))

(defun mail-draft-create-reply (structure &optional all)
  (let* ((old-header (mailstructure-headers structure))
	 (old-from (mail-get-header-value "from" old-header))
	 (old-to (mail-get-header-value "to" old-header))
	 (old-cc (mail-get-header-value "cc" old-header))
	 (old-reply-to (mail-get-header-value "reply-to" old-header))
	 (old-subject (mail-get-header-value "subject" old-header))
	 (old-msgid (mail-get-header-value "message-id" old-header))
	 (old-ref (mail-get-header-value "references" old-header))
	 (to (or old-reply-to old-from))
	 cc
	 references
	 (subject (mail-draft-subject-reply old-subject))
	 (from (mail-draft-from-default))
	 (body (mail-draft-get-reply-body structure))
	 (header (list (cons "subject" subject)
		       (cons "to" to)
		       (cons "from" from)
		       )))
    (when all
      (let ((to-addr-list (rfc822-parse-address to))
	    cc-addr-list)
	(dolist (f (list old-to old-cc))
	  (dolist (a (if (stringp f) (list f) f))
	    (dolist (addr (parse-addresses a))
	      (let ((email (car addr))
		    (name  (cdr addr)))
		(unless (or (member email to-addr-list :test #'equalp)
			    (member email cc-addr-list :test #'equalp))
		  (push (format-address email name) cc)
		  (push email cc-addr-list)))))))
      (when cc
	(push (cons "cc" cc) header)))
    (when old-msgid
      (push (cons "in-reply-to" old-msgid) header)
      (push (cons "references"
		  (format nil "~@[~A~% ~]~A"
			  old-ref
			  old-msgid)) header))
    (mail-draft-create (make-maildraft :header (reverse header)
			      :body body))
    (goto-char (mail-draft-body-start-point))))

(defun mail-draft-create-forward (structure &optional attachments)
  (let* ((old-header (mailstructure-headers structure))
	 (old-subject (mail-get-header-value "subject" old-header))
	 (old-msgid (mail-get-header-value "message-id" old-header))
	 (old-ref (mail-get-header-value "references" old-header))
	 references
	 (subject (mail-draft-subject-forward old-subject))
	 (from (mail-draft-from-default))
	 (body (mail-draft-get-reply-body structure nil))
	 (header (list (cons "subject" subject)
		       (cons "from" from)
		       )))
    (when old-msgid
      (push (cons "in-reply-to" old-msgid) header)
      (push (cons "references"
		  (format nil "~@[~A~% ~]~A"
			  old-ref
			  old-msgid)) header))
    (mail-draft-create (make-maildraft :header (reverse header)
			      :body body))
    (when attachments
      (dolist (a attachments)
	(mail-draft-add-attachment a))
      (mail-draft-refresh))
    (goto-char (mail-draft-body-start-point))))

(defun mail-draft-create-forward-as-attachment (structure file)
  (let* ((old-header (mailstructure-headers structure))
	 (old-subject (mail-get-header-value "subject" old-header))
	 (old-msgid (mail-get-header-value "message-id" old-header))
	 (old-ref (mail-get-header-value "references" old-header))
	 references
	 (subject (mail-draft-subject-forward old-subject))
	 (from (mail-draft-from-default))
	 (header (list (cons "subject" subject)
		       (cons "from" from)
		       )))
    (when old-msgid
      (push (cons "in-reply-to" old-msgid) header)
      (push (cons "references"
		  (format nil "~@[~A~% ~]~A"
			  old-ref
			  old-msgid)) header))
    (mail-draft-create (make-maildraft :header (reverse header)))
    (mail-draft-add-attachment file
			  (list (cons "content-type" "message/rfc822")))
    ;(mail-draft-attachment-header file "message/rfc822"))
    (mail-draft-refresh)
    (goto-char (mail-draft-body-start-point))))

(defun mail-draft-close (&optional force)
  (interactive "p")
  (when (or force
	    (yes-or-no-p "Draftを破棄してもよろしいですか？"))
    (mail-draft-winconf-restore)
    (delete-buffer *mail-draft-buffer*)))

(defun mail-draft-add-header-addr-dialog (field)
  (let ((header (maildraft-header *mail-draft-current*)))
    (mail-address-dialog)
    (when *mail-address-dialog-result-list*
      (dolist (address *mail-address-dialog-result-list*)
	(setq header (mail-draft-header-set header
				       field
				       (format-address (mailaddress-email address)
						       (mailaddress-name  address)))))
      (setf (maildraft-header *mail-draft-current*) header)
      (mail-draft-refresh))))

(defun mail-draft-add-header-addr (field &optional value)
  (let* ((header (maildraft-header *mail-draft-current*)))
    (setq value
	  (or value
	      (mail-address-complete
	       (format nil "~A: " (string-capitalize field))
	       (mail-get-header-value field header))))
    (when value
      (let ((address (mail-address-get value)))
	(setq header (mail-draft-header-set header
				       field
				       (if address
					   (format-address (mailaddress-email address)
							   (mailaddress-name  address))
					 value)))
	(setf (maildraft-header *mail-draft-current*) header)
	(mail-draft-refresh)))))

(defun mail-draft-delete-header-addr (field)
  (let* ((header (maildraft-header *mail-draft-current*))
	 (value (mail-get-header-value field header)))
    (when (stringp value)
      (mail-draft-delete-header-addr-value field value)
      (return-from mail-draft-delete-header-addr))
    (when (listp value)
      (let ((menu (create-popup-menu)))
	(dolist (addr value)
	  (let ((a addr)
		(f field))
	    (add-menu-item menu
			   nil
			   addr
			   #'(lambda ()
			       (interactive)
			       (mail-draft-delete-header-addr-value f a)))))
	(track-popup-menu menu)))))

(defun mail-draft-delete-header-addr-value (field addr)
  (let* ((header (maildraft-header *mail-draft-current*))
	 (value (mail-get-header-value field header)))
    (unless value
      (return-from mail-draft-delete-header-addr-value))
    (if (listp value)
	(setq header
	      (mail-draft-header-add-or-replace header
					   field
					   (delete addr value :test #'equal)))
      (if (stringp value)
	  (setq header
		(mail-draft-header-add-or-replace header
					     field
					     nil))))
    (setf (maildraft-header *mail-draft-current*) header)
    (mail-draft-refresh)))

(defun mail-draft-edit-header-string (field &optional value)
  (let* ((header (maildraft-header *mail-draft-current*)))
    (setq value
	  (or value
	      (read-string (format nil "~A: " (string-capitalize field))
			   :default (mail-get-header-value field header))))
    (when value
      (setq header (mail-draft-header-add-or-replace header field value))
      (setf (maildraft-header *mail-draft-current*) header)
      (mail-draft-refresh))))

(defun mail-draft-edit-subject ()
  (interactive)
  (mail-draft-edit-header-string "subject"))

(defun mail-draft-edit-content-type ()
  (interactive)
  (mail-draft-edit-header-string "content-type"))

#|
(defun mail-draft-edit-from ()
  (interactive)
  (mail-draft-edit-header-string "from"))
|#

(defun mail-draft-edit-from (&optional edit-p)
  (interactive "p")
  (when edit-p
    (mail-draft-edit-header-string "from")
    (return-from mail-draft-edit-from))
  (unless (and (listp *mail-from-address*)
	       (consp (car *mail-from-address*)))
    (return-from mail-draft-edit-from))
  (let ((menu (create-popup-menu)))
    (dolist (f *mail-from-address*)
      (let* ((email (car f))
	     (name  (cdr f))
	     (from (format-address email name)))
	(add-menu-item menu
		       nil
		       from
		       #'(lambda ()
			   (interactive)
			   (mail-draft-edit-header-string "from" from)))
	))
    (track-popup-menu menu)))

(defun mail-draft-add-to ()
  (interactive)
  (mail-draft-add-header-addr "to"))

(defun mail-draft-add-to-dialog ()
  (interactive)
  (mail-draft-add-header-addr-dialog "to"))

(defun mail-draft-add-cc ()
  (interactive)
  (mail-draft-add-header-addr "cc"))

(defun mail-draft-add-cc-dialog ()
  (interactive)
  (mail-draft-add-header-addr-dialog "cc"))

(defun mail-draft-add-bcc ()
  (interactive)
  (mail-draft-add-header-addr "bcc"))

(defun mail-draft-add-bcc-dialog ()
  (interactive)
  (mail-draft-add-header-addr-dialog "bcc"))

(defun mail-draft-edit-body ()
  (interactive)
  (let ((line (mail-draft-body-start-line))
	(pos (mail-draft-body-current-point)))
    (mail-edit-window-create (- line *mail-draft-edit-window-height-adjust*))
    (mail-edit-buffer-create *mail-draft-current* pos)))

(defun mail-draft-edit-current ()
  (interactive)
  (multiple-value-bind (from to tag foreground background bold underline strike-out prefix extend)
      (find-text-attribute-point (point))
    (cond ((equal tag "subject")
	   (mail-draft-edit-subject))
	  ((equal tag "from")
	   (mail-draft-edit-from))
	  ((or (equal tag "to")
	       (equal tag "cc")
	       (equal tag "bcc"))
	   (mail-draft-add-header-addr tag))
	  (t
	   (mail-draft-edit-body)))))

(defun mail-draft-delete-current ()
  (interactive)
  (multiple-value-bind (from to tag foreground background bold underline strike-out prefix extend)
      (find-text-attribute-point (point))
    (cond ((or (equal tag "to")
	       (equal tag "cc")
	       (equal tag "bcc"))
	   (mail-draft-delete-header-addr tag))
	  ((equal tag "attachments")
	   (mail-draft-delete-attachment))
	  (t
	   nil))))

(defun mail-draft-add-attachments (&optional archive-p)
  (interactive "p")
  (let ((odir (default-directory))
	ndir
	files)
    (set-default-directory *mail-draft-attachment-directory*)
    (setq files
	  (file-name-dialog :title "添付ファイルの追加"
			    :must-exist t
			    :multiple t
			    :filter '(("すべてのﾌｧｲﾙ(*.*)" . "*.*"))))
    (when files
      (setq *mail-draft-attachment-directory*
	    (directory-namestring (car files))))
    (if archive-p
	(let ((archive (mail-draft-attachments-archive-create files)))
	  (when (and archive
		     (file-exist-p archive))
	    (mail-draft-add-attachment archive)))
      (dolist (file files)
	(mail-draft-add-attachment file)))
    (mail-draft-refresh)
    (set-default-directory odir)
    (message "attachments added: ~S" files)
    ))

(defun mail-draft-attachments-archive-create (files)
  (let* ((odir (default-directory))
	 (default (car files))
	 (path (directory-namestring (car files)))
	 (archive (mail-draft-attachment-archive-filename
		   (merge-pathnames
		    (concat (pathname-name default) "." *mail-draft-attachment-archive-suffix*)
		    path))))
    (when (and archive files)
      (create-archive archive
		      files
		      path)
      archive)))

(defun mail-draft-attachment-archive-filename (&optional default)
  (let ((odir (default-directory))
	(path (directory-namestring default))
	archive)
    (set-default-directory path)
    (unwind-protect
	(setq archive
	      (file-name-dialog :title "アーカイブファイル名"
				:save t
				:filter *file-dialog-filter*
				:filter-index *file-dialog-filter-index*
				:overwrite t
				:hide-read-only t
				:default default))
      (set-default-directory odir))
    archive
    ))

(defvar *mail-draft-attachment-archive-suffix* "zip")

(defun mail-draft-add-attachment-directory ()
  (interactive)
  (let ((dir (directory-name-dialog :title "フォルダ指定"
				    :default *mail-draft-attachment-directory*))
	archive
	files)
    (unless dir
      (return-from mail-draft-add-attachment-directory))
    (setq archive (mail-draft-attachment-archive-filename
		   (merge-pathnames
		    (concat (pathname-name dir) "." *mail-draft-attachment-archive-suffix*)
		    (merge-pathnames ".." dir))))
    (setq files (directory dir
			   :absolute t
			   :file-only t
			   :recursive t))
    (when (and archive files)
      (create-archive archive
		      files
		      dir)
      (mail-draft-add-attachment archive)
      (mail-draft-refresh))))

(defun mail-draft-attachment-header (file &optional content-type)
  (let ((filename (file-namestring file)))
    (setq content-type (or content-type
			   (file-content-type file)))
    (list (cons "content-type" content-type)
	  (cons "content-disposition" (format nil "attachment; filename=\"~A\"" filename))
	  (cons "content-transfer-encoding" *mail-draft-attachment-encoding*))))

(defun mail-draft-add-attachment (file &optional attach-header)
  (let* ((header (maildraft-header *mail-draft-current*))
	 (attachments (maildraft-attachments *mail-draft-current*))
	 attach
	 boundary
	 content-type
	 )
    (setq attach-header
	  (or attach-header
	      (mail-draft-attachment-header file)))
    (setq attach (cons file attach-header))
    (unless attachments
      (setq boundary (mail-draft-boundary-string))
      (setq content-type
	    (mail-get-header-value "content-type" header))
      (setf (maildraft-body-header *mail-draft-current*)
	    (list (cons "content-type" content-type)))
      (setq header
	    (mail-draft-header-add-or-replace header
					 "content-type"
					 (format nil "multipart/mixed; boundary=\"~A\""
						 boundary)))
      (setf (maildraft-header *mail-draft-current*) header)
      (setf (maildraft-boundary *mail-draft-current*) boundary))
    (setq attachments
	  (append attachments (list attach)))
    (setf (maildraft-attachments *mail-draft-current*) attachments)
    ))


(defun mail-draft-delete-attachment ()
  (interactive)
  (let* ((attachments (maildraft-attachments *mail-draft-current*)))
    (when (listp attachments)
      (when (= 1 (list-length attachments))
	(mail-draft-delete-attachment-file (car (car attachments)))
	(return-from mail-draft-delete-attachment))
      (let ((menu (create-popup-menu)))
	(dolist (attachment attachments)
	  (let ((f (car attachment))
		(h (cdr attachment)))
	    (add-menu-item menu
			   nil
			   f
			   #'(lambda ()
			       (interactive)
			       (mail-draft-delete-attachment-file f)))))
	(track-popup-menu menu)))))

(defun mail-draft-delete-attachment-file (file)
  (let* ((attachments (maildraft-attachments *mail-draft-current*)))
    (unless (and file attachments)
      (return-from mail-draft-delete-attachment-file))
    (setq attachments
	  (delete file attachments :test #'equalp :key #'car))
    (unless attachments
      (let* ((header (maildraft-header *mail-draft-current*))
	     (body-header (maildraft-body-header *mail-draft-current*))
	     (content-type (mail-get-header-value "content-type" body-header)))
	(setq header
	      (mail-draft-header-add-or-replace header
					   "content-type"
					   (or content-type
					       *mail-draft-content-type-default*)))
	(setf (maildraft-header *mail-draft-current*) header)
	(setf (maildraft-body-header *mail-draft-current*) nil)
	(setf (maildraft-boundary *mail-draft-current*) nil)))
    (setf (maildraft-attachments *mail-draft-current*) attachments)
    (mail-draft-refresh)))

(defun mail-draft-header-set-before-send ()
  (mail-draft-header-date-set))

(defun mail-draft-header-date-set ()
  (let ((header (maildraft-header *mail-draft-current*)))
    (setq header
	  (mail-draft-header-add-or-replace header
				       "date"
				       (rfc822-format-date-local)))
    (setf (maildraft-header *mail-draft-current*) header)))

(defun mail-draft-header-x-mailer-set (user-agent)
  (let ((header (maildraft-header *mail-draft-current*)))
    (setq header
	  (mail-draft-header-add-or-replace header "x-mailer" user-agent))
    (setf (maildraft-header *mail-draft-current*) header)))

(defun mail-draft-check ()
  (let ((header (maildraft-header *mail-draft-current*))
	(fields '("from" "to" "subject"))
	(body (maildraft-body *mail-draft-current*))
	(attachments (maildraft-attachments *mail-draft-current*))
	(result t)
	error-message)
    (setq error-message
	  (with-output-to-string (s)
	    (dolist (field fields)
	      (unless (mail-get-header-value field header)
		(format s "~Aがありません。" (string-capitalize field))
		(setq result nil)))
	    (unless body
	      (format s "本文がありません。")
	      (setq result nil))
	    (when attachments
	      (dolist (attachment attachments)
		(let ((file (car attachment)))
		  (unless (file-exist-p file)
		    (format s "添付ファイルが存在しません: ~A" file)))))
	    ))
    (unless result
      (junk-error "~A" error-message))))

(defun mail-draft-add-addresses ()
  (let ((header (maildraft-header *mail-draft-current*)))
    (dolist (f (list "to" "cc" "bcc"))
      (let ((val (mail-get-header-value f header)))
	(dolist (a (if (stringp val)
		       (list val)
		     val))
	  (when a
	    (multiple-value-bind (email name)
		(parse-address a)
	      (when (and email
			 (not (mail-address-get email)))
		(mail-address-push email name *mail-address-group-default*)))))))))

#|
(defun mail-draft-send (&optional force)
  (interactive)
  (mail-draft-check)
  (unless (or force
	      (yes-or-no-p "送信しますか？"))
    (return-from mail-draft-send))
  (mail-draft-header-set-before-send)
  (send-buffer-create *mail-draft-current*)
  (multiple-value-bind (flag return)
      (send-buffer-send)
    (if flag
	(progn
	  (send-buffer-save-and-clear)
	  (mail-draft-add-addresses)
	  (mail-draft-history-delete-current)
	  (mail-draft-close)
	  (junk-message "message sent."))
      (junk-error "SMTP Error: ~A" (if return return "unknown")))))
|#

;;;
;;; Edit body
;;;
(defvar *mail-edit-major-mode* 'text-mode)
(defvar *mail-edit-mode-hook* nil)

(defvar *mail-edit-winconf* nil)

(defvar *mail-edit-map* nil)
(unless *mail-edit-map*
  (setq *mail-edit-map* (make-sparse-keymap))
  (define-key *mail-edit-map* '(#\C-c #\q)   'mail-edit-close)
  (define-key *mail-edit-map* '(#\C-x #\C-s) 'mail-edit-save)
  (define-key *mail-edit-map* #\M-Insert     'mail-edit-signature-open)
  )

(defun mail-edit-mode (&optional key)
  (kill-all-local-variables)
  (setq mode-name *prog-name*)
  (make-local-variable 'mail-edit-draft-current)
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
			  *window-flag-vscroll-bar* t)
  (set-local-window-flags (selected-buffer)
			  *window-flag-ruler* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-just-inverse* t)
  (set-buffer-fold-width nil)
  (make-local-variable 'mode-line-format)
  (funcall *mail-edit-major-mode*)
  (set-minor-mode-map *mail-edit-map*)
  (run-hooks '*mail-edit-mode-hook*)
  )

(defun mail-edit-winconf-save ()
  (setq *mail-edit-winconf*
	(current-window-configuration)))

(defun mail-edit-winconf-restore ()
  (when *mail-edit-winconf*
    (set-window-configuration *mail-edit-winconf*)
    (setq *mail-edit-winconf* nil)))

(defun mail-edit-buffer-set ()
  (set-buffer (get-buffer-create *mail-edit-buffer*)))

(defun mail-edit-buffer-create (draft &optional pos)
  (mail-edit-buffer-set)
  (mail-edit-mode)
  (modify-read-only-buffer
    (erase-buffer (selected-buffer))
    (let ((body (maildraft-body draft)))
      (when body
	(insert body))
      (setq mail-edit-draft-current draft)
      (goto-char (or pos (point-min))))))

(defun mail-edit-window-create (line)
  (mail-edit-winconf-save)
  (split-window line)
  (refresh-screen)
  (while (not (pos-visible-in-window-p (point-min)))
    (scroll-window -1))
  (other-window 1))

(defun mail-edit-signature-open ()
  (interactive)
  (let* ((header (maildraft-header mail-edit-draft-current))
	 (from (mail-get-header-value "from" header))
	 email)
    (when from
      (multiple-value-bind (mail name)
	  (parse-address from)
	(setq email mail)))
    (mail-signature-open email)))

(defun mail-edit-save ()
  (interactive)
  ; from den8view.l
  (when (re-search-forward "[\xa0-\xdf\X8540-\X889e\Xeb40-\Xffff]+" t)
    (ed::show-match)
    (junk-error "送信しちゃまずい文字発見"))
  (setf (maildraft-body *mail-draft-current*)
	(buffer-substring (point-min)
			  (point-max)))
  (mail-edit-close)
  (mail-draft-refresh))

(defun mail-edit-close ()
  (interactive)
  (mail-edit-winconf-restore)
  (delete-buffer *mail-edit-buffer*))

;;;
;;; Draft to message
;;;

(defun mail-save-buffer-set ()
  (set-buffer (get-buffer-create *mail-save-buffer*))
  (setq need-not-save t))

(defun mail-save-buffer-create (draft)
  (let* ((header (maildraft-header draft))
	 (body (maildraft-body draft))
	 (attachments (maildraft-attachments draft))
	 (content-type (mail-get-header-content "content-type" header))
	 (charset (mail-get-content-charset content-type)))
    (mail-save-buffer-set)
    (erase-buffer (selected-buffer))
    (mail-save-print-header header charset)
    (if attachments
	(let ((body-header (maildraft-body-header draft))
	      (boundary (maildraft-boundary draft)))
	  (mail-save-print-body-part body-header body boundary)
	  (dolist (attachment attachments)
	    (let ((filename (car attachment))
		  (part-header (cdr attachment)))
	      (mail-save-print-attachment part-header filename boundary)))
	  (mail-save-print-boundary boundary t))
      (mail-save-print-body header body))
    ))

(defun mail-save-insert-attachment (file)
  (let ((in (open file :encoding :binary)))
    (unwind-protect
	(insert (si:base64-encode in))
      (close in))))

(defun mail-save-print-boundary (boundary &optional end-p)
  (insert (format nil "--~A~A~%"
		  boundary
		  (if end-p "--" ""))))

(defun mail-save-print-attachment (header file boundary)
  (let* ((content-type (mail-get-header-content "content-type" header))
	 (charset (mail-get-content-charset content-type))
	 beg)
    (mail-save-print-boundary boundary)
    (mail-save-print-header header charset)
    (setq beg (point))
    (mail-save-insert-attachment file)
    ;(mail-encode-encoding header beg)
    (goto-char (point-max))
    (or (bolp) (insert "\n"))))

(defun mail-save-print-body-part (header body boundary)
  (let* ((content-type (mail-get-header-content "content-type" header))
	 (charset (mail-get-content-charset content-type)))
    (mail-save-print-boundary boundary)
    (mail-save-print-header header charset)
    (mail-save-print-body header body)))

(defun mail-save-print-body (header body)
  (let ((beg (point)))
    (insert body)
    (mail-encode-encoding header beg)
    (goto-char (point-max))
    (or (bolp) (insert "\n"))))

(defun mail-save-print-header (header charset)
  (let ((beg (point)))
    (dolist (h header)
      (let ((field (car h))
	    (value (cdr h)))
	(when value
	  (insert (format nil "~A: ~A~%"
			  (string-capitalize field)
			  (if (listp value)
			      (string-join value ",\n ")
			    value))))))
    (insert "\n")
    (goto-char beg)
    (mail-encode-mime-header charset)
    (goto-char (point-max))))
