;;; -*- Mode: Lisp -*-
;;  xml:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       xml is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:

(in-package :odoc-api)
(defmacro xml-create(feed template &body body)
  `(let((file (merge-pathnames
			   ,feed
			   (publish-directory (get-buffer-file-name)))))
	 (unless
		 (file-exist-p file)
	   (with-open-file(out file
						   :direction :output
						   :if-does-not-exist :create)
		 (format out ,template ,@body)))))

(defmacro xml-push (feed &body body)
  `(let*((title (convert-encoding-from-internal *encoding-utf8n* (page-title)))
		 (h (conf-member :host))
		 (host (if h (append-trail-slash(car h)) ""))
		 (l())(r())(main t)(entry t))
	 (with-open-file(in(merge-pathnames
						,feed
						(publish-directory (get-buffer-file-name))))
	   ,@body)
	 (with-open-file(out(merge-pathnames
						 ,feed
						 (publish-directory (get-buffer-file-name)))
						:direction :output
						:if-exists :overwrite)
	   (format out "~{~A~^~%~}" (nreverse r)))
	 ))

(defun xml-contents(list)
  (convert-encoding-from-internal
   *encoding-utf8n*
   (main-contents list)))

(provide :odoc/api/macro)
;;end
