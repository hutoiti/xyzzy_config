#|
version  2007.10.10
category Utilities

������
�Ȃ񂩂����t�@�C�����X�g�� readme.txt/hoge/c:/ �݂����ɕϊ�����
�~�j�o�b�t�@�ŕ⊮���Ȃ�����͂���悤�Ȋ����̂��́B

���Ȃ�
���Ƃ��Ƃ͎���̕⊮�|�b�v�A�b�v(�����J)�Ƒg�ݍ��킹�邽�߂ɍ�����񂾂�
xyzzy �W���̕⊮�ł��g���Ȃ��Ƃ��Ȃ��悤�Ȃ̂Ō��J���邱�Ƃɂ����B

���蓮�C���X�g�[�����@
1. fiofeo.l �� fiofeo.lc �� ~/site-lisp �Ɉړ��B
2. ~/.xyzzy �� ~/site-lisp/siteinit.l �Ɏ��̈ꕶ��ǉ��B
   (require "fiofeo")
3. xyzzy ���ċN���B
   ~/site-lisp/siteinit.l �ɏ������̂Ȃ�
   Ctrl �� Shift �������Ȃ��� xyzzy ���N�����čă_���v�B

���A���C���X�g�[�����@
NetInstaller �� �C���X�g�[�������Ƃ��́A
NetInstaller ���� fiofeo ��I������ d �������B

�蓮�ŃC���X�g�[�������Ƃ��́A
1. ESC ESC �Ɠ��́B
2. (fiofeo-uninstall) �Ɠ��́B
3. .xyzzy �� siteinit.l �ɏ����� (require "fiofeo") ���폜�B
4. ~/site-lisp �� fiofeo.l �� fiofeo.lc ���폜�B
5. �K�v�������Ctrl �� Shift �������Ȃ��� xyzzy ���N�����čă_���v�B

���g����
M-x���L�[�o�C���h�Ŏg����R�}���h�B
���낢�날�邪�֗��Ȃ̂� fiofeo-find-file-history ���������B

�������V���[�Y

���ʐݒ� -> ���낢�� -> �ۑ�����q�X�g���̌��͒Ⴍ�Ƃ� 500 �͗~�����B

�Efiofeo-find-file-history
  �ŋߎg�����t�@�C���� fiofeo �őI��ŊJ���B
�Efiofeo-session-file-history
  �ŋߎg�����Z�b�V������ fiofeo �őI��ŊJ���B
�Efiofeo-shell-execute-history
  *fiofeo-shell-execute-history* �� fiofeo �őI��Ŏ��s�B
  �ڂ����͉��L�� fiofeo-shell-execute �̂�������Q�ƁB

�g�������킩���Ƃ����l�� fiofeo-find-file-history ����������
tab �������΂��������Ӗ����킩��B

���f�B���N�g���̒��g�� fiofeo �őI��Ł�������V���[�Y

*fiofeo-�Ȃ�Ƃ�-test* �� non-nil ��Ԃ������̂��������ɂ���B
�ł��⊮�@�\�Ő��K�\�����g����ΑS�������ɂ�������Ă�
���ɂȂ��˗�ÂɂȂ�ƁB

�Efiofeo-find-file
  �f�B���N�g���̒��g�� fiofeo �őI��ŊJ���B
  *fiofeo-find-file-test* �� non-nil ��Ԃ������̂��������ɂ���B
  �W���ł́A���[�h�Ɋ֘A�t�����Ă���t�@�C�����������ɂ���B
  �\���������g���q�𑝂₷�Ȃ� .xyzzy �ȂǂŁ��̂悤�ɂȂ����B
  (pushnew '("\\.xxx" . (lambda ())) *auto-mode-alist* :test #'equalp)
�Efiofeo-shell-execute
  �f�B���N�g���̒��g�� fiofeo �őI��Ŏ��s�B
  *fiofeo-shell-execute-test* �� non-nil ��Ԃ������̂��������ɂ���B
  �W���ł́A���ׂĂ̂��̂����ɂ���B

����Ă݂͂������܂������������B
�_�C�A���O�ɂ���̂������񂾂낤���ǂȁB
dirbar.l �Ƒg�ݍ��킹��Ƃ܂��܂��g����B
�Ȃ�炩�̃f�B���N�g���I���V�X�e���Ƒg�ݍ��킹�悤�B

fiofeo-shell-execute-history ��
fiofeo-shell-execute �Ńq�X�g���ɒǉ����Ă�����s����`�ɂȂ�B
�q�X�g���ɒǉ�����ɂ� fiofeo-shell-execute1 ���g�����A
(add-history "�t�@�C����" '*fiofeo-shell-execute-history*) �ł��悵�B
�f���Ƀ����`���g���������y��ˁB

�����̂�
�Efiofeo-ra
  �e�헚�����瑶�݂��Ȃ��t�@�C���������B

���ق�
�E�C���X�g�[������ƁAfind-file �����t�@�C���͂��ׂ�
  *minibuffer-file-name-history* �ɓ���悤�ɂ���B
�E\n ����؂�Ɣ��f���ĕ����̃t�@�C���Ƃ��Ĉ����@�\����������Ƃ��B
�E�⊮�@�\�ɂ́A���̋@�\������ƕ֗��ł���C������B
  a.�c����̂��ׂĂŐ擪��v���Ă��镶�������͂���R�}���h
  b.���̈ꕶ�����c����̑������Ō��߂ē��͂���@�\
  c.a����������b������a������R�}���h
�E�~�j�o�b�t�@�ɓ������u�Ԃɕ⊮���X�g��\������ƕ֗������B
  ����� *fiofeo-hook* �œn���ꂽ���X�g���g���悤�ɂ���Ƃ悢�B
  ������ *enter-minibuffer-hook* �� start-timer ��
  *fiofeo-hook* ��g�ݍ��킹���⊮�@�\���g���Ă���B

��todo
���t�@�C������֘A�̃R�}���h�B���l�[���Ƃ��ړ��Ƃ��B
�������`����fenrir�̋@�\���p�N�肽�����A
  ����̕⊮���ƃt�@�C�������c��ɂȂ�ƒx������B�ǂ��������񂾂��B

���X�V����
2007.10.10 �ׂ����Ƃ�
2007.01.24 *before-find-file-hook* �ɒǉ�����֐����C���B
2006.10.20 ���J�B

�����C�Z���X
Copyright (c) 2006, sazasaza.  All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in
   the documentation and/or other materials provided with the
   distribution.

3. Neither the name of the University nor the names of its
   contributors may be used to endorse or promote products derived
   from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
|#

(in-package "editor")
(provide "fiofeo")

(export '(fiofeo-encode
	  fiofeo-decode
	  fiofeo-encode-list
	  fiofeo-decode-list
	  fiofeo-split
	  fiofeo-read
	  fiofeo
	  fiofeo-directory-1
	  fiofeo-directory
	  fiofeo-define-dc
	  fiofeo-ff
	  fiofeo-mode-alist-regexp
	  fiofeo-find-file-test
	  fiofeo-do-shell-execute
	  fiofeo-shell-execute-test
	  fiofeo-find-file-history
	  fiofeo-session-file-history
	  fiofeo-shell-execute-history
	  fiofeo-ra
	  fiofeo-uninstall
	  *fiofeo-slash*
	  *fiofeo-separator*
	  *fiofeo-directory-count*
	  *fiofeo-auto-ra*
	  *fiofeo-ra-list*
	  *fiofeo-hook*
	  *fiofeo-history*
	  *fiofeo-find-file-test*
	  *fiofeo-shell-execute-test*
	  *fiofeo-shell-execute-history*))

;�ݒ�

(defvar *fiofeo-slash* "/"
  "\\ �� /")
(defvar *fiofeo-separator* "\n"
  "�����p�X�̋�؂蕶���B")

(defvar *fiofeo-directory-count* nil
  "directory �ŕ\������t�@�C�����̏��")

(defvar *fiofeo-auto-ra* t
  "fiofeo-rename-file �Ȃǂ̂Ƃ������ fiofeo-ra ���邩")

(defvar *fiofeo-ra-list* '((*fiofeo-shell-execute-history*
			    *minibuffer-file-name-history*
			    *session-file-history*)
			   (*fiofeo-history*))
  "fiofeo-ra �ő|�����闚���̃V���{�������Bsecond��fiofeo��ԂɂȂ��Ă����")

(defvar *fiofeo-hook* nil)

(define-history-variable *fiofeo-history* nil)
(setf (get '*fiofeo-history* 'history-ignore-case) t)
(setf (get :fiofeo 'minibuffer-history-variable) '*fiofeo-history*)

(defvar *fiofeo-find-file-test* 'fiofeo-find-file-test)
(defvar *fiofeo-shell-execute-test* 'fiofeo-shell-execute-test)

;

(defun fiofeo-encode (filename)
  "c:/hoge/readme.txt -> readme.txt/hoge/c:/"
  (apply #'concat
	 (nreverse (cons (if (pathname-device filename)
			     nil
			   *fiofeo-slash*)
			 (mapcar (lambda (x)
				   (concat x *fiofeo-slash*))
				 (split-string (map-backslash-to-slash filename) #\/))))))

(defun fiofeo-decode (fiofeo)
  "readme.txt/hoge/c:/ -> c:/hoge/readme.txt"
  (setq fiofeo (map-backslash-to-slash fiofeo))
  (subseq (apply #'concat
		 (and (char= #\/ (char fiofeo (- (length fiofeo) 2)))
		      (char= #\/ (char fiofeo (- (length fiofeo) 1)))
		      (concat *fiofeo-slash* *fiofeo-slash*))
		 (nreverse (mapcar (lambda (x)
				     (concat *fiofeo-slash* x))
				   (split-string fiofeo #\/))))
	  1))

(defun fiofeo-encode-list (filename-list)
  "(mapcar #'fiofeo-encode filename-list)"
  (mapcar #'fiofeo-encode filename-list))

(defun fiofeo-decode-list (fiofeo-list)
  "(mapcar #'fiofeo-decode fiofeo-list)"
  (mapcar #'fiofeo-decode fiofeo-list))

(defun fiofeo-split (fiofeo)
  (split-string fiofeo *fiofeo-separator*))

(defun fiofeo-read (fiofeo-list &key prompt must-match (history :fiofeo) callback)
  "���ʂ̓��X�g�ŕԂ��Bcallback �ɂ����X�g�œn���B"
  (unless prompt
    (setq prompt "fiofeo: "))
  (run-hook-with-args '*fiofeo-hook*
		      fiofeo-list
		      :prompt prompt
		      :must-match must-match
		      :history history
		      :callback callback)
  (let* ((string (completing-read prompt
				  fiofeo-list
				  :case-fold t
				  :must-match must-match
				  :history history))
	 (list (fiofeo-split string))
	 (result (fiofeo-decode-list list))
	 (history-variable (if history
			       (get history 'minibuffer-history-variable))))
    (when history-variable
      (set history-variable (delete string (symbol-value history-variable) :test #'equalp))
      (mapc #'(lambda (item) (add-history item history-variable))
	    list))
    (if callback
	(funcall callback result)
      result)
    ))

(defun fiofeo (filelist &rest prompt+must-match+history+callback)
  "���ʂ̓��X�g�ŕԂ��Bcallback �ɂ����X�g�œn���B"
  (apply #'fiofeo-read
	 (fiofeo-encode-list filelist)
	 prompt+must-match+history+callback))

;

(defun fiofeo-directory-1 (pathname &rest rest)
  "(directory pathname :absolute t :count *fiofeo-directory-count* ,@rest)"
  (apply #'directory pathname :absolute t :count *fiofeo-directory-count* rest))

(defun fiofeo-directory (&key directory depth test wild sort-predicate sort-key (file-only t))
  "sort �֘A�͕W���̕⊮�ł͈Ӗ������������Btest �̓��X�g���Ɠn���܂��B"
  (let ((f (fiofeo-encode-list (funcall (or test
					    #'identity)
					(fiofeo-directory-1 (or directory
								(read-directory-name "directory: "))
							    :recursive t :file-only file-only
							    :depth (or depth
								       (read-integer "�[��: "))
							    :wild wild)))))
    (if sort-predicate
	(sort f sort-predicate :key sort-key)
      f)))

(defmacro fiofeo-define-dc (name &key
				 (doc "")
				 prompt
				 history
				 callback
				 default-directory
				 default-depth
				 default-test
				 default-wild
				 default-sort-predicate
				 default-sort-key
				 (file-only t))
  "sort �֘A�͕W���̕⊮�ł͈Ӗ������������Btest �̓��X�g���Ɠn���܂��B"
  `(export (defun ,name (&key (directory ,default-directory)
			      (depth ,default-depth)
			      (test ,default-test)
			      (wild ,default-wild)
			      (sort-predicate ,default-sort-predicate)
			      (sort-key ,default-sort-key))
	     ,doc
	     (interactive)
	     (fiofeo-read (fiofeo-directory :directory directory
					    :depth depth
					    :wild wild
					    :file-only ,file-only
					    :test test
					    :sort-predicate sort-predicate
					    :sort-key sort-key)
			  :prompt ,prompt
			  :history ,history
			  :callback ,callback))))

(defun fiofeo-ff (function)
  "mapc����֐���Ԃ�"
  #'(lambda (l) (mapc function l)))

;

(defun fiofeo-mode-alist-regexp (&optional (ama *auto-mode-alist*))
  (if (null ama)
      ""
    (compile-regexp (let ((ama (reverse ama)))
		      (if (cdr ama)
			  (format nil "~{\\(~A\\)\\|~}\\(~A\\) " (mapcar #'car (cdr ama)) (caar ama))
			(if (car ama)
			    (caar ama))))
		    )))

(defun fiofeo-find-file-test (filelist)
  (let ((regexp (fiofeo-mode-alist-regexp)))
    (delete-if-not #'(lambda (filename)
		       (string-matchp regexp filename))
		   filelist)))

(fiofeo-define-dc fiofeo-find-file
		  :doc "�f�B���N�g���̒��g�� fiofeo �őI��ŊJ��"
		  :prompt "Find file: "
		  :callback (fiofeo-ff #'find-file)
		  :default-test *fiofeo-find-file-test*)

(define-history-variable *fiofeo-shell-execute-history* nil
			 "fiofeo �ōŋߎ��s�����t�@�C��")

(defun fiofeo-do-shell-execute (filename)
  "add-history + shell-execute"
  (interactive "fShell execute: ")
  (when (file-exist-p filename)
    (add-history filename '*fiofeo-shell-execute-history*)
    (shell-execute filename)))

(defun fiofeo-shell-execute-test (filelist)
  filelist)

(fiofeo-define-dc fiofeo-shell-execute
		  :doc "�f�B���N�g���̒��g�� fiofeo �őI��Ŏ��s"
		  :prompt "Shell execute: "
		  :callback (fiofeo-ff #'fiofeo-do-shell-execute)
		  :default-test *fiofeo-shell-execute-test*)

;

(defun fiofeo-find-file-history ()
  "�ŋߎg�����t�@�C���� fiofeo �őI��ŊJ��"
  (interactive)
  (fiofeo *minibuffer-file-name-history*
	  :prompt "Find file history: "
	  :callback (fiofeo-ff #'find-file)))

(defun fiofeo-session-file-history ()
  "�ŋߎg�����Z�b�V������ fiofeo �őI��ŊJ��"
  (interactive)
  (fiofeo *session-file-history*
	  :prompt "Session file history: "
	  :callback #'(lambda (l) (load-session (car l)))))

(defun fiofeo-shell-execute-history ()
  "*fiofeo-shell-execute-history* �� fiofeo �őI��Ŏ��s"
  (interactive)
  (fiofeo *fiofeo-shell-execute-history*
	  :prompt "Shell execute history: "
	  :callback (fiofeo-ff #'fiofeo-do-shell-execute)))

;

(defun fiofeo-ra (&optional h)
  "�������瑶�݂��Ȃ��t�@�C��������"
  (interactive)
  (let ((test (if h
		  #'(lambda (file)
		      (if file
			  (file-exist-p file)))
		#'(lambda (file)
		    (if file
			(or (pathname-host file)
			    (file-exist-p file)))))))
    (labels ((del (symbol &key (key #'identity))
	       (set symbol (remove-if-not test
					  (symbol-value symbol)
					  :key key))
	       ))
      (mapc #'del
	    (car *fiofeo-ra-list*))
      (mapc #'(lambda (list)
		(del list
		     :key #'(lambda (file)
			      (ignore-errors (fiofeo-decode file)))))
	    (second *fiofeo-ra-list*))
      t
      )))

;find-file �����̂͂��ׂė����ɓ����B�������A�O��̋N��������J���Ă��͓̂���Ȃ��B
(add-hook '*post-startup-hook*
	  #'(lambda ()
	      (add-hook '*before-find-file-hook*
			#'(lambda (x)
			    (if (file-exist-p x)
				(if (not (file-directory-p x))
				    (add-history (map-backslash-to-slash (truename x))
						 '*minibuffer-file-name-history*)))
			    nil))))

(defun fiofeo-uninstall ()
  (mapc #'unregister-history-variable
	'(*fiofeo-history*
	  *fiofeo-shell-execute-history*)))