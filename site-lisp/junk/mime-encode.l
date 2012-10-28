;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
;$Id: mime-encode.l 769 2007-12-14 19:18:39Z torihat $
;
; mime-encode.l
;
; Contributed by Tetsuya Kamei at Sat, 10 Jun 2000 23:09:01 +0900

(provide "junk/mime-encode")

(in-package "junk")

(defvar *encode-mime-preceding-white* nil)
(defvar *encode-mime-max-width* 72)
(defvar *encode-mime-charset-name* "ISO-2022-JP")

(defmacro encode-mime-LWSP-char-p (c)
  `(find ,c " \t"))

(defun encode-mime-output-ascii (string b e prefix postfix no-folding)
  (let ((column (si:*stream-column)))
    (cond ((and (not (zerop column))
		(not no-folding)
		(> (+ column (- e b)
		      (length prefix)
		      (length postfix)
		      (if *encode-mime-preceding-white* 1 0))
		   *encode-mime-max-width*))
	   (write-char #\LFD)
	   (write-char #\SPC))
	  (*encode-mime-preceding-white*
	   (write-char #\SPC))))
  (setq *encode-mime-preceding-white* nil)
  (and prefix (princ prefix))
  (princ (subseq string b e))
  (and postfix (princ postfix)))

(defun encode-mime-output-b-ecoding (string b e prefix postfix)
  (loop
    (let* ((column (si:*stream-column))
	   (white (or (zerop column)
		      *encode-mime-preceding-white*))
	   (rest (* (truncate (- *encode-mime-max-width*
				 column
				 (length prefix)
				 (if white 1 0)
				 7 ; `=?' `?B?' `?='
				 (length *encode-mime-charset-name*)) 4) 3))
	   (encoding (gethash *encode-mime-charset-name* *mime-charset-name-hash-table*))
	   r)
      (when (plusp rest)
	(do ((i (1+ b) (1+ i)))
	    ((> i e)
	     (setq b e))
	  (let ((x (convert-encoding-from-internal
		    (or encoding *encoding-jis*) (subseq string b i))))
	    (when (or (and (> (length x) rest)
			   (or r (not (zerop column))))
		      (and postfix (= i e)
			   (> (+ (length x) (length postfix)) rest)))
	      (setq b (1- i))
	      (return))
	    (setq r x)))
	(when r
	  (when white
	    (write-char #\SPC))
	  (when prefix
	    (princ prefix)
	    (setq prefix nil))
	  (format t "=?~A?B?" *encode-mime-charset-name*)
	  (si:base64-encode r *standard-output* t)
	  (princ "?=")
	  (setq *encode-mime-preceding-white* nil))))
    (when (= b e)
      (when postfix
	(princ postfix))
      (return))
    (write-char #\LFD)))

(defun encode-mime-output (string start end prefix postfix no-folding)
  (let ((i start)
	beg)
    (while (< i end)
      (when (string-looking-at "[ \t\r\n]+" string :start i :end end)
	(setq i (match-end 0))
	(setq *encode-mime-preceding-white* t))
      (cond ((string-looking-at "[^ \t\r\n\200-\Xffff]+" string :start i :end end)
	     (setq beg i i (match-end 0))
	     (encode-mime-output-ascii string beg i
				       (and (= beg start) prefix)
				       (and (= i end) postfix)
				       no-folding))
	    ((string-looking-at "[^\000-\177]+" string :start i :end end)
	     (setq beg i i (match-end 0))
	     (encode-mime-output-b-ecoding string beg i
					   (and (= beg start) prefix)
					   (and (= i end) postfix)))
	    (t
	     (return))))))

(defun encode-mime-output-qtext (string start end no-folding)
  (let ((i start)
	beg)
    (while (< i end)
      (cond ((string-looking-at "[\000-\177]+" string :start i :end end)
	     (setq beg i i (match-end 0))
	     (encode-mime-output-ascii string beg i
				       (and (= beg start) "\"")
				       (and (= i end) "\"")
				       no-folding))
	    ((string-looking-at "[^\000-\177]+" string :start i :end end)
	     (setq beg i i (match-end 0))
	     (encode-mime-output-b-ecoding string beg i
					   (and (= beg start) "\"")
					   (and (= i end) "\"")))
	    (t
	     (return))))))

(defun encode-mime-push-element (s string b e)
  (setq string (string-trim " \t\r\n" (subseq string b e)))
  (if (zerop (length string))
      s
    (cons
     (substitute-string
      (substitute-string
       (substitute-string string "[ \t\r\n]+" " ")
       " ?\\([@;:.>]\\) ?" "\\1")
      " ?< ?" " <")
     s)))

(defun encode-mime-push-params (r s)
  (cons (nreverse s) r))

(defun encode-mime-skip-comment (s string i)
  (push (cons 'comment
	      (string-trim
	       " \t\r\n"
	       (subseq string
		       (1+ i)
		       (let ((depth 1))
			 (loop
			   (setq i (string-match "[()\\]" string (+ i 1)))
			   (unless i
			     (setq i (length string))
			     (return i))
			   (case (char string i)
			     (#\(
			      (incf depth))
			     (#\)
			      (decf depth)
			      (when (zerop depth)
				(return (prog1 i (incf i)))))
			     (t
			      (incf i))))))))
	s)
  (values s i))

(defun encode-mime-skip-element (s string i type regexp)
  (setq string (subseq string
		       (1+ i)
		       (loop
			 (setq i (string-match regexp string (+ i 1)))
			 (unless i
			   (setq i (length string))
			   (return i))
			 (unless (eql (prog1 (char string i) (incf i)) #\\)
			   (return (1- i))))))
  (push (cons type
	      (if (eq type 'qtext)
		  (substitute-string string "\n[ \t\r\n]*" " ")
		(string-trim " \t\r\n" string)))
	s)
  (values s i))

(defun encode-mime-split-address (string)
  (let ((b 0)
	(i 0)
	(s nil)
	(r nil))
    (loop
      (when (string-looking-at "[^([\":,]+" string :start i)
	(setq i (match-end 0)))
      (when (= i (length string))
	(return (nreverse (encode-mime-push-params
			   r (encode-mime-push-element s string b i)))))
      (case (char string i)
	(#\(
	 (setq s (encode-mime-push-element s string b i))
	 (multiple-value-setq (s i)
	   (encode-mime-skip-comment s string i))
	 (setq b i))
	(#\[
	 (setq s (encode-mime-push-element s string b i))
	 (multiple-value-setq (s i)
	   (encode-mime-skip-element s string i 'dtext "[]\\]"))
	 (setq b i))
	(#\"
	 (setq s (encode-mime-push-element s string b i))
	 (multiple-value-setq (s i)
	   (encode-mime-skip-element s string i 'qtext "[\\\"]"))
	 (setq b i))
	(#\:
	 (incf i)
	 (unless (string-looking-at "[ \t]*;" string :start i)
	   (setq s (encode-mime-push-element s string b i))
	   (setq b i)))
	(#\,
	 (setq r (encode-mime-push-params r (encode-mime-push-element s string b i)))
	 (setq s nil)
	 (incf i)
	 (setq b i))))))

(defun encode-mime-address (string)
  (let ((addrs (encode-mime-split-address string))
	(comma nil))
    (mapc #'(lambda (addr)
	      (when addr
		(if comma
		    (princ ",\n")
		  (setq comma t))
		(let ((*encode-mime-preceding-white* t)
		      (no-folding
		       (dolist (x addr t)
			 (when (string-match "[^\000-\177]" (if (consp x) (cdr x) x))
			   (return nil))))
		      (last nil))
		  (mapc #'(lambda (x)
			    (cond ((stringp x)
				   (setq *encode-mime-preceding-white*
					 (cond ((null last) t)
					       ((or (eq last 'qtext)
						    (eq last 'comment))
						(not (string-looking-at "[>@;:.]" x)))
					       ((stringp last)
						(not (string-match ":$" last)))
					       (t nil)))
				   (if (string-match ":;?$" x)
				       (let ((y (subseq x 0 (match-beginning 0))))
					 (encode-mime-output y 0 (length y) nil
							     (subseq x (match-beginning 0))
							     no-folding))
				     (encode-mime-output x 0 (length x) nil nil no-folding))
				   (setq last x))
				  ((eq (car x) 'qtext)
				   (setq *encode-mime-preceding-white*
					 (cond ((null last) t)
					       ((or (eq last 'qtext)
						    (eq last 'comment))
						t)
					       ((stringp last)
						(not (string-match "[<@.]$" last)))
					       (t t)))
				   (encode-mime-output-qtext (cdr x) 0 (length (cdr x))
							     no-folding)
				   (setq last 'qtext))
				  ((eq (car x) 'dtext)
				   (encode-mime-output (cdr x) 0 (length (cdr x))
						       "[" "]" no-folding)
				   (setq last 'dtext))
				  (t
				   (setq *encode-mime-preceding-white* t)
				   (encode-mime-output (cdr x) 0 (length (cdr x))
						       "(" ")" no-folding)
				   (setq last 'comment))))
			addr))))
	  addrs)))

(defun encode-mime-split-content (string)
  (let ((b 0)
	(i 0)
	(s nil)
	(r nil))
    (loop
      (when (string-looking-at "[^(\";]+" string :start i)
	(setq i (match-end 0)))
      (when (= i (length string))
	(return (nreverse (encode-mime-push-params
			   r (encode-mime-push-element s string b i)))))
      (case (char string i)
	(#\(
	 (setq s (encode-mime-push-element s string b i))
	 (multiple-value-setq (s i)
	   (encode-mime-skip-comment s string i))
	 (setq b i))
	(#\"
	 (setq s (encode-mime-push-element s string b i))
	 (multiple-value-setq (s i)
	   (encode-mime-skip-element s string i 'qtext "[\\\"]"))
	 (setq b i))
	(#\;
	 (setq r (encode-mime-push-params r (encode-mime-push-element s string b i)))
	 (setq s nil)
	 (incf i)
	 (setq b i))))))

(defun encode-mime-content (string)
  (let ((params (encode-mime-split-content string))
	(semi nil)
	(sep (if (or (string-match "[^\000-\177]" string)
		     (> (+ (si:*stream-column)
			   (length string))
			*encode-mime-max-width*))
		 ";\n" ";")))
    (mapc #'(lambda (param)
	      (when param
		(if semi
		    (princ sep)
		  (setq semi t))
		(let ((*encode-mime-preceding-white* t)
		      (no-folding
		       (dolist (x param t)
			 (when (string-match "[^\000-\177]" (if (consp x) (cdr x) x))
			   (return nil)))))
		  (mapc #'(lambda (x)
			    (cond ((stringp x)
				   (encode-mime-output x 0 (length x) nil nil no-folding))
				  ((eq (car x) 'qtext)
				   (encode-mime-output-qtext (cdr x) 0 (length (cdr x))
							     no-folding))
				  (t
				   (setq *encode-mime-preceding-white* t)
				   (encode-mime-output (cdr x) 0 (length (cdr x))
						       "(" ")" no-folding)
				   (setq *encode-mime-preceding-white* t))))
			param))))
	  params)))

(defun encode-mime-field-body (string)
  (let ((*encode-mime-preceding-white* t))
    (encode-mime-output string 0 (length string) nil nil nil)))

(defvar *encode-mime-header-type*
  (let ((h (make-hash-table :test #'equalp)))
    (mapc #'(lambda (x)
	      (setf (gethash x h) 'address))
	  '("From" "Sender" "To" "Cc" "Bcc" "Reply-To"
	    "Resent-Reply-To" "Resent-From" "Resent-Sender"
	    "Resent-To" "Resent-Cc" "Resent-Bcc"))
    (mapc #'(lambda (x)
	      (setf (gethash x h) 'content))
	  '("Content-Type" "Content-Disposition"))
    h))

(defmacro with-encode-mime-header ((b e name) &body body)
  `(insert (prog1
	       (with-output-to-string (so)
		 (let ((*standard-output* so))
		   (format t "~A:" ,name)
		   (progn ,@body)))
	     (delete-region ,b ,e))
	   #\LFD))

(setf (get 'with-encode-mime-header 'lisp-indent-hook) 1)

(defun encode-mime-header ()
  (save-excursion
    (let (nb ne bb be name)
      (goto-bol)
      (while (looking-at "^\\([\041-\071\073-\176]+\\):[ \t]*")
	(setq nb (match-beginning 1) ne (match-end 1) bb (match-end 0))
	(while (and (or (forward-line 1)
			(progn (goto-eol) nil))
		    (looking-at "[ \t]")))
	(setq be (point))
	(setq name (buffer-substring nb ne))
	(case (gethash name *encode-mime-header-type*)
	  (address
	   (with-encode-mime-header (nb be name)
	     (encode-mime-address (buffer-substring bb be))))
	  (content
	   (with-encode-mime-header (nb be name)
	     (encode-mime-content (buffer-substring bb be))))
	  (t
	   (unless (consp (parse-char-encoding-region '(:us-ascii) bb be))
	     (with-encode-mime-header (nb be name)
	       (encode-mime-field-body (buffer-substring bb be))))))))))
