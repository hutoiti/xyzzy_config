#|
version  2006.09.15
category Utilities

������
�L�[�o�C���h����Ă���֐����|�b�v�A�b�v���j���[�ŕ\������B

�����_
�E�����֐��ɕ����̃L�[���ݒ肳��Ă��Ă��A��̃L�[�����\���ł��Ȃ��B
�E�L�[�Ɋ֘A�t�����Ă���֐��� lambda ������
  �s���D�ȏ�� ctl-x-map �Ȃǂł͂����ƃL�[��\���ł��Ȃ��B

���蓮�C���X�g�[�����@
1. popup-key.l �� popup-key.lc �� ~/site-lisp �Ɉړ��B
2. ~/.xyzzy �� ~/site-lisp/siteinit.l �Ɏ��̈ꕶ��ǉ��B
   (require "popup-key")
3. xyzzy ���ċN���B
   ~/site-lisp/siteinit.l �ɏ������̂Ȃ�
   Ctrl �� Shift �������Ȃ��� xyzzy ���N�����čă_���v�B

���A���C���X�g�[�����@
NetInstaller �� �C���X�g�[�������Ƃ��́A
NetInstaller ���� popup-key ��I������ d �������B

�蓮�ŃC���X�g�[�������Ƃ��́A
1. ESC ESC �Ɠ��́B
2. (popup-key-uninstall) �Ɠ��́B
3. .xyzzy �� siteinit.l �ɏ����� (require "popup-key") ���폜�B
4. ~/site-lisp �� popup-key.l �� popup-key.lc ���폜�B
5. �K�v�������Ctrl �� Shift �������Ȃ��� xyzzy ���N�����čă_���v�B

���g�p��
�\��(V) > �c�[���o�[(Q) > ���[�J���L�[(K) �Ƀ`�F�b�N������
���̃o�[���g�����A���L�̂悤�ɃL�[�o�C���h�B

;���[�J���L�[�ƃ}�C�i�[���[�h�̃L�[���|�b�v�A�b�v
(global-set-key #\S-F1 'popup-key-local)

;�}�E�X�̈ʒu�ł͂Ȃ��J�[�\���̈ʒu�ɕ\���������Ƃ����Ƃ�
(global-set-key #\S-F1
		'(lambda ()
		  (interactive)
		  (popup-key-local :any t)))

;�����L�[�Ŏn�܂���̂��܂Ƃ߂ăc���[�\�����ė~�����Ƃ��B
(global-set-key #\S-F1
		'(lambda ()
		  (interactive)
		  (popup-key-local :expand t)))

;�����Ƃ��K�p�������B
(global-set-key #\S-F1
		'(lambda ()
		  (interactive)
		  (popup-key-local :any t :expand t)))

;C-x�Ŏn�܂�L�[���|�b�v�A�b�v ctl-x-map �Ƃ��ɂ��Ă� keymap.l ���Q��
(global-set-key '#\S-F1
		'(lambda ()
		  (interactive)
		  (popup-key ctl-x-map :expand t)))

;��������[�J���L�[�Ɠ����悤�Ƀ|�b�v�A�b�v�ʒu��ς�����B
(global-set-key '#\S-F1
		'(lambda ()
		  (interactive)
		  (popup-key ctl-x-map :any t :expand t)))

���֐��̐���

popup-key-local (&key any expand)
���[�J���ȃL�[���|�b�v�A�b�v�B
���W���[���[�h(lisp-mode �Ƃ� netinstaller �݂����Ȃ�)��
�}�C�i�[���[�h(�r�����[�h�݂����Ȃ�)�̗������\������܂��B

:any �̓|�b�v�A�b�v����ʒu�B
:button1 :button2 �ɂ��邩�ȗ�����ƃ}�E�X�̈ʒu�B
����ȊO���w�肷��ƃJ�[�\���̈ʒu�B
:expand �̓c���[�����邩�ǂ����B
����� t �ɂ���ƁA���Ƃ��� lisp-mode �� ESC Ctrl+q �� ESC Ctrl+x �̂悤��
�����L�[�����߂ɉ������̂���̍��ڂɂ܂Ƃ߂��ăc���[�����܂��B
�ȗ����邩 nil �ɂ���ƃc���[�����܂���B
�L�[�������Ȃ�������c���[�����Ȃ��ق������₷���C�����܂��B

popup-key (keymap &key any expand)
�w�肵���L�[�}�b�v�̃L�[���|�b�v�A�b�v�B

keymap �̓L�[�}�b�v�Bctl-x-map �Ƃ��Aspec-map �Ƃ��B
�����̃L�[�}�b�v�ɂ��Ă� ~/lisp/keymap.l ���Q��

���X�V����
2006.09.15 interactive �łȂ��֐���������� interactive ������悤�ɂ����B
           filer-keymap �ł����p�ł���悤�ɂȂ������g�����舫���B
2006.04.16 documentation �̈������C���B
           �C���f���g���@��xyzzy�W���̂��̂ɁB
           �J�e�S����ύX�B
2006.03.20 popup-key-add-doc ��ǉ��B
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

(provide "popup-key")
(in-package "editor")
(export '(popup-key
	  popup-key-local
	  popup-key-local-menu
	  popup-key-menu-fugaga
	  popup-key-menu
	  popup-key-list
	  popup-key-local-bar
	  popup-key-uninstall))

(defun popup-key (keymap &key (any :button2) expand)
  "popup-key: �w�肵���L�[�}�b�v���|�b�v�A�b�v"
  (track-popup-menu (popup-key-menu
		     (popup-key-list ""
				     keymap
				     nil
				     :expand expand))
		    any))

(defun popup-key-local (&key (any :button2) expand)
  "popup-key: ���[�J���ȃL�[���|�b�v�A�b�v"
  (interactive)
  (track-popup-menu (popup-key-local-menu :expand expand) any))

(defun popup-key-local-menu (&key expand menu)
  (let ((list (nreverse (popup-key-list ""
					(local-keymap)
					nil
					:expand expand))))
    (dolist (x (minor-mode-map))
      (push nil list)
      (dolist (y (popup-key-list ""
				      x
				      nil
				      :expand expand))
	(push y list)))
    (popup-key-menu (nreverse list) menu)))

(defun popup-key-menu-fugaga (item i)
  "(values popup tag name object)"
  (when item
    (cond ((atom item)
	   (values nil
		   nil
		   (concat "&" (string (code-char i)) ": "
			   (let ((s (documentation item 'function)))
			     (if s
				 (substring s 0 (position #\LFD s))
			       (string item))))
		   (if (commandp item)
		       item
		     #'(lambda ()
			 (interactive)
			 (funcall item)
			 ))))
	  ((eq :lambda (car item))
	   (values nil
		   nil
		   (concat "&"
			   (string (code-char i))
			   ": lambda - "
			   (second item))
		   (third item)))
	  (t
	   (values t
		   nil
		   (concat "&"
			   (string (code-char i))
			   ": "
			   (car item))
		   (popup-key-menu (cdr item)))))))

(defun popup-key-menu (list &optional menu)
  (unless menu
    (setq menu (create-popup-menu 'popup-key)))
  (let ((i (char-code #\1))
	(separator t))
    (dolist (x (if (car list)
		   list
		 (cdr list)))
      (multiple-value-bind (popup tag name object)
	  (popup-key-menu-fugaga x i)
	(if name
	    (progn
	      (setq separator nil)
	      (if popup
		  (add-popup-menu menu
				  object
				  name)
		(add-menu-item menu
			       tag
			       name
			       object))
	      (setq i (case (code-char i)
			(#\9 (char-code #\A))
			(#\Z (char-code #\{))
			(#\~ (char-code #\:))
			(#\@ (char-code #\SPC))
			(#\SPC i)
			(t (1+ i)))))
	  (unless separator
	    (add-menu-separator menu)
	    (setq separator t)))))
    menu))

;�L�[�}�b�v����֐��̃��X�g��Ԃ��B
;�����L�[�Ŏn�܂���̂�(list "�L�[�������̓}�b�v��" + �֐��̃��X�g)
;lambda��(list 'lambda "�L�[��str" + ���ۂ�lambda��)
;�قƂ��keymap.l��describe-bindings-1�̃R�s�y
(defun popup-key-list (prefix keymap shadow &key prefix-string expand)
  (setq keymap (keymapp keymap))
  (when keymap
    (let (prefixlist result)
      (setq shadow (mapcan #'(lambda (x)
			       (setq x (keymapp x))
			       (and x (list x)))
			   shadow))
      (do ((index 0)
	   (nl nil))
	  ((>= index *full-keymap-length*))
	(let ((nindex (1+ index))
	      (bound (lookup-keymap-index keymap shadow index)))
	  (when bound
	    (if (>= index 128)
		(when nl
		  (push nil result)
		  (setq nl nil))
	      (unless nl
		(push nil result)
		(setq nl t)))
	    (cond ((symbolp bound)
		   (while (and (< nindex *full-keymap-length*)
			       (eq bound (lookup-keymap-index keymap shadow nindex)))
		     (setq nindex (1+ nindex)))
		   (push bound result))
		  ((keymapp bound))
		  (t
		   (push (list :lambda
			       (format nil
				       "~A~:C"
				       prefix
				       (*keymap-index-char index))
			       bound)
			 result))))
	  (setq index nindex)))
      (dotimes (index *full-keymap-length*)
	(let* ((c (*keymap-index-char index))
	       (x (lookup-keymap keymap c)))
	  (when (keymapp x)
	    (let ((y (mapcar #'(lambda (x) (lookup-keymap x c)) shadow)))
	      (when (notany #'(lambda (x) (and x (not (keymapp x)))) y)
		(let ((list (popup-key-list
			     (format nil "~A~:C " prefix c)
			     x
			     y
			     :prefix-string
			     (if (sequencep x)
				 (concat (format nil "~A~:C" prefix c) " prefix")
			       (string x))
			     :expand expand)))
		  (if expand
		      (push list prefixlist)
		    (dolist (x list)
		      (push x result)))))))))
      (if expand
	  (if prefix-string
	      (append (list prefix-string)
		      (nreverse prefixlist)
		      (nreverse result))
	    (append (nreverse prefixlist)
		    (nreverse result)))
	(nreverse result)))))

(defun popup-key-local-bar ()
  (create-tool-bar
   'popup-key-local-bar
   (merge-pathnames "toolbar.bmp" (etc-path))
   '(("���[�J���L�[" 59 popup-key-local))))
(define-command-bar 'popup-key-local-bar "���[�J���L�[(&K)")

(defun popup-key-uninstall ()
  (delete-command-bar 'popup-key-local-bar))