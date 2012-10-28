(provide "key-chord")
(in-package "editor")

(defun key-chord-version nil
  (interactive)
  (and (interactive-p)
       (message "key-chord lapse ~A on 2009-01-31 21:46" (key-chord-version)))
  "004")

#| key-chord for xyzzy-0.2.2.235

Copyright (c) 2009 knenet \kneneglect_std(^o^)yahoo.co.jp/

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

MIT���C�Z���X�ł��B����҂𖾂炩�ɂ���ΓK���Ɏg���ėǂ��ł��B
���̃\�t�g�̎g�p�ɂ���Đ��������v�ɂ��āA����҂͈�ؐӔC�������܂���B

���T�v

�Q�����������R�}���h�����s�ł���悤�ɂȂ�܂��B
f+j �� end-of-line �Ƃ��o����悤�ɂȂ�܂��B
emacs��key-chord.el���֗����ƕ����č��܂������A
�\�[�X�͌��ĂȂ��̂Ŏd�l�E���C�Z���X�Ɍ݊����͂���܂���B

������

(require "key-chord")
(toggle-key-chord t)
��.xyzzy�ɂł������܂��B
���̃t�@�C����~/site-lisp�ɓ���ăo�C�g�R���p�C�����܂��B
netinstaller��p���ăC���X�g�[�������Ȃ炱���܂ł͕s�v�ł��B

.xyzzy��
(define-key-chord '(#\f #\j) 'end-of-line)
�Ƃ������܂��B�W���ł͉����o�^����Ă��Ȃ��̂ŁA�D���Ȃ����o�^���܂��B
x.xyzzy��]������Ύg���܂��B

���ݒ�

�������͂̎�t���Ԃ� ed::*key-chord-interval* �ŕύX�ł��܂��B
�P�ʂ̓~���b�ł��B�����ݒ��16ms�ł��B

��t������ed::*key-chord-test*��lambda���ŋL�q���܂��B
�ŏ��ɓǂݍ��񂾕����������ɔ��肵�܂��B
���͎�t���͘A�����͂������Ȃ��Ȃ�����A���͕������������肷��̂ŁA
���ꂪ�s�ւȏꍇ�ɂ�nil��Ԃ��Ē�~�����܂��B

toggle-key-chord�œ����on/off�ł��܂��B

��todo

�R�}���h�ꗗ�\��
���[�h���ɃR�}���h�o�^

������
004 2009-01-31 21:46 �L�[����͂����Ɏ��s�����ۂɃG���[�ɂȂ�o�O���C���B
003 2009-01-28 19:11 �s�K�؂Ȑ������C���B
002 2009-01-04 16:51 �����Ō������Q���傫���ł���悤�ɁBmap���n�b�V���ɁB
                     ��t�������_��ɁB
001 2009-01-03 18:52 �ł����B

�����I���|#

(defvar *key-chord-test*
  (lambda (x) (and (not (get-ime-mode))
				   (= (char-columns x) 1))))
(defvar *key-chord-map* nil)
(unless *key-chord-map*
  (setq *key-chord-map* (make-hash-table :test 'equal :size 37)))
(defvar *key-chord-interval* 16)
(defvar *key-chord-max-length* 4)
(setq *key-chord-stack* nil)

(export '(toggle-key-chord define-key-chord))

(defun key-chord ()
  "���������R�}���h�����s�ł���B"
  (let ((time (get-internal-real-time))
		(a *last-command-char*)
		c cmd)
	(when (and (null *key-chord-stack*)
			   (not *executing-macro*)
			   (funcall *key-chord-test* a))
	  (while (and (< (1+ (length c)) *key-chord-max-length*)
				  (<= (- (get-internal-real-time) time) *key-chord-interval*))
		(let ((key (read-char-no-hang *keyboard*)))
		  (when key (push key c) (do-events))))
	  (if c
		  (if (setq cmd (gethash (stable-sort (append (list a) (copy-list c)) 'char<)
								 *key-chord-map*))
			  (setq *this-command* cmd)
			(progn (setq *key-chord-stack* (reverse c)) (refresh-screen)))
		))))

(defun key-chord-post ()
  (let ((key (pop *key-chord-stack*)))
	(if key (unread-char key))))

(defun toggle-key-chord (&optional (tgl nil g))
  "�����������͂�؂�ւ���B"
  (interactive)
  (if g
	  (if (eq tgl t)
		  (progn
			(add-hook '#1=*pre-command-hook* '#2=key-chord)
			(add-hook '#3=*post-command-hook* '#4=key-chord-post))
		(progn
		  (delete-hook '#1# '#2#)
		  (delete-hook '#3# '#4#)))
	(if (find '#2# #1#)
		(toggle-key-chord nil)
	  (toggle-key-chord t))))

(defun define-key-chord (keys cmd)
  "���������R�}���h��o�^����B"
  (setf (gethash (stable-sort keys 'char<) *key-chord-map*) cmd))

;end of file key-chord.l