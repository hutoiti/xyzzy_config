;;; -*- Mode: Lisp; Package: USER; Last modified: "2007/12/31 01:04:52" -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   buf-menu-plus.l --- buffer-menu �̊g����(�H)
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>
#|

���T�v

  �E�E�B���h�E�𕪊����Ȃ��ŁC�J�����g�E�B���h�E�Ƀ��X�g��\��
  �E���E�B���h�E���J���ăo�b�t�@���{��
  �E�}�[�N�s���ɐF�t��
  �E�����o�b�t�@�ɂ܂Ƃ߂ă}�[�N������/�͂���
  �E�t�@�C���̂Ȃ��o�b�t�@�ۑ����Ɂu���O��t���ĕۑ��v�_�C�A���O��\��
  �E�I�����Ƀ}�[�N�����s
  �Ediff �̎��s
  �E�����t�@�C���ꊇ�o�C�g�R���p�C��
  �E�����t�@�C���ꊇ���
  �E���s(shell-execute)
  �E�}�E�X�_�u���N���b�N�Ή�
  �Ebuffer-menu �N�����ɁC�A�N�e�B�u�������o�b�t�@�̍s�Ɉړ�
  �E����̃t���[���Ɉړ����ċN���i�v bufmenu.l�j


���C���X�g�[��

  1. buf-menu-plus.l �� site-lisp �ɃR�s�[����B

  2. �K�v�ɉ����C�o�C�g�R���p�C������B

       M-x byte-compile-file

  3. .xyzzy �� siteinit.l �Ɉȉ��̋L�q��ǉ�����B

      (require "buf-menu-plus")

  4. xyzzy ���ċN�����C�ݒ�𔽉f������B
     siteinit.l �ɋL�q�����ꍇ�͍ă_���v������B


���N�����@

  �EC-x C-b �Ŋg����(�H)buffer-menu���N�����܂��B

  �EC-u �Ɠ��͂��Ă����L�R�}���h�����s����ƁC�t�@�C���Ɋ֘A�t����ꂽ
    �o�b�t�@�݂̂�\�����܂��BM-x buffer-menu-plus-visit �ł��悢�ł��B


���L�[�o�C���h

    RET : �J�[�\���s�̃o�b�t�@���J��
    TAB : �J�[�\���s�̃o�b�t�@�𑼂̃E�B���h�E�ŉ{��
    M-n : ���s�̃o�b�t�@�𑼂̃E�B���h�E�ŉ{���ior M-Down�j
    M-p : �O�s�̃o�b�t�@�𑼂̃E�B���h�E�ŉ{���ior M-Up�j
    0   : �J�[�\���s�̃o�b�t�@���J�����g�E�B���h�E�ŊJ��
    1   : �J�[�\���s�̃o�b�t�@���J�������̃E�B���h�E�����
    b   : �o�C�g�R���p�C���}�[�N "B" ������
    p   : ����}�[�N "P" ��t����
    D   : �S�Ẵo�b�t�@�ɍ폜�}�[�N "D" ������
    S   : ���ۑ��o�b�t�@�ɕۑ��}�[�N "S" ������
    U   : �S�Ẵ}�[�N������
    x   : �}�[�N�����s
    t   : diff �}�[�N "O" �܂��� "N" ���g�O��
    M-f : diff �����s
    M-s : �J�[�\���s�̃t�@�C�������s
    q   : buffer-menu ���I��

  ���̑��́C�W���� buffer-menu (list-buffers) �Ɠ����B�i���Ԃ�j

    f   : �J�[�\���s�̃o�b�t�@���J��
    s   : �ۑ��}�[�N "S" ��t����
    d   : �폜�}�[�N "D" ��t����
    k   : �폜�}�[�N "D" ��t����
    o   : �J�[�\���s�̃o�b�t�@�𑼂̃E�B���h�E�ŊJ��
    C-d : �폜�}�[�N "D" ��t���đO�̍s�Ɉړ�
    C-k : �폜�}�[�N "D" ��t����
    SPC : ���̍s�Ɉړ�
    ~   : �ύX�}�[�N������
    u   : �}�[�N������


��diff

  diff �̎��s�ɂ́Cdiff.exe ���K�v�ƂȂ�܂��B�ǂ��������ɓ���Ă��������B

  buffer-menu �Ŕ�r�������o�b�t�@�ɃJ�[�\�������킹�Ct �������܂��B���̃L
  �[�ɂ��}�[�N���g�O�����܂����C`O' �� old file�C`N' �� new file �ƂȂ�
  �܂��B�}�[�N��t������CM-f ����͂��Cdiff �����s���܂��B

  diff ���s��ɂ́C�Ώۃo�b�t�@�ɑ΂� revert-buffer �����s���Cdiff �̌���
  ���o�b�t�@�ɔ��f�����܂��B


���J�X�^�}�C�Y

  buffer-menu ���� navigate �����s����ɂ͂���Ȋ����ŁB�ꗗ����I���ł���
  �̂ł�����ƕ֗������B

    ;;; browser �ŊJ�� (M-b)
    (defun buf-menu-plus-navigate ()
      (interactive)
      (save-excursion
        (bx:navigate (get-buffer-file-name (ed::buffer-menu-buffname)))))
    (define-key ed::*buffer-menu-mode-map* #\M-b 'buf-menu-plus-navigate)


���X�V����

  [Version 1.02] 2007-12-31 (��)
  �EMIT���C�Z���X�ɂ����B

  [Version 1.01] 2005-02-03 (Thu)
  �E���J�p�ɂ����炩�����B

  [Version 1.00] 2003-10-05 (Sun)
  �E���ō쐬�B


�����C�Z���X

  buf-menu-plus.l ��MIT���C�Z���X�Ɋ�Â��ė��p�\�ł��B
  <http://www.opensource.org/licenses/mit-license.php>

Copyright (c) 2007 HIE Masahiro

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

(provide "buf-menu-plus")

;;; ������������������������������������������������������������������������ ;;;
;;;  �� �ϐ��ݒ�i�K���ɃJ�X�^�}�C�Y���邠����j
;;; ������������������������������������������������������������������������ ;;;

;;; �I�����Ƀ}�[�N�����s����
(defvar *buf-menu-plus-execute-mark-before-quit* t)

;;; �o�b�t�@��I�������� buffer-menu ���I������
(defvar *buf-menu-plus-close-buffer* t)

;;; diff ���s��C����Ƀf�B�X�N����ǂݒ���
(defvar *buf-menu-plus-diff-revert-buffer-no-question* t)

;;; �^�C�g���̐F
(defvar *buffer-menu-plus-color-title* '(:color 14))

;;; �Z�p���[�^�̐F
(defvar *buffer-menu-plus-color-sep* '(:color 15))

;;; �폜�}�[�N�s�̐F
(defvar *buffer-menu-plus-color-D* '(:color 1))

;;; �폜�}�[�N�s(���ۑ��o�b�t�@)�̐F
(defvar *buffer-menu-plus-color-*D* '(:color 1 0 :bold))

;;; �ۑ��}�[�N�s�̐F
(defvar *buffer-menu-plus-color-S* '(:color 4 0 :bold))

;;; �o�C�g�R���p�C��/����}�[�N�̐F
(defvar *buffer-menu-plus-color-BP* '(:color 4))

;;; Diff �}�[�N�iOld�j�s�̐F
(defvar *buffer-menu-plus-color-O* '(:color 10 0 :bold))

;;; Diff �}�[�N�iNew�j�s�̐F
(defvar *buffer-menu-plus-color-N* '(:color 13 0 :bold))

;;; �J�����g�o�b�t�@�̐F
(defvar *buffer-menu-plus-color-dot* '(:color 0 0 :bold))

;;; *hoge* �o�b�t�@�̐F
(defvar *buffer-menu-plus-color-** '(:color 9))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� ���̑��̕ϐ��ݒ�
;;; ������������������������������������������������������������������������ ;;;

(defvar *buf-menu-plus-buffer-name* "*Buffer List*")
(defvar *buf-menu-plus-diff-list* nil)
(defvar *buf-menu-plus-windows* nil)
(defvar *buffer-menu-plus-hook* nil)


;;; ������������������������������������������������������������������������ ;;;
;;;  �� buffer-menu
;;; ������������������������������������������������������������������������ ;;;

(defun buffer-menu-plus (&optional arg)
  "�g����(�H)buffer-menu"
  (interactive)
  (setf *buf-menu-plus-windows* (count-windows))
  ;; bufmenu.l ������Ί���̃t���[���Ɉړ�������
  (when (fboundp 'bufmenu-select-default-frame)
    (bufmenu-select-default-frame))
  (let (winconf)
    (setq winconf (current-window-configuration))
    (setq *list-buffers-plus-winconf* (current-window-configuration))
    (list-buffers (or arg *prefix-args*))
    (set-window-configuration winconf)
    (set-buffer *buf-menu-plus-buffer-name*)
    (scan-buffer "^\\." :regexp t))
  ;; �o�b�t�@�̏�Ԃ𒲐�
  (make-local-variable 'regexp-keyword-list)
  (setf regexp-keyword-list
	(compile-regexp-keyword-list
	 `(("^ MR.*" t ,*buffer-menu-plus-color-title*)
	   ("^[ -]+$" t ,*buffer-menu-plus-color-sep*)
	   ("^.[^*]D.*" t ,*buffer-menu-plus-color-D*)
	   ("^.\\*D.*" t ,*buffer-menu-plus-color-*D*)
	   ("^.S[^D].*" t ,*buffer-menu-plus-color-S*)
	   ("^..[BP].*" t ,*buffer-menu-plus-color-BP*)
	   ("^..O.*" t ,*buffer-menu-plus-color-O*)
	   ("^..N.*" t ,*buffer-menu-plus-color-N*)
	   ("^\\..*" t ,*buffer-menu-plus-color-dot*)
	   ("^....\\*.*" t ,*buffer-menu-plus-color-**)
	   )))
  (let ((buf (selected-buffer)))
    (set-local-window-flags buf *window-flag-line-number* nil)
    (set-local-window-flags buf *window-flag-newline* nil)
    (set-local-window-flags buf *window-flag-eof* nil))
  (run-hooks '*buffer-menu-plus-hook*))

(defun buffer-menu-plus-visit ()
  "bufmenu-plus �t�@�C���Ɋ֘A�t����ꂽ�o�b�t�@�ꗗ"
  (interactive)
  (buffer-menu-plus t))

(defun buf-menu-plus-execute ()
  "bufmenu-plus �}�[�N�����s"
  (interactive)
  ;; �ۑ�
  (goto-char (point-min))
  (while (scan-buffer "^.S" :regexp t)
    (save-excursion
      (set-buffer (ed::buffer-menu-buffname))
      (if (get-buffer-file-name)
	  (save-buffer)
	(progn
	  (refresh-screen)
	  (save-buffer-dialog))))
    (forward-line 1))
  ;; �폜
  (goto-char (point-min))
  (while (scan-buffer "^..D" :regexp t)
    (delete-buffer (ed::buffer-menu-buffname))
    (forward-line 1))
  ;; �o�C�g�R���p�C��
  (goto-char (point-min))
  (while (scan-buffer "^..B" :regexp t)
    (byte-compile-file (get-buffer-file-name (ed::buffer-menu-buffname)))
    (forward-line 1))
  ;; ���
  (goto-char (point-min))
  (let ((i 0))
    (while (scan-buffer "^..P" :regexp t)
      (if (zerop i)
	  (progn
	    (print-dialog (ed::buffer-menu-buffname))
	    (setq i (1+ i)))
	(print-buffer (ed::buffer-menu-buffname)))
      (forward-line 1)))
  (buffer-menu-plus))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� buffer-menu �}�[�N������
;;; ������������������������������������������������������������������������ ;;;

(defun buf-menu-plus-unmark-all ()
  "bufmenu-plus ����Ԃ̃}�[�N���O��"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (goto-line 3)
    (while (not (eobp))
      (buffer-menu-unmark))))

(defun buf-menu-plus-delete-all ()
  "bufmenu-plus ����Ԃɍ폜�}�[�N"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (goto-line 3)
    (while (not (eobp))
      (if (equal (ed::buffer-menu-buffname) "*scratch*")
	  (next-line)
	(buffer-menu-delete)))))

(defun buf-menu-plus-save-all ()
  "bufmenu-plus ���ۑ��o�b�t�@�ɕۑ��}�[�N"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (goto-line 3)
    (while (scan-buffer "^.\\*" :regexp t)
      (if (equal (ed::buffer-menu-buffname) "*scratch*")
	  (next-line)
	(buffer-menu-save)))))

;;; shell-execute
(defun buf-menu-plus-shell-execute ()
  "bufmenu-plus shell-execute"
  (interactive)
  (shell-execute (get-buffer-file-name (ed::buffer-menu-buffname))))

(defun buf-menu-plus-byte-compile ()
  "bufmenu-plus �o�C�g�R���p�C������t�@�C���Ƀ}�[�N"
  (interactive)
  (ed::buffer-menu-buffer-exist-p)
  (goto-column 2)
  (let ((buffer-read-only nil))
    (declare (special buffer-read-only))
    (insert #\B)
    (delete-char 1))
  (forward-line 1))

(defun buf-menu-plus-print ()
  "bufmenu-plus �������t�@�C���Ƀ}�[�N"
  (interactive)
  (ed::buffer-menu-buffer-exist-p)
  (goto-column 2)
  (let ((buffer-read-only nil))
    (declare (special buffer-read-only))
    (insert #\P)
    (delete-char 1))
  (forward-line 1))

(defun buf-menu-plus-mark-diff ()
  "bufmenu-plus diff ����t�@�C���Ƀ}�[�N"
  (interactive)
  (ed::buffer-menu-buffer-exist-p)
  (goto-column 2)
  (let ((buffer-read-only nil))
    (declare (special buffer-read-only))
    (if (not (save-excursion
	       (goto-char (point-min))
	       (scan-buffer "^..O" :regexp t)))
	(insert #\O)
      (if (not (save-excursion
		 (goto-char (point-min))
		 (scan-buffer "^..N" :regexp t)))
	  (insert #\N)
	(insert #\SPC)))
    (delete-char 1)))

;;; buffer-menu�����
(defun buf-menu-plus-quit ()
  "bufmenu-plus �I��"
  (interactive)
  ;;�}�[�N�����s
  (when (and *buf-menu-plus-execute-mark-before-quit*
	     (save-excursion
	       (goto-char (point-min))
	       (scan-buffer "^.\\(S\\|.[BDP]\\)" :regexp t))
	     (yes-or-no-p "�}�[�N�����s����H"))
    (buf-menu-plus-execute))
  ;;�K�v�ɉ����E�B���h�E�����
  (when (< *buf-menu-plus-windows* (count-windows))
    (delete-other-windows))
  (kill-buffer (selected-buffer)))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� buffer-menu �o�b�t�@��I�����ĊJ��
;;; ������������������������������������������������������������������������ ;;;

(defun buf-menu-plus-1-window ()
  "bufmenu-plus �J�[�\���s�̃o�b�t�@���J�������̃E�B���h�E�����"
  (interactive)
  (buffer-menu-1-window)
  (when *buf-menu-plus-close-buffer*
    (delete-buffer *buf-menu-plus-buffer-name*)))

(defun buf-menu-plus-other-window ()
  "bufmenu-plus �J�[�\���s�̃o�b�t�@�𑼃E�B���h�E�ŉ{��"
  (interactive)
  (save-excursion
    (ed::buffer-menu-other-window)
    (other-window -1)))

(defun buf-menu-plus-view-next (&optional (arg -1))
  "bufmenu-plus "
  (interactive)
  (next-virtual-line arg)
  (buf-menu-plus-other-window))

(defun buf-menu-plus-view-previous (&optional (arg 1))
  "bufmenu-plus "
  (interactive)
  (buf-menu-plus-view-next 1))

(defun buf-menu-plus-this-window ()
  "bufmenu-plus �J�[�\���s�̃o�b�t�@���J�����g�E�B���h�E�ŊJ��"
  (interactive)
  (buffer-menu-this-window)
  (when *buf-menu-plus-close-buffer*
    (delete-buffer *buf-menu-plus-buffer-name*)))

(defun buf-menu-plus-left-press ()
  "bufmenu-plus �_�u���N���b�N�ŊJ��"
  (interactive)
  (let ((click (mod *last-mouse-click-count* 6)))
    (if (= click 2)
	(buf-menu-plus-open)
      (mouse-left-press))))

;;; �J�[�\���s�̃o�b�t�@���J�����g�E�B���h�E�ŊJ��
(defun buf-menu-plus-open ()
  "bufmenu-plus �J�[�\���s�̃o�b�t�@���J��"
  (interactive)
  (if (= *buf-menu-plus-windows* (count-windows))
      (buf-menu-plus-this-window)
    (buf-menu-plus-1-window)))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� buffer-menu ���� diff
;;; ������������������������������������������������������������������������ ;;;

(require "diff")

(defun buf-menu-plus-diff ()
  "bufmenu-plus diff���s"
  (interactive)
  (define-key *diff-mode-map* #\q 'buf-menu-plus-diff-quit)
  (setq *buf-menu-plus-diff-list* nil)
  (let (o n)
    (goto-char (point-min))
    (while (scan-buffer "^..O" :regexp t)
      (push (ed::buffer-menu-buffname) *buf-menu-plus-diff-list*)
      (setq o (get-buffer-file-name (ed::buffer-menu-buffname)))
      (forward-line 1))
    (goto-char (point-min))
    (while (scan-buffer "^..N" :regexp t)
      (push (ed::buffer-menu-buffname) *buf-menu-plus-diff-list*)
      (setq n (get-buffer-file-name (ed::buffer-menu-buffname)))
      (forward-line 1))
    (buf-menu-plus-quit)
    (if (and o n)
	(diff n o)
      (message "�t�@�C�����Ȃ����"))
    ))

(defun buf-menu-plus-diff-quit ()
  "bufmenu-plus diff�I�����f�B�X�N����ǂݒ���"
  (interactive)
  (diff-quit)
  (with-set-buffer
    (dolist (buffer *buf-menu-plus-diff-list* t)
      (when (find-buffer buffer)
	(or (null (get-buffer-file-name buffer))
	    (null (buffer-local-value buffer 'verify-visited-file-modtime))
	    (verify-visited-file-modtime buffer)
	    (save-excursion
	      (set-buffer buffer)
	      (when (or *buf-menu-plus-diff-revert-buffer-no-question*
			(yes-or-no-p "�f�B�X�N����ǂݒ����܂���?"))
		(update-visited-file-modtime)
		(revert-buffer)))))))
  (setq *buf-menu-plus-diff-list* nil)
  ;;�߂��Ȃ��Ă����Q�͂Ȃ��悤�ȋC�����邯��ǁc
  (define-key *diff-mode-map* #\q 'diff-quit)
  t)


;;; ������������������������������������������������������������������������ ;;;
;;;  �� buffer-menu �L�[�o�C���h
;;; ������������������������������������������������������������������������ ;;;

(define-key ed::*buffer-menu-mode-map* #\LBtnUp 'buf-menu-plus-left-press)

(define-key ed::*buffer-menu-mode-map* #\U   'buf-menu-plus-unmark-all)
(define-key ed::*buffer-menu-mode-map* #\D   'buf-menu-plus-delete-all)
(define-key ed::*buffer-menu-mode-map* #\S   'buf-menu-plus-save-all)

(define-key ed::*buffer-menu-mode-map* #\RET 'buf-menu-plus-open)
(define-key ed::*buffer-menu-mode-map* #\TAB 'buf-menu-plus-other-window)
(define-key ed::*buffer-menu-mode-map* #\M-Up 'buf-menu-plus-view-next)
(define-key ed::*buffer-menu-mode-map* #\M-Down 'buf-menu-plus-view-previous)
(define-key ed::*buffer-menu-mode-map* #\M-p 'buf-menu-plus-view-next)
(define-key ed::*buffer-menu-mode-map* #\M-n 'buf-menu-plus-view-previous)
(define-key ed::*buffer-menu-mode-map* #\1   'buf-menu-plus-1-window)
(define-key ed::*buffer-menu-mode-map* #\0   'buf-menu-plus-this-window)
(define-key ed::*buffer-menu-mode-map* #\b   'buf-menu-plus-byte-compile)
(define-key ed::*buffer-menu-mode-map* #\p   'buf-menu-plus-print)
(define-key ed::*buffer-menu-mode-map* #\q   'buf-menu-plus-quit)
(define-key ed::*buffer-menu-mode-map* #\x   'buf-menu-plus-execute)
(define-key ed::*buffer-menu-mode-map* #\t   'buf-menu-plus-mark-diff)
(define-key ed::*buffer-menu-mode-map* #\M-f 'buf-menu-plus-diff)
(define-key ed::*buffer-menu-mode-map* #\M-s 'buf-menu-plus-shell-execute)

;;; buffer-menu �N��
(define-key ctl-x-map #\C-b 'buffer-menu-plus)


;;; buf-menu-plus.l ends here.