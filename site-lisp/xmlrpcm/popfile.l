;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: popfile.l,v 1.2 2006/03/07 18:12:25 torihat Exp $
;
; xmlrpcm/popfile.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xmlrpcm/defs"))

(provide "xmlrpcm/popfile")

(in-package "xmlrpcm")

(defun popfile-get-session-key (url username password)
  (let* ((req (list "POPFile/API.get_session_key"
		    (list nil username 'string)
		    (list nil password 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (xmlrpcm-param-value (car res))))

(defun popfile-release-session-key (url sesskey)
  (let* ((req (list "POPFile/API.release_session_key"
		    (list nil sesskey 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    t))				; 何も帰ってこない？

(defun popfile-classify (url sesskey filename)
  (let* ((req (list "POPFile/API.classify"
		    (list nil sesskey 'string)
		    (list nil filename 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (xmlrpcm-param-value (car res))))

(defun popfile-handle-message (url sesskey infile outfile)
  (let* ((req (list "POPFile/API.handle_message"
		    (list nil sesskey 'string)
		    (list nil infile 'string)
		    (list nil outfile 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (xmlrpcm-param-value (car res))))

(defun popfile-get-buckets (url sesskey)
  (let* ((req (list "POPFile/API.get_buckets"
		    (list nil sesskey 'string)
		    ))
	 (res (xmlrpcm-send-request url req))
	 items)
    ; stringのarray
    (dolist (item (xmlrpcm-param-value (car res)))
      (push (xmlrpcm-param-value item) items))
    (nreverse items)))

(defun popfile-get-bucket-word-count (url sesskey bucket)
  (let* ((req (list "POPFile/API.get_bucket_word_count"
		    (list nil sesskey 'string)
		    (list nil bucket 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (xmlrpcm-param-value (car res))))

(defun popfile-get-bucket-word-list (url sesskey bucket)
  (let* ((req (list "POPFile/API.get_bucket_word_list"
		    (list nil sesskey 'string)
		    (list nil bucket 'string)
		    ))
	 (res (xmlrpcm-send-request url req))
	 items)
    ; stringのarray
    (dolist (item (xmlrpcm-param-value (car res)))
      (push (xmlrpcm-param-value item) items))
    (nreverse items)))

(defun popfile-get-word-count (url sesskey)
  (let* ((req (list "POPFile/API.get_word_count"
		    (list nil sesskey 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (xmlrpcm-param-value (car res))))

(defun popfile-get-bucket-unique-count (url sesskey bucket)
  (let* ((req (list "POPFile/API.get_bucket_unique_count"
		    (list nil sesskey 'string)
		    (list nil bucket 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (xmlrpcm-param-value (car res))))

(defun popfile-get-bucket-color (url sesskey bucket)
  (let* ((req (list "POPFile/API.get_bucket_color"
		    (list nil sesskey 'string)
		    (list nil bucket 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (xmlrpcm-param-value (car res))))

(defun popfile-set-bucket-color (url sesskey bucket color)
  (let* ((req (list "POPFile/API.set_bucket_color"
		    (list nil sesskey 'string)
		    (list nil bucket 'string)
		    (list nil color 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (eq 1 (xmlrpcm-param-value (car res)))))

(defun popfile-get-bucket-parameter (url sesskey bucket parameter)
  (let* ((req (list "POPFile/API.get_bucket_parameter"
		    (list nil sesskey 'string)
		    (list nil bucket 'string)
		    (list nil parameter 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (xmlrpcm-param-value (car res))))

(defun popfile-set-bucket-parameter (url sesskey bucket parameter value)
  (let* ((req (list "POPFile/API.get_bucket_parameter"
		    (list nil sesskey 'string)
		    (list nil bucket 'string)
		    (list nil parameter 'string)
		    (list nil value 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    t))				; 何も返ってこない

(defun popfile-get-html-colored-message (url sesskey filename)
  (let* ((req (list "POPFile/API.get_html_colored_message"
		    (list nil sesskey 'string)
		    (list nil filename 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (xmlrpcm-param-value (car res))))

(defun popfile-create-bucket (url sesskey bucket)
  (let* ((req (list "POPFile/API.create_bucket"
		    (list nil sesskey 'string)
		    (list nil bucket 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    t))				; 何も返ってこない

(defun popfile-clear-bucket (url sesskey bucket)
  (let* ((req (list "POPFile/API.clear_bucket"
		    (list nil sesskey 'string)
		    (list nil bucket 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    t))				; 何も返ってこない

(defun popfile-delete-bucket (url sesskey bucket)
  (let* ((req (list "POPFile/API.delete_bucket"
		    (list nil sesskey 'string)
		    (list nil bucket 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    t))				; 常に1が返る

(defun popfile-rename-bucket (url sesskey old new)
  (let* ((req (list "POPFile/API.rename_bucket"
		    (list nil sesskey 'string)
		    (list nil old 'string)
		    (list nil new 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (eq 1 (xmlrpcm-param-value (car res)))))

(defun popfile-add-message-to-bucket (url sesskey bucket filename)
  (let* ((req (list "POPFile/API.add_message_to_bucket"
		    (list nil sesskey 'string)
		    (list nil bucket 'string)
		    (list nil filename 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (eq 1 (xmlrpcm-param-value (car res)))))

(defun popfile-remove-message-from-bucket (url sesskey bucket filename)
  (let* ((req (list "POPFile/API.remove_message_from_bucket"
		    (list nil sesskey 'string)
		    (list nil bucket 'string)
		    (list nil filename 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (eq 1 (xmlrpcm-param-value (car res)))))

(defun popfile-get-buckets-with-magnets (url sesskey)
  (let* ((req (list "POPFile/API.get_buckets_with_magnets"
		    (list nil sesskey 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    res)) ;;; 未テスト

(defun popfile-get-magnet-types-in-bucket (url sesskey bucket)
  (let* ((req (list "POPFile/API.get_magnet_types_in_bucket"
		    (list nil sesskey 'string)
		    (list nil bucket 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    res)) ;;; 未テスト

(defun popfile-clear-magnets (url sesskey)
  (let* ((req (list "POPFile/API.clear_magnets"
		    (list nil sesskey 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    t))				; 何も返ってこない

(defun popfile-get-magnets (url sesskey bucket type)
  (let* ((req (list "POPFile/API.get_magnets"
		    (list nil sesskey 'string)
		    (list nil bucket 'string)
		    (list nil type 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    res)) ;;; 未テスト

(defun popfile-create-magnet (url sesskey bucket type value)
  (let* ((req (list "POPFile/API.create_magnet"
		    (list nil sesskey 'string)
		    (list nil bucket 'string)
		    (list nil type 'string)
		    (list nil value 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    t))				; 何も返ってこない

(defun popfile-get-magnet-types (url sesskey)
  (let* ((req (list "POPFile/API.get_magnet_types"
		    (list nil sesskey 'string)
		    ))
	 (res (xmlrpcm-send-request url req))
	 items)
    ; stringのarray
    (dolist (item (xmlrpcm-param-value (car res)))
      (push (xmlrpcm-param-value item) items))
    (nreverse items)))

(defun popfile-delete-magnet (url sesskey bucket type value)
  (let* ((req (list "POPFile/API.delete_magnet"
		    (list nil sesskey 'string)
		    (list nil bucket 'string)
		    (list nil type 'string)
		    (list nil value 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    t))				; 何も返ってこない

(defun popfile-get-stopword-list (url sesskey)
  (let* ((req (list "POPFile/API.get_stopword_list"
		    (list nil sesskey 'string)
		    ))
	 (res (xmlrpcm-send-request url req))
	 items)
    ; stringのarray
    (dolist (item (xmlrpcm-param-value (car res)))
      (push (xmlrpcm-param-value item) items))
    (nreverse items)))

(defun popfile-add-stopword (url sesskey stopword)
  (let* ((req (list "POPFile/API.add_stopword"
		    (list nil sesskey 'string)
		    (list nil stopword 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (eq 1 (xmlrpcm-param-value (car res)))))

(defun popfile-remove-stopword (url sesskey stopword)
  (let* ((req (list "POPFile/API.remove_stopword"
		    (list nil sesskey 'string)
		    (list nil stopword 'string)
		    ))
	 (res (xmlrpcm-send-request url req)))
    (eq 1 (xmlrpcm-param-value (car res)))))
