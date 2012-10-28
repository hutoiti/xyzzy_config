;;; -*- Mode: Lisp -*-
;;  rss:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       rss is released under an MIT license.
;;                 See odoc/docmit-license for full license.
;;; Code:

(in-package :odoc-api)
(defun rss-create()
  (xml-create
   *rss-xml*
   "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>
<rss xmlns:content=\"http://purl.org/rss/1.0/modules/content/\"
     version=\"2.0\">
  <channel>
  <title>~A</title>
  <link>~A</link>
  <description>~A</description>
  <docs>http://blogs.law.harvard.edu/tech/rss</docs>
  <pubDate>~A</pubDate>
  <lastBuildDate>~A</lastBuildDate>
  <language>ja</language>
  </channel>
</rss>"
   (or(convert-encoding-from-internal
	   *encoding-utf8n* (car(conf-member :title))) "")
   (or(car(conf-member :host))"")
   (or(convert-encoding-from-internal
	   *encoding-utf8n* (car(conf-member :sub)))"")
   ;;(concat  (or(car(conf-member :host)) "/") *rss-xml*)
   (format-date-string "%a, %d %b %Y %H:%M:%S %Z")
   (format-date-string "%a, %d %b %Y %H:%M:%S %Z")
   ))

(defun rss-push(contents description)
  (xml-push
   ;;list
   *rss-xml*
   (while(setq l (read-line in nil nil nil))
	 (cond((and main (string-match "</language>" l))
		   (setq main ())
		   (push l r)
		   (push
			(format nil "    <item>
    <title>~A</title>
    <link>~A~A.html</link>
    <guid>~A</guid>
    <description>
~A
    </description>
    <content:encoded>
    <![CDATA[
~A
    ]]>
    </content:encoded>
    <pubDate>~A</pubDate>
    </item>"
					title host title (GUID)
					;;(substitute-string
					 description; "<[^>]+?>" "")
					contents
					(format-date-string "%a, %d %b %Y %H:%M:%S %Z")
					)
			r))
		  ((and entry
		   (string-match (format nil "<title>~A</title>" title) l))
		   (setq entry ())
		   (setq r (cdr r)))
		  ((and(not entry)(string-match "</item>" l))
		   (setq entry t))
		  (entry (push l r))
		  ;;(t (push l r))
		  )))
  )

(provide :odoc/api/rss)
;;end
