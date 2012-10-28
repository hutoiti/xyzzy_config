;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
; $Id: mail-address.l 769 2007-12-14 19:18:39Z torihat $
;
; junk/mail-address.l
;
; by HATTORI Masashi

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "junk/defs"))

(provide "junk/mail-address")

(in-package "junk")

(defvar *mail-address-file*
  (merge-pathnames "address-book.dat" *base-directory*))

(defvar *mail-from-address* nil)
(defvar *mail-address-list* nil)
(defvar *mail-address-group-list* nil)
(defvar *mail-address-group-default* "default")

(defstruct mailaddress
  email
  name
  group)

(defun mail-address-load ()
  (when (file-exist-p *mail-address-file*)
    (setq *mail-address-list*
	  (data-read-from-file *mail-address-file*))
    (let (group-list)
      (dolist (a *mail-address-list*)
	(pushnew (mailaddress-group a) group-list :test #'equal))
      (setq *mail-address-group-list* (reverse group-list)))))

(defun mail-address-save ()
  (data-write-to-file *mail-address-file* *mail-address-list*))

(defun mail-address-get (email)
  (car (member email *mail-address-list*
	       :test #'equal
	       :key #'mailaddress-email)))

(defun mail-address-complete (&optional prompt default)
  (completing-read (or prompt "Address: ")
		   (mapcar #'mailaddress-email *mail-address-list*)
		   :default default
		   :must-match nil))

(defun mail-address-group-complete ()
  (completing-read "Address Group: "
		   *mail-address-group-list*
		   :must-match nil))

(defun mail-address-push (email name group)
  (let ((address (make-mailaddress :email email
				   :name  name
				   :group group)))
    (setq *mail-address-list*
	  (append *mail-address-list* (list address)))
    (mail-address-save)))

(defun mail-address-delete (email)
  (setq *mail-address-list*
	(delete email *mail-address-list*
		:test #'equal
		:key #'mailaddress-email))
  (mail-address-save))

(defun mail-address-add (&optional email name group)
  (interactive)
  (unless email
    (setq email (read-string "E-Mail: ")))
  (unless name
    (setq name (read-string "Name: ")))
  (unless group
    (setq group (mail-address-group-complete)))
  (mail-address-push email name group))

(defun mail-address-del (&optional email)
  (interactive)
  (unless email
    (setq email (mail-address-complete)))
  (mail-address-delete email))

(defvar *mail-address-dialog-group-string* "■ ")
(defvar *mail-address-dialog-result-list* nil)

(defun mail-address-group-addresses (group)
  (let (address-list)
    (mapc #'(lambda (x)
	      (when (equal group (mailaddress-group x))
		(push x address-list)))
	  *mail-address-list*)
    (nreverse address-list)))

(defun mail-address-dialog ()
  (let (mail-list
	result-list)
    (setq *mail-address-dialog-result-list* nil)
    (dolist (g *mail-address-group-list*)
      (let ((addrs (mail-address-group-addresses g)))
	(when addrs
	  ; グループ名
	  (push (list (concat *mail-address-dialog-group-string* g) "") mail-list)
	  ; 中味
	  (dolist (a addrs)
	    (let ((name (mailaddress-name a))
		  (addr (mailaddress-email a)))
	      (push (list (or name "") addr) mail-list))))
	))
    ; ダイアログ作成
    (multiple-value-bind (result data)
	(dialog-box `(dialog 0 0 222 237
			     (:caption "アドレス帳")
			     (:font 9 "ＭＳ Ｐゴシック")
			     (:control
			      (:listbox name-list nil #x50b10911 7 7 206 202)
			      (:button IDOK "OK" #x50010001 106 216 50 14)
			      (:button IDCANCEL "ｷｬﾝｾﾙ" #x50010000 164 216 50 14)))
		    (list (cons 'name-list
				(mapcar #'(lambda (x) x) (reverse mail-list))))
		    '((name-list :column (24 40) :must-match t :enable (IDOK))))
      (when result
	(dolist (current (cdar data))
	  (let ((name (car current))
		(addr (cadr current)))
	    ; グループを選択した場合はグループの全アドレスを追加
	    (if (string-match (concat "^" *mail-address-dialog-group-string*) name)
		(let ((group (substring name
					(length *mail-address-dialog-group-string*)
					(length name))))
		  (setq result-list (mail-address-group-addresses group)))
	      (unless (string= "" addr)
		(setq result-list (list (mail-address-get addr)))))))))
    (setq *mail-address-dialog-result-list* result-list)))
