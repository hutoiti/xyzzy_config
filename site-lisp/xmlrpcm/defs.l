;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: defs.l,v 1.8 2006/02/04 20:01:07 torihat Exp $
;
; defs.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xml-parser-modoki")
  (require "junk/http"))

(defpackage "xmlrpcm"
  (:use "lisp" "editor"))

(provide "xmlrpcm/defs")

(in-package "xmlrpcm")

(defvar *version* "0.0.0.4")

(defvar *prog-name* (format nil "xml-rpc-modoki/~A" *version*))

(defvar *user-agent* (format nil "~A|~A" *prog-name* junk::*junk-http-user-agent*))

(defvar *debug-mode* nil)

(defconstant *xmlrpcm-boolean-false* 0)
(defconstant *xmlrpcm-boolean-true*  1)

(defconstant *xmlrpcm-response-ok*      t)
(defconstant *xmlrpcm-response-fault* nil)

(setq *xmlrpcm-value-type-string*
  '((boolean  . "boolean")
    (int      . "int")
    (i4       . "int")
    (string   . "string")
    (double   . "double")
    (base64   . "base64")
    (dateTime . "dateTime.iso8601")
    (struct   . "struct")
    (array    . "array")
    ))

(setq *xmlrpcm-value-type-symbol*
  '(("boolean"          . boolean)
    ("int"              . int)
    ("i4"               . int)
    ("string"           . string)
    ("double"           . double)
    ("base64"           . base64)
    ("dateTime.iso8601" . dateTime)
    ("array"            . array)
    ("struct"           . struct)
    ))

(defmacro xmlrpcm-response-ok-p (status)
  `(eq ,status *xmlrpcm-response-ok*))

(defmacro xmlrpcm-request-methodName (xml)
  `(car ,xml))

(defmacro xmlrpcm-request-params (xml)
  `(cdr ,xml))

(defmacro xmlrpcm-param-name (param)
  `(car ,param))

(defmacro xmlrpcm-param-value (param)
  `(cadr ,param))

(defmacro xmlrpcm-param-type (param)
  `(caddr ,param))

(defun xmlrpcm-param-type-string (param)
  (cdr (assoc (xmlrpcm-param-type param)
	      *xmlrpcm-value-type-string*)))

