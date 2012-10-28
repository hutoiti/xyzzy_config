;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: wikirpc2.l,v 1.3 2006/02/04 20:01:07 torihat Exp $
;
; xmlrpcm/wikirpc2.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xmlrpcm/defs"))

(provide "xmlrpcm/wikirpc2")

(in-package "xmlrpcm")

(defstruct wikirpc2pageinfo
  name
  lastModified
  author
  version
  others)

;;; pageInfoを取得
;;; (Hikiが返すstructの中味が全然違うのはなぜだ？)
(defun wikirpc2-parse-pageInfo (page)
  (let ((info (make-wikirpc2pageinfo))
	others)
    (dolist (item (xmlrpcm-param-value page))
      (let ((key (xmlrpcm-param-name item)))
	(cond ((or (equal key "name")
		   (equal key "title"))	; for Hiki
	       (setf (wikirpc2pageinfo-name info) (wikirpc2-get-utf8-value item)))
	      ((equal key "lastModified")
	       (setf (wikirpc2pageinfo-lastModified info) (xmlrpcm-param-value item)))
	      ((equal key "author")
	       (setf (wikirpc2pageinfo-author info) (wikirpc2-get-utf8-value item)))
	      ((equal key "version")
	       (setf (wikirpc2pageinfo-version info) (xmlrpcm-param-value item)))
	      (t
	       (push item others)))))
    (setf (wikirpc2pageinfo-others info) (nreverse others))
    info))

;;; base64でutf8テキストの場合の処理
(defun wikirpc2-get-utf8-value (item)
  (let ((value (xmlrpcm-param-value item)))
    (if (and (eq (xmlrpcm-param-type item) 'base64)
	     value)
	(map-utf-8-to-internal value)
      value)))

;;; array getRecentChanges( Date timestamp )
(defun wikirpc2-getRecentChanges (url timestamp)
  (let* ((req (list "wiki.getRecentChanges"
		    (list nil timestamp 'dateTime)
		    ))
	 (res (xmlrpcm-send-request url req))
	 pages)
    ; structのarray
    (dolist (item (xmlrpcm-param-value (car res)))
      (let ((page (wikirpc2-parse-pageInfo item)))
	(when page
	  (push page pages))))
    (nreverse pages)))

;;; int getRPCVersionSupported()
(defun wikirpc2-getRPCVersionSupported (url)
  (let* ((req (list "wiki.getRPCVersionSupported"))
	 (res (xmlrpcm-send-request url req)))
    (xmlrpcm-param-value (car res))))

;;; utf8 getPage( utf8 pagename )
(defun wikirpc2-getPage (url pagename)
  (let* ((req (list "wiki.getPage"
		    (list nil pagename 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (wikirpc2-get-utf8-value (car res))))

;;; utf8 getPageVersion( utf8 pagename, int version )
(defun wikirpc2-getPageVersion (url pagename version)
  (let* ((req (list "wiki.getPageVersion"
		    (list nil pagename 'string)
		    (list nil version 'int)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (wikirpc2-get-utf8-value (car res))))

;;; utf8 getPageHTML( utf8 pagename )
(defun wikirpc2-getPageHTML (url pagename)
  (let* ((req (list "wiki.getPageHTML"
		    (list nil pagename 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (wikirpc2-get-utf8-value (car res))))

;;; utf8 getPageHTMLVersion( utf8 pagename, int version )
(defun wikirpc2-getHTMLPageVersion (url pagename version)
  (let* ((req (list "wiki.getPageHTMLVersion"
		    (list nil pagename 'string)
		    (list nil version 'int)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (wikirpc2-get-utf8-value (car res))))

;;; array getAllPages()
(defun wikirpc2-getAllPages (url)
  (let* ((req (list "wiki.getAllPages"))
	 (res (xmlrpcm-send-request url req))
	 pages)
    ; stringのarray
    (dolist (item (xmlrpcm-param-value (car res)))
      (push (wikirpc2-get-utf8-value item) pages))
    (nreverse pages)))

;;; struct getPageInfo( utf8 pagename )
(defun wikirpc2-getPageInfo (url pagename)
  (let* ((req (list "wiki.getPageInfo"
		    (list nil pagename 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (wikirpc2-parse-pageInfo (car res))))

;;; struct getPageInfoVersion( utf8 pagename, int version )
(defun wikirpc2-getPageInfoVersion (url pagename version)
  (let* ((req (list "wiki.getPageInfoVersion"
		    (list nil pagename 'string)
		    (list nil version 'int)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (wikirpc2-get-utf8-value (car res))))

;;; array listLinks( utf8 pagename )
(defun wikirpc2-listLinks (url pagename)
  (let* ((req (list "wiki.listLinks"
		    (list nil pagename 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    res))

;;; array getBackLinks( utf8 pagename )
(defun wikirpc2-getBackLinks (url pagename)
  (let* ((req (list "wiki.getBackLinks"
		    (list nil pagename 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    res))

;;; putPage( utf8 pagename, utf8 content, struct attributes )
(defun wikirpc2-putPage (url pagename content attributes)
  (let* ((req (list "wiki.putPage"
		    (list nil pagename 'string)
		    (list nil content 'string)
		    (list nil attributes 'struct)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (eq (xmlrpcm-param-value (car res))
	*xmlrpcm-boolean-true*)))

;;; array listAttachments( utf8 pagename )
(defun wikirpc2-listAttachments (url pagename)
  (let* ((req (list "wiki.listAttachments"
		    (list nil pagename 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    res))

;;; base64 getAttachment( utf8 attachmentName )
(defun wikirpc2-getAttachment (url attachmentName)
  (let* ((req (list "wiki.getAttachment"
		    (list nil attachmentName 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    res))

;;; putAttachment( utf8 attachmentName, base64 content )
(defun wikirpc2-putAttachment (url attachmentName content)
  (let* ((req (list "wiki.putAttachment"
		    (list nil attachmentName 'string)
		    (list nil content 'base64)
		    ))
	 (res (xmlrpcm-send-request url req)))
    res))
