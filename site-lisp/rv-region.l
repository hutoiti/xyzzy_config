;;; -*- Mode: Lisp; Last modified: <2007/12/31 01:12:59> -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   rv-region.l --- ���[�W�����𔽓]�\��
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>
#|

���T�v

  ���[�W�����𔽓]�\������B�����āA����Ȃ�ɉ�������B
  ������������΁A���[�W�����̍쐬�Ɠ����ɃZ���N�V�������쐬����B


���C���X�g�[��

  1. rv-region.l �� ~/site-lisp �ɃR�s�[����B

  2. �K�v�Ȃ�΃o�C�g�R���p�C������B

       M-x byte-compile-file

  3. .xyzzy �� siteinit.l �Ɉȉ��̋L�q��ǉ�����B

      (require "rv-region")


���g����

  ���[�W�����̔��]���J�n���邽�߂ɁA�u���̂P�v�܂��́u���̂Q�v�̐ݒ�
  ���s���B

  ���[�W�����A�Z���N�V�����A��`�A�}�E�X�֌W���̃R�}���h�����s����ƁA
  ���]�\�������������B

  �����I�ɔ��]�\�����~�߂�ꍇ�́AC-g ����B

  ���]�\���F�́A�u�j�Z���]�F�v�Őݒ肳�ꂽ���́B�������C[���ʐݒ�
  ][�\��][�����Ɣ��]����]�Ƀ`�F�b�N�������Ă���ƁA�u�j�Z���]�F�v
  �͎g�p����Ȃ��悤�ł��B


  ���̂P

  ���]�\���J�n�p�R�}���h���s���̂݁A���]�\�����J�n����B�ȉ��̐ݒ�
  �ł́AC-@ �Ń}�[�N��ݒ肷��ƁA���[�W�����̔��]�\�����J�n����B
  ���̑��̃R�}���h�Ń}�[�N��ݒ肵���ꍇ�́A���]�\�����Ȃ��B

    (global-set-key #\C-@ 'rv-set-mark-command)

  ���̐ݒ�ł́A���]�\���J�n��A���]�\�������������܂ł̊Ԃ̂݁A
  ���]�\�������p�R�}���h���A*post-command-hook* �ɐݒ肳��Ă���B

  *post-command-hook* �ւ̐ݒ�R�}���h���ixyzzy �ւ̕��ׂ��j�A�ɗ�
  ���炵�������ɂ́A������̕����ǂ������B


  ���̂Q

  �}�[�N�Z�b�g��͕K�����]�\�����J�n����B�ȉ��̐ݒ������ƁA
  *rv-start-command-list* �ɓo�^���ꂽ�R�}���h�����s��A���[�W����
  �̔��]�\�����J�n����B

    (setq *rv-region-stay-on* t)

  ���̐ݒ�ł́A�펞�A���]�\���J�n�p�R�}���h���A*post-command-hook*
  �ɐݒ肳��Ă���B

  ���]�\���ҋ@�̒�~/�J�n�́AM-x rv-toggle-watch ����B


