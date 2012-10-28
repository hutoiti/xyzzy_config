;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: lib.l 769 2007-12-14 19:18:39Z torihat $
;
; junk/lib.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "junk/defs")
  (require "junk/macro"))

(provide "junk/lib")

(in-package "junk")

(defun data-read-from-file (file)
  (let (data)
    (with-open-file (s
		     file
		     :direction :input
		     :if-does-not-exist :error)
      (let (tmp)
	(while (setq tmp (read s nil))
	  (push tmp data))))
    (nreverse data)))

(defun data-write-to-file (file data)
  (with-open-file (s
		   file
		   :direction :output
		   :if-exists :overwrite
		   :if-does-not-exist :create)
    (format s "~{~S~%~}" data))
  t)

(defun md5sum (file)
  (let (sum)
    (with-open-file (is file
			:direction :input
			:encoding :binary)
      (setq sum (si:md5 is)))
    sum))

(defun junk-message (fmt &rest args)
  (apply #'message (concat *prog-name* ": " fmt) args))

(defun junk-msgbox (fmt &rest args)
  (message-box (apply #'format nil fmt args)
	       *prog-name*))

(defun junk-error (fmt &rest args)
  (apply #'error (concat *prog-name* "~%~%" fmt) args))

(defun url-http-p (url)
  (string-match "^http://" url))

(defun url-local-p (url)
  (or (string-match "^[a-zA-Z]:/" url)
      (string-match "^//" url)))

(defun url-to-filename (url)
  (cond ((url-http-p url)
	 (si:www-url-encode url))
	((url-local-p url)
	 url)
	(t
	 (ni-msgbox "URL解析不能: ~S" url))))

(defun string-length (str)
  (1- (si:chunk-size (si:make-string-chunk str))))

(defun reverse-line ()
  (clear-reverse-region)
  (reverse-region (progn (goto-eol) (point))
		  (progn (goto-bol) (point))))

(defun string-join (list &optional (expr " "))
  (let (str)
    (while list
      (if str
	  (setq str (concat str expr (car list)))
	(setq str (car list)))
      (setq list (cdr list))
      )
    str))

(defun open-in-browser (url)
  (shell-execute url t))

(defun rfc822-format-date (&optional time (tzdiff 9))
  "Dateヘッダー書式化して返す。(ex.Date: Sun, 12 Sep 1999 13:18:13 GMT)"
  (setq time (- (or time (get-universal-time)) (* tzdiff 60 60)))
  (format-date-string "%a, %d %b %Y %H:%M:%S GMT" time))

(defun rfc822-format-date-local (&optional time)
  (format-date-string "%a, %d %b %Y %H:%M:%S %Z" time))

(defun parse-http-header (is)
  (let (line headers)
    (unless (setq line (read-line is nil))
      (junk-error "Connection closed."))
    (loop
      (or line (return))
      (cond ((string= line "")
	     (return))
	    ((string-match "^\\([-a-zA-Z0-9_]+\\)[ \t]*:[ \t]*\\(.*\\)" line)
	     (let (key val)
	       (junk-message "~A" line)
	       (setq key (nstring-downcase (match-string 1)))
	       (setq val (match-string 2))
	       (if (setq line (read-line is nil))
		   (while (string-match "^[ \t]+\\(.*\\)" line)
		     (setq val (concat val line))
		     (unless (setq line (read-line is nil))
		       (return)))
		 (return))
	       (push (cons (nstring-downcase key) val) headers)
	       ))
	    (t
	     (junk-msgbox "Not header line: ~S" line)
	     (or (setq line (read-line s nil)) (return)))
	    ))
    (values headers is)))

(defun load-config-file (file)
  (let ((lc (concat file "c")))
    (if (file-exist-p lc)
	(if (file-newer-than-file-p file lc)
	    (load file)
	  (load lc))
      (if (file-exist-p file)
	  (load file)))))

(defun pack-H* (str)
  (let ((len (length str))
	(i 0))
    (with-output-to-string (s)
      (while (< i len)
	(let ((tmp (parse-integer (substring str i (min len (+ i 2))) :radix 16)))
	  (format s "~C" (code-char tmp))
	  (incf i 2))))))

(defvar *rfc822-date-time-regexp*
  (compile-regexp
   "^[ \t]*\\([A-Za-z]+[ \t]*,[ \t]*\\)?\\([0-9]+\\)[ \t]+\\([A-Za-z]+\\)[ \t]+\\([0-9]+\\)[ \t]+\\\([0-9]+\\):\\([0-9]+\\)\\(:\\([0-9]+\\)\\)?\\([ \t]+\\([-+][0-9]+\\|[A-Za-z]+\\)\\)?"))

(defvar *rfc822-month-name-hash*
  (let ((hash (make-hash-table :test #'equalp)))
    (dotimes (i 12)
      (setf (gethash (svref #("Jan" "Feb" "Mar" "Apr" "May" "Jun"
			      "Jul" "Aug" "Sep" "Oct" "Nov" "Dec")
			    i)
		     hash)
	    (+ i 1)))
    hash))
 
(defvar *rfc822-timezone-hash-table*
  (let ((hash (make-hash-table :test #'equal)))
    (mapc #'(lambda (x)
	      (setf (gethash (car x) hash) (cdr x)))
	  '(("A" . "-0100") ("B" . "-0200") ("C" . "-0300") ("D" . "-0400")
	    ("E" . "-0500") ("F" . "-0600") ("G" . "-0700") ("H" . "-0800")
	    ("I" . "-0900") ("K" . "-1000") ("L" . "-1100") ("M" . "-1200")
	    ("N" . "+0100") ("O" . "+0200") ("P" . "+0300") ("Q" . "+0400")
	    ("R" . "+0500") ("S" . "+0600") ("T" . "+0700") ("U" . "+0800")
	    ("V" . "+0900") ("W" . "+1000") ("X" . "+1100") ("Y" . "+1200")
	    ("Z" . "+0000")
	    ("IDLW" . "-1200") ("NT" . "-1100") ("AHST" . "-1000") ("CAT" . "-1000")
	    ("HST" . "-1000") ("YST" . "-0900") ("PST" . "-0800") ("MST" . "-0700")
	    ("CST" . "-0600") ("EST" . "-0500") ("AST" . "-0400") ("AT" . "-0200")
	    ("WAT" . "-0100") ("GMT" . "+0000") ("UT" . "+0000") ("UTC" . "+0000")
	    ("WET" . "+0000") ("CET" . "+0100") ("FWT" . "+0100") ("MET" . "+0100")
	    ("MEWT" . "+0100") ("SWT" . "+0100") ("EET" . "+0200") ("BT" . "+0300")
	    ("ZP4" . "+0400") ("ZP5" . "+0500") ("ZP6" . "+0600") ("WAST" . "+0700")
	    ("CCT" . "+0800") ("HKT" . "+0800") ("JST" . "+0900") ("EAST" . "+1000")
	    ("GST" . "+1000") ("IDLE" . "+1200") ("NZST" . "+1200") ("NZT" . "+1200")
	    ("HDT" . "-0900") ("YDT" . "-0800") ("PDT" . "-0700") ("MDT" . "-0600")
	    ("CDT" . "-0500") ("EDT" . "-0400") ("ADT" . "-0400") ("BST" . "+0100")
	    ("MEST" . "+0200") ("MESZ" . "+0200") ("SST" . "+0200") ("FST" . "+0200")
	    ("WADT" . "+0800") ("EADT" . "+1100") ("NZDT" . "+1300")))
    hash))
   
(defun rfc822-parse-date (date)
  (when date
    (while (let (f)
	     (multiple-value-setq (date f)
	       (substitute-string date "([^()]*)" " "))
	     (and f (plusp f))))
    (when (string-match *rfc822-date-time-regexp* date)
      (encode-universal-time (if (match-beginning 8)
				 (parse-integer (subseq date (match-beginning 8) (match-end 8)))
			       0)
			     (parse-integer (subseq date (match-beginning 6) (match-end 6)))
			     (parse-integer (subseq date (match-beginning 5) (match-end 5)))
			     (parse-integer (subseq date (match-beginning 2) (match-end 2)))
			     (gethash (subseq date (match-beginning 3) (match-end 3))
				      *rfc822-month-name-hash* 1)
			     (parse-integer (subseq date (match-beginning 4) (match-end 4)))
			     (if (match-beginning 9)
				 (let ((zone (subseq date (match-beginning 9) (match-end 9))))
				   (setq zone (string-left-trim " \t" zone))
				   (when (string-match "^[a-zA-Z]+$" zone)
				     (setq zone (gethash zone *rfc822-timezone-hash-table* zone)))
				   (if (string-match "^[-+][0-9][0-9][0-9][0-9]$" zone)
				       (- (truncate (parse-integer zone) 100))
				     0))
			       0)))))

(defun iso8601-format-datetime (&optional timestamp (tz "+09:00"))
  (concat (format-date-string "%Y-%m-%dT%H:%M:%S" timestamp)
	  tz))

(defvar *iso8601-date-time-regexp*
  (compile-regexp
   "\\([0-9]\\{4\\}\\)-?\\([0-9]\\{2\\}\\)-?\\([0-9]\\{2\\}\\)T\\([0-9]\\{2\\}\\):\\([0-9]\\{2\\}\\)\\(:\\([0-9]\\{2\\}\\)\\)?\\([-+][0-9][0-9]:?[0-9][0-9]\\|Z\\)?"))

(defun iso8601-parse-datetime (str)
  (when (string-match *iso8601-date-time-regexp* str)
    (let ((year  (parse-integer (match-string 1)))
	  (month (parse-integer (match-string 2)))
	  (day   (parse-integer (match-string 3)))
	  (hour  (parse-integer (match-string 4)))
	  (min   (parse-integer (match-string 5)))
	  (sec   (if (match-beginning 6)
		     (parse-integer (match-string 7))
		   0))
	  (tzdiff 0))
      (when (match-beginning 8)
	(let ((tz (match-string 8)))
	  (unless (equal tz "Z")
	    (setq tzdiff
		  (- (truncate (parse-integer
				(substitute-string tz ":" ""))
			       100))))))
      (encode-universal-time sec min hour day month year tzdiff))))

(defun cram-md5-responce (user pass challenge)
  (si:base64-encode
   (concat user " " (si:hmac-md5 pass (si:base64-decode challenge)))
   nil t))

(defun file-content-type (file)
  (or (let ((ext (pathname-type file)))
	(and ext (read-registry (concat "." ext)
				"Content Type" :classes-root)))
      "application/octet-stream"))

(defun insert-file-noconv (file)
  (let ((*expected-fileio-encoding* *encoding-sjis*))
    (declare (special *expected-fileio-encoding*))
    (insert-file-contents file)))

(defun create-directory-if (dir)
  (unless (file-exist-p dir)
    (or (create-directory dir)
	(junk-error "Could not create directory: ~S" dir))))

(defvar *parse-address-regexp* "<?\\([-0-9a-zA-Z\._]+@[-0-9a-zA-Z\._]+\\)>?")

(defun parse-addresses (addr-string)
  (unless (stringp addr-string)
    (return-from parse-addresses))
  (let ((tmp-list (split-string addr-string ","))
	tmp
	addrs)
    (while (setq tmp (car tmp-list))
      (setq tmp-list (cdr tmp-list))
      (if (string-match *parse-address-regexp* tmp)
	  (multiple-value-bind (email name)
	      (parse-address tmp)
	    (when email
	      (pushnew (cons email name) addrs :test #'equal :key #'car)))
	(setf (car tmp-list) (concat tmp (car tmp-list)))))
    (nreverse addrs)))

(defun parse-address (addr-string)
  (unless (stringp addr-string)
    (return-from parse-address))
  (let (name
	email)
    (when (string-match *parse-address-regexp* addr-string)
      (setq email (match-string 1))
      (setq name (concat
		  (string-trim " \n\t" (substring addr-string 0 (match-beginning 0)))
		  " "
		  (string-trim " \n\t" (substring addr-string (match-end 0) (length addr-string))))))
    (when name
      (setq name (string-trim " \n\t" name))
      (when (string-match "^[(（\"'].*[)）\"']$" name)
	(setq name (substring name 1 (1- (length name)))))
      (when (equal name "")
	(setq name nil)))
    (values email name)))

(defun format-address (email name)
  (if name
      (format nil "\"~A\" <~A>" name email)
    email))

(defun abbreviate-menu-string (string &optional (maxlen 74))
  (if (<= (length string) maxlen)
      string
    (concat (abbreviate-string-column string (- maxlen 3))
	    "...")))

(defun parse-mailto (mailto)
  (when (string-matchp "mailto:\\([^?]+\\)\\(\\?\\(.+\\)\\)?" mailto)
    (let* ((header
	    (cons (cons "to" (subseq mailto (match-beginning 1) (match-end 1)))
		  (and (match-beginning 3)
		       (mapcan #'(lambda (x)
				   (let ((i (position #\= x)))
				     (and i (list (cons (nstring-downcase (subseq x 0 i))
							(subseq x (+ i 1)))))))
			       (split-string (subseq mailto (match-beginning 3)) #\&)))))
	   (encoding (and (find #\% mailto)
			  (detect-char-encoding (si:www-url-decode mailto)))))
      (if encoding
	  (mapcar #'(lambda (x)
		      (let ((f (car x))
			    (v (cdr x)))
			(cons f (convert-encoding-to-internal
				 encoding (si:www-url-decode v)))))
		  header)
	header))))


(defun read-password (&optional prompt &key (default ""))
  (interactive)
  (let ((pw default)
	ch
	len)
    (loop
      (minibuffer-prompt "~A~A"
			 (or prompt "Password: ")
			 (substitute-string pw "." "*"))
      (setq ch (read-char ed:*keyboard*))
      (cond ((char= ch #\RET)
	     (return))
	    ((char= ch #\C-h)
	     (when (< 0 len)
	       (setq pw (substring pw 0 (1- len)))))
	    ((char= ch #\C-u)
	     (setq pw ""))
	    ((char= ch #\C-g)
	     (quit))
	    (t
	     (setq pw (format nil "~A~C" pw ch)))
	    ))
    pw))
