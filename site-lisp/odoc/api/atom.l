;;; -*- Mode: Lisp -*-
;;  atom:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       atom is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:

(in-package :odoc-api)

(defun atom-create()
  (xml-create
   *atom-xml*
   "<?xml version=\"1.0\" encoding=\"utf-8\" ?>
<feed xmlns='http://www.w3.org/2005/Atom'>
<title>~A</title>
<subtitle>~A</subtitle>
<link rel=\"self\" type=\"application/atom+xml\" href=\"~A\"/>
<updated>~A</updated>
  <author>
   <name>~A</name>
   <email>~A</email>
   </author>
   <id>urn:uuid:~A</id>
</feed>"
   (or(convert-encoding-from-internal
	   *encoding-utf8n* (car(conf-member :title)))
	  "")
   (or(convert-encoding-from-internal
	   *encoding-utf8n* (car(conf-member :sub)))
	  "")
   (if (conf-member :host) (car(conf-member :host))"")
   (format-date-string "%Y-%m-%dT%H:%M:%S%Z")
   (or(car(conf-member :author))"")
   (or(car(conf-member :mail))"")
   (GUID)))

(defun atom-push(contents summary)
  (xml-push
   ;;list
   *atom-xml*
   (while(setq l (read-line in nil nil nil))
	 (cond((and main (string-match "</updated>" l))
		   (push(concat "  <updated>"
						(format-date-string "%Y-%m-%dT%H:%M:%S%Z")
						"</updated>")
				r))
		  ((and main (string-match "</id>" l))
		   (setq main ())
		   (push l r)
		   (push
			(format
			 nil "   <entry>
    <title>~A</title>
    <link rel=\"alternate\" type=\"text/html\" href=\"~A~A.html\"/>
    <id>urn:uuid:~A</id>
    <modified>~A</modified>
    <issued>~A</issued>
     <summary>
~A
     </summary>
     <content type=\"text/html\" mode=\"escaped\">
     <![CDATA[
~A
     ]]>
     </content>
   </entry>"
			 title host title (GUID)
			 (format-date-string "%Y-%m-%dT%H:%M:%SZ")
			 (format-date-string "%Y-%m-%dT%H:%M:%SZ") ; ?
			 ;;(substitute-string
			  summary; "<[^>]+?>" "")
			 contents
			 )
			r))
		  ((and entry
			  (string-match (format nil "<title>~A</title>" title) l))
		   (setq entry ())
		   (setq r (cdr r)))
		  ((and(not entry)(string-match "</entry>" l))
		   (setq entry t))
		  (entry (push l r))
		  ;;(t (push l r))
		  ))))


(provide :odoc/api/atom)
;;end
