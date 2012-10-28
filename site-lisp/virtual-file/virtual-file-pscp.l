;;; -*- mode: lisp -*-
;;; name:     virtual-file-pscp
;;; version:  2007.07.09
;;; author:   shiro
;;; depends:  complete+, virtual-file
;;; category: Utilities, File Systems
;;; src:      http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fvirtual-file-pscp&openfile=
;;; changes:  ����
;;; files:    site-lisp/virtual-file/sample._pscp
;;;           site-lisp/virtual-file/virtual-file-pscp.l
;;;           site-lisp/virtual-file/virtual-file-pscp.lc
;;;           site-lisp/ni-autoload/silog/virtual-file-pscp.l

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
;; virtual-file��pscp.exe�p�v���O�C��
;; 
;; pscp.exe���o�R����
;;   �t�@�C���̃��X�g���擾
;;   �t�@�C�����擾
;;   �t�@�C����]��
;; ���邱�Ƃ�
;;   �~�j�o�b�t�@�ŃT�[�o��̃t�@�C����⊮
;;   �ǂݍ��ݎ��Ɉꎞ�t�@�C���Ƀ_�E�����[�h���o�b�t�@�ɓǂݍ���
;;   �ۑ����Ɏ����ōăA�b�v���[�h
;; ���\�ɂȂ�܂��B
;; 
;; virtual-file-ftp�Ɣ�r�����
;;   scp�Ȃ̂ŒʐM���Í��������
;;   �����g����̂Ńp�X���[�h���t�@�C���ɒ��ڏ����Ȃ��čς�
;;   pagent.exe���g����SOCKS���g����
;;   pscp.exe���N�����鎞�Ԃ��]�v�ɂ�����
;;   (ftp�̕���xyzzy lisp�����Ŋ������Ă���)
;; �����قȂ�܂��B

;; ����:
;; 
;; 1. pscp.exe���K�v�ł�
;;    putty�������ϔłɓ����Ă܂�
;; 
;; 2. ������sample._pscp���Q�l��_pscp�t�@�C�����쐬���Ă�������
;;    :pscp
;;      pscp.exe�̃p�X
;;      pscp.exe��PATH���ʂ��Ă���ꍇ�͕s�v
;;    :host
;;      ���[�U��@�z�X�g���܂���pagent�̃Z�b�V������
;;    :options
;;      pscp.exe�̃I�v�V����
;;      �ڂ�����pscp.exe�����������Ŏ��s���ĕ\�������Usage���Q��

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
;; �ŉ��s�R�[�h��ϊ����Ă���ۑ����Ă��������B

;; ���̑�:
;; 
;; �L���b�V���̒��g������
;;   (virtual-file-plugin-pscp-list-memoized-dump)

;; ����:
;; 
;; 2007.07.09
;; - ����

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "virtual-file/virtual-file"))

(provide "virtual-file/virtual-file-pscp")
(in-package "complete+")
(export '(virtual-file-plugin-pscp-list-memoized-dump
		  *virtual-file-plugin-pscp-show-type*))


;; ------------------------------------------------------------------
;; configuration
;; ------------------------------------------------------------------

;; PSCP�̏o�͂��󂯂�o�b�t�@
(defvar *plugin-pscp-message-buffer* "*PSCP*")

;; �R�}���h�v�����v�g�̕\���`��
;;   :hide     �o���Ȃ�
;;   :minimize �ŏ������ďo��
;;   �ڍׂ̓��t�@�����X��call-process�̍��ڂ��Q��
(defvar *virtual-file-plugin-pscp-show-type* :minimize)

;; �L���b�V�����鎞�� (default: 300000=5min)
(defvar *plugin-scp-cache-interval* *virtual-file-default-cache-interval*)

;; -ls�̃t�@�C�����X�g����p���K�\��
(defvar *plugin-pscp-file-line-regexp*
  "^[ \t]*\\([^ \t]+\\)[ \t]+[^ \t]+[ \t]+.*[ \t]\\([^ \t]+\\)[ \t]+\\([^ \t]+\\)[ \t]+\\([^ \t]+\\)$")

;; debug?
(defparameter *plugin-pscp-debug* nil)

;; ------------------------------------------------------------------
;; library
;; ------------------------------------------------------------------

;; _pscp�t�@�C���̉��
#|
(plugin-pscp-parse-config-file "sample._pscp")
=> (:pscp "C:/bin/putty/pscp.exe" :host "bar" :options "-scp")
|#
(defun plugin-pscp-parse-config-file (file)
  (with-open-file (f file)
	(let (res tmp)
	  (while (setf tmp (read f nil))
		(push tmp res))
	  (nreverse res))))

;; filter
(defun plugin-pscp-filter (fn lst)
  (let ((acc nil))
	(dolist (x lst)
	  (let ((val (funcall fn x)))
		(if val (push val acc))))
	(nreverse acc)))

;; �o�b�t�@�̎擾
(defun plugin-pscp-get-buffer (&optional name)
  (unless name
	(setf name (concat (unless *plugin-pscp-debug* " ")
					   *plugin-pscp-message-buffer*)))
  (let ((buf (find-buffer name)))
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

;; �f�o�b�O(�W���o�͂ɂȂ񂩗���)
(defvar *plugin-pscp-debug-buffer-name* "*PSCP Massage*")
(defvar *plugin-pscp-debug-buffer-stream* nil)
(defmacro plugin-pscp-get-debug-stream (&rest body)
  `(when *plugin-pscp-debug*
	 (let ((*standard-output*
			(or *plugin-pscp-debug-buffer-stream*
				(setf *plugin-pscp-debug-buffer-stream*
					  (make-buffer-stream
					   (get-buffer-create
						*plugin-pscp-debug-buffer-name*))))))
	   ,@body)))

