;;; -*- mode: lisp -*-
;;; name:     virtual-file-ftp
;;; version:  2007.03.23
;;; author:   shiro
;;; depends:  complete+, virtual-file
;;; category: Utilities, File Systems
;;; src:      http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fvirtual-file-ftp&openfile=
;;; changes:  ���X�g��Ԃ��֐��̎d�l��ύX
;;; files:    site-lisp/virtual-file/virtual-file-ftp.l
;;;           site-lisp/virtual-file/virtual-file-ftp.lc
;;;           site-lisp/ni-autoload/silog/virtual-file-ftp.l

;; Copyright (C) 1999-2005 Masashi Hattori
;; Copyright (C) 2007 shiro
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:
;;
;; 1. Redistributions of source code must retain the above copyright
;;    notice, this list of conditions and the following disclaimer.
;;
;; 2. Redistributions in binary form must reproduce the above copyright
;;    notice, this list of conditions and the following disclaimer in
;;    the documentation and/or other materials provided with the
;;    distribution.
;;
;; 3. The name of the author may not be used to endorse or promote
;;    products derived from this software without specific prior
;;    written permission.
;;
;; THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;; PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
;; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
;; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
;; STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;; ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;; POSSIBILITY OF SUCH DAMAGE.

;; �T�v:
;; 
;; virtual-file��FTP�p�v���O�C��
;; 
;; �~�j�o�b�t�@��FTP�ɐڑ����ĕ⊮���A
;; �ǂݍ��ݎ��Ɉꎞ�t�@�C���Ƀ_�E�����[�h���A
;; �ۑ����ɍăA�b�v���[�h���s���܂��B

;; �ݒ�:
;; 
;; ���炩���߈ȉ��̗�̂悤�ɏ����ꂽ
;; �t�@�C�� foo._ftp ��p�ӂ���B
;; 
;; :user   "bar"
;; :pass   "baz"
;; :host   "ftp.qux.com"
;; 
;; �����f�B���N�g�����w�肵�����l��
;; :cwd    "public_html"
;; �������Ă����B
;; 
;; ���{��̃t�@�C������������������l��
;; :encode  map-euc-to-sjis
;; �������Ă����B
;; utf8 �Ȃ� map-utf-8-to-sjis ���g���B
;; ����ȊO�̐l�� $XYZZY/lisp/encoding.l �����ēK���ɁB
;; 
;; pasv���ǂ��l��.xyzzy�Ɉȉ��������΂�������(�Q�l: lisp/wip/ftp.l)
;; (setf *ftp-passive-mode* t)

;; �g����:
;; 
;; 1. ��L�̐ݒ���s��
;; 2. find-file [C-x C-f]
;; 3. ��L�̐ݒ���s�����t�@�C���̖�����/������
;; 4. �ҏW���I������� save-buffer [C-x C-s] �ŏ���ɃA�b�v���[�h

;; ����:
;; 
;; �t�@�C��1�ɂ����O�C���E�t�@�C���̎擾�E���O�A�E�g���s���܂��B
;; �Z�b�V������10��20���t�@�C�����J���悤�Ȃ��Ƃ�����ƒ��x����������܂���B
;; 
;; ���s�R�[�h�܂ł͕ϊ����Ȃ��̂�
;;  [C-x C-k n]
;; �܂���
;;  M-x change-eol-code
;; �ŉ��s�R�[�h��lf�ɂ��Ă���ۑ����Ă��������B

;; ����:
;; 
;; 2007.03.23
;; - ���X�g��Ԃ��֐��̎d�l��ύX
;; 
;; 2007.03.22
;; - ���X�g��Ԃ��֐����S�Ă̌��݂̂�Ԃ��悤�ɂ���
;; 
;; 2007.03.14
;; - �ꎞ�t�@�C���ɕۑ����ăA�b�v���[�h����悤�ɂ���
;; 
;; 2007.03.07
;; - ����

;;; Code:

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "virtual-file/virtual-file")
  (require "wip/ftp"))

(provide "virtual-file/virtual-file-ftp")
(in-package "complete+")

;; non-nil�Ȃ�FTP�̃��b�Z�[�W��*FTP Message*�Ƃ����o�b�t�@�ɏo�͂��܂��B
;; e.g. (setf complete+::*plugin-ftp-message-buffer* t)
(defvar *plugin-ftp-message-buffer* nil)

;; �L���b�V�����鎞�� (default: 300000=5min)
(defvar *plugin-ftp-cache-interval* 300000)

(defparameter *plugin-ftp-complete-hash*
  (make-hash-table :test 'equalp))

(defun plugin-ftp-list-internal (base file &key host cwd user pass encode)
  (format t "~%* FTP connect to ~S (list)~%" host)
  (let (subpath hash fname)
	(unless file
	  (return-from plugin-ftp-list-internal nil))
	(if (string-match "\\(.*\\)/\\([^/]*\\)$" file)
		(setq subpath (match-string 1)
			  fname (match-string 2))
	  (psetq subpath ""
			 fname subpath))
	(let* ((not-match 0)
		   (hash (gethash (concat base subpath) *plugin-ftp-complete-hash*))
		   (x (if (and hash
					   (> (+ *plugin-ftp-cache-interval* (cadr hash))
						  (get-internal-real-time)))
				  (car hash)
				(user::with-ftp-stream (ftp host)
				  (user::ftp-login ftp user pass)
				  (let ((ret (user::ftp-ls ftp (concat (when cwd (append-trail-slash cwd)) subpath))))
					(setf (gethash (concat base subpath) *plugin-ftp-complete-hash*) (list ret (get-internal-real-time)))
					ret
					)))))
	  (setq x (mapcar (lambda (f)
						(cond ((string-match *plugin-ftp-file-line-regexp-1* f)
							   (let* ((perm (match-string 1))
									  (file (if (string= "->" (match-string 3))
												(match-string 2)
											  (match-string 4))))
								 (list file
									   nil
									   (plugin-ftp-file-type perm)
									   f)))
							  ((string-match *plugin-ftp-file-line-regexp-1* f)
							   (let ((ftime (format nil "~A ~A"
													(match-string 1)
													(match-string 2)))
									 (size (match-string 3))
									 (file (match-string 4)))
								 (list file
									   ftime
									   (if (equal "<DIR>" size)
										   *plugin-ftp-directory*
										 *plugin-ftp-file*)
									   f)))
							  (t
							   (list "" ""))
							  )) x))
	  (let ((ret (mapcar (lambda (x) (concat (car x)
											 (if (eql *plugin-ftp-directory* (caddr x)) "/")))
						 x)))
		(when (and (= (length ret) 1)
				   (string-match (concat (regexp-quote fname) "/$") (car ret)))
		  (setf ret (mapcar (lambda (x) (concat (car ret) x))
							(plugin-ftp-list-internal
							 base (concat base subpath (car ret))
							 :host host :cwd cwd :user user :pass pass))))
		(when encode
		  (setf ret (mapcar (lambda (f) (funcall encode f)) ret)))
		ret))))

(defun plugin-ftp-load-internal (base file &key host cwd user pass encode)
  (format t "~%* FTP connect to ~S (load)~%" host)
  (user::with-ftp-stream (ftp host)
	(user::ftp-login ftp user pass)
	(let* ((dir (make-temp-file-name "ftp_" "" nil t))
		   (bufname (if (string-match "[/\\]\\([^/\\]+\\)$" file)
						(subseq file (match-beginning 1) (match-end 1))
					  file))
		   (tmp-file (merge-pathnames (file-namestring file) dir)))
	  (with-open-file (fs tmp-file :direction :output)
		(user::ftp-get ftp (if (and cwd (not (string= cwd "")))
							   (concat (append-trail-slash cwd) file)
							 file)
					   fs))
	  (unwind-protect
		  (progn
			(find-file tmp-file)
			(set-default-directory
			 (directory-namestring
			  (remove-trail-slash base)))
			(rename-buffer bufname)
			(set-buffer-file-name nil)
			(set-buffer-alternate-file-name
			 (merge-pathnames file base))
			(virtual-file-mode-on))
		(delete-file tmp-file :if-access-denied :force)
		(delete-directory dir :if-access-denied :force)))
	(selected-buffer)))

(defun plugin-ftp-save-internal (base file nomsg append &key host cwd user pass encode)
  (save-excursion
	(let ((tmp-file (make-temp-file-name)))
	  (unwind-protect
		  (progn
			(when append
			  (save-excursion
				(set-buffer (plugin-ftp-load-internal
							 base file
							 :host host :cwd cwd :user user :pass pass :encode encode))
				(write-file tmp-file t)))
			(write-file tmp-file t append)
			(user::with-ftp-stream (ftp host)
			  (user::ftp-login ftp user pass)
			  (with-open-file (s tmp-file)
				(user::ftp-put ftp s (if (and cwd (not (string= cwd "")))
										 (concat (append-trail-slash cwd) file)
									   file)))))
		(delete-file tmp-file))))
  (set-buffer-modified-p nil)
  (unless nomsg
	(message "Wrote ~a: ~a~a"
			 host
			 (if (and cwd (not (string= cwd ""))) (append-trail-slash cwd) "")
			 file)))

(defvar *plugin-ftp-file-line-regexp-1*
  "^[ \t]*\\([^ \t]+\\)[ \t]+[^ \t]+[ \t]+.*[ \t]\\([^ \t]+\\)[ \t]+\\([^ \t]+\\)[ \t]+\\([^ \t]+\\)$")
(defvar *plugin-ftp-file-line-regexp-2*
  "\\([-0-9]+\\)[ \t]+\\([0-9:]+[AP]M\\)[ \t]+\\([^ \t\n]+\\)[ \t]+\\([^ \t\n]+\\)")

(defvar *plugin-ftp-file* nil)
(defvar *plugin-ftp-directory* 1)

(defvar *plugin-ftp-symlink* 2)

(defun plugin-ftp-file-type (perm)
  (cond ((char= (char perm 0) #\d)
		 *plugin-ftp-directory*)
		((char= (char perm 0) #\l)
		 *plugin-ftp-symlink*)
		(t
		 *plugin-ftp-file*)))

(defun plugin-ftp-get-log-buffer ()
  (let* ((name "*FTP Message*")
		 (buf (find-buffer name)))
	(unless buf
	  (setf buf (create-new-buffer name))
	  (with-set-buffer
		(save-excursion
		  (set-buffer buf)
		  (setq buffer-read-only nil)
		  (setq need-not-save t)
		  (setq kept-undo-information nil)
		  (setq auto-save nil))))
	buf))

(defun plugin-ftp-list (base file)
  (let ((param (with-open-file (f base)
				 (let (ret tmp)
				   (while (setf tmp (read f nil))
					 (push tmp ret))
				   (nreverse ret)))))
	(values (cond (*plugin-ftp-message-buffer*
				   (with-output-to-buffer ((plugin-ftp-get-log-buffer))
					 (format t "~%* FTP connect --- ~S~%" param)
					 (apply #'plugin-ftp-list-internal base file param)))
				  (t (apply #'plugin-ftp-list-internal base file param)))
			:list)))

(defun plugin-ftp-load (base file)
  (let ((param (with-open-file (f base)
				 (let (ret tmp)
				   (while (setf tmp (read f nil))
					 (push tmp ret))
				   (nreverse ret)))))
	(cond (*plugin-ftp-message-buffer*
		   (with-output-to-buffer ((plugin-ftp-get-log-buffer))
			 (apply #'plugin-ftp-load-internal base file param)))
		  (t (apply #'plugin-ftp-load-internal base file param)))))

;; char-encoding �� eol-code �͗ǂ��킩���ĂȂ��̂Ńp�X
(defun plugin-ftp-save (base file nomsg append char-encoding eol-code)
  (let ((param (with-open-file (f base)
				 (let (ret tmp)
				   (while (setf tmp (read f nil))
					 (push tmp ret))
				   (nreverse ret)))))
	(cond (*plugin-ftp-message-buffer*
		   (with-output-to-buffer ((plugin-ftp-get-log-buffer))
			 (apply #'plugin-ftp-save-internal base file nomsg append param)))
		  (t (apply #'plugin-ftp-save-internal base file nomsg append param)))))

(regist-virtual-file-handler
 ;; �}�b�`���鐳�K�\��
 "\\._ftp/$"

 ;; �⊮���X�g�̐������s���֐����w�肷��
 ;; 
 ;; ����
 ;;   base  ._ftp/�܂ł̃p�X
 ;;   file  ._ftp/����̃p�X
 ;;   
 ;;   e.g.  C:/ftp/foo._ftp/ , public_htm/index.html
 ;; 
 ;; �߂�l
 ;;   �⊮���̃��X�g(�f�B���N�g���s�v)
 ;;   
 ;;   e.g. ("abbrev.l" "about.l" "backup.l")
 'plugin-ftp-list
 
 ;; �t�@�C���̓ǂݍ��݂��s���֐����w�肷��
 ;; 
 ;; ����
 ;;   base ._ftp/�܂ł̃p�X
 ;;   file ._ftp/����̃p�X
 ;;   
 ;;   e.g.  C:/ftp/foo._ftp/ , public_htm/index.html
 ;;
 ;; �߂�l
 ;;   �I���������o�b�t�@
 ;;
 'plugin-ftp-load
 
 ;; �t�@�C���̕ۑ����s���֐����w�肷��
 ;;
 ;; ����
 ;;   base          ._ftp/�܂ł̃p�X
 ;;   file          ._ftp/����̃p�X
 ;;                 (��������optional)
 ;;   nomsg         ���b�Z�[�W��\�����Ȃ�
 ;;   append        �����̃t�@�C���ɒǉ�����
 ;;   char-encoding �G���R�[�h
 ;;   eol-code      ���s�R�[�h
 ;;   
 ;;   e.g.  C:/ftp/foo._ftp/, public_htm/index.html, nil, t
 'plugin-ftp-save
 )

;;; virtual-file-ftp.l ends here