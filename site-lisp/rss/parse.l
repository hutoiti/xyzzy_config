;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: parse.l 731 2006-09-01 18:09:41Z torihat $
;
; rss/parse.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "rss/defs")
  (require "rss/macro"))

(provide "rss/parse")

(in-package "rss")

(defun rss-parse-channel (xml)
  (let (cur)
    (while xml
      (or xml (return))
      (or (listp xml) (return))
      (setq cur (car xml))
      (setq xml (cdr xml))
      (when (listp cur)
	(let ((name (ed::xmlpm-tag-name cur))
	      (opts (ed::xmlpm-tag-opts cur))
	      (contents (ed::xmlpm-tag-contents cur)))
	  (cond ((or (equal name "title")
		     (equal name "link")
		     (equal name "description")
		     (equal name "id"))
		 (push (cons name (car contents)) *rss-channel*))
		((equal name "guid")
		 (push (cons "id" (car contents)) *rss-channel*))))))))

(defun rss-parse-1 (xml)
  (let (cur)
    (while xml
      (or xml (return))
      (or (listp xml) (return))
      (setq cur (car xml))
      (setq xml (cdr xml))
      (cond ((listp cur)
	     (let ((name (ed::xmlpm-tag-name cur))
		   (opts (ed::xmlpm-tag-opts cur))
		   (contents (ed::xmlpm-tag-contents cur)))
	       (cond ((or (equal name "channel")
			  (equal name "feed"))
		      (rss-parse-channel contents))
		     ((or (equal name "item")
			  (equal name "entry"))
		      (rss-parse-item contents))
		     (t
		      nil))
	       (when contents
		 (rss-parse-1 contents))))
	    ((stringp cur)
	     nil)
	    (t
	     nil))
      )))

(defun rss-parse-item (xml)
  (let (cur
	item
	id
	title
	description
	content
	link
	dateString
	timestamp)
    (while xml
      (or xml (return))
      (or (listp xml) (return))
      (setq cur (car xml))
      (setq xml (cdr xml))
      (when (listp cur)
	(let ((name (ed::xmlpm-tag-name cur))
	      (opts (ed::xmlpm-tag-opts cur))
	      (contents (ed::xmlpm-tag-contents cur)))
	  (cond ((equal name "title")
		 (setq title (car contents)))
		((or (equal name "summary")
		     (equal name "description"))
		 (setq description (rss-decode-content (car contents))))
		((or (equal name "content")
		     (equal name "content:encoded"))
		 (setq content (rss-decode-content (rss-contents-to-string contents))))
		((equal name "link")
		 (if (ed::xmlpm-tag-single-p cur)
		     (when (equal "alternate" (cdr (assoc "rel" opts :test #'equal)))
		       (setq link (cdr (assoc "href" opts :test #'equal))))
		   (setq link (car contents))))
		((equal name "enclosure")
		 (setq link (cdr (assoc "url" opts :test #'equal))))
		((or (equal name "dc:date")
		     (equal name "modified")
		     (equal name "updated"))
		 (let* ((datestr (car contents))
			(ts (if datestr
				(junk::iso8601-parse-datetime datestr)
			      0)))
		   (setq dateString (if (and (numberp ts)
					     (< 0 ts))
					(progn
					  (setq timestamp ts)
					  (format-date-string *rss-datetime-format* ts))
				      datestr))))
		((equal name "pubDate")
		 (let* ((datestr (car contents))
			(ts (junk::rfc822-parse-date datestr)))
		   (setq dateString (if ts
					(progn
					  (setq timestamp ts)
					  (format-date-string *rss-datetime-format* ts))
				      datestr))))
		((or (equal name "guid")
		     (equal name "id"))
		 (setq id (car contents)))
		))))
    (when title
      (setq item (list (cons "title" title)
		       (cons "description" (rss-remove-unvisible-chars (or description content)))
		       (cons "link" link)
		       (cons "date" dateString)
		       (cons "timestamp" timestamp)
		       (cons "id" id)))
      (push (cons item nil) *rss-item-list*))))

(defun rss-contents-to-string (contents)
  (with-output-to-string (s)
    (dolist (content contents)
      (ed::xmlpm-write-tag s content))))

(defun rss-remove-unvisible-chars (str)
  (when str
    (substitute-string str "
" "")))

(defun rss-decode-content (cdata)
  (when cdata
    (substitute-string
     (substitute-string
      (substitute-string
       (ed::xmlpm-decode-special-chars (substitute-string cdata "[\n\r]" ""))
       "\\(<br[^<>]*>\\|</p>\\|<p[^<>]*>\\|</[uo]l>\\)" "\n")
      "<li>" "\n  ÅE")
     "<[^<>]+>" "")))

(defun rss-study-format (xml)
  (let* ((tag (car xml))
	 (name (ed::xmlpm-tag-name tag))
	 (opts (ed::xmlpm-tag-opts tag)))
    (cond ((equal name "rdf:RDF")
	   (let ((xmlns (cdr (assoc "xmlns" opts :test #'equal))))
	     (if (stringp xmlns)
		 (cond ((string-match "1.0" xmlns)
			'RSS-100)
		       (t
			nil))
	       nil)))
	  ((equal name "rss")
	   (let ((version (cdr (assoc "version" opts :test #'equal))))
	     (cond ((equal version "2.0")
		    'RSS-200)
		   (t
		    nil))))
	  ((equal name "feed")
	   (let ((version (cdr (assoc "version" opts :test #'equal))))
	     (cond ((equal version "0.3")
		    'ATOM-03)
		   (t
		    'ATOM-10))))
	  (t
	   nil))))

(defun rss-parse (xml)
  (let ((format (rss-study-format xml)))
    ;; ÇπÇ¡Ç©Ç≠å`éÆÇîªï ÇµÇΩÇÃÇ…ìØÇ∂èàóùÇ©ÇÊÇ¡ÅI
    (rss-parse-1 xml)
;    (cond ((eq format 'RSS-100)
;	   (rss-parse-1 xml))
;	  ((eq format 'RSS-200)
;	   (rss-parse-1 xml))
;	  ((eq format 'ATOM-10)
;	   (rss-parse-1 xml))
;	  ((eq format 'ATOM-03)
;	   (rss-parse-1 xml))
;	  (t
;	   (rss-parse-1 xml)))
    ))
