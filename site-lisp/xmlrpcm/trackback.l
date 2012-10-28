;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: trackback.l,v 1.2 2006/01/21 18:28:21 torihat Exp $
;
; xmlrpcm/trackback.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xmlrpcm/defs"))

(provide "xmlrpcm/trackback")

(in-package "xmlrpcm")

(defun trackback-ping-send (ping-url url &key blog_name title excerpt)
  (let ((method "POST")
	(buf "*TB TEMP*")
	post
	tmp
	(data (list (cons "url" url)
		    (cons "blog_name" blog_name)
		    (cons "title" title)
		    (cons "excerpt" excerpt)))
	error-code
	error-message)
    (dolist (d data)
      (let ((key (car d))
	    (val (cdr d)))
	(when val
	  (push (format nil "~A=~A"
			key
			(si:www-url-encode (map-internal-to-utf-8 val)))
		tmp))))
    (setq post (format nil "~A~{&~A~}" (car tmp) (cdr tmp)))
    (long-operation
      (multiple-value-bind (proto host path anchor port ping-url)
	  (junk::junk-http-url-study ping-url)
	(multiple-value-bind (http-stream headers request)
	    (junk::junk-http-request-send host path method
					  :port port
					  :data post)
	  (multiple-value-bind (http-stream status headers response)
	      (junk::junk-http-response-get http-stream)
	    (progn
	      (unless (equal status "200")
		(error "HTTP Error: ~S" response))
	      (let (xml)
		(save-excursion
		  (set-buffer (get-buffer-create buf))
		  (erase-buffer (selected-buffer))
		  (with-output-to-selected-buffer ()
		    (junk::junk-http-copy-stream http-stream *standard-output*))
		  (setq xml (ed::xmlpm-parse))
		  (delete-buffer buf))
		(when xml
		  (dolist (tag (ed::xmlpm-tag-contents (car xml)))
		    (let ((name (ed::xmlpm-tag-name tag))
			  (content (car (ed::xmlpm-tag-contents tag))))
		      (cond ((equal name "error")
			     (setq error-code content))
			    ((equal name "message")
			     (setq error-message content))))))
		))))))
    (if (equal error-code "0")
	(values t
		error-code
		error-message)
      (values nil
	      (or error-code "99")
	      (or error-message "unknown error")))
    ))
