;;; -*- Mode: Lisp -*-
;;  re-study: 
;;; Author:        amefura <amefura@gmail.com>
;;; Last Modified: Wed, 16 Jan 2008 17:18:45
;;; License:       re-study is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:

(in-package :odoc-api)

(defun re-study(dir)
  (sort
  (append
   (mapcar #'(lambda(x)
			   (cons :ul (list(one-line-char-encode (concat "* ["(pathname-name x) "]")))))
		  (directory dir :file-only t :wild '("*.html")))
   (delete nil (mapcar #'(lambda(x)
			   (if(file-exist-p(merge-pathnames (concat x "index.html") dir))
				   (cons :ul (list(one-line-char-encode (concat "* [" x "]"))))))
					   (directory dir :directory-only t))))
   #'string-lessp :key 'cadr))
   

(provide :odoc/api/re-study)
;;end
