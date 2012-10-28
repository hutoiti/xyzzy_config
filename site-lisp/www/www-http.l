; $Id: www-http.l,v 1.5 2005/12/21 14:58:24 torihat Exp $
;
; www-http.l
;
; by HATTORI Masashi

(provide "www/www-http")

(in-package "www")

(defvar *www-recv-vector-size* 256)

(defvar *www-http-version* "1.0")

(defvar *www-http-debug* nil)

(defvar *www-http-accept-language* "ja,en")

(setf (get 'www-interval-message 'lisp-indent-hook) 1)

(defmacro www-interval-message ((interval) &body body)
  `(let ((#1=#:last-tick (+ (get-internal-real-time) ,interval))
	 (#2=#:tick))
     (flet ((message (&rest args)
	      (setq #2# (get-internal-real-time))
	      (when (> #2# #1#)
		(setq #1# (+ #2# ,interval))
		(apply #'message args))))
       ,@body)))

;;;
;;; 亀井さんが送って下さったPROXY対応
;;;
(defvar *www-proxy-host* nil)          ; PROXY のホスト
(defvar *www-proxy-port* nil)          ; PROXY のポート
(defvar *www-direct-connect-list* nil) ; PROXY を経由しないホストのリスト

;;; Proxy Authorization
(defvar *www-proxy-user* nil)
(defvar *www-proxy-pass* nil)

(defun www-http-get (host file &key port head no-cache referer post auth other)
  (interactive)
  (let (line status header s proxy-p host-orig port-orig request response)
    (when (and *www-proxy-host* *www-proxy-port*
	       (not (find-if #'(lambda (x)
				 (string-matchp (cond ((string-match "^\\([0-9]+\\.\\)+$" x)
						       (concat "^" (regexp-quote x)))
						      ((string-match "^[0-9]+\\(\\.[0-9]+\\)*" x)
						       (concat "^" (regexp-quote x) "\\($\\|\\.\\)"))
						      (t
						       (concat "\\(^\\|\\.\\)" (regexp-quote x) "$")))
						host))
			     *www-direct-connect-list*)))
      (setq file (concat "http://" host (and port (format ":~a" port)) file))
      (setq host-orig host)
      (setq host *www-proxy-host*)
      (setq port-orig port)
      (setq port *www-proxy-port*)
      (setq proxy-p t))
    (message "WWW: connecting to ~A ..." host)
    (setq s (connect host (or port *www-port*)))
    (setq request
	  (with-output-to-string (req)
	    (cond (post
		   (let ((clength (www-string-length post)))
		     (format req "POST ~A HTTP/~A~%" file *www-http-version*)
		     (unless (assoc "content-type" other :test #'equalp)
		       (format req "Content-Type: application/x-www-form-urlencoded~%"))
		     (unless (assoc "content-length" other :test #'equalp)
		       (format req "Content-Length: ~D~%" clength))
		     ))
		  (head
		   (format req "HEAD ~A HTTP/~A~%" file *www-http-version*))
		  (t
		   (format req "GET ~A HTTP/~A~%" file *www-http-version*))
		  )
	    (format req "Host: ~A~%" (or host-orig host))
	    (when no-cache
	      (format req "Pragma: no-cache~%"))
	    (when (stringp referer)
	      (format req "Referer: ~A~%" referer))
	    (when (stringp auth)
	      (format req "Authorization: basic ~A~%" auth))
	    (when (and *www-proxy-user*
		       *www-proxy-pass*)
	      (format req "Proxy-Authorization: basic ~A~%"
		      (www-auth-encode-account *www-proxy-user*
					       *www-proxy-pass*)))
	    (when other
	      (let (other-header)
		(dolist (other-header other)
		  (let ((key (car other-header))
			(val (cdr other-header)))
		    (format req "~A: ~A~%" (string-capitalize key) val)))))
	    (unless (assoc "accept-language" other :test #'equalp)
	      (format req "Accept-Language: ~A~%" *www-http-accept-language*))
	    (when *www-cookie-enable*
	      (unless (assoc "cookie" other :test #'equalp)
		(let ((cookies (cookie-get host file)))
		  (when cookies
		    (when *www-http-debug*
		      (msgbox "Cookie: ~A" cookies))
		    (format req "Cookie: ~A~%" cookies)))))
	    (format req "User-Agent: ~A~%" *www-user-agent*)
	    (format req "X-Yzzy-Version: xyzzy-~A~%" (software-version))
	    (format req "~%")))
    (format s "~A" request)
    (when post
      (with-input-from-string (ss post)
	(www-put-data-to-stream ss s))
      (set-stream-encoding s :text))
    (message "WWW: waiting for reply ...")
    (unless (setq line (read-line s nil))
      (error "WWW: connection closed."))
    (if (string-match "^HTTP/\\([0-9.]+\\)[ \t]+\\([0-9]+\\)[ \t]*\\(.*\\)$" line)
	(progn
	  (message "~A" line)
	  (push line response)
	  (setq status (substring line (match-beginning 2) (match-end 2)))
	)
      (error "WWW: not status: ~A" line)
    )
    (unless (setq line (read-line s nil))
      (error "WWW: connection closed."))
    (loop
      (or line (return))
      (push line response)
      (cond ((string= line "")
	     (return))
	    ((string-match "^\\([-a-zA-Z_]+\\)[ \t]*:[ \t]*\\(.*\\)" line)
	     (let (key val)
	       (message "~A" line)
	       (setq key (nstring-downcase (substring line (match-beginning 1) (match-end 1))))
	       (setq val (substring line (match-beginning 2) (match-end 2)))
	       (if (setq line (read-line s nil))
		   (while (string-match "^[ \t]+\\(.*\\)" line)
		     (setq val (concat val line))
		     (unless (setq line (read-line s nil))
		       (return))
		   )
		 (return)
	       )
	       (push (list key val) header)
	       (when (and *www-cookie-enable*
			  (equal key "set-cookie"))
		 (when *www-http-debug*
		   (msgbox "~A: ~A" key val))
		 (cookie-eat val host file))
	       ))
	    (t
	     (setq line (read-line s nil))
	    )
      )
    )
    (when *www-http-debug*
      (setq *x* header)
      (copy-to-clipboard (format nil "~S~%~%~{~S~%~}" request (reverse response)))
      (msgbox "~S~%~%~{~S~%~}" request (reverse response)))
    (values s status header request)
  ))

(defun www-get-data-to-stream (is os &optional size (dowhat "getting"))
  (set-stream-encoding is :binary)
  (set-stream-encoding os :binary)
  (let ((data (make-vector *www-recv-vector-size* :element-type 'character :fill-pointer 0))
	(bytes 0))
    (message "WWW: ~A data ..." dowhat)
    (www-interval-message (300)
      (while (read-into data is nil)
	(format os "~A" data)
	(when *www-show-status-message*
	  (incf bytes (length data))
	  (if size
	      (message "WWW: ~A ~3d% of ~d bytes"
		       dowhat
		       (truncate (/ (* 100 bytes) size)) size)
	    (message "WWW: ~A ~d bytes" dowhat bytes)))))
  ))

(defun www-put-data-to-stream (is os &optional size)
  (www-get-data-to-stream is os size "putting"))

(defun www-get-data (is &optional size)
  (let ((os (make-buffer-stream (selected-buffer))))
    (set-stream-encoding os :binary)
    (www-get-data-to-stream is os size)))

(defun www-get-data-to-file (is file &optional size)
  (let ((os (open file :direction :output)))
    (unwind-protect
	(progn
	  (set-stream-encoding is :binary)
	  (set-stream-encoding os :binary)
	  (www-get-data-to-stream is os size))
      (close os))))

(defun www-get-header-value (key header)
  (cadr (assoc key header :test #'equalp)))

(defun www-http-get-url (url &key no-cache referer post head auth other)
  (interactive)
  (let (proto
	host
	port
	file
	anchor
	)
    (multiple-value-setq (proto host file anchor port)
      (www-url-study url))
    (unless (string= proto "http")
      (error (format nil "WWW: http protocol unmatch: ~A" url)))
    (setq file (concat "/" file))
    (www-http-get host
		  file
		  :port port
		  :no-cache no-cache
		  :referer referer
		  :post post
		  :head head
		  :auth auth
		  :other other)
  ))

(defun www-string-length (str)
  (1- (si:chunk-size (si:make-string-chunk str))))
