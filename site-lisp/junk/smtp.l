; $Id: smtp.l 769 2007-12-14 19:18:39Z torihat $
;
; smtp.l
;
; by Masashi Hattori

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "junk/defs")
  (require "junk/macro")
  (require "junk/mail"))

(require "junk/lib")
(require "junk/log")
(require "junk/rfc822")

(provide "junk/smtp")

(in-package "junk")

(defconstant *smtp-port* 25)

(defconstant *smtp-answer-connected* 220)
(defconstant *smtp-answer-closed*    221)
(defconstant *smtp-answer-ok*        250)
(defconstant *smtp-answer-send-mail* 354)
(defconstant *smtp-answer-ready*     334)
(defconstant *smtp-answer-auth-ok*   235)

(defvar *smtp-buffer-prefix* "*Junk:SMTP ")
(defvar *smtp-buffer-output* (concat *smtp-buffer-prefix* "OUTPUT*"))
(defvar *smtp-stream-output* nil)

(defvar *smtp-socket-stream-timeout* 180)

(defvar *smtp-domain-name* nil)

(defvar *smtp-debug* nil)

(defun smtp-parse-address ()
  (let ((header (mail-parse-header))
	sender
	from
	rcpt-list)
    (setq sender (mail-get-header-value "sender" header))
    (when sender
      (setq sender (rfc822-parse-address sender :strict t)))
    (setq from (mail-get-header-value "from" header))
    (unless from
      (return-from smtp-parse-address))
    (when from
      (setq from (rfc822-parse-address from :strict t :allow-list sender)))
    (unless sender
      (setq sender from))
    (dolist (x '("to" "cc" "bcc"))
      (let (tmp)
	(when (setq tmp (mail-get-header-value x header))
	  (dolist (rcpt (rfc822-parse-address tmp :strict t :allow-group t :allow-list t))
	    (pushnew rcpt rcpt-list :test #'equal)))))
    (values sender (nreverse rcpt-list))))

(defun smtp-connect (server &key port auth user pass realm)
  (let (s)
    (setq s (smtp-open server port))
    (multiple-value-bind (flag return)
	(smtp-login s auth user pass realm)
      (values s flag return))))

(defun smtp-msgid-add (stream &optional domain)
  (let ((header (mail-parse-header))
	msgid)
    (unless (mail-get-header-value "message-id" header)
      (when (setq msgid (smtp-msgid-create stream domain))
	(save-excursion
	  (goto-char (point-min))
	  (insert (format nil "Message-Id: ~A~%" msgid)))))))

(defun smtp-send-buffer-contents (stream &optional (show t))
  (multiple-value-bind (flag return)
      (smtp-data stream)
    (unless flag
      (return-from smtp-send-buffer-contents (values flag return))))
  ; 内容の送信
  (message "Sending message ...")
  (goto-char (point-min))
  (with-input-from-selected-buffer
    (let (line
	  (bytes 0)
	  bcc)
      (junk::interval-message (300)
	; header
	(while (setq line (read-line nil nil))
	  (when (equal line "")
	    (format stream "~A~%" line)
	    (and *smtp-stream-output*
		 (format *smtp-stream-output* "~A~%" line))
	    (return))
	  (when (and bcc
		     (not (string-match "^[ \t]" line)))
	    (setq bcc nil))
	  (when (string-matchp "^bcc: " line)
	    (setq bcc t))
	  (unless bcc
	    (format stream "~A~%" line)
	    (and *smtp-stream-output*
		 (format *smtp-stream-output* "~A~%" line))
	    (when show
	      (setq bytes (+ bytes (length line)))
	      (message "Sending data: ~D" bytes))))
	; body
	(while (setq line (read-line nil nil))
	  (when (and (> (length line) 0)
		     (char= (char line 0) #\.))
	    (setq line (concat "." line)))
	  (format stream "~A~%" line)
	  (and *smtp-stream-output*
	       (format *smtp-stream-output* "~A~%" line))
	  (when show
	    (setq bytes (+ bytes (length line)))
	    (message "Sending data: ~D" bytes))))
      (format stream ".~%")))
  (smtp-return stream *smtp-answer-ok*))

(defun smtp-send-buffer (server &key port auth user pass realm show msgid-add)
  (let (s
	header
	rcpt-list
	sender
	rcpt-flag)
    ; アドレスの抽出
    (multiple-value-setq (sender rcpt-list)
      (smtp-parse-address))
    (unless (and sender rcpt-list)
      (return-from smtp-send-buffer (values nil "Missing Sender or Recipient")))
    ; サーバーに接続
    (multiple-value-bind (stream flag return)
	(smtp-connect server
		      :port port
		      :auth auth
		      :user user
		      :pass pass
		      :realm realm)
      (if flag
	  (progn
	    (setq s stream)
	    (socket-stream-set-timeout s *smtp-socket-stream-timeout*))
	(return-from smtp-send-buffer (values flag return))))
    ;Message-ID
    (when msgid-add
      (smtp-msgid-add s (car sender)))
    ; MAIL
    (multiple-value-bind (flag return)
	(smtp-mail s (car sender))
      (unless flag
	(return-from smtp-send-buffer (values flag return))))
    ; RCPT
    (dolist (x rcpt-list)
      (multiple-value-bind (flag return)
	  (smtp-rcpt s x)
	(if flag
	    (setq rcpt-flag t)
	  (unless (yes-or-no-p "SMTP: RCPT ~A: ~A: \n続行しますか？: "
			       x
			       (or return "unknown"))
	    (return-from smtp-send-buffer (values flag return)))
	  )))
    (unless rcpt-flag
      (return-from smtp-send-buffer (values nil "SMTP: Missing Valid Recipients")))
    ; DATA送信
    (multiple-value-bind (flag return)
	(smtp-send-buffer-contents s show)
      (unless flag
	(return-from smtp-send-buffer (values flag return))))
    ; QUIT
    (smtp-quit s)
    ))

(defvar *smtp-msgid-last-time* nil)

(defun smtp-msgid-create (stream &optional string)
  (let (user domain time)
    (if (and string
	     (string-match "\\([^ \t@]+\\)@\\([^ \t@]+\\)" string))
	(setq user (match-string 1)
	      domain (match-string 2))
      (setq user (user-name)
	    domain (socket-stream-local-name stream)))
    (setq user (si:base64-encode user nil t))
    (setq time (get-universal-time))
    ; へなちょこな同一Message-ID回避
    (when (and *smtp-msgid-last-time*
	       (<= time *smtp-msgid-last-time*))
      (setq time (1+ *smtp-msgid-last-time*)))
    (setq *smtp-msgid-last-time* time)
    (format nil "<~A.xyzzy/smtp.~A@~A>"
	    (format-date-string "%Y%m%d%H%M%S%Z" time)
	    user
	    domain)))

(defun smtp-return (stream num)
  (let ((reg (format nil "^~D[ \t]+" num))
	(cont (format nil "^~D-" num))
	(lines nil))
    (loop
      (let ((return (smtp-read-line stream)))
	(cond ((string-match reg return)
	       (progn
		 (push return lines)
		 (message "~A" return)
		 (return-from smtp-return (values t return lines))
		 ))
	      ((string-match cont return)
	       (push return lines)
	       (message "~A" return))
	      (t
	       (return-from smtp-return (values nil return)))
	      )))))

(defun smtp-open (server &optional port)
  (let (stream)
    (if *smtp-debug*
	(when (or (not *smtp-stream-output*)
		  (not (find-buffer *smtp-buffer-output*)))
	  (setq *smtp-stream-output*
		(log-init *smtp-buffer-output*)))
      (setq *smtp-stream-output* nil))
    (message "Connecting to server: ~A" server)
    (setq stream (connect server (or port *smtp-port*)))
    (multiple-value-bind (flag return)
	(smtp-return stream *smtp-answer-connected*)
      (unless flag
	(error "SMTP: connect failed: ~A" (or return "unknown"))))
    stream))

(defun smtp-read-line (stream)
  (let (return)
    (setq return (read-line stream nil))
    (format *smtp-stream-output* "~A~%" return)
    return))

(defun smtp-login (stream &optional auth user pass realm)
  (unless (streamp stream)
    (return-from smtp-login (values nil "Not connected.")))
  (if auth
      (smtp-auth stream auth user pass realm)
    (smtp-helo stream)))

(defun smtp-auth-support-mech (lines)
  (let (mech
	(reg (format nil "~D[ -]AUTH " *smtp-answer-ok*)))
    (dolist (line lines)
      (when (string-match reg line)
	(setq mech (split-string (substring line (match-end 0) (length line))
				 " \t"))
	(return)))
    mech))

(defun smtp-auth (stream auth user pass realm)
  (let (mechs)
    (multiple-value-bind (flag return lines)
	(smtp-ehlo stream)
      (unless flag
	(return-from smtp-auth (value flag return)))
      ;ここでサーバーが認証方法をサポートしているかチェックしないといけないんだけど
      ;(setq mechs (smtp-auth-support-mech lines))
    ))
  (let ((func
	 (cond ((string-matchp "cram-md5" auth)
		'smtp-auth-cram-md5)
	       ((string-matchp "plain" auth)
		'smtp-auth-plain)
	       ((string-matchp "login" auth)
		'smtp-auth-login))))
    (if func
	(funcall func stream user pass realm)
      (return-from smtp-auth (values nil (format nil "Not supported mech: ~A" (or auth "")))))
    ))

(defun smtp-plain-string (user pass realm)
  (si:base64-encode
   (format nil "~A~@[@~A~]\000~A\000~A" user realm user pass)
   nil t))

(defun smtp-auth-plain (stream user pass realm)
  (unless (streamp stream)
    (return-from smtp-auth-plain (values nil "Not connected.")))
  (let ((plain (smtp-plain-string user pass realm)))
    (format stream "AUTH PLAIN ~A~%" plain)
    (format *smtp-stream-output* "AUTH PLAIN ~A~%" plain)
    (smtp-return stream *smtp-answer-auth-ok*)
  ))

(defun smtp-auth-login (stream user pass realm)
  (unless (streamp stream)
    (return-from smtp-auth-login (values nil "Not connected.")))
  (format stream "AUTH LOGIN ~A~%" (si:base64-encode user nil t))
  (format *smtp-stream-output* "AUTH LOGIN ~A~%" (si:base64-encode user nil t))
  (multiple-value-bind (flag return)
      (smtp-return stream *smtp-answer-ready*)
    (if flag
	(progn
	  (format stream "~A~%" (si:base64-encode pass nil t))
	  (format *smtp-stream-output* "~A~%" (si:base64-encode pass nil t))
	  (smtp-return stream *smtp-answer-auth-ok*))
      (values flag return))))

(defun smtp-auth-cram-md5 (stream user pass realm)
  (unless (streamp stream)
    (return-from smtp-auth-cram-md5 (values nil "Not connected.")))
  (when realm
    (setq user (concat user "@" realm)))
  (format stream "AUTH CRAM-MD5~%")
  (format *smtp-stream-output* "AUTH CRAM-MD5~%")
  (multiple-value-bind (flag return)
      (smtp-return stream *smtp-answer-ready*)
    (unless flag
      (return-from smtp-auth-cram-md5 (values flag return)))
    (if (and flag
	     (string-match (format nil "~D \\([^ \r\n]+\\)" *smtp-answer-ready*)
			   return))
	(let* ((challenge (substring return (match-beginning 1) (match-end 1)))
	       (response (cram-md5-responce user pass challenge)))
	  (format stream "~A~%" response)
	  (format *smtp-stream-output* "~A~%" response)
	  (smtp-return stream *smtp-answer-auth-ok*))
      (values flag return))))

(defun smtp-ehlo (stream)
  (unless (streamp stream)
    (return-from smtp-ehlo (values nil "Not connected.")))
  (let ((domain (smtp-domain-name stream)))
    (format stream "EHLO ~A~%" domain)
    (format *smtp-stream-output* "EHLO ~A~%" domain)
    (smtp-return stream *smtp-answer-ok*)
  ))

(defun smtp-helo (stream)
  (unless (streamp stream)
    (return-from smtp-helo (values nil "Not connected.")))
  (let ((domain (smtp-domain-name stream)))
    (format stream "HELO ~A~%" domain)
    (format *smtp-stream-output* "HELO ~A~%" domain)
    (smtp-return stream *smtp-answer-ok*)
  ))

(defun smtp-quit (stream)
  (unless (streamp stream)
    (return-from smtp-quit nil))
  (let ((return ""))
    (format stream "QUIT~%")
    (format *smtp-stream-output* "QUIT~%")
    (smtp-return stream *smtp-answer-closed*)
  ))

(defun smtp-rset (stream)
  (unless (streamp stream)
    (return-from smtp-rset nil))
  (let ((return ""))
    (format stream "RSET~%")
    (format *smtp-stream-output* "RSET~%")
    (smtp-return stream *smtp-answer-ok*)
  ))

(defun smtp-mail (stream from)
  (unless (streamp stream)
    (return-from smtp-mail nil))
  (let ((return ""))
    (format stream "MAIL FROM:<~A>~%" from)
    (format *smtp-stream-output* "MAIL FROM:<~A>~%" from)
    (smtp-return stream *smtp-answer-ok*)
  ))

(defun smtp-rcpt (stream to)
  (unless (streamp stream)
    (return-from smtp-rcpt nil))
  (let ((return ""))
    (format stream "RCPT TO:<~A>~%" to)
    (format *smtp-stream-output* "RCPT TO:<~A>~%" to)
    (smtp-return stream *smtp-answer-ok*)
  ))

(defun smtp-data (stream)
  (unless (streamp stream)
    (return-from smtp-data nil))
  (let ((return ""))
    (format stream "DATA~%")
    (format *smtp-stream-output* "DATA~%")
    (smtp-return stream *smtp-answer-send-mail*)
  ))

(defun smtp-send-data (stream data)
  (if (smtp-data stream)
      (progn
	(format stream "~A~%.~%" data)
	(format *smtp-stream-output* "~A~%\.~%" data)
	(smtp-return stream *smtp-answer-ok*))
    nil))

(defun smtp-domain-name (stream)
  (or *smtp-domain-name*
      (socket-stream-local-name stream)
      (concat "[" (socket-stream-local-address stream) "]")))
