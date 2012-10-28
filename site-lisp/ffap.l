;;; -*- mode: lisp -*-
;;; name:     ffap
;;; version:  2007.10.19
;;; author:   shiro
;;; category: Utilities
;;; src:      http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fffap&openfile=
;;; changes:  virtual-file����find-file�����ꍇ�̏����f�B���N�g�����܂Ƃ��ɂ���
;;; files:    site-lisp/ffap.l
;;;           site-lisp/ffap.lc
;;;           site-lisp/ni-autoload/silog/ffap.l

;; Copyright (C) 2001-2005 OHKUBO Hiroshi.
;; Copyright (C) 2006-2007 snj14
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

;;; Commentary:

;; �T�v:
;;
;;   emacs�ɂ���ffap�̐���(http://www.bookshelf.jp/soft/meadow_23.html#SEC226)
;;   ���݂đz���Ŏ����������̂ł��B
;;   �R�[�h�͎Q�l�ɂ��Ă��Ȃ��̂Ńo�O��@�\�s�������邩������܂���B
;;
;;   �J�[�\���ʒu���ӂ̕��������ăp�X��URI��T���A
;;   �p�X�̏ꍇ�A�f�t�H���g�̒l�Ɏw�肵����Ԃ�find-file���܂��B
;;   URI�̏ꍇ�A�u���E�U���ŊJ���܂��B(�ݒ��)
;;   �J�[�\���ʒu���ӂ���T���Ȃ������ꍇ�́A
;;   �ȑO�ƕς���find-file�����y���ݒ����܂��B
;;
;;   �v����� (require "ffap") �� <a href="../index.html">
;;   ���̏��C-x C-f�����Ƃ��Ƀ~�j�o�b�t�@��
;;   Find file: c:/bin/xyzzy/site-lisp/ffap.l
;;   ��
;;   Find file: c:/data/web/index.html
;;   �Ƃ�����Ԃ�find-file���J�n�ł���悤�ɂȂ�܂��B
;;
;;   �J�[�\�����ӂ̃t�@�C�����̐e�f�B���N�g�����A�N�e�B�u�ȑ��A
;;   �܂��̓A�N�e�B�u�łȂ����̃p�X�ɂ���2��ʃt�@�C�����J���@�\������܂��B

;; �ݒ�:
;;
;; NetInstaller�œ����������� 1 �͕s�v�ł�
;; (ni-autoload)���Ă������ 2 ��1�s�ڂ͕s�v�ł�
;;
;;   1 $XYZZY/site-lisp/ �ȉ��ɃR�s�[���A
;;     �o�C�g�R���p�C�����Ă�������
;;   2 .xyzzy �� siteinit.l �Ɉȉ����L�q���A
;;     siteinit.l�ɋL�q�������͍ă_���v���Ă��������B
;;
;;   (require "ffap")
;;   (ffap-bindings)

;; �g����:
;;
;; find-file-at-point :
;;
;;   �ʏ�ʂ�find-file(�f�t�H���g��C-x C-f)���Ă�������
;;   �ȑO��find-file���l�AC-u C-x C-f�ŃG���R�[�h���w��o���܂�
;;   ffap���p�X��T�����A���������̓Z���N�V�����őI������C-x C-f���Ă�������
;;   URI�����������ꍇ�͊֘A�t���ɏ]���ĊJ�����Ƃ��܂�
;;
;; open-filer-at-point :
;;
;;   �ʏ�ʂ�open-filer(�f�t�H���g��C-c C-f)���Ă�������
;;   �A�N�e�B�u�ȑ��̃p�X��ύX���ăt�@�C�����J��
;;      C-u C-c C-f
;;   �A�N�e�B�u�łȂ����̃p�X��ύX���ăt�@�C���J��
;;      C-u C-u C-c C-f

;; ����:
;; 
;; 2007.10.19
;; - virtual-file����find-file�����ꍇ�̏����f�B���N�g�����܂Ƃ��ɂ���
;; 
;; 2007.02.22
;; - �L�����b�g�t�߂ɋ󔒂�����Ƃ���open-filer-at-point����ƃG���[���o���̂��C��
;; 
;; 2007.02.19
;; - uri�̃q�X�g�������悤�ɂ���
;; 
;; 2007.02.13
;; - find-other-file-at-point, insert-file-at-point, read-file-at-point��ǉ�
;; - �S�ẴL�[���蓖�Ă�����֐� ffap-bindings ��ǉ�
;; 
;; 2007.02.08
;; - open-filer-at-point�Ńo�b�t�@��̕������p�X�łȂ��ꍇ��default-directory���g���悤�ɂ���
;; 
;; 2006.10.08
;; - �o�b�t�@��̕������l�����ăt�@�C�����J���@�\��ǉ�
;;
;; 2006.10.05
;; - 1��ʃt�@�C�����J�������ɕ����̃t�@�C�����I�ׂȂ��Ȃ��Ă����̂��C��
;;
;; 2006.05.10
;; - ����

;; �ӎ�:
;;
;;   �쐬�ɂ�����Aclickable-uri���Q�l�ɂ����Ă��������܂����B
;;   ��҂�OHKUBO Hiroshi����Ɋ��ӂ������܂��B

;;; Code:

(provide "ffap")

(in-package "editor")

(export '(*ffap-uri-open-command-alist*
		  *ffap-uri-chars*
		  *ffap-extension-alist*
		  *ffap-path-alist*
		  *ffap-uri-modify-uri-alist*
		  *ffap-default-extension*
		  find-file-at-point
		  open-filer-at-point
		  find-other-file-at-point
		  insert-file-at-point
		  read-file-at-point
		  ffap-bindings))

;;; URI���J���ݒ�
;;; �ݒ薳��       : �֘A�t�����s
;;; ������         : �R�}���h���C���Ƃ݂Ȃ��Ď��s����
;;;                : URI���L�q����ׂ��ꏊ��~A�ƋL�q
;;; lambda��       : lambda����URI�������Ƃ��ēn���ĕ]������
;;; �֐��̃V���{�� : �֐�    ��      �V
;;;
;;; ��
;;; (push '("^https?:" . "C:/bin/FireFox/FireFox.exe ~A")
;;;       *ffap-uri-open-command-alist*)
(defvar *ffap-uri-open-command-alist*
  '((#'(lambda (uri) (string-matchp "^file:.+\\.l$" uri)) .
	 #'find-file)
	))

;;; URI���K�\�� (�Ă��Ɓ[)
(defvar *ffap-uri-regexp*
  "\\(h?t?tps?\\|ftp\\|telnet\\|gopher\\|www\\|wais\\|file\\|mailto\\):[-a-zA-Z0-9_/~.@?&=;+(),'$!*:#%|]+")

;;; ���[���A�h���X���K�\��
(defvar *ffap-uri-mail-address-regexp*
  "[-a-zA-Z0-9_.]+@[-a-zA-Z0-9_]+\\(?:\\.[-a-zA-Z0-9_]+\\)+")

;;; URI�\��������
;;; skip-chars-forward,skip-chars-backward�Ŏg�p
(defvar *ffap-uri-chars* "-a-zA-Z0-9_/\\~.@?&=;+(),'$!*:#%| ")

;;; URI�␳�֐� �A�z���X�g
(defvar *ffap-uri-modify-uri-alist*
  '((#'ffap-uri-uri-mail-address-p  . #'(lambda (uri) (concat "mailto:" uri)))
	("^ttp:" . #'(lambda (uri) (concat "h"  uri)))
	("^tp:"  . #'(lambda (uri) (concat "ht" uri)))
	("^file://"  . #'(lambda (uri) (substring uri 7)))
	))

;;; ���[�h�Ɗg���q�̐ݒ�
;;; (require "hoge") ���A�g���q�̖��������񂩂�t�@�C����T���ꍇ�̊g���q�𐳋K�\���Ń��[�h���Ɏw�肵�܂��B
;;; �ʏ�� *auto-mode-alist* ����g���q���擾���܂����A
;;; *auto-mode-alist*�ɐݒ肳��Ă��Ȃ����[�h�͂���ɒǉ����Ă��������B
;;; *auto-mode-alist*�ɂ������ɂ��ݒ肳��Ă��Ȃ����[�h�̏ꍇ�͊��ϐ�PATHEXT����g���q���擾���܂��B
(defvar *ffap-extension-alist*
  '((lisp-interaction-mode . "\\.l$")))

;;; ���[�h�ƃp�X�̐ݒ�
;;; ��������p�X�����[�h���ɕύX����ꍇ�͂����Ŏw�肵�܂��B
;;; �����͈ȉ���4�Ŏw�肳�ꂽ�p�X��S�Ďg���čs���܂��B
;;;  1 ���[�h���ɐݒ肳�ꂽ�p�X
;;;  2 �f�t�H���g�̃p�X*ffap-default-path*
;;;  3 �o�b�t�@����Ƃ��Ă���f�B���N�g�� = (default-directory)�̕Ԃ��l
;;;  4 �J���Ă���t�@�C���̐e�f�B���N�g��(�o�b�t�@���t�@�C���̏ꍇ)
;;; �Ȃ��A������/��\\�̗L���͖₢�܂���B
;;;
;;; ��
;;; ;py-mode�ł̌����p�X��clnchex,script,extension��ǉ�����
;;; (push '(py-mode "c:/bin/clnchex/" "c:/bin/clnchex/script" "c:/bin/clnchex/extension")
;;;       *ffap-path-alist*)
(defvar *ffap-path-alist*
  (list (append (list 'lisp-mode) *load-path*)
		(append (list 'lisp-interaction-mode) *load-path*)))

;; �f�t�H���g�̊g���q
;; >> "\\.\\(COM\\|EXE\\|BAT\\|CMD\\|VBS\\|VBE\\|JS\\|JSE\\|WSF\\|WSH\\)$"
(defvar *ffap-default-extension*
  (concat "\\.\\("
		  (substitute-string (substitute-string
							  (si:getenv "PATHEXT")
							  "\\." "")
							 ";" "\\\\|")
		  "\\)$"))

;; �f�t�H���g�̃p�X
(defvar *ffap-default-path*
  (append ;xyzzy�̃C���X�g�[���f�B���N�g��
   (list (si:system-root))
   ;���ϐ� PATH
   (mapcar 'map-backslash-to-slash
		   (split-string (si:getenv "PATH") ";"))
   ;Windows (�����Ă邩���M�Ȃ�)
   (mapcar 'map-backslash-to-slash
		   (split-string (si:getenv "WINDIR") ";"))
   ;Home
   (mapcar 'map-backslash-to-slash
		   (split-string (si:getenv "HOME") ";"))
   ;XyzzyHome
   (mapcar 'map-backslash-to-slash
		   (split-string (si:getenv "XYZZYHOME") ";"))))

;; history
(defvar *ffap-uri-history* nil)
(setf (get '*ffap-uri-history* 'minibuffer-history-variable)
      '*ffap-uri-history*)
(register-history-variable '(*ffap-uri-history*))

(defun ffap-uri-uri-mail-address-p (uri)
  (and (stringp *ffap-uri-mail-address-regexp*)
	   (string-matchp (concat "^" *ffap-uri-mail-address-regexp* "$") uri)))

(defun ffap-get-extension-from-auto-mode-alist (mode)
  "*auto-mode-alist*�ƃ��[�h������g���q���擾"
  (let ((list (apply 'append
					 (mapcar #'(lambda (x)
								 (when (eq (cdr x) mode)
								   (list (car x))))
							 *auto-mode-alist*))))
	(when list
	  (format nil "\\(~A)" (string-right-trim "|" (format nil "~{~A\\|~}" list))))))

(defun ffap-get-path-and-extension (&optional buffer)
  "buffer�̃��[�h�����猟������p�X�Ɗg���q�𓾂�"
  (let ((mode buffer-mode))
	(when buffer
	  (save-excursion
		(set-buffer buffer)
		(setf mode buffer-mode)))
	(values (remove-duplicates
			 (append (cdr (assoc mode *ffap-path-alist*))
					 (list (default-directory)) ;��ƃf�B���N�g��
					 (let ((cur (get-buffer-file-name))) ;�J���Ă�t�@�C���̐e�f�B���N�g��
					   (when cur (list (map-backslash-to-slash
										(directory-namestring cur)))))
					 *ffap-default-path*)
			 :test 'equalp)
			(or (cdr (assoc mode *ffap-extension-alist*))
				(ffap-get-extension-from-auto-mode-alist mode)
				*ffap-default-extension*))))

;; (ffap-locate "grep.l")
;; >> ("C:/bin/xyzzy/lisp/grep.l")
;; (ffap-locate "grep.exe")
;; >> ("c:/cygwin/bin/grep.exe")
(defun ffap-locate (file)
  "�t�@�C��������t���p�X��T��"
  (when (string= file "")
	(return-from ffap-locate))
  (let (path-list extension res)
	(multiple-value-setq (path-list extension)
	  (ffap-get-path-and-extension))
	(setf res
		  (some #'(lambda (path)
					(when (file-exist-p path) path))
				(mapcar #'(lambda (dir)
							(merge-pathnames file dir))
						path-list)))
	(and res (not (file-directory-p res))
		 res)))

;; (ffap-locate-approx "lisp/grep")
;; >> "C:/bin/xyzzy/lisp/grep.l"
(defun ffap-locate-approx (file)
  "�t�@�C����(�g���q�Ȃ�)����t���p�X��T��"
  (when (string= file "")
	(return-from ffap-locate-approx))
  (let (path-list extension res)
	(multiple-value-setq (path-list extension)
	  (ffap-get-path-and-extension))
	(setf res
		  (some #'(lambda (path)
					(when (string-matchp
						   (concat "[\\/]" (regexp-quote file) extension)
						   path)
					  path))
				(apply 'append
					   (mapcar #'(lambda (dir)
								   (directory (directory-namestring
											   (merge-pathnames file dir))
											  :absolute t))
							   path-list))))
	(and res (not (file-directory-p res))
		 res)))

(defun ffap-get-uri (str)
  (and (string-matchp *ffap-uri-regexp* str)
	   (match-string 0)))

(defun ffap-get-mail-address (str)
  (and (string-matchp *ffap-uri-mail-address-regexp* str)
	   (match-string 0)))

(defun ffap-get-region ()
  "���[�W��������s�Ȃ當�����Ԃ�"
  (let ((ptline (current-line-number))
		mkline)
	(save-excursion
	  (and (mark t)
		   (goto-char (mark))
		   (setf mkline (current-line-number))))
	(when (eq ptline mkline)
	  (buffer-substring (point) (mark)))))

(defun ffap-get-current-string-regexp ()
  (let ((pt (point)) string
		(region (ffap-get-region)))
	(save-excursion
	  (and (stringp region)
		   (> (mark) pt)
		   (goto-char (mark)))
	  (and (scan-buffer *ffap-uri-regexp* :regexp t :reverse t
						:limit (or (and region (> (mark) pt) pt)
								   (and region (< (mark) pt) (mark))
								   (save-excursion (goto-bol) (point))))
		   (< (match-beginning 0) pt)
		   (<= pt (match-end 0))
		   (setf string (match-string 0);(buffer-substring (match-beginning 0) pt)
				 )
		   (string-match *ffap-uri-regexp* string)
		   string))))

(defun ffap-get-current-string-uri-chars ()
  "*ffap-uri-chars*�����ĕ������擾"
  (save-excursion
	(unless (pre-selection-p)
	  (skip-chars-forward *ffap-uri-chars*)
	  (ed::begin-selection)
	  (skip-chars-backward *ffap-uri-chars*))
	(selection-start-end (start end)
	  (buffer-substring start end))))

(defun ffap-get-current-string-syntax ()
  "�V���^�b�N�X�e�[�u�������ĕ������擾"
  (save-excursion
	(unless (pre-selection-p)
	  (skip-syntax-spec-forward "w_.\\")
	  (ed::begin-selection)
	  (skip-syntax-spec-backward "w_.\\"))
	(selection-start-end (start end)
	  (buffer-substring start end))))

(defun ffap-correct-uri (uri)
  (when uri
	(let ((modify-func
		   (eval (cdr (assoc uri *ffap-uri-modify-uri-alist*
							 :test #'(lambda (uri checker)
									   (setf checker (eval checker))
									   (or (and (or (regexpp checker) (stringp checker))
												(string-matchp checker uri))
										   (and (functionp checker) (funcall checker uri)))))))))
	  (if modify-func
		  (funcall modify-func uri)
		uri))))

(defvar *ffap-find-uri* t)

(defun ffap-get-path ()
  (let ((str (substitute-string
			  (ffap-get-current-string-syntax)
			  "\\\\\\\\" "\\\\")); �p�X�̋�؂肪\\�̎��ɂ��̒l��"\\\\"�ƂȂ�΍�
		(str1 (substitute-string
			   (ffap-get-current-string-uri-chars)
			   "\\\\\\\\" "\\\\")))
	(ffap-correct-uri
	 (or (and (not (string= str "")) (file-exist-p str) str)
		 (and (not (string= str1 "")) (file-exist-p str1) str1)
		 (ffap-locate str)
		 (ffap-locate-approx str)
		 (when *ffap-find-uri*
		   (ffap-get-uri str))
		 (ffap-get-mail-address str)
		 
		 (ffap-locate str1)
		 (ffap-locate-approx str1)
		 (when *ffap-find-uri*
		   (ffap-get-uri str1))
		 (ffap-get-mail-address str1)))))

(defun ffap-open-uri (uri)
  (when (and uri
			 (string-matchp *ffap-uri-regexp* uri)
			 (setf uri (read-string "URI: " :default (match-string 0)
									:history '*ffap-uri-history*))
			 (not (string= uri "")))
	(let ((cmd (cdr (assoc uri *ffap-uri-open-command-alist*
						   :test #'(lambda (uri checker)
									 (setf checker (eval checker))
									 (or (and (or (regexpp checker) (stringp checker))
											  (string-matchp checker uri))
										 (and (functionp checker) (funcall checker uri))))))))
	  (cond ((consp cmd)
			 (funcall (eval cmd) uri))
			((functionp cmd)
			 (funcall (symbol-function cmd) uri))
			((stringp cmd)
			 (call-process
			  (format nil (map-slash-to-backslash cmd) uri)
			  :wait nil))
			(t (shell-execute uri t))
			))))

(defun ffap-get-truename (path)
  (when path
	(let ((file (string-match "^file://" path)))
	  (setf path (truename path))
	  (and (file-directory-p path)
		   (not (string-match "/$" path))
		   (setf path (concat path "/")))
	  (if file
		  (concat "file://" path)
		path))))


;; virtual file ?
(defun ffap-check-virtual-file ()
  (when (find-package "complete+")
	(eval (intern "*virtual-file-mode*" "complete+"))))
;; virtual-file-archive (C:/archive/hoge.zip:moge -> C:/archive/hoge.zip/moge )
(defun ffap-virtual-file-archive-convert (file)
  (if (= 2 (count #\: file))
	  (substitute #\/ #\: file :from-end t :count 1)
	file))

(defun find-file-at-point ()
  (interactive)
  (let ((path (ffap-get-path)))
	(or (ffap-open-uri path)
		(find-file (read-file-name-list "Find-file: "
										:default (if (ffap-check-virtual-file)
													 (directory-namestring
													  (ffap-virtual-file-archive-convert
													   (get-buffer-alternate-file-name)))
												   (ffap-get-truename path)))
				   (when *prefix-args*
					 (read-char-encoding "Encoding: "))))))

(defun find-other-file-at-point (filename &optional encoding nomsg)
  (interactive "FFind other file: \n0zEncoding: "
	:title0 "Find other file"
	:default0 (or (let ((*ffap-find-uri* nil))
					(ffap-get-path))
				  (cond ((ffap-check-virtual-file)
						 (let ((p (get-buffer-alternate-file-name)))
						   (if *find-other-file-requires-file-name*
							   (ffap-virtual-file-archive-convert p)
							 (directory-namestring p))))
						(*find-other-file-requires-file-name*
						 (get-buffer-file-name)))))
  (find-other-file filename encoding nomsg))

(defun insert-file-at-point (filename &optional encoding)
  (interactive "*fInsert file: \n0zEncoding: "
	:title0 "Insert file"
	:default0 (let ((*ffap-find-uri* nil))
				(ffap-get-path)))
  (insert-file filename encoding))

(defun read-file-at-point (filename &optional encoding nomsg)
  (interactive "fRead file: \n0zEncoding: "
	:title0 "Read file"
	:default0 (let ((*ffap-find-uri* nil))
				(ffap-get-path)))
  (read-file filename encoding nomsg))

(defun open-filer-at-point-current-window (path)
  (let ((*filer-primary-directory* path))
	(open-filer)))

(defun open-filer-at-point-other-window (path)
  (let ((*filer-secondary-directory* path))
	(open-filer)))

(defun open-filer-at-point ()
  (interactive)
  (cond (*prefix-args*
		 (let ((path (ffap-get-path))
			   (dir (default-directory)))
		   (cond ((and path
					   (not (string= path ""))
					   (not (string-match "^ *$" path))
					   (valid-path-p path))
				  (when (and (not (file-directory-p path)))
					(setf path (directory-namestring path)))
				  (cond ((> *prefix-value* 4)
						 (open-filer-at-point-other-window path))
						(t
						 (open-filer-at-point-current-window path))))
				 (t
				  (cond ((> *prefix-value* 4)
						 (open-filer-at-point-other-window dir))
						(t
						 (open-filer-at-point-current-window dir)))))))
		(t
		 (open-filer))))

(defun ffap-bindings ()
  "[C-x C-f], [C-c C-f], [C-x C-v], [C-x i], [C-x C-r]��ffap�p�̊֐������蓖�Ă܂�"
  (global-set-key '(#\C-x #\C-f) 'find-file-at-point)
  (global-set-key '(#\C-c #\C-f) 'open-filer-at-point)
  (global-set-key '(#\C-x #\C-v) 'find-other-file-at-point)
  (global-set-key '(#\C-x #\i)   'insert-file-at-point)
  (global-set-key '(#\C-x #\C-r) 'read-file-at-point))

;;; ffap.l ends here