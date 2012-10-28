;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: format.l 731 2006-09-01 18:09:41Z torihat $
;
; rss/format.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "rss/defs")
  (require "rss/macro"))

(provide "rss/format")

(in-package "rss")

(defvar *rss-template-encoding* *encoding-utf8n*)

(defvar *rss-template-beg* 
"<?xml version=\"1.0\" encoding=\"utf-8\"?>
<!DOCTYPE rss PUBLIC \"-//Netscape Communications//DTD RSS 0.91//EN\"
            \"http://my.netscape.com/publish/formats/rss-0.91.dtd\">
<rss version=\"0.91\">
<channel>
<title>~A</title>
<link>~A</link>
<description>~@[~A~]</description>
")

(defvar *rss-template-end*
"</channel>
</rss>
")

(defvar *rss-template-item*
"<item>
<title>~A</title>
<link>~A</link>
<description>~@[~A~]</description>
</item>
")

(defun rss-set-buffer-format ()
  (set-buffer (get-buffer-create *rss-buffer-format*))
  (erase-buffer (selected-buffer)))

(defun convert-to-rss (xml outfile)
  (save-excursion
    (rss-set-buffer-format)
    (rss-parse xml)
    (insert (format nil *rss-template-beg*
		    (ed::xmlpm-encode-special-chars (or (rss-title *rss-channel*) ""))
		    (ed::xmlpm-encode-special-chars (or (rss-link *rss-channel*) ""))
		    (ed::xmlpm-encode-special-chars (or (rss-description *rss-channel*) ""))))
    (dolist (ritem (reverse *rss-item-list*))
      (let ((item (car ritem)))
	(insert (format nil *rss-template-item*
			(ed::xmlpm-encode-special-chars (or (rss-title item) ""))
			(ed::xmlpm-encode-special-chars (or (rss-link item) ""))
			(ed::xmlpm-encode-special-chars (or (rss-description item) ""))))))
    (insert (format nil *rss-template-end*))
    (write-region (point-min) (point-max) outfile nil *rss-template-encoding*)
    (delete-buffer *rss-buffer-format*)
    ))

(defun rss-create (title link description items)
  (let ((channel (list (list "title" nil title)
		       (list "link" nil link)
		       (list "description" nil description)
		       (list "language" nil "ja"))))
    (dolist (item items)
      (setq channel (append channel (list item))))
    (list (list "rss"
		(list (cons "version" "0.91"))
		(append (list "channel" nil) channel)))))

(defun rss-create-item (title link &optional description)
  (list "item" nil
	(list "title" nil title)
	(list "link" nil link)
	(list "description" nil description)))
