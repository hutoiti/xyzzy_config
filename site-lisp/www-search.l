#|
version  2006.10.14
category Utilities

������
google �����Ȃǂ����郁�j���[�ƁA�V���Ȍ����R�}���h�����}�N���B

���蓮�C���X�g�[�����@
1. www-search.l �� www-search.lc �� ~/site-lisp �Ɉړ��B
2. ~/.xyzzy �� ~/site-lisp/siteinit.l �Ɏ��̈ꕶ��ǉ��B
   (require "www-search")
3. xyzzy ���ċN���B
   ~/site-lisp/siteinit.l �ɏ������̂Ȃ�
   Ctrl �� Shift �������Ȃ��� xyzzy ���N�����čă_���v�B

���A���C���X�g�[�����@
NetInstaller �� �C���X�g�[�������Ƃ��́A
NetInstaller ���� www-search ��I������ d �������B

�蓮�ŃC���X�g�[�������Ƃ��́A
1. ESC ESC �Ɠ��́B
2. (www-search-uninstall) �Ɠ��́B
3. .xyzzy �� siteinit.l �ɏ����� (require "www-search") ���폜�B
4. ~/site-lisp �� www-search.l �� www-search.lc ���폜�B
5. �K�v�������Ctrl �� Shift �������Ȃ��� xyzzy ���N�����čă_���v�B

���g����
��M-x ��L�[�o�C���h�ȂǂŎg�������

�\��(V) > �c�[���o�[(Q) > www-search(W) �̃c�[���o�[�ŌĂяo����
M-x �� google �Ƃ��A(global-set-key '(#\C-c #\g) 'google) �Ƃ��B

�Egoogle
  �I�𕶎��񂪑��݂��Ă����炻��������A
  �����łȂ���΃~�j�o�b�t�@�œ��͂��������������
  (google "�Ȃ�Ƃ�����Ƃ�")�Ƃ��Ă������ł���B
�Egoogle1
  �~�j�o�b�t�@�œ��͂����������google��������B
  (google1 "�Ȃ�Ƃ�����Ƃ�")�Ƃ��Ă������ł���B
�Egoogle-selection
  �I�𕶎��񂪑��݂����炻��� google ��������B
  �����łȂ���Ή������� nil ��Ԃ�
�Ewikipedia-jp
  ��L�� google �̂�� wikipedia ���{��ŗp�B
  wikipedia-jp1 ��� wikipedia-jp-selection �������邪�����͏ȗ��B
�Ekokugo ruigo eiwa waei
  �Ȃ񂩂����������T

�Ewww-search-popup
  �|�b�v�A�b�v���j���[��\������B

��Lisp �Ŏg������

�Ewww-search-define
  interactive �Ȍ����p�֐������B
  .xyzzy �� siteinit.l �� (require "www-search") �Ƃ��Ă����Ƃ��A
  (www-search-define "google"
		     "http://www.google.co.jp/search?lr=lang_ja&q="
		     "Google(&G)"
		     map-internal-to-utf-8)
  �̂悤�ɂ���ƁAgoogle google1 google-selection��
  �O�̊֐������݂̃p�b�P�[�W���ɏ���ɍ���� export �����B
  ����Ɋ֐��̏�� *www-search-data* �ɒǉ������B
  ���� *www-search-define-hook* ���B
  "Google(&G)" �Ƃ����̂̓��j���[�쐬�Ɏg����B
  �G���R�[�h�͖��w��Ȃ� euc�B
  �w�肷��Ƃ��� map-internal-to-utf-8 �Ȃǂ� ~/lisp/encoding.l ���̊֐����g���B

�Ewww-search-unregister
  (www-search-unregister 'google) �Ƃ���ƁA
  google �����j���[�ɕ\������Ȃ��悤�ɂ���B
  �ʂ̌������������ *www-search-data* ���珜�O����B

�E*www-search-hook*
  ���s���ꂽ�Ƃ��Ɏg���֐��Bfuncall �ŌĂяo�����̂� setq ���邱�ƁB
  ��F�u���E�U����Ȃ� www-mode �ŊJ���B
  (setq *www-search-hook* #'www-open-url)

���X�V����
2006.10.14 ������ύX�B
           www-search-unregister ��ǉ��B
2006.09.04 completing-read �� :history ���܂Ƃ��ɁB
2006.08.01 ���w�莞�̃G���R�[�h�� euc �ɕύX�B
           *www-search-hook* ��ǉ��B�u���E�U�ȊO�ŊJ����悤�ɂ����B
2006.04.21 ���j���[���܂��������̂��C���B*www-search-menu* ��p�~�B
2006.04.16 �֐����ϐ�����ύX�B
           �C���f���g���@�� xyzzy �W���̂��̂ɁB
           �J�e�S����ύX�B
2006.03.20 �A���C���X�g�[�����@��ύX�B
2006.03.15 ���J�B

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

(provide "www-search")
(in-package "editor")
(export '(www-search-default-hook
	  www-search-define
	  www-search-unregister
	  www-search-menu
	  www-search-popup
	  www-search-bar
	  www-search-uninstall
	  *www-search-hook*
	  *www-search-data*
	  *www-search-history*
	  *www-search-define-hook*))

(defvar *www-search-hook* nil
  "www-search: �J���Ƃ��̏����Bfuncall �ŌĂяo�����̂� setq ���邱��")
(defun www-search-default-hook (url)
  (shell-execute url t))
(unless *www-search-hook*
  (setq *www-search-hook* #'www-search-default-hook))

(defvar *www-search-data* nil)
(define-history-variable *www-search-history* '())

(setf (get :www-search 'minibuffer-history-variable) '*www-search-history*)

(defvar *www-search-define-hook* nil)

(defmacro www-search-define (fnname url caption &optional (e 'map-internal-to-euc))
  (let ((fn (intern fnname))
	(fn1 (intern (concat fnname "1")))
	(selection (intern (concat fnname "-selection")))
	(s (gensym)))
    `(progn
       (export '(,fn1
		 ,fn
		 ,selection))
       (defun ,fn1 (&optional (str (completing-read (concat ,(string-capitalize fnname)
							    ": ")
						    *www-search-history*
						    :history :www-search)))
	 (interactive)
	 (funcall *www-search-hook* (concat ,url
					    (si:www-url-encode (,e str)))))
       (defun ,selection ()
	 (interactive)
	 (if (pre-selection-p)
	     (selection-start-end (a b)
	       (,fn (buffer-substring a b)))
	   nil))
       (defun ,fn (&optional str)
	 (interactive)
	 (if str
	     (,fn1 str)
	   (unless (,selection)
	     (call-interactively ',fn1))))
       (let ((,s (find ',fn *www-search-data* :key #'car)))
	 ;���� fnname �Ɠ������̂� www-search-define ����Ă�������e��u��������B
	 (if ,s
	     (setf (cdddr ,s) '(,url ,caption ,e))
	   (setq *www-search-data*
		 (nconc *www-search-data*
			'((,fn ,fn1 ,selection ,url ,caption ,e)))))
	 (run-hook-with-args '*www-search-define-hook*
			     (null ,s) ',fn ',fn1 ',selection ',url ',caption ',e)
	 *www-search-data*)
       )))

(defun www-search-unregister (fn)
  "*www-search-data*��������ă��j���[�ŕ\�����Ȃ�����B"
  (setq *www-search-data*
	(delete fn
		*www-search-data*
		:key #'car)))

(defun www-search-menu ()
  (let ((menu (create-popup-menu :www-search)))
    (dolist (x *www-search-data*)
      (add-menu-item menu nil (fifth x) (car x)))
    menu))

(defun www-search-popup (&optional (any :button2))
  (interactive)
  (track-popup-menu (www-search-menu) any))

(defun www-search-bar ()
  (create-tool-bar 'www-search-bar
		   (merge-pathnames "toolbar.bmp" (etc-path))
		   '(("www-search" 41 www-search-popup))))
(define-command-bar 'www-search-bar "www-search(&W)")

(defun www-search-uninstall ()
  (delete-command-bar 'www-search-bar)
  (unregister-history-variable '*www-search-history*))

(www-search-define "google"
		   "http://www.google.co.jp/search?lr=lang_ja&q="
		   "Google(&G)"
		   map-internal-to-utf-8)
(www-search-define "wikipedia-jp"
		   "http://ja.wikipedia.org/wiki/%E7%89%B9%E5%88%A5:Search?search="
		   "Wikipedia-jp(&W)"
		   map-internal-to-utf-8)
(www-search-define "kokugo"
		   "http://dic.yahoo.co.jp/dsearch?stype=0&dtype=0&p="
		   "����(&K)")
(www-search-define "ruigo"
		   "http://dic.yahoo.co.jp/dsearch?stype=0&dtype=5&p="
		   "�ތ�(&R)")
(www-search-define "eiwa"
		   "http://dic.yahoo.co.jp/dsearch?stype=0&dtype=1&p="
		   "�p�a(&E)")
(www-search-define "waei"
		   "http://dic.yahoo.co.jp/dsearch?stype=0&dtype=3&p="
		   "�a�p(&J)")