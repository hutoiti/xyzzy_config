;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
;
; outputz.l
;
; by HATTORI Masashi
;
;�� outputz.l �Ƃ́H
;
;	Outputz <http://outputz.com/> ��API�o�R��xyzzy�ŏ������������𑗐M���܂�
;
;�� �����
;
;	xyzzy-0.2.2.235 �ȍ~�̂ݓ���m�F���Ă��܂��B
;
;	�ȉ��̊g�����K�v�ł��B�ʓr�C���X�g�[�����Ă��������B
;		- xml-http-request
;
;�� �C���X�g�[��
;
;    1. �t�@�C���̓W�J
;
;	�z�z�A�[�J�C�u�� system-root �ȉ��ɓW�J���Ă��������B
;
;    2. ~/.xyzzy �Ȃǂɐݒ�
;
;	(require "outputz")
;	(setq outputz::*outputz-api-key* "pTinoeHd7rr6") ; �����̎���
;
;    3. ��������
;
;	�t�@�C���ۑ����Ɏ����I�ɑ��M����܂��B
;	
;
;�� Changelog
;
;	[2009/10/07]	����
;
;�� License
;
; outputz.l
;
; Copyright (C) 2009 Masashi Hattori
; All rights reserved.
; 
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions
; are met:
; 
; 1. Redistributions of source code must retain the above copyright
;    notice, this list of conditions and the following disclaimer.
; 
; 2. Redistributions in binary form must reproduce the above copyright
;    notice, this list of conditions and the following disclaimer in
;    the documentation and/or other materials provided with the
;    distribution.
; 
; 3. The name of the author may not be used to endorse or promote
;    products derived from this software without specific prior
;    written permission.
; 
; THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
; PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
; STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
; ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE!
; POSSIBILITY OF SUCH DAMAGE.

(provide "outputz")

(defpackage "outputz"
  (:use "lisp" "editor"))

(in-package "outputz")

(require "xml-http-request")
(use-package :xml-http-request)

(define-history-variable *outputz-queue* nil)

(defvar *outputz-api-url* "http://outputz.com/api/post")
(defvar *outputz-api-key* nil)
(defvar *outputz-url-base* "http://localhost/")

(defvar *outputz-counter* nil)

(defvar *outputz-debug* nil)

(defmacro outputz-queue-key (queue)
  `(car ,queue))

(defmacro outputz-queue-uri (queue)
  `(cadr ,queue))

(defmacro outputz-queue-size (queue)
  `(caddr ,queue))

(defun outputz-file-url (path)
  (let ((dirs (pathname-directory path))
	(file (file-namestring path))
	(drive (pathname-device path)))
    (format nil
	    (concat *outputz-url-base* "~A~{/~A~}/~A")
	    drive
	    dirs
	    file)))

(defun outputz-post-data (key uri size)
  (format nil "key=~A&uri=~A&size=~D"
	  key
	  (si:www-url-encode (convert-encoding-from-internal *encoding-utf8n* uri) nil "0-9A-Za-z---._~")
	  size))

(defun outputz-queue-get (key uri)
  (assoc-if #'(lambda (x)
		(and (equal key (outputz-queue-key x))
		     (equal uri (outputz-queue-uri x))))
	    *outputz-queue*))

(defun outputz-queue-del (key uri)
  (delete-if #'(lambda (x)
		 (and (equal key (outputz-queue-key x))
		      (equal uri (outputz-queue-uri x))))
	     *outputz-queue*))

(defun outputz-queue-add (key uri size)
  (let ((queue (outputz-queue-get key uri)))
    (if queue
	(let ((new-size (+ size (outputz-queue-size queue))))
	  (outputz-queue-del key uri)
	  (push (list key uri new-size) *outputz-queue*))
      (push (list key uri size) *outputz-queue*))
    ))

(defun outputz-queue-send ()
  (when *outputz-queue*
    (let (queue)
      (dolist (q (reverse *outputz-queue*))
	(push (copy-list q) queue))
      (setq *outputz-queue* nil)
      (dolist (q queue)
	(outputz-post-send (outputz-queue-key q)
			   (outputz-queue-uri q)
			   (outputz-queue-size q))))))

(defun outputz-post (key path size)
  (let ((uri (outputz-file-url path)))
    (outputz-post-send key uri size)))

(defun outputz-post-send (key uri size)
  (when *outputz-debug*
    (msgbox "~{~S~%~}" (list key uri size)))
  (xhr-post-async *outputz-api-url*
		  (outputz-post-data key uri size) ; <= �悭�킩��Ȃ����A���X�g���Ƒ���Ȃ�
		  :encoding *encoding-utf8n*
		  :oncomplete #'(lambda (res)
				  (when *outputz-debug*
				    (msgbox "~D ~A~%~%~S"
					    (xhr-status res)
					    (xhr-status-text res)
					    (xhr-response-text res))))
		  :onsuccess #'(lambda (res)
				 (let ((status (xhr-status res))
				       (text (xhr-status-text res)))
				   (message "~D ~A" status text)
				   (outputz-queue-send) ; queue������Α��M
				   ))
		  :onfailure #'(lambda (res)
				 (let ((status (xhr-status res))
				       (text (xhr-status-text res)))
				   (cond ((= status 12007) ; �ڑ����Ă��Ȃ�
					  (progn
					    (outputz-queue-add key uri size) ; queue�ɓ����
					    (message "~D ~A" status text)))
					 (t
					  (msgbox "~D ~A~%~%~S"
						  status
						  text
						    (xhr-response-text res))))
				   ))
		  ))

(defun outputz-get(f)
  (or (cdr (assoc f *outputz-counter* :test #'path-equal))
      0))

(defun outputz-put(f size)
  (if (assoc f *outputz-counter* :test #'path-equal)
      (setf (cdr (assoc f *outputz-counter* :test #'path-equal)) size)
    (push (cons f size) *outputz-counter*)))

(defun outputz-count-before ()
  (let ((size (buffer-size))
	(path (get-buffer-file-name)))
    (outputz-put path size)))

(defun outputz-count-after ()
  (let* ((size (buffer-size))
	 (path (get-buffer-file-name))
	 (before (outputz-get path)))
    (unless (= size before)
      (outputz-put path size)
      (when (and *outputz-api-key*
		 (> size before))
	(outputz-post *outputz-api-key* path (- size before))))))

(add-hook 'editor::*find-file-hooks* 'outputz-count-before)
(add-hook 'editor::*after-save-buffer-hook* 'outputz-count-after)