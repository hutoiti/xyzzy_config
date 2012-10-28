;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: wsse.l 769 2007-12-14 19:18:39Z torihat $
;
; junk/wsse.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "junk/defs")
  (require "junk/macro"))
(require "junk/lib")

(provide "junk/wsse")

(in-package "junk")

(defstruct wsse
  Username
  PasswordDigest
  Created
  Nonce)

(defun wsse-timestamp-format (&optional timestamp)
  (format-date-string "%Y-%m-%dT%H:%M:%SZ" timestamp))

(defun wsse-base64-encode (str)
  (substitute-string (si:base64-encode str) "\n" ""))

(defun wsse-digest (str)
  (wsse-base64-encode
   (pack-H*
    (si:sha-1 str))))

(defun wsse-create (username password)
  (let* ((created (wsse-timestamp-format))
	 (nonce (si:md5 (format nil "junk/wsse~A~D" created (random 256))))
	 (digest (wsse-digest (concat nonce created password))))
    (make-wsse :Username       username
	       :PasswordDigest digest
	       :Created        created
	       :Nonce          nonce)))

(defun wsse-create-http-header (username password)
  (let ((wsse (wsse-create username password)))
    (format nil "UsernameToken Username=\"~A\", PasswordDigest=\"~A\", Nonce=\"~A\", Created=\"~A\""
	    (wsse-Username wsse)
	    (wsse-PasswordDigest wsse)
	    (wsse-base64-encode (wsse-Nonce wsse))
	    (wsse-Created wsse))))

#|
; raw nonce
(defun wsse-create-http-header2 (username password)
  (let ((wsse (wsse-create username password)))
    (format nil "UsernameToken Username=\"~A\", PasswordDigest=\"~A\", Nonce=\"~A\", Created=\"~A\""
	    (wsse-Username wsse)
	    (wsse-PasswordDigest wsse)
	    (wsse-Nonce wsse)
	    (wsse-Created wsse))))

|#
