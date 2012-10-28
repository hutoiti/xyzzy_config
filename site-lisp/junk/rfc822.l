;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
;$Id: rfc822.l 769 2007-12-14 19:18:39Z torihat $
;
; rfc822.l
;
; Contributed by Tetsuya Kamei at Thu, 30 Mar 2000 20:25:07 +0900

(provide "junk/rfc822")

(in-package "junk")

(defvar *rfc822-lex-last-token* nil)
(defvar *rfc822-lex-backup-p* nil)
(defvar *rfc822-lex-string* nil)
(defvar *rfc822-lex-index* nil)
(defvar *rfc822-lex-tokb* nil)
(defvar *rfc822-lex-toke* nil)
(defvar *rfc822-addr-list* nil)
(defvar *rfc822-strict* nil)
(defvar *rfc822-allow-local* nil)
(defvar *rfc822-allow-group* nil)
(defvar *rfc822-allow-list* nil)
(defvar *rfc822-allow-source-route* nil)

(defun rfc822-backup-token ()
  (setq *rfc822-lex-backup-p* t))

(defun rfc822-last-token-string (&optional (b *rfc822-lex-tokb*) (e *rfc822-lex-toke*))
  (subseq *rfc822-lex-string* b e))

(defun rfc822-good-dotnum-p (dotnum)
  (let* ((num (split-string dotnum #\. t " \t\r\n"))
	 (nparts (length num)))
    (when (<= 1 nparts 4)
      (mapc #'(lambda (num lim)
		(when (> (cond ((string-matchp "^0x[0-9a-z]+$" num)
				(parse-integer num :radix 16 :start 2))
			       ((string-match "^0[0-9]+$" num)
				(when (string-match "[89]" num)
				  (return-from rfc822-good-dotnum-p nil))
				(parse-integer num :radix 8))
			       ((string-match "^[0-9]+$" num)
				(parse-integer num :radix 10))
			       (t
				(return-from rfc822-good-dotnum-p nil)))
			 lim)
		  (return-from rfc822-good-dotnum-p nil)))
	    num (svref #(nil (4294967295) (255 16777215) (255 255 65535) (255 255 255 255)) nparts))
      t)))

(defun rfc822-next-token ()
  (when *rfc822-lex-backup-p*
    (setq *rfc822-lex-backup-p* nil)
    (return-from rfc822-next-token *rfc822-lex-last-token*))
  (setq *rfc822-lex-last-token*
	(loop
	  (when (string-looking-at "[ \t\r\n]+" *rfc822-lex-string*
				   :start *rfc822-lex-index*)
	    (setq *rfc822-lex-index* (match-end 0)))
	  (when (= *rfc822-lex-index* (length *rfc822-lex-string*))
	    (return nil))
	  (let ((c (char *rfc822-lex-string* *rfc822-lex-index*)))
	    (cond ((find c "<>@,;:.")
		   (incf *rfc822-lex-index*)
		   (return c))
		  ((char= c #\()
		   (let ((depth 1))
		     (loop
		       (setq *rfc822-lex-index*
			     (or (string-match "[()\\]" *rfc822-lex-string* (1+ *rfc822-lex-index*))
				 (error "unterminated comment")))
		       (case (char *rfc822-lex-string* *rfc822-lex-index*)
			 (#\(
			  (incf depth))
			 (#\)
			  (decf depth)
			  (when (zerop depth)
			    (incf *rfc822-lex-index*)
			    (return)))
			 (t
			  (incf *rfc822-lex-index*)
			  (when (= *rfc822-lex-index* (length *rfc822-lex-string*))
			    (error "orphaned \\ in comment")))))))
		  ((char= c #\[)
		   (setq *rfc822-lex-tokb* *rfc822-lex-index*)
		   (loop
		     (setq *rfc822-lex-index*
			   (or (string-match "[][\\]" *rfc822-lex-string* (1+ *rfc822-lex-index*))
			       (error "unterminated domain-literal")))
		     (case (char *rfc822-lex-string* *rfc822-lex-index*)
		       (#\[
			(error "unterminated domain-literal"))
		       (#\]
			(incf *rfc822-lex-index*)
			(return))
		       (t
			(incf *rfc822-lex-index*)
			(when (= *rfc822-lex-index* (length *rfc822-lex-string*))
			  (error "orphaned \\ in domain-literal")))))
		   (setq *rfc822-lex-toke* *rfc822-lex-index*)
		   (when (and *rfc822-strict*
			      (not (rfc822-good-dotnum-p (subseq *rfc822-lex-string*
								 (1+ *rfc822-lex-tokb*)
								 (1- *rfc822-lex-toke*)))))
		     (error "bad dotnum"))
		   (return 'domain-literal))
		  ((char= c #\")
		   (setq *rfc822-lex-tokb* *rfc822-lex-index*)
		   (loop
		     (setq *rfc822-lex-index*
			   (or (string-match "[\"\\]" *rfc822-lex-string* (1+ *rfc822-lex-index*))
			       (error "unterminated quoted-string")))
		     (case (char *rfc822-lex-string* *rfc822-lex-index*)
		       (#\"
			(incf *rfc822-lex-index*)
			(return))
		       (t
			(incf *rfc822-lex-index*)
			(when (= *rfc822-lex-index* (length *rfc822-lex-string*))
			  (error "orphaned \\ in quoted-string")))))
		   (setq *rfc822-lex-toke* *rfc822-lex-index*)
		   (return 'quoted-string))
		  ((char= c #\))
		   (error "unbalanced )"))
		  ((char= c #\])
		   (error "unbalanced ]"))
		  ((char= c #\\)
		   (error "unexpected \\"))
		  (t
		   (setq *rfc822-lex-tokb* *rfc822-lex-index*)
		   (string-looking-at "[^][ \t\r\n()<>@,;:\\\".]+" *rfc822-lex-string*
				      :start *rfc822-lex-index*)
		   (setq *rfc822-lex-index* (match-end 0))
		   (when (string-match "[\000-\037]" *rfc822-lex-string*
				       *rfc822-lex-tokb* *rfc822-lex-index*)
		     (error "invalid control character in atom"))
		   (setq *rfc822-lex-toke* *rfc822-lex-index*)
		   (return 'atom)))))))

(defun rfc822-sub-domain (stream lead-dot-p)
  (let ((tok (rfc822-next-token)))
    (cond ((eq tok 'atom)
	   (when lead-dot-p
	     (write-char #\. stream))
	   (princ (rfc822-last-token-string) stream))
	  ((eq tok 'domain-literal)
	   (when lead-dot-p
	     (write-char #\. stream))
	   (princ (substitute-string (rfc822-last-token-string) "[ \t\r\n]" "") stream))
	  (t
	   (when (or *rfc822-strict* (not lead-dot-p))
	     (error "bad sub-domain"))
	   nil))))

(defun rfc822-domain (stream)
  (rfc822-sub-domain stream nil)
  (while (and (eql (rfc822-next-token) #\.)
	      (rfc822-sub-domain stream t)))
  (rfc822-backup-token))

(defun rfc822-addr-spec (stream)
  (loop
    (unless (member (rfc822-next-token) '(atom quoted-string))
      (error "bad addr-spec"))
    (princ (rfc822-last-token-string) stream)
    (case (rfc822-next-token)
      (#\.
       (write-char #\. stream))
      (#\@
       (write-char #\@ stream)
       (rfc822-domain stream)
       (return))
      (t
       (when *rfc822-allow-local*
	 (rfc822-backup-token)
	 (return))
       (error "bad addr-spec")))))

(defun rfc822-route (stream)
  (loop
    (unless (eql (rfc822-next-token) #\@)
      (error "illegal route"))
    (write-char #\@ stream)
    (rfc822-domain stream)
    (case (rfc822-next-token)
      (#\,
       (write-char #\, stream))
      (#\:
       (write-char #\: stream)
       (return))
      (t
       (error "illegal route")))))

(defun rfc822-route-addr (stream)
  (when (prog1
	    (eql (rfc822-next-token) #\@)
	  (rfc822-backup-token))
    (unless *rfc822-allow-source-route*
      (error "explicit source routes may not allowed"))
    (rfc822-route stream))
  (rfc822-addr-spec stream)
  (unless (eql (rfc822-next-token) #\>)
    (error "missing >")))

(defun rfc822-parse-address-1 (parse-groups)
  (loop
    (let ((nwords 0)
	  (tok (rfc822-next-token))
	  (tokb *rfc822-lex-tokb*)
	  (toke *rfc822-lex-toke*)
	  addr)
      (while (or (eq tok 'quoted-string)
		 (eq tok 'atom))
	(incf nwords)
	(setq tok (rfc822-next-token)))
      (setq addr (cond ((or (eq tok 'domain-literal)
			    (eql tok #\>))
			(error "unexpected ~a" tok))
		       ((eql tok #\<)
			(with-output-to-string (stream)
			  (rfc822-route-addr stream)))
		       ((eql tok #\@)
			(unless (= nwords 1)
			  (error "missing comma"))
			(with-output-to-string (stream)
			  (princ (rfc822-last-token-string tokb toke) stream)
			  (write-char tok stream)
			  (rfc822-domain stream)))
		       ((eql tok #\:)
			(when parse-groups
			  (error "unexpected :"))
			(unless *rfc822-allow-group*
			  (error "group may not allowed"))
			(when (zerop nwords)
			  (error "no phrases for group"))
			(rfc822-parse-address-1 t))
		       ((eql tok #\.)
			(unless (= nwords 1)
			  (error "Unexpected ."))
			(with-output-to-string (stream)
			  (princ (rfc822-last-token-string tokb toke) stream)
			  (write-char tok stream)
			  (rfc822-addr-spec stream)))
		       (t
			(rfc822-backup-token)
			(cond ((null tok)
			       (when parse-groups
				 (error "Missing ;")))
			      ((eql tok #\;)
			       (unless parse-groups
				 (error "unexpected ;")))
			      (t
			       (when (zerop nwords)
				 (error "empty address"))))
			(case nwords
			  (0 nil)
			  (1
			   (unless *rfc822-allow-local*
			     (error "bad address format"))
			   (rfc822-last-token-string))
			  (t
			   (error "missing ,"))))))
      (when addr
	(push addr *rfc822-addr-list*))
      (setq tok (rfc822-next-token))
      (cond ((or (null tok)
		 (and parse-groups (eql tok #\;)))
	     (return))
	    ((eql tok #\,)
	     (unless *rfc822-allow-list*
	       (error "list may not allowed")))
	    (t
	     (error "missing ,"))))))

(defun rfc822-parse-address (string &key strict allow-local allow-group allow-list allow-source-route)
  (let ((*rfc822-lex-last-token* nil)
	(*rfc822-lex-backup-p* nil)
	(*rfc822-addr-list* nil)
	(*rfc822-lex-string* string)
	(*rfc822-lex-index* 0)
	(*rfc822-strict* strict)
	(*rfc822-allow-local* allow-local)
	(*rfc822-allow-group* allow-group)
	(*rfc822-allow-list* allow-list)
	(*rfc822-allow-source-route* allow-source-route))
    (rfc822-parse-address-1 nil)
    (nreverse *rfc822-addr-list*)))

(defun rfc822-parse-msgid (string &key strict allow-local allow-list)
  (if strict
      (let ((*rfc822-lex-last-token* nil)
	    (*rfc822-lex-backup-p* nil)
	    (*rfc822-addr-list* nil)
	    (*rfc822-lex-string* string)
	    (*rfc822-lex-index* 0)
	    (*rfc822-strict* strict)
	    (*rfc822-allow-local* allow-local)
	    (*rfc822-allow-list* allow-list)
	    (*rfc822-allow-source-route* t))
	(let ((nmsgid 0))
	  (loop
	    (let ((tok (rfc822-next-token)))
	      (while (or (eq tok 'quoted-string)
			 (eq tok 'atom))
		(setq tok (rfc822-next-token)))
	      (cond ((null tok)
		     (return))
		    ((eql tok #\<)
		     (unless (or (zerop nmsgid) *rfc822-allow-list*)
		       (error "list may not allowed"))
		     (incf nmsgid)
		     (push (with-output-to-string (stream)
			     (write-char #\< stream)
			     (rfc822-addr-spec stream)
			     (unless (eql (rfc822-next-token) #\>)
			       (error "missing >"))
			     (write-char #\> stream))
			   *rfc822-addr-list*))
		    ((eql tok #\,)
		     (when *rfc822-strict*
		       (error "unexpected ,")))
		    (t
		     (error "unexpected ~a" tok))))))
	(nreverse *rfc822-addr-list*))
    (let ((*rfc822-addr-list* nil)
	  (index 0))
      (while (string-match "<[^<>\n]+>" string index)
	(push (subseq string (match-beginning 0) (match-end 0))
	      *rfc822-addr-list*)
	(setq index (match-end 0)))
      (nreverse *rfc822-addr-list*))))