;; _pscp/�����̃p�X�̕���
(defun plugin-pscp-split-file-name (file)
  (cond ((string-match "\\(.*\\)/\\([^/]*\\)$" file)
		 (values (match-string 1)
				 (match-string 2)))
		(t
		 (values "" file))))

;; ------------------------------------------------------------------
;; pscp.exe
;; ------------------------------------------------------------------

;; pscp.exe�����݂��邩�H
(defun plugin-pscp-file-exist-p (file)
  (or (file-exist-p file)
	  (some (lambda (x)(file-exist-p (merge-pathnames file x)))
		(mapcar 'map-backslash-to-slash
				(split-string (si:getenv "PATH") ";")))))

;; �R�}���h�̎��s
;; from lisp/process.l
(defun plugin-pscp-execute-command1 (command &optional infile output environ directory)
	;; for debug
  (plugin-pscp-get-debug-stream
   (format t "command: ~S~%" command))
  
  (let ((outfile (make-temp-file-name)))
	(unless directory
	  (setq directory (default-directory)))
	(unless output
	  (setq output (plugin-pscp-get-buffer)))
	(unwind-protect
		(prog1
			(multiple-value-bind (cmdline dir)
				(ed::shell-command-line command directory)
			  (call-process cmdline
							:input infile
							:output outfile
							:exec-directory dir
							:environ environ
							:show *virtual-file-plugin-pscp-show-type*
							:wait t))
		  (when output
			(let (new)
			  (unless (bufferp output)
				(setq output (or (find-buffer output)
								 (progn
								   (setq new t)
								   (create-new-buffer output)))))
			  (erase-buffer output)
			  (update-visited-file-modtime)
			  (set-buffer output)
			  (insert-file-contents outfile)
			  (and new
				   (setq need-not-save t))
			  (set-buffer-modified-p nil)
			  (set-default-directory directory))))
	  (when outfile
		(delete-file outfile)))))

