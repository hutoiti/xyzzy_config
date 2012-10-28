;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: publish.l 821 2009-05-14 17:03:46Z torihat $
;
; publish.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "atomm/defs")
  (require "junk/http")
  (require "junk/wsse"))

(require "atomm/parser")

(provide "atomm/publish")

(in-package "atomm")

(defun atomm-send-request (url method username password expected &optional xml)
  (let* (headers
	 response-headers
	 response-xml)
    (when xml
      (when *debug-mode*
	(msgbox "~S" xml))
      (push (cons "content-type" "application/atom+xml") headers))
    (when (and username password)
      (push (cons "x-wsse" (junk::wsse-create-http-header username password)) headers))
    (long-operation
      (multiple-value-bind (proto host path anchor port url)
	  (junk::junk-http-url-study url)
	(multiple-value-bind (stream headers request)
	    (junk::junk-http-request-send host path method
					  :port port
					  :headers headers
					  :data xml)
	  (progn
	    (when *debug-mode*
	      (setq *temp0* (list headers request))
	      (msgbox "~S~%~%~S" headers request))
	    (multiple-value-bind (http-stream status headers response)
		(junk::junk-http-response-get stream)
	      (progn
		(when *debug-mode*
		  (setq *temp1* (list status headers response))
		  (msgbox "~S~%~S~%~S" status headers response))
		(unless (equal expected status)
		  (error "Error: ~S" response))
		(setq response-headers headers)
		(save-excursion
		  (atomm-set-buffer-temp)
		  (with-output-to-selected-buffer
		    (junk::junk-http-copy-stream http-stream *standard-output*))
		  (when *debug-mode*
		    (setq *temp1* (buffer-substring (point-min) (point-max)))
		    (msgbox "~S" *temp1*))
		  (setq response-xml (ed:xmlpm-parse))
		  (when *debug-mode*
		    (setq *temp2* response-xml)
		    (msgbox "~S" *temp2*))
		  (atomm-delete-buffer-temp))
		))))))
    (values response-xml response-headers)
    ))

(defun atomm-get-service (url username password)
  (let* ((method "GET")
	 (expected "200")
	 (response (atomm-send-request url method username password expected))
	 titles)
    (when response
      (let* ((service (car response))
	     (collections (ed::xmlpm-tag-contents
			   (car
			    (ed::xmlpm-tag-contents service)))))
	(dolist (collection collections)
	  (when (equal (ed::xmlpm-tag-name collection) "collection")
	    (let* ((options  (ed::xmlpm-tag-opts collection))
		   (contents (ed::xmlpm-tag-contents collection))
		   (href  (cdr (assoc "href"  options :test #'equal)))
		   title
		   accept)
	      (when href
		(dolist (content contents)
		  (when (equal (ed::xmlpm-tag-name content) "atom:title")
		    (setq title (car (ed::xmlpm-tag-contents content))))
		  (when (equal (ed::xmlpm-tag-name content) "accept")
		    (setq accept (car (ed::xmlpm-tag-contents content)))))
		(when title
		  (push (list href title accept) titles)))))))
      titles)))

(defun atomm-get-root (url username password)
  (let* ((method "GET")
	 (expected "200")
	 (response (atomm-send-request url method username password expected))
	 titles)
    (when response
      (let* ((feed (car response))
	     (links (ed::xmlpm-tag-contents feed)))
	(dolist (link links)
	  (let* ((options (ed::xmlpm-tag-opts link))
		 (title (cdr (assoc "title" options :test #'equal)))
		 (rel   (cdr (assoc "rel"   options :test #'equal)))
		 (href  (cdr (assoc "href"  options :test #'equal)))
		 (type  (cdr (assoc "type"  options :test #'equal))))
	    (if (assoc title titles :test #'equal)
		(setf (cdr (assoc title titles :test #'equal))
		      (push (cons rel href) (cdr (assoc title titles :test #'equal))))
	      (push (list title (cons rel href)) titles)))))
      titles)))

(defun atomm-get-feed (url username password)
  (let* ((method "GET")
	 (expected "200")
	 (response (atomm-send-request url method username password expected)))
    (when response
      (let* ((feed (car response)))
	(atomm-parse-feed feed)))))

(defun atomm-get-categories (url username password)
  (let* ((method "GET")
	 (expected "200")
	 (response (atomm-send-request url method username password expected)))
    (when response
      (let* ((categories (car response))
	     subjects)
	(dolist (category (ed::xmlpm-tag-contents categories))
	  (when (equal "subject" (ed::xmlpm-tag-name category))
	    (push (car (ed::xmlpm-tag-contents category)) subjects)))
	(nreverse subjects)))))

(defun atomm-get-entry (url username password)
  (let* ((method "GET")
	 (expected "200")
	 (response (atomm-send-request url method username password expected)))
    (when response
      (let* ((entry (car response)))
	(atomm-parse-entry entry)))))

(defun atomm-post-entry (url username password entry)
  (let* ((method "POST")
	 (expected "201")
	 (xml (ed::xmlpm-write-xml entry)))
    (atomm-send-request url
			method
			username
			password
			expected
			xml)
    t))

(defun atomm-edit-entry (url username password entry)
  (let* ((method "PUT")
	 (expected "200")
	 (xml (ed::xmlpm-write-xml entry)))
    (atomm-send-request url
			method
			username
			password
			expected
			xml)
    t))

(defun atomm-delete-entry (url username password)
  (let* ((method "DELETE")
	 (expected "200"))
    (atomm-send-request url
			method
			username
			password
			expected)
    t))
