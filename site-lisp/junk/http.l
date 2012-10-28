;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: http.l 769 2007-12-14 19:18:39Z torihat $
;
; junk/http.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "junk/defs")
  (require "junk/macro"))
(require "junk/lib")

(provide "junk/http")

(in-package "junk")

(defvar *junk-config-file-http*
  (merge-pathnames "config-http.l" *base-directory*))

(defvar *junk-http-recv-vector-size* 2048)

(defvar *junk-http-version* "1.0")
(defvar *junk-http-port* 80)
(defvar *junk-http-accept-language* "ja,en")

(defvar *junk-http-prog-version* *prog-version*)
(defvar *junk-http-user-agent*
  (format nil "junk-http/~A" *junk-http-prog-version*))

(defvar *junk-http-show-status-message* t)

(defvar *junk-http-proxy-host* nil)          ; PROXY のホスト
(defvar *junk-http-proxy-port* nil)          ; PROXY のポート
(defvar *junk-http-direct-connect-list* nil) ; PROXY を経由しないホストのリスト

(defvar *junk-http-proxy-user* nil)
(defvar *junk-http-proxy-pass* nil)

(defvar *junk-http-debug* nil)

(defmacro junk-http-get-header-value (key headers)
  `(cdr (assoc ,key ,headers :test #'equal)))

(defmacro junk-http-add-header (key val headers)
  `(pushnew (cons ,key ,val) ,headers :test #'equalp :key #'car))

(defun junk-http-request-send (host
			       file
			       method
			       &key
			       port
			       headers
			       data)
  (let (host-orig
	port-orig
	proxy-p
	data-length
	request
	http-stream)
;;;
;;; 亀井さんが送って下さったPROXY対応
;;;
    (when (and *junk-http-proxy-host*
	       *junk-http-proxy-port*
	       (not (find-if #'(lambda (x)
				 (string-matchp (cond ((string-match "^\\([0-9]+\\.\\)+$" x)
						       (concat "^" (regexp-quote x)))
						      ((string-match "^[0-9]+\\(\\.[0-9]+\\)*" x)
						       (concat "^" (regexp-quote x) "\\($\\|\\.\\)"))
						      (t
						       (concat "\\(^\\|\\.\\)" (regexp-quote x) "$")))
						host))
			     *junk-http-direct-connect-list*)))
      (setq file (concat "http://" host (and port (format ":~a" port)) file))
      (setq host-orig host)
      (setq host *junk-http-proxy-host*)
      (setq port-orig port)
      (setq port *junk-http-proxy-port*)
      (setq proxy-p t))
    (setq port (or port *junk-http-port*))
    (setq request
	  (with-output-to-string (req)
	    (format req "~A ~A HTTP/~A~%" method file *junk-http-version*)
	    (cond ((or (string-equal method "POST")
		       (string-equal method "PUT"))
		   (setq data-length (string-length data))
		   (junk-http-add-header "content-type" "application/x-www-form-urlencoded" headers)
		   (junk-http-add-header "content-length" (format nil "~D" data-length) headers)
		   )
		  (t
		   nil))
	    (junk-http-add-header "host" (or host-orig host) headers)
	    (when (and *junk-http-proxy-user*
		       *junk-http-proxy-pass*)
	      (junk-http-add-header "proxy-authorization"
				    (concat "basic "
					    (junk-http-auth-encode-account *junk-http-proxy-user*
									   *junk-http-proxy-pass*))
				    headers))
	    (junk-http-add-header "accept-language" *junk-http-accept-language* headers)
	    (junk-http-add-header "user-agent" *junk-http-user-agent* headers)
	    (junk-http-add-header "x-yzzy-version" (format nil "xyzzy-~A" (software-version)) headers)
	    (junk-http-add-header "connection" "close" headers)
	    (when *junk-http-debug*
	      (msgbox "~{~S~%~}" headers))
	    (when headers
	      (let (other-header)
		(dolist (other-header headers)
		  (let ((key (car other-header))
			(val (cdr other-header)))
		    (format req "~A: ~A~%" (string-capitalize key) val)))))
	    (format req "~%")))
    (junk-message "connecting to ~A ..." host)
    (setq http-stream (connect host port))
    (format http-stream "~A" request)
    (if data
	(let (is os)
	  (with-input-from-string (ss data)
	    (multiple-value-setq (is os)
	      (junk-http-copy-stream ss http-stream)))
	  (set-stream-encoding os :text)
	  (values os headers request))
      (values http-stream headers request))))

(defun junk-http-response-get (http-stream)
  (let (status
	response
	headers)
    (junk-message "waiting for reply ...")
    (unless (setq line (read-line http-stream nil))
      (junk-error "HTTP connection closed."))
    (if (string-match "^HTTP/\\([0-9.]+\\)[ \t]+\\([0-9]+\\)[ \t]*\\(.*\\)$" line)
	(progn
	  (message "~A" line)
	  (push line response)
	  (setq status (match-string 2)))
      (junk-error "Response was not status: ~A" line))
    (multiple-value-bind (headers is)
	(parse-http-header http-stream)
      (values is status headers response))
    ))

(defun junk-http-copy-stream (is os &optional size)
  (set-stream-encoding is :binary)
  (set-stream-encoding os :binary)
  (let ((data (make-vector *junk-http-recv-vector-size* :element-type 'character :fill-pointer 0))
	(bytes 0))
    (interval-message (300)
      (while (read-into data is nil)
	(format os "~A" data)
	(when *junk-http-show-status-message*
	  (incf bytes (length data))
	  (if size
	      (junk-message "~3d% of ~d bytes"
			    (truncate (/ (* 100 bytes) size))
			    size)
	    (junk-message "~d bytes" bytes)))))
    (values is os)))

(defun junk-http-url-study (url)
  (let (port
	(proto "")
	(host "")
	(path "")
	anchor)
    (when (string-match "\\([^#]*\\)#\\(.*\\)" url)
      (setq anchor (match-string 2))
      (setq url (match-string 1)))
    (cond ((string-match "^file://\\(.*\\)$" url)
	   (progn
	     (setq proto "file")
	     (setq path (match-string 1))))
	  ((string-match "^mailto:" url)
	   (setq proto "mailto"))
	  ((string-match "^\\([^:]+\\)://\\([^:/]+\\)\\(:[0-9]+\\)?\\(/.*\\)?$" url)
	   (progn
	     (setq proto (match-string 1))
	     (setq host (match-string 2))
	     (when (match-beginning 3)
	       (setq port (parse-integer (substring url (1+ (match-beginning 3)) (match-end 3)))))
	     (if (match-beginning 4)
		 (setq path (match-string 4))
	       (setq path "/"))))
	  )
    (values proto host path anchor port url)
    ))

(defun junk-http-auth-encode-account (user pass)
  (substitute-string (si:base64-encode (concat user ":" pass)) "\n" ""))

(defun junk-http-data-to-file (is file &optional size &key append)
  (with-open-file (os file
		      :direction :output
		      :if-exists (if append
				     :append
				   :supersede)
		      :if-does-not-exist :create)
    (junk-http-copy-stream is os size))
  (close is))

(defun junk-http-gzip-to-file (is file &optional size &key append)
  (set-stream-encoding is :binary)
  (unwind-protect
      (with-open-file (os file
			  :direction :output
			  :if-exists (if append
					 :append
				       :supersede)
			  :if-does-not-exist :create
			  :encoding :binary)
	(si:inflate-stream is os))
    (close is)))

;;;
;;; Obsolete function for upper compatibility.
;;;
(defun junk-http-get-url (url &key no-cache referer post head auth headers)
  (let ((method (if post
		    "POST"
		  (if head
		      "HEAD"
		    "GET"))))
    (when no-cache
      (push (cons "pragma" "no-cache") headers))
    (when referer
      (push (cons "referer" referer) headers))
    (multiple-value-bind (proto host file anchor port)
	(junk-http-url-study url)
      (let (stream)
	(unless (string= proto "http")
	  (junk-error "Protocol is not http: ~A" url))
	(setq stream (junk-http-request-send host
					     file
					     method
					     :port port
					     :headers headers
					     :data post))
	(junk-http-response-get stream)))))

;;;
;;; Obsolete function for upper compatibility.
;;;
(defun junk-http-download-file (url file &optional force &key headers post)
  (let (sock
	status
	response-headers
	dir
	size
	wtime
	result)
    ; ローカルディレクトリがなければ作成
    (setq dir (directory-namestring file))
    (unless (file-exist-p dir)
      (create-directory dir))
    ; 既にファイルがある場合
    (when (file-exist-p file)
      (setq size (file-length file))
      (setq wtime (file-write-time file))
      (unless (or force post)
	; If-Modified-Since: 更新されていれば取得
	(push (cons "If-Modified-Since" (rfc822-format-date wtime)) headers)))
    (push (cons "Accept" "*/*") headers)
    ; HTTP GET
    (handler-case
	(multiple-value-setq (sock status response-headers)
	  (junk-http-get-url url :headers headers :post post))
      (socket-error (c)
	(when (socket-stream-p sock)
	  (close sock))
	(junk-error "Socket error: ~A" (si:*condition-string c)))
      (quit (c)
	(when (socket-stream-p sock)
	  (close sock))
	(junk-error "Interrupted: ~A" (si:*condition-string c)))
      )
    (unless (stringp status)
      (junk-error "~S~%~S" status response-headers))
    ; 更新されていない
    (when (string-match "^304" status)
      (junk-message "~A" status)
      (return-from junk-http-download-file))
    ; Redirect
    (when (string-match "^302" status)
      (let ((location (junk-http-get-header-value "location" response-headers)))
	(when location
	  (return-from junk-http-download-file
	    (junk-http-download-file location file force)))))
    ; エラーステータス
    (unless (and (string-match "^2[0-9][0-9]" status)
		 response-headers)
      (junk-error "~S~%~S~%~S" url status response-headers))
    (let ((clength (junk-http-get-header-value "content-length" response-headers))
	  (last (junk-http-get-header-value "last-modified" response-headers))
	  (cencoding (junk-http-get-header-value "content-encoding" response-headers))
	  stime
	  (gzip-p nil))
      ; 更新日時の取得
      (when last
	(setq stime (rfc822-parse-date last)))
      ; 受信バイト数の取得
      (if (and (stringp clength)
	       (string-match "^[0-9]+$" clength))
	  (setq clength (parse-integer clength))
	(setq clength nil))
      ; エンコーディング
      (when (and (stringp cencoding)
		 (string-match "gzip" cencoding))
	(setq gzip-p t))
      ; 受信
      (long-operation
	(if gzip-p
	    (junk-http-gzip-to-file sock file clength)
	  (junk-http-data-to-file sock file clength))
	(when stime
	  (set-file-write-time file stime))
	(junk-message "saved:  ~A" file)))
    t))

;load時に設定ファイルがあれば読み込み
(load-config-file *junk-config-file-http*)