;; ���̃��b�p(?)
(defmacro plugin-pscp-execute-command (command-line pscp host options body)
  `(when ,host
	 (cond ((= 0 (plugin-pscp-execute-command1 ,command-line))
			,body)
		   ((not (plugin-pscp-file-exist-p ,pscp))
			(error "pscp.exe does not exist"))
		   (t
			(error (concat "virtual-file-pscp error: "
						   (buffer-substring (point-min) (point-max))))))))

;; ------------------------------------------------------------------
;; list
;; ------------------------------------------------------------------

;; �t�@�C���̎�ނ𔻒�
(defvar *plugin-pscp-file* nil)
(defvar *plugin-pscp-directory* 1)
(defvar *plugin-pscp-symlink* 2)

(defun plugin-pscp-file-type (perm)
  (cond ((char= (char perm 0) #\d)
		 *plugin-pscp-directory*)
		((char= (char perm 0) #\l)
		 *plugin-pscp-symlink*)
		(t
		 *plugin-pscp-file*)))

(defun plugin-pscp-list-internal (base subpath)
  (unless subpath
	(return-from plugin-pscp-list-internal))
  (let ((param (plugin-pscp-parse-config-file base))
		lst)
	(and (setf lst (apply 'plugin-pscp-list-fetch subpath param))      ; fetch
		 (setf lst (plugin-pscp-filter 'plugin-pscp-list-parse lst))))); parse

(defun plugin-pscp-list-fetch (file &key (pscp "pscp.exe") host (options ""))
  (plugin-pscp-execute-command
   (format nil "~a ~a -ls ~a:~a" pscp options (or host "") file)
   pscp host options
   (save-excursion
	 (set-buffer (plugin-pscp-get-buffer))
	 (goto-char (point-min))
	 (let (lst)
	   (while (not (eobp))
		 (push (buffer-substring (point) (progn (goto-eol) (point))) lst)
		 (forward-char))
	   (nreverse lst)))))

(defun plugin-pscp-list-parse (f)
  (when (string-match *plugin-pscp-file-line-regexp* f)
	(let ((file (if (string= "->" (match-string 3))
					(match-string 2)
				  (match-string 4)))
		  (type (plugin-ftp-file-type (match-string 1))))
	  (concat file
			  (if (eql *plugin-ftp-directory* type) "/")))))

(multiple-value-bind (fn dump)
	(virtual-file-memoize 'plugin-pscp-list-internal *plugin-scp-cache-interval*)
  (setf (symbol-function 'plugin-pscp-list-memoized) fn
		(symbol-function 'virtual-file-plugin-pscp-list-memoized-dump) dump))

(defun plugin-pscp-list (base file)
  (multiple-value-bind (subpath fname)
	  (plugin-pscp-split-file-name file)
	(setf lst (plugin-pscp-list-memoized base subpath))
	;; (���X�g�̗v�f��1�� and ���ꂪ�f�B���N�g��) �Ȃ� ����1��
	(when (and (car lst) (null (cdr lst))) ; (= (length lst) 1)
	  (let ((subdir (car lst)))
		(string-match (concat (regexp-quote fname) "/$") subdir)
		(setf lst (mapcar (lambda (x) (concat subdir x))
						  (plugin-pscp-list
						   base (concat file subdir))))))
	(values lst :list)))

;; ------------------------------------------------------------------
;; load
;; ------------------------------------------------------------------

(defun plugin-pscp-load-internal (base file tmp-dir)
  (multiple-value-bind (subpath fname)
	  (plugin-pscp-split-file-name file)
	(let ((tmp-file (merge-pathnames fname tmp-dir)))
	  (unwind-protect
		  (progn
			(find-file tmp-file)
			(set-default-directory
			 (directory-namestring
			  (remove-trail-slash base)))
			(rename-buffer fname)
			(set-buffer-file-name nil)
			(set-buffer-alternate-file-name
			 (merge-pathnames file base))
			(virtual-file-mode-on))
		(delete-file tmp-file :if-access-denied :force)
		(delete-directory tmp-dir :if-access-denied :force)))))

(defun plugin-pscp-load-fetch (base file tmp-dir &key (pscp "pscp.exe") host (options ""))
  (plugin-pscp-execute-command
   (format nil "~a ~a ~a:~a ~a" pscp options (or host "") file tmp-dir)
   pscp host options
   t))

(defun plugin-pscp-load (base file)
  (let ((param (plugin-pscp-parse-config-file base))
		(tmp-dir (make-temp-file-name "pscp_" "" nil t)))
	(and (prog1
			 (apply 'plugin-pscp-load-fetch base file tmp-dir param)
		   (plugin-pscp-load-internal base file tmp-dir))
		 (selected-buffer))))

;; ------------------------------------------------------------------
;; save
;; ------------------------------------------------------------------

(defun plugin-pscp-save-internal (base file nomsg append)
  (save-excursion
	(let ((tmp-file (make-temp-file-name)))
	  (unwind-protect
		  (progn
			(when append
			  ;; �I���W�i���t�@�C�����ɕۑ����Ƃ�
			  (save-excursion
				(plugin-pscp-load base file)
				(write-file tmp-file t)))
			(write-file tmp-file t append)
			(let ((param (plugin-pscp-parse-config-file base)))
			  (apply 'plugin-pscp-save-put base file tmp-file nomsg param)))
		(delete-file tmp-file))))
  (set-buffer-modified-p nil))

(defun plugin-pscp-save-put (base file tmp-file nomsg &key (pscp "pscp.exe") host (options ""))
  (plugin-pscp-execute-command
   (format nil "~a ~a ~a ~a:~a" pscp options tmp-file (or host "") file)
   pscp host options
   (progn
	 (unless nomsg
	   (message "Wrote ~a: ~a" host file))
	 t)))

;; char-encoding �� eol-code �͗ǂ��킩���ĂȂ��̂Ńp�X
(defun plugin-pscp-save (base file &optional nomsg append char-encoding eol-code)
  (plugin-pscp-save-internal base file nomsg append))

;; ------------------------------------------------------------------
;; regist
;; ------------------------------------------------------------------

(regist-virtual-file-handler
 "\\._pscp/$"
 'plugin-pscp-list
 'plugin-pscp-load
 'plugin-pscp-save)

;;; virtual-file-pscp.l ends here