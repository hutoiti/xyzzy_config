;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: mail.l 769 2007-12-14 19:18:39Z torihat $
;
; mail.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "junk/defs")
  (require "junk/macro"))

(require "encdec")

(require "junk/lib")
(require "junk/rfc822")
(require "junk/rfc2045")

(provide "junk/mail")

(in-package "junk")

(defstruct mailstructure
  number
  headers
  beg
  end
  structure)

(defmacro mail-get-header (key headers)
  `(assoc ,key ,headers :test #'string=))

(defmacro mail-get-header-value (key headers)
  `(cdr (assoc ,key ,headers :test #'string=)))

(defmacro mail-get-header-option-value (key opts)
  `(cdr (assoc ,key ,opts :test #'equalp)))

(defun mail-decode-mime-header ()
  (save-excursion
    (while (or (looking-for "From ")
	       (looking-for ">From ")
	       (looking-for "X-KaMail-Status"))
      (or (forward-line 1) (return)))
    (save-excursion
      (when (scan-buffer "^X-Mailer :" :regexp t :tail t)
	(delete-region (- (point) 2) (- (point) 1))))
    (decode-mime-header)))

(defun mail-encode-mime-header (&optional charset)
  (setq charset (or charset *encode-mime-charset-name*))
  (let ((*encode-mime-charset-name* charset))
    (declare (special *encode-mime-charset-name*))
    (encode-mime-header)))

(defun mail-multipart-p (headers)
  (let((content-type
	(mime-parse-content
	 (or (mail-get-header-value "content-type" headers) ""))))
    (and (mail-get-header-option-value "multipart" content-type)
	 (mail-get-header-option-value "boundary" content-type))))

(defvar *mail-header-fields-only-one*
  '("date"
    "from"
    "sender"
    "reply-to"
    "to"
    "cc"
    "bcc"
    "message-id"
    "in-reply-to"
    "references"
    "subject"))

(defun mail-parse-header ()
  (let (headers
	key
	val)
    (save-excursion
      (goto-char (point-min))
      (while (not (looking-at "^$"))
	(if (looking-at "^\\([^\000-\040:\177-\377]+\\):[ \t]*\\(.*\\)$")
	    (let (old)
	      (setq key (string-downcase (match-string 1)))
	      (setq val (match-string 2))
	      (while (and (forward-line 1)
			  (looking-at "^[ \t]+\\(.*\\)$"))
		(setq val (concat val " " (match-string 1))))
	      (if (setq old (mail-get-header-value key headers))
		  (if (member key *mail-header-fields-only-one* :test #'equal)
		      (setf (mail-get-header-value key headers) val)
		    (setf (mail-get-header-value key headers)
			  (if (listp old)
			      (append old (list val))
			    (list old val))))
		(push (cons key val) headers)))
	  (or (forward-line 1) (return)))))
    (nreverse headers)))

(defun mail-goto-body-beg ()
  (unless (scan-buffer "^$" :regexp t)
    (return-from mail-goto-body-beg))
  (or (forward-line) (return-from mail-goto-body-beg))
  t)

(defun mail-get-header-content (key headers)
  (let ((value (mail-get-header-value key headers)))
    (when value
      (cond ((equal key "content-type")
	     (mime-parse-content value))
	    ((equal key "content-disposition")
	     (mime-parse-disposition value))
	    ((equal key "content-transfer-encoding")
	     (mime-parse-encoding value))
	    (t
	     value)))))

(defun mail-get-content-mime-type (content-type)
  (when content-type
    (format nil "~@[~A~]/~@[~A~]"
	    (car (car content-type))
	    (cdr (car content-type)))))

(defun mail-get-content-charset (content-type)
  (mail-get-header-option-value "charset" content-type))

(defun mail-inline-p (headers)
  (let* ((content-type
	  (mail-get-header-content "content-type" headers))
	 (mime-type (mail-get-content-mime-type content-type))
	 (content-disposition
	  (mail-get-header-content "content-disposition" headers))
	 (content-transfer-encoding
	  (mail-get-header-content "content-transfer-encoding" headers)))
    (or (not mime-type)
	(and (equalp "text/plain" mime-type)
	     (not (equalp "attachment" (car content-disposition)))))
    ))

(defun mail-get-filename (headers)
  (let* ((content-type
	  (mail-get-header-content "content-type" headers))
	 (mime-type (mail-get-content-mime-type content-type))
	 (content-disposition
	  (mail-get-header-content "content-disposition" headers)))
    (or (mail-get-header-option-value "filename" content-disposition)
	(mail-get-header-option-value "name" content-type))))

(defun mail-parse-multipart (headers &optional prefix)
  (let ((boundary (mail-multipart-p headers))
	structures
	body-start
	(content-type (mail-get-header-value "content-type" headers))
	(cnt 0))
    (unless boundary
      (return-from mail-parse-multipart))
    (save-excursion
      (unless (mail-goto-body-beg)
	(return-from mail-parse-multipart))
      (setq body-start (point))	; body 開始位置 - 不要？
      (let ((boundary-regexp (concat "^--" (regexp-quote boundary) "\\(--\\)?$"))
	    beg
	    end)
	(unless (scan-buffer boundary-regexp :regexp t :tail nil)
	  ;(error "Missing boundary.")
	  (return-from mail-parse-multipart))
	(or (forward-line) (return-from mail-parse-multipart))
	(setq beg (point))
	(while (scan-buffer boundary-regexp :regexp t :tail nil)
	  (setq end (point))
	  (incf cnt)
	  (let ((end-p (match-beginning 1))
		(part-number (format nil "~@[~A.~]~D" prefix cnt))
		part-headers
		part-beg
		part-end
		part-body
		part-structures)
	    (save-excursion
	      (save-restriction
		(narrow-to-region beg end)
		(goto-char beg)
		(mail-decode-mime-header)
		(setq part-headers (mail-parse-header))
		;; RFC 2046 - 5.1.1
		;; If no Content-Type field is present it is assumed to be "message/rfc822" in a
		;; "multipart/digest" and "text/plain" otherwise.
		(unless (mail-get-header "content-type" part-headers)
		  (if (string-match "multipart/digest" content-type)
		      (push (cons "content-type" "message/rfc822") part-headers)
		    (push (cons "content-type" "text/plain") part-headers)))
		(mail-goto-body-beg)
		(setq part-beg (point))
		(setq part-end (point-max))
		(when (mail-multipart-p part-headers)
		  (goto-char beg)
		  (setq part-structures
			(mail-parse-multipart part-headers (format nil "~D" cnt))))
		(push (make-mailstructure :number part-number
					  :headers part-headers
					  :body part-body
					  :beg part-beg
					  :end part-end
					  :structure part-structures)
		      structures)))
	    (and end-p (return))
	    (goto-char (1+ beg))
	    (or (scan-buffer boundary-regexp :regexp t) (return))
	    (or (forward-line) (return))
	    (setq beg (point))
	    ))
	))
    (nreverse structures)))

(defun mail-decode-encoding (headers &optional beg end)
  (let ((charset (mail-get-content-type-charset headers))
	(encoding (mail-get-transfer-encoding headers)))
    (setq beg (or beg (point)))
    (setq end (or end (point-max)))
    (save-restriction
      (narrow-to-region beg end)
      (when (equalp encoding "quoted-printable")
	(quoted-printable-decode-region beg end))
      (setq end (point-max))
      (when (equalp encoding "base64")
	(base64-decode-region beg end))
      (setq end (point-max))
      (if (eq charset *encoding-auto*)
	  (map-char-encoding-region (or beg (point))
				    (or end (point-max)))
	(map-char-encoding-region (or beg (point))
				  (or end (point-max))
				  charset)))
    encoding))

(defun mail-encode-encoding (headers &optional beg end)
  (let ((charset (mail-get-content-type-charset headers))
	(encoding (mail-get-transfer-encoding headers)))
    (setq beg (or beg (point)))
    (setq end (or end (point-max)))
    (save-restriction
      (narrow-to-region beg end)
      (goto-char beg)
      (unless (eq charset *encoding-auto*)
	(when (eq charset *encoding-utf8*)
	  (setq charset *encoding-utf8n*)) ; UTF-8はBOMなしで
	(insert (convert-encoding-from-internal charset
						(buffer-substring beg end)))
	(delete-region (point) (point-max))
	(setq end (point-max)))
      (when (equalp encoding "quoted-printable")
	(goto-char beg)
	(insert (si:quoted-printable-encode
		 (buffer-substring beg end)))
	(delete-region (point) (point-max)))
      (setq end (point-max))
      (when (equalp encoding "base64")
	(goto-char beg)
	(insert (si:base64-encode
		 (buffer-substring beg end)))
	(delete-region (point) (point-max))))
    encoding))

(defun mail-get-mime-charset (charset)
  (or (gethash charset *mime-charset-name-hash-table*)
      *encoding-auto*))

(defun mail-get-content-type-charset (headers)
  (let* ((ctype (mail-get-header-content "content-type" headers))
	 (charset (mail-get-header-option-value "charset" ctype)))
    (if charset
	(mail-get-mime-charset charset)
      *encoding-auto*
      )))

(defun mail-get-transfer-encoding (headers)
  (mail-get-header-content "content-transfer-encoding" headers))

(defun mail-parse ()
  (let (headers
	beg
	end
	structure)
    (mail-decode-mime-header)
    (setq headers (mail-parse-header))
    (if (mail-multipart-p headers)
	(setq structure (mail-parse-multipart headers))
      (setq beg (progn
		  (mail-goto-body-beg)
		  (point))
	    end (point-max)))
    (make-mailstructure :headers headers
			:beg beg
			:end end
			:structure structure)))

(defun test-print-structure (s structure)
  ;(mail-inline-p (mailstructure-headers structure))
  (format s "~S~%~{~S~%~}~S~%~S~%----------~%"
	  (mailstructure-number structure)
	  (mailstructure-headers structure)
	  (mailstructure-beg structure)
	  (mailstructure-end structure))
  (dolist (part (mailstructure-structure structure))
    (test-print-structure s part)))

(defun user::test-mail-parse ()
  (interactive)
  (setq structure (mail-parse))
  (message-box
   (with-output-to-string (s)
     (test-print-structure s structure))))
