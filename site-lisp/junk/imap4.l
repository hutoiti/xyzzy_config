;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: imap4.l 779 2007-12-23 05:14:06Z torihat $
;
; imap4.l
;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "junk/defs")
  (require "junk/macro"))
(require "junk/lib")
(require "junk/log")
(require "junk/mail")

(provide "junk/imap4")

(in-package "junk")

(defconstant *imap4-port* 143)

(defvar *imap4-buffer-prefix* "*Junk:IMAP4 ")
(defvar *imap4-buffer-output* (concat *imap4-buffer-prefix* "OUTPUT*"))
(defvar *imap4-buffer-temp* (concat *imap4-buffer-prefix* "TEMP*"))

(defvar *imap4-debug* nil)
(defvar *imap4-stream-output* nil)

(defconstant *imap4-authenticate-type-login* "LOGIN")
(defconstant *imap4-authenticate-type-cram-md5* "CRAM-MD5")

(defvar *imap4-capability* '(*imap4-authenticate-type-cram-md5*))
(defvar *imap4-authenticate-type-default* "LOGIN")

(defconstant *imap4-status-none*          0)
(defconstant *imap4-status-connected*     1)
(defconstant *imap4-status-authenticated* 2)
(defconstant *imap4-status-selected*      3)

(defconstant *imap4-flag-flagged*  "\\Flagged")
(defconstant *imap4-flag-seen*     "\\Seen")
(defconstant *imap4-flag-answered* "\\Answered")
(defconstant *imap4-flag-deleted*  "\\Deleted")
(defconstant *imap4-flag-draft*    "\\Draft")
(defconstant *imap4-flag-recent*   "\\Recente")

(defstruct
  (imapstream
   (:constructor imapstream-create (stream status number)))
  stream status number folder auth)

;
; other functions
;
(defun imap4-tag-current (stream)
  "現在のタグ番号を返す"
  (format nil "A~3,'0D" (imapstream-number stream))
)

(defun imap4-tag-increment (stream)
  "タグ番号をひとつ進めて返す"
  (let ((number (imapstream-number stream)))
    (setf (imapstream-number stream) (1+ number))
    (imap4-tag-current stream)
  ))

(defun imap4-return-ok-p (stream return)
  (if (and (stringp return)
	   (string-match (format nil "^~A[ \t]+OK" (imap4-tag-current stream)) return))
      (values t return)
    (values nil return)
    ))

(defun imap4-return-continue-p (stream return)
  (if (and (stringp return)
	   (equal "+" (substring return 0 1)))
      (values t return)
    (values nil return)
    ))

(defun imap4-read-line (stream)
  (let (return)
    (setq return (read-line (imapstream-stream stream) nil))
    (when *imap4-stream-output*
      (format *imap4-stream-output* "~@[~A~]~%" return))
    return))

(defun imap4-warn (str)
  (format *imap4-stream-output* "IMAP WARN: ~A~%" str))

(defun imap4-folder-name-encode (folder)
  (map-internal-to-utf-7 folder nil t t t))

(defun imap4-folder-name-decode (folder)
  (map-utf-7-to-internal folder nil t))

(defun imap4-uid-join (uid-list)
  (format nil "~A~{,~A~}" (car uid-list) (cdr uid-list)))

(defvar *imap4-socket-stream-timeout* 180)

(defun imap4-socket-stream-set-timeout (stream timeout)
  (socket-stream-set-timeout (imapstream-stream stream) timeout))

(defun imap4-init ()
  (when *imap4-debug*
    (unless *imap4-stream-output*
      (save-excursion
	(set-buffer (get-buffer-create *imap4-buffer-output*))
	(erase-buffer (selected-buffer))
	(setq need-not-save t)
	(setq kept-undo-information nil)
	(setq auto-save nil)
	(setq *imap4-stream-output* (make-buffer-stream *imap4-buffer-output*))
	))))

(defun imap4-open (server &optional port timeout)
  (let (return sock stream)
    (imap4-init)
    (message "Connecting to server: ~A" server)
    (setq sock (connect server (or port *imap4-port*)))
    (setq stream (imapstream-create sock *imap4-status-connected* 0))
    (imap4-socket-stream-set-timeout stream (or timeout *imap4-socket-stream-timeout*))
    (setq return (imap4-read-line stream))
    (message "~A" return)
    (multiple-value-bind (result auth)
	(imap4-capability stream)
      (setf (imapstream-auth stream) auth))
    stream
  ))

(defun imap4-connected-p (stream)
  (and stream
       (>= (imapstream-status stream)
	   *imap4-status-connected*)))

(defun imap4-authenticated-p (stream)
  (and stream
       (>= (imapstream-status stream)
	   *imap4-status-authenticated*)))

(defun imap4-selected-p (stream)
  (and stream
       (= (imapstream-status stream)
	  *imap4-status-selected*)))

(defun imap4-selected-folder-p (stream folder-name)
  (and (imap4-selected-p stream)
       (stringp (imapstream-folder stream))
       (string= (imapstream-folder stream) (imap4-folder-name-encode folder-name))))

;
; LOGIN LOGOUT
;

(defun imap4-capable-p (stream auth)
  (member auth (imapstream-auth stream) :test #'string-equal))

(defun imap4-authenticate-type (stream)
  (dolist (x *imap4-capability*)
    (when (imap4-capable-p stream x)
      (message "Selecting ~A" x)
      (return-from imap4-authenticate-type x)))
  *imap4-authenticate-type-default*)

(defun imap4-login (stream user pass &optional auth)
  (setq auth (or auth (imap4-authenticate-type stream)))
  (cond ((string-equal *imap4-authenticate-type-cram-md5* auth)
	 (imap4-authenticate-cram-md5 stream user pass))
	(t
	 (imap4-authenticate-login stream user pass))
  ))

(defun imap4-authenticate-login (stream user pass)
  (unless (imap4-connected-p stream)
    (return-from imap4-authenticate-login nil))
  (let ((return ""))
    (message "Logging in as ~A ..." user)
    (format (imapstream-stream stream) "~A LOGIN ~A ~A~%" (imap4-tag-increment stream) user pass)
    (format *imap4-stream-output* "~A LOGIN ~A ~A~%" (imap4-tag-current stream) user pass)
    (while (not (string-match "^A[0-9]+" return))
      (setq return (imap4-read-line stream)))
    (message "~A" return)
    (when (imap4-return-ok-p stream return)
      (setf (imapstream-status stream) *imap4-status-authenticated*)
      t)
  ))

(defun imap4-authenticate-cram-md5 (stream user pass)
  (unless (imap4-connected-p stream)
    (return-from imap4-authenticate-cram-md5 nil))
  (let ((return ""))
    (message "Logging in as ~A ..." user)
    (format (imapstream-stream stream) "~A AUTHENTICATE CRAM-MD5~%" (imap4-tag-increment stream))
    (format *imap4-stream-output* "~A AUTHENTICATE CRAM-MD5~%" (imap4-tag-current stream))
    (setq return (imap4-read-line stream))
    (when (string-match "^+ \\([^ \t]+\\)$" return)
      (let* ((challenge (substring return (match-beginning 1) (match-end 1)))
	     (response (cram-md5-responce user pass challenge)))
	(format (imapstream-stream stream) "~A~%" response)
	(format *imap4-stream-output* "~A~%" response)
	(setq return (imap4-read-line stream))))
    (while (not (string-match "^A[0-9]+" return))
      (setq return (imap4-read-line stream)))
    (when (imap4-return-ok-p stream return)
      (setf (imapstream-status stream) *imap4-status-authenticated*)
      t)
  ))

(defun imap4-logout (stream)
  (unless (imap4-authenticated-p stream)
    (setq stream nil)
    (return-from imap4-logout nil))
  (when (imap4-selected-p stream)
    (imap4-close stream))
  (let ((return "")
	flag)
    (message "Logging out ...")
    (format (imapstream-stream stream) "~A LOGOUT~%" (imap4-tag-increment stream))
    (format *imap4-stream-output* "~A LOGOUT~%" (imap4-tag-current stream))
    (while (not (string-match "^A[0-9]+" return))
      (setq return (imap4-read-line stream)))
    (message "~A" return)
    (setq flag (imap4-return-ok-p stream return))
    (setq stream nil)
    (values flag return)
    ))

(defun imap4-noop (stream)
  (unless (imap4-authenticated-p stream)
    (return-from imap4-noop nil))
  (let (return)
    (format (imapstream-stream stream) "~A NOOP~%" (imap4-tag-increment stream))
    (format *imap4-stream-output* "~A NOOP~%" (imap4-tag-current stream))
    (setq return (imap4-read-line stream))
    (while (and return
		(not (string-match "^A[0-9]+" return)))
      (setq return (imap4-read-line stream)))
    (message "~A" return)
    (imap4-return-ok-p stream return)
    ))

(defun imap4-capability (stream)
  (unless (imap4-connected-p stream)
    (return-from imap4-capability nil))
  (let (return auth)
    (format (imapstream-stream stream) "~A CAPABILITY~%" (imap4-tag-increment stream))
    (format  t "~A CAPABILITY~%" (imap4-tag-current stream))
    (setq return (imap4-read-line stream))
    (message "~A" return)
    (when (string-match "^\* CAPABILITY" return)
      (while (string-match "AUTH=\\([^ \t]+\\)" return)
	(push (substring return (match-beginning 1) (match-end 1)) auth)
	(setq return (substring return (match-end 0) (length return)))))
    (while (not (string-match "^A[0-9]+" return))
      (setq return (imap4-read-line stream)))
    (message "~A" return)
    (values (imap4-return-ok-p stream return) (nreverse auth))
  ))

#|
(defun imap4-append (stream folder string &optional flags)
  "IMAP4 APPEND"
  (unless (imap4-authenticated-p stream)
    (return-from imap4-append))
  (let (return chunk bytes)
    (setq chunk (si:make-string-chunk string))
    (setq bytes (- (si:chunk-size chunk) 1))
    (format (imapstream-stream stream) "~A APPEND ~A (~A) {~D}~%" (imap4-tag-increment stream) folder "\\Seen" bytes)
    (format *imap4-stream-output* "~A APPEND ~A (~A) {~D}~%" (imap4-tag-current stream) folder "\\Seen" bytes)
    (format (imapstream-stream stream) "~A~%" string)
    (format *imap4-stream-output* "~A~%" string)
    (setq return (imap4-read-line stream))
    (while (not (string-match "^A[0-9]+" return))
      (setq return (imap4-read-line stream))
    )
    (message "~A" return)
    (imap4-return-ok-p stream return)
  ))
|#

(defun imap4-append-file (stream folder-name file)
  "IMAP4 APPEND (from file)"
  (unless (imap4-authenticated-p stream)
    (return-from imap4-append-file))
  (unless (file-exist-p file)
    (error "ないっす: ~A" file))
  (let (return
	(folder (imap4-folder-name-encode folder-name))
	(vector (make-vector 4096 :element-type 'character :fill-pointer 0))
	bytes
	(len 0))
    (setq bytes (file-length file))
    (format (imapstream-stream stream) "~A APPEND ~A (~A) {~D}~%"
	    (imap4-tag-increment stream) folder "\\Seen" bytes)
    (format *imap4-stream-output* "~A APPEND ~A (~A) {~D}~%"
	    (imap4-tag-current stream) folder "\\Seen" bytes)
;    (setq return (imap4-read-line stream))
;    (unless (imap4-return-ok-p stream return)
;      (return-from imap4-append-file (values nil return)))
    (with-open-file (s file)
      (interval-message (300)
 	(while (read-into vector s nil)
 	  (princ vector (imapstream-stream stream))
 	  (princ vector *imap4-stream-output*)
	  (incf len (length vector))
	  (message "append: ~D/~D bytes" len bytes))))
    (format (imapstream-stream stream) "~%")
    (format *imap4-stream-output* "~%")
    (setq return (imap4-read-line stream))
    (while (and return
		(not (string-match "^A[0-9]+" return)))
      (setq return (imap4-read-line stream)))
    (message "~A" return)
    (imap4-return-ok-p stream return)
  ))

;
; Authenticated
;

(defun imap4-list (stream &optional path pattern)
  "IMAP4 LIST"
  (setq path (concat "\"" (or path "") "\""))
  (unless pattern
    (setq pattern "%"))
  (let ((return "")
	folders)
    (message "Listing folders: ~A ~A" path pattern)
    (format (imapstream-stream stream) "~A LIST ~A ~A~%" (imap4-tag-increment stream) path pattern)
    (format *imap4-stream-output* "~A LIST ~A ~A~%" (imap4-tag-current stream) path pattern)
    (while (not (string-match "^A[0-9]+" return))
      (setq return (imap4-read-line stream))
      (cond ((string-match "^\*[ \t]+\\(NO\\|BAD\\)" return)
	     (return-from imap4-list))
	    ((string-match "^\*[ \t]+LIST[ \t]+\(\\([^\)]*\\)\)[ \t]+\"\\([^\"]+\\)\"[ \t]+\"\\([^\"]+\\)\"" return)
	     (let ((props (match-string 1))
		   (folder (match-string 3)))
	       (pushnew (list (imap4-folder-name-decode folder) props) folders)
	       (format *imap4-stream-output* "FOLDER: ~A: ~A~%" folder (imap4-folder-name-decode folder))
	       ))
	    ((string-match "^\*[ \t]+LIST[ \t]+\(\\([^\)]+\\)\)[ \t]+\\([^ \t]+\\)[ \t]+\\(.*\\)$" return)
	     (let ((props (match-string 1))
		   (folder (match-string 3)))
	       (pushnew (list (imap4-folder-name-decode folder) props) folders)
	       (format *imap4-stream-output* "FOLDER: ~A: ~A~%" folder (imap4-folder-name-decode folder))
	       ))
	    ))
    (message "~A" return)
    (values (imap4-return-ok-p stream return) (nreverse folders))
    ))

(defun imap4-create (stream folder-name)
  "IMAP4 CREATE"
  (unless (imap4-authenticated-p stream)
    (return-from imap4-create nil))
  (let (return
	(folder (imap4-folder-name-encode folder-name)))
    (format (imapstream-stream stream) "~A CREATE ~A~%" (imap4-tag-increment stream) folder)
    (format  t "~A CREATE ~A~%" (imap4-tag-current stream) folder)
    (setq return (imap4-read-line stream))
    (while (not (string-match "^A[0-9]+" return))
      (setq return (imap4-read-line stream)))
    (message "~A" return)
    (imap4-return-ok-p stream return)
    ))

(defun imap4-delete (stream folder-name)
  "IMAP4 DELETE"
  (unless (imap4-authenticated-p stream)
    (return-from imap4-delete nil))
  (let (return
	(folder (imap4-folder-name-encode folder-name)))
    (format (imapstream-stream stream) "~A DELETE ~A~%" (imap4-tag-increment stream) folder)
    (format  t "~A DELETE ~A~%" (imap4-tag-current stream) folder)
    (setq return (imap4-read-line stream))
    (while (not (string-match "^A[0-9]+" return))
      (setq return (imap4-read-line stream)))
    (message "~A" return)
    (imap4-return-ok-p stream return)
  ))

(defun imap4-rename (stream old-name new-name)
  "IMAP4 RENAME"
  (unless (imap4-authenticated-p stream)
    (return-from imap4-rename nil))
  (let (return
	(old (imap4-folder-name-encode old-name))
	(new (imap4-folder-name-encode new-name)))
    (format (imapstream-stream stream) "~A RENAME ~A ~A~%" (imap4-tag-increment stream) old new)
    (format  t "~A DELETE ~A ~A~%" (imap4-tag-current stream) old new)
    (setq return (imap4-read-line stream))
    (while (not (string-match "^A[0-9]+" return))
      (setq return (imap4-read-line stream)))
    (message "~A" return)
    (imap4-return-ok-p stream return)
  ))

(defun imap4-select (stream folder-name)
  "IMAP4 SELECT"
  (let ((return "")
	(folder (imap4-folder-name-encode folder-name))
	(exists 0)
	(recent 0)
	unseen
	flag)
    (message "Selecting folder: ~A" folder-name)
    (format (imapstream-stream stream) "~A SELECT \"~A\"~%" (imap4-tag-increment stream) folder)
    (format *imap4-stream-output* "~A SELECT \"~A\"~%" (imap4-tag-current stream) folder)
    (while (not (string-match "^A[0-9]+" return))
      (setq return (imap4-read-line stream))
      (cond ((string-match "^\*[ \t]+\\([0-9]+\\)[ \t]+EXISTS" return)
	     (setq exists (parse-integer (substring return (match-beginning 1) (match-end 1)))))
	    ((string-match "^\*[ \t]+\\([0-9]+\\)[ \t]+RECENT" return)
	     (setq recent (parse-integer (substring return (match-beginning 1) (match-end 1)))))
	    ((string-match "^\*[ \t]+OK[ \t]+\[UNSEEN[ \t]+\\([0-9]+\\)\]" return)
	     (setq unseen (parse-integer (substring return (match-beginning 1) (match-end 1)))))
      )
    )
    (message "~A" return)
    (when (setq flag (imap4-return-ok-p stream return))
      (setf (imapstream-folder stream) folder)
      (setf (imapstream-status stream) *imap4-status-selected*))
    (values flag exists recent unseen)
    ))

(defun imap4-status (stream folder-name)
  "IMAP4 STATUS"
  (let ((return "")
	(folder (imap4-folder-name-encode folder-name))
	(exists 0)
	(unseen 0)
       )
    (message "Getting status of folder: ~A" folder-name)
    (format (imapstream-stream stream) "~A STATUS \"~A\" (MESSAGES UNSEEN)~%" (imap4-tag-increment stream) folder)
    (format *imap4-stream-output* "~A STATUS \"~A\" (MESSAGES UNSEEN)~%" (imap4-tag-current stream) folder)
    (setq return (imap4-read-line stream))
    (while (not (string-match "^A[0-9]+" return))
      (cond
       ((string-match
	 (format nil "^\*[ \t]+STATUS[ \t]+\"?~A\"?[ \t]+(MESSAGES[ \t]+\\([0-9]+\\)[ \t]+UNSEEN[ \t]+\\([0-9]+\\))" (regexp-quote folder))
	 return)
	(setq exists (parse-integer (substring return (match-beginning 1) (match-end 1))))
	(setq unseen (parse-integer (substring return (match-beginning 2) (match-end 2))))
	))
      (setq return (imap4-read-line stream)))
    (message "~A" return)
    (values (imap4-return-ok-p stream return) exists unseen)
  ))

;
; Selected
;
(defun imap4-uid-fetch (stream num &optional part)
  "IMAP4 UID FETCH"
  (unless part
    (setq part "RFC822"))
  (imap4-fetch stream num part t))

(defun imap4-fetch (stream num &optional part uid-p)
  "IMAP4 FETCH"
  (unless part
    (setq part "RFC822"))
  (let ((return "")
	(flags "")
	mail
	last
	total)
    (message "Fetching ~A as ~A: " num part)
    (format (imapstream-stream stream) "~A~:[~; UID~] FETCH ~A (FLAGS ~A)~%"
	    (imap4-tag-increment stream) uid-p num part)
    (format *imap4-stream-output* "~A FETCH ~A (FLAGS ~A)~%"
	    (imap4-tag-current stream) uid-p num part)
    (setq return (imap4-read-line stream))
    (if (string-match (format nil "^\*[ \t]+~A[ \t]+FETCH[ \t]+(FLAGS[ \t]+(\\([^)]*\\))[^{]*{\\([0-9]+\\)}" num) return)
	(progn
	  (setq flags (substring return (match-beginning 1) (match-end 1)))
	  (setq total (substring return (match-beginning 2) (match-end 2)))
	  (setq return (imap4-read-line stream))
	)
      (return-from imap4-fetch nil))
    (interval-message (300)
      (while (not (string-match (concat "^" (imap4-tag-current stream) "[ \t]+\\(OK\\|NO\\|BAD\\)") return))
	(setq last (length return))
	(if mail
	    (setq mail (concat mail "\n" return))
	  (setq mail return))
	(message "Fetching ~A as ~A: ~D/~A" num part (length mail) total)
	(setq return (imap4-read-line stream)))
    )
    ;最後の行を取り除く
    (setq mail (substring mail 0 (- (length mail) last)))
    (message "~A" return)
    (values (imap4-return-ok-p stream return) mail flags total)
  )
)

(defun imap4-uid-fetch-to-buffer (stream num &optional buffer)
  "IMAP4 UID FETCH (to buffer)"
  (imap4-fetch-to-buffer stream num buffer t))

(defun imap4-fetch-to-buffer (stream num &optional buffer uid-p)
  "IMAP4 FETCH (to buffer)"
  (let ((buf (or buffer (buffer-name (selected-buffer))))
	tmpfile
	os
	ok-p
	return)
    (unwind-protect
	(progn
	  (setq tmpfile (make-temp-file-name))
	  (when buffer
	    (set-buffer (get-buffer-create buffer)))
	  (erase-buffer buf)
	  (with-open-file (os tmpfile
			      :direction :output
			      :if-exists :overwrite
			      :if-does-not-exist :create)
	    (multiple-value-setq (ok-p return)
	      (imap4-fetch-to-stream stream num os uid-p)))
	  (let ((*expected-fileio-encoding* *encoding-sjis*))
	    (declare (special *expected-fileio-encoding*))
	    (insert-file-contents tmpfile)))
      (when tmpfile
	(delete-file tmpfile)))
    (values ok-p return)))

(defun imap4-uid-fetch-to-stream (stream num os &optional (part "RFC822"))
  "IMAP4 FETCH (to stream)"
  (imap4-fetch-to-stream stream num os t part))

(defun imap4-fetch-to-stream (stream num os &optional uid-p (part "RFC822"))
  "IMAP4 FETCH (to stream)"
  (let ((return "")
	(flags "")
	(len 0)
	total)
    (message "Fetching ~A as ~A" num part)
    (format (imapstream-stream stream) "~A~:[~; UID~] FETCH ~A (FLAGS ~A)~%"
	    (imap4-tag-increment stream) uid-p num part)
    (format *imap4-stream-output* "~A~:[~; UID~] FETCH ~A (FLAGS ~A)~%"
	    (imap4-tag-current stream) uid-p num part)
    (setq return (imap4-read-line stream))
    (if (string-match "^\*[ \t]+[0-9]+[ \t]+FETCH[ \t]+\\((FLAGS[ \t]+(\\([^)]*\\))\\)?[^{]*{\\([0-9]+\\)}" return)
	(progn
	  (setq total (match-string 3))
	  (when (match-beginning 1)
	    (setq flags (match-string 2))))
      (return-from imap4-fetch-to-stream (values nil return)))
    (message "Fetching ~A as ~A ..." num part)
    (read-bytes-from-stream (imapstream-stream stream) os (parse-integer total))
    (while (not (string-match (concat "^" (imap4-tag-current stream) "[ \t]+\\(OK\\|NO\\|BAD\\)") return))
      (setq return (imap4-read-line stream)))
    (message "~A" return)
    (imap4-return-ok-p stream return)
    ))

(defun imap4-uid-fetch-header (stream num)
  "IMAP4 UID FETCH (header)"
  (imap4-fetch-header stream num t))

(defun imap4-fetch-header (stream num &optional uid-p)
  "IMAP4 FETCH (header)"
  (imap4-fetch stream num "RFC822.HEADER" uid-p))

(defun imap4-uid-fetch-size (stream num)
  "IMAP4 UID FETCH (size)"
  (imap4-fetch-size stream num t))

(defun imap4-fetch-size (stream num &optional uid-p)
  "IMAP4 FETCH (size)"
  (let ((part "RFC822.SIZE")
	(return "")
	size)
    (format (imapstream-stream stream) "~A~:[~; UID~] FETCH ~A (~A)~%"
	    (imap4-tag-increment stream) uid-p num part)
    (format *imap4-stream-output* "~A~:[~; UID~] FETCH ~A (~A)~%"
	    (imap4-tag-current stream) uid-p num part)
    (setq return (imap4-read-line stream))
    (while (not (string-match (concat "^" (imap4-tag-current stream) "[ \t]+\\(OK\\|NO\\|BAD\\)") return))
      (when (string-match (format nil "^\*[ \t]+\\([0-9]+\\)[ \t]+FETCH[ \t]+(~A[ \t]+\\([0-9]+\\))" part) return)
	(let ((num (parse-integer (substring return (match-beginning 1) (match-end 1))))
	      (bytes (parse-integer (substring return (match-beginning 2) (match-end 2)))))
	  (push (list num bytes) size)
	)
      )
      (message "~A" return)
      (setq return (imap4-read-line stream))
    )
    (message "~A" return)
    size))

(defun imap4-uid-fetch-structure (stream num)
  "IMAP4 UID FETCH (structure)"
  (imap4-fetch-structure stream num t))

(defun imap4-fetch-structure (stream num &optional uid-p)
  "IMAP4 FETCH (structure)"
  (let ((part "BODYSTRUCTURE")
	(return "")
	structure)
    (format (imapstream-stream stream) "~A~:[~; UID~] FETCH ~A (~A)~%"
	    (imap4-tag-increment stream) uid-p num part)
    (format *imap4-stream-output* "~A~:[~; UID~] FETCH ~A (~A)~%"
	    (imap4-tag-current stream) uid-p num part)
    (setq return (imap4-read-line stream))
    (while (not (string-match (concat "^" (imap4-tag-current stream) "[ \t]+\\(OK\\|NO\\|BAD\\)") return))
      (when (string-match "^\*[ \t]+\\([0-9]+\\)[ \t]+FETCH[ \t]+\\(.*\\)" return)
	(let ((num (parse-integer (match-string 1)))
	      (tmp (match-string 2)))
	  (with-input-from-string (is tmp)
	    (let ((sval (read is nil)))
	      (setq structure (cadr (member-if #'(lambda (x)
						   (and (symbolp x)
							(equalp (symbol-name x) part)))
					       sval)))
	      ;(msgbox "~S~%~%~S" sval structure)
	      ))))
      (message "~A" return)
      (setq return (imap4-read-line stream)))
    (message "~A" return)
    structure))

(defun imap4-fetch-headers-range (stream start stop &optional uid-p &key (part "RFC822.HEADER"))
  "IMAP4 FETCH HEADERS from start to stop"
  (imap4-fetch-headers stream
		       (format nil "~D:~D" start stop)
		       uid-p
		       :part part))

(defun imap4-uid-fetch-headers (stream nums &key (part "RFC822.HEADER"))
  "IMAP4 FETCH (headers)"
  (imap4-fetch-headers stream nums t :part part))

(defun imap4-fetch-headers (stream nums &optional uid-p &key (part "RFC822.HEADER"))
  "IMAP4 FETCH (headers)"
  (let ((return "")
	(flags "")
	(len 0))
    (message "Fetching headers ~A ..." nums)
    (format (imapstream-stream stream) "~A~:[~; UID~] FETCH ~A (FLAGS ~A)~%"
	    (imap4-tag-increment stream) uid-p nums part)
    (format *imap4-stream-output* "~A~:[~; UID~] FETCH ~A (FLAGS ~A)~%"
	    (imap4-tag-current stream) uid-p nums part)
    (setq return (imap4-read-line stream))
    (save-excursion
      (set-buffer (get-buffer-create *imap4-buffer-temp*))
      (erase-buffer *imap4-buffer-temp*)
      (setq need-not-save t)
      (setq kept-undo-information nil)
      (setq auto-save nil)
      (interval-message (300)
	(while (not (string-match (concat "^" (imap4-tag-current stream) "[ \t]+\\(OK\\|NO\\|BAD\\)") return))
	  (insert (format nil "~A~%" (map-jis-to-internal return))) ;JIS
	  (setq len (+ len (length return) 2))
	  (message "Fetching headers [~A]: ~D" (abbreviate-display-string  nums 15) len)
	  (setq return (imap4-read-line stream)))
      )
      (message "~A" return)
      (goto-char (point-min))
      (imap4-parse-headers))))

(defun imap4-parse-headers ()
  (let (headers)
    (while
	;                         number                       flags,uid,part                        total
	(scan-buffer "^\*[ \t]+\\([0-9]+\\)[ \t]+FETCH[ \t]+(\\([^{]*\\){\\([0-9]+\\)}"
		     :regexp t :tail t)
      (let ((number (parse-integer (match-string 1)))
	    (opts (match-string 2))
	    (total (match-string 3))
	    flags
	    beg
	    header)
	(unless (forward-line 1)
	  (return))
	(when (string-match "FLAGS[ \t]+(\\([^)]+\\))" opts)
	  (setq flags (match-string 1)))
	(when (string-match "UID[ \t]+\\([0-9]+\\)" opts)
	  (setq number (parse-integer (match-string 1)))) ; UID
	(setq beg (point))
	(when (scan-buffer "^[ \t]*\\(FLAGS[ \t]+(\\([^)]*\\))\\)?[ \t]*)$" :regexp t :tail t)
	  (when (match-beginning 1)
	    (setq flags (match-string 2)))
	  (save-restriction
	    (narrow-to-region beg (point))
	    (goto-char beg)
	    (mail-decode-mime-header)
	    (setq header (mail-parse-header))
	    (when (and number header)
	      (push (list number header flags) headers))))))
    (nreverse headers)))

(defun imap4-uid-copy (stream nums folder-name)
  "IMAP4 UID COPY"
  (imap4-copy stream nums folder-name t))

(defun imap4-copy (stream nums folder-name &optional uid-p)
  "IMAP4 COPY"
  (let ((return "")
	(folder (imap4-folder-name-encode folder-name)))
    (message "Copy mails ...")
    (format (imapstream-stream stream) "~A~:[~; UID~] COPY ~A \"~A\"~%"
	    (imap4-tag-increment stream) uid-p nums folder)
    (format *imap4-stream-output* "~A~:[~; UID~] COPY ~A \"~A\"~%"
	    (imap4-tag-current stream) uid-p nums folder)
    (while (not (string-match "^A[0-9]+" return))
      (setq return (imap4-read-line stream))
    )
    (message "~A" return)
    (imap4-return-ok-p stream return)
    ))

(defun imap4-uid-move-messages (stream nums folder-name)
  "IMAP4 UID move mails"
  (imap4-move-messages stream nums folder-name t))

(defun imap4-move-messages (stream nums folder-name &optional uid-p)
  "IMAP4 move mails"
  (and (imap4-copy stream nums folder-name uid-p)
       (imap4-delete-messages stream nums uid-p)
       ))

(defun imap4-uid-delete-messages (stream nums)
  "IMAP4 UID delete mails"
  (imap4-delete-messages stream nums t))

(defun imap4-delete-messages (stream nums &optional uid-p)
  "IMAP4 delete mails"
  (and (imap4-store-deleted stream nums "+" uid-p)
       (imap4-expunge stream)))

;;;
;;; flags
;;;
(defun imap4-flag-check (flag-string flag)
  (and (stringp flag-string)
       (string-matchp (regexp-quote flag) flag-string)))

(defun imap4-flag-flagged (flag-string)
  (imap4-flag-check flag-string *imap4-flag-flagged*))

(defun imap4-flag-seen (flag-string)
  (imap4-flag-check flag-string *imap4-flag-seen*))

(defun imap4-flag-answered (flag-string)
  (imap4-flag-check flag-string *imap4-flag-answered*))

(defun imap4-flag-deleted (flag-string)
  (imap4-flag-check flag-string *imap4-flag-deleted*))

(defun imap4-flag-draft (flag-string)
  (imap4-flag-check flag-string *imap4-flag-draft*))

(defun imap4-flag-recent (flag-string)
  (imap4-flag-check flag-string *imap4-flag-recent*))

(defun imap4-flag-add (before add)
  (unless (imap4-flag-check before add)
    (setq before (format nil "~@[~A ~]~A" before add)))
  before)

(defun imap4-flag-del (before del)
  (when before
    (setq before (string-trim " "
			      (substitute-string before
						 (regexp-quote del)
						 ""))))
  before)

;;;
(defun imap4-uid-store-deleted (stream nums &optional (flag "+"))
  (imap4-store-deleted stream nums flag t))

(defun imap4-store-deleted (stream nums &optional (flag "+") uid-p)
  (imap4-store stream nums (concat flag "FLAGS") (list "\\Deleted") uid-p))

(defun imap4-uid-store-seen (stream nums &optional (flag "+"))
  (imap4-store-seen stream nums flag t))

(defun imap4-store-seen (stream nums &optional (flag "+") uid-p)
  (imap4-store stream nums (concat flag "FLAGS") (list "\\Seen") uid-p))

(defun imap4-uid-store-answered (stream nums &optional (flag "+"))
  (imap4-store-answered stream nums flag t))

(defun imap4-store-answered (stream nums &optional (flag "+") uid-p)
  (imap4-store stream nums (concat flag "FLAGS") (list "\\Answered") uid-p))

(defun imap4-uid-store-flagged (stream nums &optional (flag "+"))
  (imap4-store-flagged stream nums flag t))

(defun imap4-store-flagged (stream nums &optional (flag "+") uid-p)
  (imap4-store stream nums (concat flag "FLAGS") (list "\\Flagged") uid-p))

(defun imap4-uid-store (stream nums param flags)
  "IMAP4 UID STORE"
  (imap4-store stream nums param flags t))

(defun imap4-store (stream nums param flags &optional uid-p)
  "IMAP4 STORE"
  (let ((return ""))
    (message "Store mails ...")
    (format (imapstream-stream stream) "~A~:[~; UID~] STORE ~A ~A (~A~{ ~A~})~%"
	    (imap4-tag-increment stream) uid-p nums param (car flags) (cdr flags))
    (format *imap4-stream-output* "~A~:[~; UID~] STORE ~A ~A (~A~{ ~A~})~%"
	    (imap4-tag-current stream) uid-p nums param (car flags) (cdr flags))
    (while (not (string-match "^A[0-9]+" return))
      (setq return (imap4-read-line stream)))
    (message "~A" return)
    (imap4-return-ok-p stream return)
  ))

(defun imap4-date-string (time)
  (format-date-string "%d-%b-%Y" time))

(defun imap4-close (stream)
  "IMAP4 CLOSE"
  (let ((return "") flag)
    (message "Closing folder ...")
    (format (imapstream-stream stream) "~A CLOSE~%" (imap4-tag-increment stream))
    (format *imap4-stream-output* "~A CLOSE~%" (imap4-tag-current stream))
    (while (not (string-match "^A[0-9]+" return))
      (setq return (imap4-read-line stream)))
    (message "~A" return)
    (when (setq flag (imap4-return-ok-p stream return))
      (setf (imapstream-folder stream) nil)
      (setf (imapstream-status stream) *imap4-status-authenticated*))
    (values flag return)))

(defun imap4-expunge (stream)
  "IMAP4 EXPUNGE"
  (let ((return ""))
    (format (imapstream-stream stream) "~A EXPUNGE~%" (imap4-tag-increment stream))
    (format *imap4-stream-output* "~A EXPUNGE~%" (imap4-tag-current stream))
    (while (not (string-match "^A[0-9]+" return))
      (setq return (imap4-read-line stream)))
    (imap4-return-ok-p stream return)
  ))

(defun read-bytes-from-stream (is os bytes)
  (let* ((vsize 4096)
	 (s (make-vector vsize :element-type 'character :fill-pointer 0))
	 (is-encoding (stream-encoding is))
	 (os-encoding (stream-encoding os))
	 (size 0)
	 (rest bytes))
    (set-stream-encoding is :binary)
    (set-stream-encoding os :binary)
    (while (< 0 rest)
      (when (< rest vsize)
	(setq s (make-vector rest :element-type 'character :fill-pointer 0)))
      (read-into s is nil)
      (princ s os)
      (incf size (length s))
      (message "~d/~d bytes" size bytes)
      (decf rest vsize))
    (when is-encoding
      (set-stream-encoding is is-encoding))
    (when os-encoding
      (set-stream-encoding os os-encoding))))

(defun imap4-uid-search (stream conditions &optional phrase (target "TEXT"))
  "IMAP4 UID SEARCH"
  (imap4-search stream conditions phrase target t))

(defun imap4-search (stream conditions &optional phrase (target "TEXT") uid-p)
  "IMAP4 SEARCH"
  (let* ((return "")
	 (tag (imap4-tag-increment stream))
	 cmd
	 searched)
    (message "Search mails ...")
    (setq cmd
	  (with-output-to-string (s)
	    (format s "ALL")
	    (dolist (c conditions)
	      (let ((key (car c))
		    (val (cdr c)))
		(format s " ~A~@[ ~A~]" key val)))))
    (when phrase
      (return-from imap4-search (imap4-search-phrase stream cmd phrase target uid-p)))
    (format (imapstream-stream stream) "~A~:[~; UID~] SEARCH ~A~%" tag uid-p cmd)
    (format *imap4-stream-output* "~A~:[~; UID~] SEARCH ~A~%" tag uid-p cmd)
    (setq return (imap4-read-line stream))
    (while (not (string-match "^A[0-9]+" return))
      (when (string-match "^\*[ \t]+SEARCH[ \t]+\\([0-9 \t]+\\)" return)
	(setq searched
	      (append searched
		      (split-string (match-string 1) " \t"))))
      (setq return (imap4-read-line stream)))
    (message "~A" return)
    (values (imap4-return-ok-p stream return) searched)
    ))

(defvar *imap4-search-encoding* ed::*encoding-utf8n*)
(defvar *imap4-search-encoding-name* "UTF-8")

(defun imap4-search-phrase (stream condition-string phrase &optional (target "TEXT") uid-p)
  "IMAP4 SEARCH (phrase)"
  (let* ((return "")
	 (encoded (convert-encoding-from-internal *imap4-search-encoding* phrase))
	 (phrase-len (string-length encoded))
	 (tag (imap4-tag-increment stream))
	 search)
    (message "Search mails ...")
    (format (imapstream-stream stream) "~A~:[~; UID~] SEARCH CHARSET ~A ~A ~A {~D}~%"
	    tag uid-p *imap4-search-encoding-name* condition-string target phrase-len)
    (format *imap4-stream-output* "~A~:[~; UID~] SEARCH CHARSET ~A ~A ~A {~D}~%"
	    tag uid-p *imap4-search-encoding-name* condition-string target phrase-len)
    (setq return (imap4-read-line stream))
    (if (imap4-return-continue-p stream return)
	(progn
	  (format (imapstream-stream stream) "~A~%" encoded)
	  (format *imap4-stream-output* "~A~%" encoded))
      (progn
	(format (imapstream-stream stream) "~%")
	(format *imap4-stream-output* "~%")))
    (while (not (string-match "^A[0-9]+" return))
      (when (string-match "^\*[ \t]+SEARCH[ \t]+\\([0-9 \t]+\\)$" return)
	(setq search
	      (split-string
	       (substring return (match-beginning 1) (match-end 1))
	       " 	")))
      (setq return (imap4-read-line stream))
      )
    (message "~A" return)
    (values (imap4-return-ok-p stream return) search)
    ))