(defun xmlrpcm-param-string-type (paramstr)
  (and (stringp paramstr)
       (cdr (assoc paramstr *xmlrpcm-value-type-symbol* :test #'equal))))

(defun xmlrpcm-param-value-string (param)
  (let ((type (xmlrpcm-param-type param))
	(value (xmlrpcm-param-value param)))
    (cond ((or (eq type 'int)
	       (eq type 'i4)
	       (eq type 'boolean))
	   (format nil "~D" value))
	  ((eq type 'double)
	   (string-trim "\"" (format nil "~S" value)))
	  ((eq type 'dateTime)
	   (format-date-string "%Y%m%dT%H:%M:%S" value))
	  ((eq type 'string)
	   (ed::xmlpm-encode-special-chars value))
	  ((eq type 'base64)
	   value)		; base64はエンコードした値が渡されるものとする
	  (t
	   ""))))

(defun xmlrpcm-format-request-param (param s)
  (let ((type (xmlrpcm-param-type param))
	(values (xmlrpcm-param-value param)))
    (format s "<value>~%")
    (cond ((eq type 'struct)	; struct
	   (format s "<struct>~%")
	   (dolist (value values)
	     (format s "<member>~%")
	     (format s "<name>~A</name>~%" (xmlrpcm-param-name value))
	     (xmlrpcm-format-request-param value s)
	     (format s "</member>~%"))
	   (format s "</struct>~%"))
	  ((eq type 'array)	; array
	   (format s "<array>~%")
	     (format s "<data>~%")
	   (dolist (value values)
	     (xmlrpcm-format-request-param value s))
	   (format s "</data>~%")
	   (format s "</array>~%"))
	  (t			; t
	   (format s "~A" (xmlrpcm-format-request-value param))
	   ))
    (format s "</value>~%")
    ))

(defun xmlrpcm-format-request-value (param)
  (format nil "<~A>~A</~A>~%"
	  (xmlrpcm-param-type-string param)
	  (xmlrpcm-param-value-string param)
	  (xmlrpcm-param-type-string param)))

(defun xmlrpcm-format-request (xml)
  (let ((methodName (xmlrpcm-request-methodName xml))
	(params (xmlrpcm-request-params xml)))
    (convert-encoding-from-internal
     *encoding-utf8n*
     (with-output-to-string (strXml)
       (format strXml "<?xml version=\"1.0\" encoding=\"UTF-8\"?>~%")
       (format strXml "<methodCall>~%")
       (format strXml "<methodName>~A</methodName>~%" methodName)
       (when params
	 (format strXml "<params>~%")
	 (dolist (param params)
	   (format strXml "<param>~%")
	   (xmlrpcm-format-request-param param strXml)
	   (format strXml "</param>~%"))
	 (format strXml "</params>~%"))
       (format strXml "</methodCall>~%")
       ))))

(defun xmlrpcm-parse-response (xmlpm)
  (let* ((resp (car xmlpm))
	 (res (car (ed::xmlpm-tag-contents resp))))
    (unless (equal (ed::xmlpm-tag-name resp) "methodResponse")
      (error "not methodResponse: ~S" (ed::xmlpm-tag-name resp)))
    (cond ((equal (ed::xmlpm-tag-name res) "params")
	   (return-from xmlrpcm-parse-response
	     (values
	      *xmlrpcm-response-ok*
	      (xmlrpcm-parse-response-params (ed::xmlpm-tag-contents res)))))
	  ((equal (ed::xmlpm-tag-name res) "fault")
	   (return-from xmlrpcm-parse-response
	     (values
	      *xmlrpcm-response-fault*
	      (xmlrpcm-parse-response-fault (ed::xmlpm-tag-contents res)))))
	  (t
	   (error "unknown response: ~S" (ed::xmlpm-tag-name res))))
    ))

(defun xmlrpcm-fault-msg (params)
  (let* ((fault (xmlrpcm-param-value params)))
    (error "Fault: ~S:~S"
	   (xmlrpcm-param-value (assoc "faultCode" fault :test #'equal))
	   (xmlrpcm-param-value (assoc "faultString" fault :test #'equal)))))

(defun xmlrpcm-parse-response-params (params)
  (let (parsed)
    (dolist (param params)
      (when *debug-mode*
	(msgbox "xmlrpcm-parse-response-params: param: ~S" param))
      (let ((value (car
		    (ed::xmlpm-tag-contents
		     (car
		      (ed::xmlpm-tag-contents param))))))
	(push (xmlrpcm-parse-value value) parsed)))
    (nreverse parsed)))

#|
;;; タイムゾーンをまともに読み取ると・・・
(defun xmlrpcm-parse-dateTime (str)
  (or (junk::iso8601-parse-datetime str) 0))
|#

(defun xmlrpcm-parse-dateTime (str)
  (if (string-match "\\([0-9]\\{4\\}\\)-?\\([0-9]\\{2\\}\\)-?\\([0-9]\\{2\\}\\)T\\([0-9]\\{2\\}\\):\\([0-9]\\{2\\}\\):\\([0-9]\\{2\\}\\)"
		    str)
      (let ((year  (parse-integer (match-string 1)))
	    (month (parse-integer (match-string 2)))
	    (day   (parse-integer (match-string 3)))
	    (hour  (parse-integer (match-string 4)))
	    (min   (parse-integer (match-string 5)))
	    (sec   (parse-integer (match-string 6))))
	(encode-universal-time sec min hour day month year))
    (progn
      (msgbox "Could not parse dateTime: ~S" str)
      0)))

(defun xmlrpcm-parse-value (value)
  (let* ((name (ed::xmlpm-tag-name value))
	 (type (xmlrpcm-param-string-type name))
	 (contents (ed::xmlpm-tag-contents value))
	 (content (car contents)))
    (when *debug-mode*
      (msgbox "xmlrpcm-parse-value: ~S" value))
    (cond ((or (eq type 'int)
	       (eq type 'i4))
	   (list nil (parse-integer content) type))
	  ((eq type 'double)
	   (list nil (read-from-string content) type))
	  ((eq type 'boolean)
	   (list nil (parse-integer content) type))
	  ((eq type 'string)
	   (list nil content type))
	  ((eq type 'base64)
	   (if content
	       (list nil (si:base64-decode content) type)
	     (list nil nil type)))
	  ((eq type 'dateTime)
	   (list nil (xmlrpcm-parse-dateTime content) type))
	  ((eq type 'array)
	   (xmlrpcm-parse-array content))
	  ((eq type 'struct)
	   (xmlrpcm-parse-struct contents))
	  (t
	   (error "unknown type: ~S" name)))
    ))

(defun xmlrpcm-parse-member (member)
  (let* ((contents (ed::xmlpm-tag-contents member))
	 (name (car (ed::xmlpm-tag-contents (car contents))))
	 (value (xmlrpcm-parse-value (car (ed::xmlpm-tag-contents (cadr contents))))))
    (when *debug-mode*
      (msgbox "xmlrpcm-parse-member: ~S" member))
    (setf (xmlrpcm-param-name value) name)
    value))

(defun xmlrpcm-parse-array (data)
  (let (values)
    (when *debug-mode*
      (msgbox "xmlrpcm-parse-array: ~S" data))
    (dolist (value (ed::xmlpm-tag-contents data))
      (let ((adata (car (ed::xmlpm-tag-contents value))))
	(when adata
	  (push (xmlrpcm-parse-value adata) values))))
    (list nil (reverse values) 'array)))

(defun xmlrpcm-parse-struct (struct)
  (let (members)
    (when *debug-mode*
      (msgbox "xmlrpcm-parse-struct: ~S" struct))
    (dolist (member struct)
      (push (xmlrpcm-parse-member member) members))
    (list nil (reverse members) 'struct)))

(defun xmlrpcm-parse-response-fault (fault)
  (xmlrpcm-parse-value
   (car (ed::xmlpm-tag-contents
	 (car fault)))))

(defun xmlrpcm-send-request (url req &optional (method "POST"))
  (let* ((buf "*XMLRPCM TEMP*")
	 (reqstr (xmlrpcm-format-request req))
	 (headers (list (cons "content-type" "text/xml")))
	 response-status
	 response-params
	 (junk::*junk-http-user-agent* *user-agent*))
    (declare (special junk::*junk-http-user-agent*))
    (when *debug-mode*
      (msgbox "~S" reqstr))
    (long-operation
      (multiple-value-bind (proto host path anchor port url)
	  (junk::junk-http-url-study url)
	(multiple-value-bind (stream headers request)
	    (junk::junk-http-request-send host path method
					  :port port
					  :headers headers
					  :data reqstr) ; 
	  (multiple-value-bind (http-stream status resp-headers response)
	      (junk::junk-http-response-get stream)
	    (progn
	      (unless (equal status "200")
		(error "HTTP Error: ~S" response))
	      (when *debug-mode*
		(msgbox "~A~%~%~A~%~%~{~A~%~}" request response resp-headers))
	      (save-excursion
		(set-buffer (get-buffer-create buf))
		(erase-buffer (selected-buffer))
		(let ((os (make-buffer-stream (selected-buffer))))
		  (junk::junk-http-copy-stream http-stream os))
		(when *debug-mode*
		  (msgbox "~A" (buffer-substring (point-min) (point-max))))
		(multiple-value-setq (response-status response-params)
		  (let ((parsed-xml (ed::xmlpm-parse)))
		    (when *debug-mode*
		      (msgbox "~S" parsed-xml))
		    (xmlrpcm-parse-response parsed-xml)))
		(delete-buffer buf)
		))))))
    (when *debug-mode*
      (msgbox "~S~%~S" response-status response-params))
    (if (xmlrpcm-response-ok-p response-status)
	response-params
      (xmlrpcm-fault-msg response-params))))

;;
;; Introspection
;;

;array system.listMethods ()
(defun system-listMethods (url)
  (let* ((req (list "system.listMethods"))
	 (res (xmlrpcm-send-request url req))
	 methods)
    ; stringのarray
    (dolist (item (xmlrpcm-param-value (car res)))
      (push (xmlrpcm-param-value item) methods))
    (nreverse methods)))

;string system.methodHelp (string methodName)
(defun system-methodHelp (url methodName)
  (let* ((req (list "system.methodHelp"
		    (list nil methodName 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (xmlrpcm-param-value (car res))))

;array system.methodSignature (string methodName)
(defun system-methodSignature (url methodName)
  (let* ((req (list "system.methodSignature"
		    (list nil methodName 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    res))
