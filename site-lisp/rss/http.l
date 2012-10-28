;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: http.l 731 2006-09-01 18:09:41Z torihat $
;
; rss/http.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "rss/defs")
  (require "rss/macro"))

(provide "rss/http")

(in-package "rss")

(defun rss-fetch (item &optional force)
  (let* ((url (rss-link item))
	 (file (rss-url-to-file url))
	 xml
	 res)
    (cond ((rss-url-http-p url)
	   (when (or force
		     (not (file-exist-p file)))
	     (let ((junk::*junk-http-user-agent* *user-agent*))
	       (declare (special junk::*junk-http-user-agent*))
	       (long-operation
		 (when (setq res (junk::junk-http-download-file url file))
		   (rss-apply-filter item file))))))
	  ((rss-url-local-p url)
	   (if (file-exist-p url)
	       (when (or (not (file-exist-p file))
			 (file-newer-than-file-p file url))
		 (setq res (copy-file url file :if-exists :overwrite)))
	     (error "file not exist: ~A" url)))
	  (t
	   (error "not supported: ~A" url)))
    (unless (file-exist-p file)
      (error "fetch error: ~S" url))
    res))
