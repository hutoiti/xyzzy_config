;;; -*- Mode: Lisp -*-
;;  index:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       index is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:

(in-package :odoc-api)

(export '(index-study))

(defun index-study(dir)
  (let*((buf) (l) (r)(tmp)(pub) (path)
		(ext (concat "*." *odoc-extension*))
		(dl (sort
			  (directory dir
						 :wild ext
						 :file-only t
						 :absolute t)
			  #'(lambda(a b)
				  (file-newer-than-file-p a b))))
		(ln (length dl))
		)
	(dolist(x (subseq dl 0 (if(<= ln 10) ln 10))
			 (values(delete nil (nreverse r))
					(delete nil (nreverse pub))))
	  (when(setq path (pathname-name x))
		(push (format nil "= [~A]~%"  path) r)
		(push (list
			   :h
			   (format nil "= ~A" path))
			  pub)
		(with-open-file(f x)
		  (dotimes (i 10)
			(setq l (or(read-line f nil nil nil)
					   (read-line f nil nil nil)));)
			(and l (setq l(one-line-char-encode l)))
			(if(and l (string-match "^=+ *\\([^=]+\\)" l))
				(progn(setq l (match-string 1))(push l r))
			  (progn (push l r)
				(and(< 0 (length l))(push (list :p l) pub)))); (push l tmp)))) 
			))
		;(push(push :p tmp)pub)
		(push (list
			   :p
			   (format nil "<a href=\"~A.html\" tagert=\"_blank\">‘±‚«‚ð“Ç‚Þ ...<a>~%"
					   (si:www-url-encode path)))
			  pub)
		))))

(provide :odoc/api/index)
;;end