���ݒ��

  �E���[�W�����̍쐬�Ɠ����ɃZ���N�V�������쐬���A���]�\���̓Z���N
    �V�����ɔC���B

      (setq *rv-region-use-selection* t)

  �E���]���~�߂�R�}���h���s����A���̃R�}���h���s�܂Ŕ��]�\����
    ����B

      (setq *rv-region-keep-reverse* t)

  �E���]�\�����J�n����R�}���h��ǉ�����B�i�u���̂Q�v�̏ꍇ�ɗL���j

      (pushnew 'command *rv-start-command-list*)

  �E���]�\�����~�߂�R�}���h��ǉ�����B

      (setq *rv-exit-command-list* (list 'command1 'command2))

  �E���]�\���𑱂���R�}���h��ǉ�����B

      (setq *rv-continue-command-list* (list 'command1 'command2))

  �E���]����Ă��Ȃ����[�W�����ɑ΂����]���J�n����B(M-R)

      (global-set-key #\M-R 'rv-restart)

  �E���]����Ă��Ȃ����[�W�������ꎞ�I�ɔ��]����B(M-V)

      (global-set-key #\M-V 'rv-check)


���X�V����

  [Version 2.04] 2007-12-31 (��)
  �E���C�Z���X����(MIT���C�Z���X)���L�ځB

  [Version 2.03.2] 2004/04/09
  �E*rv-exit-command-regexp* �ɁCregister ��ǉ������B

  [Version 2.03.1] 2003/04/19
  �E*rv-exit-command-regexp* �ɁAtabify ��ǉ������B

  [Version 2.03] 2003/01/28
  �Erv-restart �̒ǉ�����я����������炩�ł��y���Ȃ邱�Ƃ������
    rv-region-command �����������Ă݂��B
  �E*rv-exit-command-regexp* �ɂ����炩�ǉ������B
  �Erv-region-toggle-watch �� rv-toggle-watch �ɕύX�����B
  �Erv-region-check �� rv-check �ɕύX�����B
  �E�u�g�����v�́u���̂P�v�Ɓu���̂Q�v����ւ��A�u���̂P�v�����X�X��
    �Ƃ����B

  [Version 2.02.1] 2003/01/26
  �E2.02 �ŏC���ł��Ă��Ȃ������̂��C�������B
    �����킾���񂪏ڂ��������Ă���Ă����̂ɁD�D�D�B;(;_;);

  [Version 2.02] 2003/01/26 (��)
  �E*rv-region-use-selection* �� t �ɂ��Ă���ƁAset-mark-command
    �ł������]�\���i�Z���N�V�����j���J�n����Ȃ��̂��C�������B

  [Version 2.01] 2003/01/26 (��)
  �E�����킾����̂��Q�l�ɁA���[�W�����̍쐬�Ɠ����ɃZ���N�V������
    �쐬���A���]�\���̓Z���N�V�����ɔC�����Ƃ��ł���悤�ɂ����B
  �Erv-region-start, rv-region-stop �� interactive �łȂ������B

  [Version 2.00] 2003/01/22 (��)
  �ETKI ����̂��Q�l�ɁA�}�[�N��ݒ肷��R�}���h�̎��s��҂��ă��[
    �W�����̔��]�\�����J�n���邱�Ƃ��ł���悤�ɂ����B
  �E���]���~�߂�R�}���h���s����A���̃R�}���h���s�܂Ŕ��]�\����
    ���邱�Ƃ��ł���悤�ɂ����B
  �E��`�������s��ɂ��A���]�\������������悤�ɂ����B
  �E���̑����낢��B

  [Version 1.02] 2003/01/18 (�y) ��
  �E�I������R�}���h��S�ė�L���Ȃ��ŁA��̂Ŕ��f����悤�ɂ����B
  �E*rv-continue-command-list* ��ǉ������B

  [Version 1.01] 2003/01/18 (�y) ��
  �Erv-quit ���폜�����B

  [Version 1.00] 2003/01/17 (��)
  �E�������B


�����C�Z���X

  rv-region.l ��MIT���C�Z���X�Ɋ�Â��ė��p�\�ł��B
  <http://www.opensource.org/licenses/mit-license.php>

Copyright (c) 2003-2007 HIE Masahiro

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
|#

(provide "rv-region")

;;; ������������������������������������������������������������������������ ;;;
;;;  �� �ϐ��ݒ�
;;; ������������������������������������������������������������������������ ;;;

(defvar *rv-region-stay-on* nil
  "rv-region: �}�[�N�Z�b�g��͏�ɔ��]�\�����J�n")

(defvar *rv-region-keep-reverse* nil
  "rv-region: ���̃R�}���h���s�܂Ŕ��]�\���𑱂���")

(defvar *rv-region-use-selection* nil
  "rv-region: ���[�W�����ƃZ���N�V�����𓯎��ɍ쐬����")

(defvar *rv-start-command-list*
  (list 'set-mark-command 'mark-paragraph 'mark-page 'mark-defun
	'mark-sexp 'mark-word 'mark-whole-buffer 'rv-restart)
  "rv-region: ���]�\�����J�n����R�}���h�̃��X�g")

(defvar *rv-exit-command-list* nil
  "rv-region: ���]�\�����~�߂�R�}���h�̃��X�g")

(defvar *rv-continue-command-list* nil
  "rv-region: ���]�\���𑱂���R�}���h�̃��X�g")

(defvar *rv-exit-command-regexp*
  (compile-regexp (concat
		   "\\(quit\\|self-insert-command"
		   "\\|.*\\(region\\|selection\\|rectangle\\|mouse\\|newline\\|indent\\|tabify\\|register\\).*\\)"))
  "rv-region: ���]�\�����~�߂�R�}���h��\�����K�\��")


;;; ������������������������������������������������������������������������ ;;;
;;;  �� ���[�W�������]�\���p�֐�
;;; ������������������������������������������������������������������������ ;;;

(defun rv-region ()
  (let ((com (if *rv-region-keep-reverse* *last-command* *this-command*)))
    (if (and (not (member com *rv-continue-command-list*))
	     (or (member com *rv-exit-command-list*)
		 (string-match *rv-exit-command-regexp* (format nil "~S" com))))
	(rv-region-stop)
      (let ((m (mark t)))
	(and m (rv-region-command m com))))))

(defun rv-region-command (m com)
  (let ((p (point)))
    (if *rv-region-use-selection*
	(if (member com (remove 'set-mark-command *rv-start-command-list*))
	    (save-excursion
	      (save-restriction
		(narrow-to-region m p)
		(if (> m p)
		    (progn
		      (goto-char (point-max))
		      (selection-beginning-of-buffer))
		  (progn
		    (goto-char (point-min))
		    (selection-end-of-buffer)))))
	  (ed::begin-selection))
      (reverse-region m p t))))

(defun rv-region-watch ()
  (let ((m (mark t))
	(com *this-command*))
    (when (and m (member com *rv-start-command-list*))
      (rv-region-start)
      (rv-region-command m com))))

(defun rv-region-start ()
  (stop-selection)
  (add-hook '*post-command-hook* 'rv-region))

(defun rv-region-stop ()
  (delete-hook '*post-command-hook* 'rv-region))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �Θb�I�Ȋ֐�
;;; ������������������������������������������������������������������������ ;;;

(defun rv-set-mark-command ()
  "rv-region: �}�[�N��t�����[�W�������]�\�����J�n"
  (interactive)
  (set-mark-command)
  (rv-region-start))

(defun rv-restart ()
  "rv-region: ���[�W�������]�\�����J�n"
  (interactive)
  (rv-region-start))

(defun rv-check ()
  "rv-region: ���]����Ă��Ȃ����[�W�������ꎞ�I�ɔ��]�\��"
  (interactive)
  (let ((m (mark t)))
    (and m (reverse-region m (point) t))))

(defun rv-toggle-watch ()
  "rv-region: �}�[�N�Z�b�g���ɔ��]�\���̃g�O��"
  (interactive)
  (if *rv-region-stay-on*
      (progn
	(delete-hook '*post-command-hook* 'rv-region-watch)
	(setq *rv-region-stay-on* nil)
	(message "rv-region: off"))
    (progn
      (add-hook '*post-command-hook* 'rv-region-watch)
      (setq *rv-region-stay-on* t)
      (message "rv-region: on"))))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �N������
;;; ������������������������������������������������������������������������ ;;;

(add-hook '*post-startup-hook*
	  #'(lambda ()
	      (when *rv-region-stay-on*
		(add-hook '*post-command-hook* 'rv-region-watch))))


;;; rv-region.l ends here.