;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
;$Id: rfc2045.l 769 2007-12-14 19:18:39Z torihat $
;
; rfc2045.l
;
; Contributed by Tetsuya Kamei at Fri, 19 May 2000 12:38:27 +0900

(provide "junk/rfc2045")

(in-package "junk")

(defvar *mime-lex-last-token* nil)
(defvar *mime-lex-string* nil)
(defvar *mime-lex-index* nil)
(defvar *mime-lex-tokb* nil)
(defvar *mime-lex-toke* nil)

(defmacro with-mime-parse-field ((string index) &body body)
  `(let ((*mime-lex-last-token* nil)
	 (*mime-lex-string* ,string)
	 (*mime-lex-index* ,index))
     (ignore-errors ,@body)))

(setf (get 'with-mime-parse-field 'lisp-indent-hook) 'defun)

(defun mime-lex-last-token-string (&optional (b *mime-lex-tokb*) (e *mime-lex-toke*))
  (subseq *mime-lex-string* b e))

(defun mime-lex-next-token ()
  (setq *mime-lex-last-token*
	(loop
	  (when (string-looking-at "[ \t\r\n]+" *mime-lex-string*
				   :start *mime-lex-index*)
	    (setq *mime-lex-index* (match-end 0)))
	  (when (= *mime-lex-index* (length *mime-lex-string*))
	    (return nil))
	  (let ((c (char *mime-lex-string* *mime-lex-index*)))
	    (cond ((find c "<>@,;:/[]?=")
		   (incf *mime-lex-index*)
		   (return c))
		  ((char= c #\()
		   (let ((depth 1))
		     (loop
		       (setq *mime-lex-index*
			     (or (string-match "[()\\]" *mime-lex-string* (1+ *mime-lex-index*))
				 (error "unterminated comment")))
		       (case (char *mime-lex-string* *mime-lex-index*)
			 (#\(
			  (incf depth))
			 (#\)
			  (decf depth)
			  (when (zerop depth)
			    (incf *mime-lex-index*)
			    (return)))
			 (t
			  (incf *mime-lex-index*)
			  (when (= *mime-lex-index* (length *mime-lex-string*))
			    (error "orphaned \\ in comment")))))))
		  ((char= c #\")
		   (setq *mime-lex-tokb* (1+ *mime-lex-index*))
		   (loop
		     (setq *mime-lex-index*
			   (or (string-match "[\"\\]" *mime-lex-string* (1+ *mime-lex-index*))
			       (error "unterminated quoted-string")))
		     (case (char *mime-lex-string* *mime-lex-index*)
		       (#\"
			(incf *mime-lex-index*)
			(return))
		       (t
			(incf *mime-lex-index*)
			(when (= *mime-lex-index* (length *mime-lex-string*))
			  (error "orphaned \\ in quoted-string")))))
		   (setq *mime-lex-toke* (1- *mime-lex-index*))
		   (return 'quoted-string))
		  ((char= c #\))
		   (error "unbalanced )"))
		  ((char= c #\\)
		   (error "unexpected \\"))
		  (t
		   (setq *mime-lex-tokb* *mime-lex-index*)
		   (string-looking-at "[^][ \t\r\n()<>@,;:\\\"/?=]+" *mime-lex-string*
				      :start *mime-lex-index*)
		   (setq *mime-lex-index* (match-end 0))
		   (when (string-match "[\000-\037]" *mime-lex-string*
				       *mime-lex-tokb* *mime-lex-index*)
		     (error "invalid control character in atom"))
		   (setq *mime-lex-toke* *mime-lex-index*)
		   (return 'atom)))))))

(defun mime-decode-parameter-extensions (params)
  (let ((initial-name nil)
	value-list
	sequence
	charset
	(new-params nil))
    (flet ((dispose-remainder ()
	     (when initial-name
	       (setq value (apply #'concat (nreverse value-list)))
	       (push (cons initial-name
			   (if charset
			       (convert-encoding-to-internal
				charset value)
			     value))
		     new-params))))
      (mapc #'(lambda (param)
		(let ((name (car param))
		      (value (cdr param)))
		  (cond ((and initial-name
			      (string-matchp (concat "^"
						     (regexp-quote initial-name)
						     "\\*"
						     (format nil "~a" sequence)
						     "\\(\\*?\\)$")
					     name))
			 (push (if (match-beginning 1)
				   (si:www-url-decode value)
				 value)
			       value-list)
			 (incf sequence))
			(t
			 (dispose-remainder)
			 (cond ((string-match "\\*0\\(\\*?\\)$" name)
				(setq initial-name (subseq name 0 (match-beginning 0)))
				(let ((extended-value-p (match-beginning 1)))
				  (setq charset
					(and (string-match "^\\([^']*\\)'\\([^']*\\)'" value)
					     (prog1
						 (gethash (subseq value 0 (match-end 1))
							  *mime-charset-name-hash-table*)
					       (setq value (subseq value (match-end 0))))))
				  (setq value-list (list (if extended-value-p
							     (si:www-url-decode value)
							   value))))
				(setq sequence 1))
			       ((string-match "\\*$" name)
				(setq charset
				      (and (string-match "^\\([^']*\\)'\\([^']*\\)'" value)
					   (prog1
					       (gethash (subseq value 0 (match-end 1))
							*mime-charset-name-hash-table*)
					     (setq value (subseq value (match-end 0))))))
				(push (cons (subseq name 0 (1- (length name)))
					    (if charset
						(convert-encoding-to-internal
						 charset (si:www-url-decode value))
					      value))
				      new-params))
			       (t
				(setq initial-name nil)
				(push param new-params)))))))
	    params)
      (dispose-remainder)
      (nreverse new-params))))

(defun mime-parse-parameters ()
  (let ((params nil))
    (while (and (eql (mime-lex-next-token) #\;)
		(eq (mime-lex-next-token) 'atom))
      (let ((name (mime-lex-last-token-string)))
	(unless (and (eql (mime-lex-next-token) #\=)
		     (let ((tok (mime-lex-next-token)))
		       (or (eq tok 'atom)
			   (eq tok 'quoted-string))))
	  (return))
	(setq params (acons name (mime-lex-last-token-string) params))))
    (mime-decode-parameter-extensions (nreverse params))))

(defun mime-parse-content (string &optional (index 0))
  (with-mime-parse-field (string index)
    (when (eq (mime-lex-next-token) 'atom)
      (let ((type (mime-lex-last-token-string)))
	(when (and (eql (mime-lex-next-token) #\/)
		   (eq (mime-lex-next-token) 'atom))
	  (acons type (mime-lex-last-token-string) (mime-parse-parameters)))))))

(defun mime-parse-encoding (string &optional (index 0))
  (with-mime-parse-field (string index)
    (let ((tok (mime-lex-next-token)))
      (when (or (eq tok 'atom)
		(eq tok 'quoted-string))
	(mime-lex-last-token-string)))))

(defun mime-parse-disposition (string &optional (index 0))
  (with-mime-parse-field (string index)
    (when (eq (mime-lex-next-token) 'atom)
      (cons (mime-lex-last-token-string) (mime-parse-parameters)))))

(defun mime-parse-field (string)
  (cond ((string-matchp "^Content-Type[ \t]*:" string)
	 (cons "content-type"
	       (mime-parse-content string (match-end 0))))
	((string-matchp "^Content-Transfer-Encoding[ \t]*:" string)
	 (cons "content-transfer-encoding"
	       (mime-parse-encoding string (match-end 0))))
	((string-matchp "^Content-Disposition[ \t]*:" string)
	 (cons "content-disposition"
	       (mime-parse-disposition string (match-end 0))))
	(t nil)))
