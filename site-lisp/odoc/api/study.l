;;; -*- Mode: Lisp -*-
;;  study:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       study is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:

(in-package :odoc-api)

(defun one-line-char-encode(str &optional pre)
  (dolist(x (if pre
				(subseq *substitute-alist* 0 4)
				(append *substitute-alist*
					(mapcar
					 #'(lambda(c)
						 (let((l (split-string c #\TAB)))
						   (cons(car l)(cadr l))))
					 (conf-member :regex))))
			str)
	(if(or (car x)(cdr x))
		(setq str
			  (substitute-string
			   str (car x)(cdr x))))))

(defun string-macro(str)
  (dolist(x (conf-member :macro) str)
	(let((s (split-string x #\TAB)))
	  (if(or(car s)(cadr s))
		  (setq str
				(substitute-string
				 str
				 (regexp-quote(car s))(cadr s)))))))

(defun study()
  (let((res ())(p ())(str ()))
	(flet((pos()(setq p (point)))
		  (element(x)
			(if(and (< 0 (length
						  (setq str(buffer-substring p (point)))))
					(not (string= str #\LFD)))
				(push
				 (cons x (split-string
						  (string-macro ; macro
						   (one-line-char-encode ; Character entity reference
							str (eq :pre x)))
						  #\LFD))
				 res)))
		  (scan(regex)(scan-buffer regex :regexp t)))
	  (setq *md5* (md5))
	  (save-excursion
		(goto-char(point-max))
		(and(< 0
			  (length(buffer-substring
					  (progn(goto-bol)(point))
					  (progn(goto-eol)(point)))))
			(newline))
		(goto-char(point-min))
		(while(not(eobp))
		  (cond((looking-at "^=.*$") ; h
				(goto-eol)(forward-char)
				(push (list :h (one-line-char-encode (match-string 0))) res)) ; ??
			   ((looking-at "^----.*")(goto-eol) ; hr
				(push (list :hr (match-string 0)) res))
			   ((looking-at "^ [^\*-\r\n]+$")(pos) ; pre
				(scan "^[^ ]*$")
				(element :pre))
			   ((looking-at "^|.*")(pos) ; table
				(scan "^[^|]*$")
				(element :table))
			   ((looking-at "^:.*")(pos) ; dl
				(scan "^[^:]*$")
				(element :dl))
			   ((looking-at "^>[^\r\n]+")(pos) ; blockquote
				(scan "^[^>]*$")
				(element :bkq))
			   ((looking-at "^\\(\\*\\| +\\)[^\*-\r\n]+")(pos) ; ul
				(scan "^[^\*-]*$")
				(element :ul))
			   ((looking-at "^\\(-\\| +\\)[^\*-\r\n]+")(pos) ; ol
				(scan "^[^\*-]*$")
				(element :ol))
			   (t (setq p (point)) ; p
				  (or(scan "^$")
					 (scan "\\'"))
				  (element :p)
				  (forward-char))
			   ))))
	(nreverse res)))


(provide :odoc/api/study)
;; end