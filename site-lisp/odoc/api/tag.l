;;; -*- Mode: Lisp -*-
;;  tag:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       tag is released under an MIT license.
;;                 See odoc/doc/mit-license for full license.
;;; Code:

(in-package :odoc-api)


(defun h(str)
  (if str
	  (let((n (position-if-not #'(lambda(c)(eq c #\=))str)))
		(and(< 5 n)(setq n 5))
		(substitute-string
		 (substitute-string
		  str
		  (format nil "^=\\{~A\\}\\( *.+$\\)" n)
		  (format nil "<h~A>\\1</h~A>"(1+ n)(1+ n)))
		 "\\(<h[^>]+?>\\) *\\(.*?\\)\\(</h[^>]+?>\\)"
		 (format
		  nil
		  (cond((zerop *heading-link*);contents top
				"<div class=\"cp\">~%\\1<a name=\"\\2\">\\2</a>\\3~%<div class=\"cc\">~%")
			   ((= 1 n)
				"</div>~%</div>~%<div class=\"cp\">~%\\1<a name=\"\\2\">\\2</a>\\3~%<div class=\"cc\">~%")
			   ((< 1 n)
				"</div>~%\\1<a name=\"\\2\">\\2</a>\\3~%<div class=\"cc\">~%")
			   (t ""))
		  (incf *heading-link*)))
		)
	""))

(defun option-div(list)
  (let((form "" )(end ""))
	(when list
	  (cond((string-match "[^\\]\\$\\([^\$]+?\\)\\$" (car list))
			(setq from (concat "<div class=\""(match-string 1)"\">~%")
				  end "</div>~%")
			(setq list (cdr list)))
		   ((string-match "[^\\]%\\([^%]+?\\)%" (car list))
			(setq from (concat "<div id=\"" (match-string 1)"\">~%")
				  end "</div>~%")
			(setq list (cdr list)))
		   (t (setq from  "" end ""))))
	(values from end list)))

(defmacro template-div (list template &optional (fn 'arg))
  `(multiple-value-bind(f e l)
	   (option-div ,list)
	 (format nil (concat f ,template e)
			 ((lambda(arg) ,fn) l))))

(defun td(str)
  (mapcar #'(lambda(x)
			  (format nil "<td>~A</td>" x))
		  (split-string str #\|)))

(defun table(list)
  (template-div
   list
   "<table>~%~{~{~A~}~%~}</table>~%"
   (mapcar
	#'(lambda(a)
		(append(cons "<tr>" (td a))(list "</tr>")))
	arg)))

(defun dtdd(str)
  (let((l (split-string str #\:)))
	(format nil "<dt>~A</dt>~%<dd>~{~A~}</dd>"
			(if(car l)(car l) "")
			(if(nth 1 l)
				(mapcar #'(lambda(x)
							(substitute-string x "\\(https?\\)" "\\1:"));uoon
						(cdr l)) ""))))

(defun dl(list)
  (template-div
   list
   "<dl>~%~{~A~%~}</dl>~%"
   (mapcar #'(lambda(x)(dtdd x)) arg)))

(defun ol(list)(list-judge list))

(defun ul(list)(list-judge list))

(defun pre(list)
  (template-div list "<pre>~{~A~^~%~}</pre>~%"))

(defun p(list)
  (template-div list "<p>~{~A~^~%~}</p>~%"))

(defun blockquote(list)
  (template-div list "<blockquote>~{~A~^<br/>~%~}</blockquote>~%"))

(defun hr()(format nil "<hr/>~%"))

(defun list-judge(list)
  (let((ul "ul")(ol "ol")
	   (ulr "^ *\\*\\(.+\\)")(olr "^ *-\\(.+\\)")
	   tag regex rec-tag (i 0))
	(flet((posit(s)
			(round(/ (position-if-not #'(lambda(c)(eq c #\SPC))(car s))
					 2))))
	  (multiple-value-bind(f e l)
		  (option-div list)
		(do((x l (cdr x));(i 0)
			(top)(close)(res)
			(sub)(now 0)(rec 0))
			((null x)
			 (format nil(concat f "~{~A~%~}" e)
					 (nreverse (delete nil(append (nreverse close) res)))))
		  ; tag = regex
		  (cond((and(car x)(string-match ulr (car x)))
				(setq tag ul regex ulr))
			   ((and(car x)(string-match olr (car x)))
				(setq tag ol regex olr))
			   )
		  (and(car x)
			  (setq sub (substitute-string
						 (car x)  regex
						 "<li>\\1")))
		  (and(string-match regex (car x))(setq now (posit x)))
		  (setq last 0)
		  (cond
		   ; first
		   ((and(equal(car l)(car x))(zerop i));;option-div
			(push (format nil "<~A>" tag) res)
			(push tag top)
			(push sub res)
			(push (format nil "</li>~%</~A>" tag) close)
			)
		   ;; indent + => <tag>
		   ((> now rec);rec=>now
			(push (format nil "<~A>" tag) res)
			(push sub res)
			(push (format nil "</li>~%</~A>" tag) close)
			)
		   ((< now rec);rec=>now
			(dotimes (y (- rec now))(push (pop close) res))
			(and(equal tag rec-tag)
				(push(format nil "</li>") res))
			(push sub res)
			)
		   ;; indent 0 => </tag>
		   ((= now 0)
			(or(equal tag rec-tag)
			   (push (format nil "</li>~%</~A>~%<~A>" rec-tag tag) res);?
			   (setq close (list(format nil "</li>~%</~A>" tag))))
			(push sub res)
			(if(equal tag rec-tag)
				(push (format nil "</li>" tag) res))
			)
		   ;; indent =
		   ((= now rec)
			(push (concat sub "</li>") res))
		   )
		  (setq rec (posit x))
		  (setq rec-tag tag)
		  )))
	))

(provide :odoc/api/tag)
;;end
