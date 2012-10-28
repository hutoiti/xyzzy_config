;;; -*- Mode: Lisp; Last modified: <2008/01/03 22:36:03> -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   ese-fortune.l --- dubious fortune mode
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>
#|

���T�v

  �N�����Ƀ��t�@�����X�Ƃ��C�肢�Ƃ��CTODO�������_���ɕ\�����܂��B

  TKI ����� fortune-yz �����Ƃɂ��������̂ł��B

    http://www2.ocn.ne.jp/~cheerful/script/xyzzy/play/startword.html


���C���X�g�[��

  1. reference.txt ���擾���Cetc �t�H���_�ɃR�s�[����B

     NetInstaller ����C���X�g�[�������ꍇ�́Cetc �t�H���_�ɒu����܂��B

  2. ese-fortune.l �� site-lisp �ɃR�s�[����B

  3. �K�v�ɉ����C�o�C�g�R���p�C������B(�C��)

       M-x byte-compile-file

  4. .xyzzy �� siteinit.l �Ɉȉ��̋L�q��ǉ�����B

       (require "ese-fortune")

  5. xyzzy ���ċN������ƁCxyzzy Reference ���\�������悤�ɂȂ�܂��B


���g����

    a : �����X�V�̃g�O��
    i : �X�V�Ԋu(�b)��ύX
    n : ���y�[�W
    j : �w�� No �Ɉړ�
    q : �I��
    . : �I��


���ݒ��

  ;;; �N��������ڂ����ƌ���B(�����X�V���[�h)
  (setq *ese-fortune-absent* t)

  ;;; �ڂ����ƌ����Ă�Ƃ��ɁC�u���u������B
  ;;;   TKI ����́CshakeWindow �𒸂��C�ǂݍ���ł����B
  ;;;   http://www2.ocn.ne.jp/~cheerful/script/xyzzy/mode/shakeWindow.html
  (require "shakeWindow")

  ;;; �o�b�t�@�^�u���\������B
  (setq *ese-fortune-buffer* " *ese-fortune*")

  ;;; �֘A����L�[���[�h�� F1 �� info-modoki-mode ��������B
  ;;; �iinfo-modoki-mode ���K�v�ł��j
  (define-key *ese-fortune-mode-map* '#\F1 'imm-refer-selection)

  ;;; ���̑��C�J�X�^�}�C�Y�p�ϐ����Q�Ƃ��ēK���ɁB


���f�[�^�`��

  ese-fortune �p�̃f�[�^�́C1�s��1���Ƃ��Ĉ����܂��B���s�R�[�h��TAB�ŕ\
  �����܂��B�T���v���́C�ȉ��̂Ƃ���B([  TAB  ]�́CTAB����������킷)

    1|�i���ł��B[  TAB  ]    ���� �����q
    2|�˂ނ��Ă�����܂���B�P�_
    3|�ċx�݂̂��܂育��[  TAB  ]  * ���Q[  TAB  ]  * ���N��[  TAB  ]  * ������!?


���f�[�^�t�@�C���̐ݒ��

  xyzzy Reference �ȊO�̃f�[�^��\��������ꍇ�́C�f�[�^�t�@�C���̎w���
  �s���܂��B�f�[�^�t�@�C�����w�肷��ɂ́C�ȉ��̕��@������܂��B

  # �f�[�^�t�@�C���́C�ǂ�������e�L�g�[�ɒT���܂��B

    1. �f�[�^�t�@�C�����w�肷��B

           (setq *ese-fortune-dat* "tentori.data")

    2. �f�[�^�t�H���_���w�肷��

       *ese-fortune-dat* �Ƀt�H���_���w�肷��ƁC�t�H���_�ɑ��݂���t�@
       �C�����ׂĂ��f�[�^�t�@�C���Ƃ��ĔF�����C�����_���ɑI�����܂��B

           (setq *ese-fortune-dat* "F:/foo/bar/")

    3. �����̃t�@�C�����w�肷��B

       �g�p����f�[�^�t�@�C���������_���ɑI�����܂��B
       *ese-fortune-dat-list* ���w�肵���ꍇ�C*ese-fortune-dat* �ɗD�悵
       �܂��B

           (setq *ese-fortune-dat-list*
                 '("reference.dat"
                   "tentori.data"
                   ))

    4. etc �t�H���_�ȊO�̃t�@�C�����w�肷��B

      *ese-fortune-dat* �Ƀt���p�X�Ńt�@�C���w�肵�܂��B

           (setq *ese-fortune-dat* "d:/foo/bar.dat")

      �����t�@�C�����w�肷��ꍇ�B

           (setq *ese-fortune-dat-list*
                 '("d:/foo/bar.dat"
                   "piyo.txt"
                   ))


�����p�\�ȃf�[�^�t�@�C��

  [�_�Ƃ�肢]

    Taro's Page [Let's Enjoy Tentori Fortune!] ����Ctentori.lzh �𒸂��C
    �����t�f�[�^(tentori.data) ��etc �t�H���_�ɃR�s�[���܂��B

      http://taro.haun.org/tenjoy.html

    �_�Ƃ�肢�f�[�^���g���ꍇ�́C�f�[�^�t�@�C���̎w�肪�K�v�ł��B

      (setq *ese-fortune-dat* "tentori.data")

  [(BSD�Y��) fortune �p�f�[�^]

    �ȉ��̎菇�ŁCese-fortune �p�̃t�@�C���ɕϊ����Ďg�p���邱�Ƃ��ł��܂��B

      1. fortune �p�f�[�^�t�@�C������������
      2. F12 �L�[������
      3. �ϊ����t�@�C��(fortune �p�f�[�^�t�@�C��)���w�肷��
      4. �ϊ���t�@�C��(ese-fortune �p�f�[�^�t�@�C��)���w�肷��
      5. �f�[�^�t�@�C�����w�肷��

           (setq *ese-fortune-dat* "hoge.dat")


�� ese-fortune �p�̃f�[�^�`���łȂ��f�[�^�t�@�C���𒼐ڎg��

    �g���q��".dats"�Ƃ����t�@�C�����w�肷��ƁC�ȉ��̂悤�Ȍ`���̃t�@�C
    �������̂܂܎g�p���邱�Ƃ��ł��܂��B

    [hoge.dats]
      1|B&D �ŁC�g�C���b�g�y�[�p�[�𔃂��B
      2|
      3|  �F�̓s���N�B
      4|
      5|%
      6|�}�L�������g�C���ɂ����Ă����B
      7|
      8|%
      9|�Ђ�����B�s��ł��B �O�_

    TODO ���X�g�̂悤�ɁC�ύX�𑦔��f���������悤�ȏꍇ�́C���̌`����
    �p����Ƃ悢�ł��傤�B�A���C���s����s�x�f�[�^�ϊ����s�����߁C������
    �d���Ȃ�܂��B


���X�V����

  [Version 1.09.1] 2008-01-03 (��)
  �Eabsent-mode ON �̂܂܃t�@�C�����J���ƁC�t�@�C������t�H�[�J�X���O���
    ���܂����߁C�e�L�g�E�ȑΏ��������B

  [Version 1.09] 2007-12-31 (��)
  �E���C�Z���X����(MIT���C�Z���X)���L�ځB
  �Ereference.txt ���� reference.dat ��K�v�ɉ��������쐬����悤�ɂ����B
    �� ������s���ƁC�X�V���B
  �E���s�F�����������l(*ese-fortune-br*)���^�u�����ɕύX�����B
  �Exyzzy Part7 657 ����̒�Ă���荞�݁C�����̃f�[�^�t�@�C���������_��
    �ɕ\���ł���悤�ɂ���(����)�Bm(__)m
  �Eese-fortune �p�̃f�[�^�t�@�C���łȂ��Ă��C���s���ɕϊ����Č��邱�Ƃ�
    �ł���悤�ɂ����B
  �E�f�[�^�t�H���_���w��ł���悤�ɂ����B
  �Einfo-modoki-mode �ň����₷���悤�ɁC�V���^�b�N�X���`�����B
  �Eese-fortune �p�o�b�t�@���C�\������悤�ɂ����B
  �E�Ď��s���ɁC�o�b�t�@���쐬���Ȃ����Ȃ��悤�ɂ����B
  �E�ڂ����ƌ����悤�ɂ����B�i�ӂ�������̃A�C�f�B�A�j
  �ETKI ����� shakeWindow ��ǂݍ���ł����ƁC�ڂ����ƌ��Ă�Ƃ���
    �u���u������悤�ɂ����B

  [Version 1.08.3] 2003/07/06 (��)
  �E�{�̂� site-lisp �ɁCreference.dat�@�� etc �ɒu���悤�ɂ����B
  �Edat �t�@�C���́C�������Ȃ��悤�ɂ����B
  �E���܂�g��Ȃ������ȃL�[�o�C���h���폜�����B

  [Version 1.08.2] 2003/05/05 (��)
  �Ereference.dat �� reference.xml ���璼�ڍ쐬����悤�ɂ����B�܂��A
    �\�����Ă����܂肤�ꂵ���Ȃ����ȁu�ړI�ʍ����v�Ƃ��u�֐��ꗗ�v
    �̓f�[�^�Ɋ܂߂Ȃ��悤�ɂ����B����ɂ��Aref2fortune �͍폜�����B
  �Ereference.dat �� reference.xml 2003.04.30 �ł�����������̂�
    �����B
  �Erefernce.dat �݂̂𓯍�����悤�ɂ����B

  [Version 1.08.1] 2003/04/19 (�y)
  �Emixed.dat �𓯍����Ȃ��悤�ɂ����B�����ɍ쐬���@��ǉ����Ă�
    �����Bm(__)m

  [Version 1.08] 2003/04/06 (��)
  �E.xyzzy �� (ese-fortune) �Ƃ������Ȃ��Ă������悤�ɂ����B
  �Exyzzy �N������ ese-fortune ���s���_�ŁA*scratch*, �~�j�o�b�t�@
    �ȊO�̃o�b�t�@�����݂���ꍇ�́A�N�����Ȃ��悤�ɂ����i����j�B
  �E������ reference.dat �� reference.xml 2003.03.30 �ł��������
    ���̂ɂ����B

  [Version 1.07] 2003/02/18 (��)
  �Euser �p�b�P�[�W�Ɉڂ����B�i�����B�j

  [Version 1.06] 2002/12/06 (��)
  �E�f�[�^�t�@�C�������̋󔒍s�܂őI�����Ă��܂��Ă����̂��C�������B
  �E*ese-fortune-title* ��ǉ������B
  �Eexport ������̂��������ǉ������B
  �E�ݒ��Ƃ������������B

  [Version 1.05] 2002/11/29 (��)
  �Exyzzy �� SendTo �Ƃ�����A�t�@�C�������w�肵�ċN�������ꍇ�A
    ese-fortune �����s���Ȃ��悤�ɂ��Ă������肪�A�����Ȃ���
    �Ȃ������̂��C����������B
  �E���̑��A����Ȃ������ȂƂ��������������B
  �E�ł��A�������Ђ��Ă���̂ŁA�@�������Ă��邩������Ȃ��B�P�_

  [Version 1.04] 2002/11/26 (��)
  �E*ese-fortune-br* �ŉ��s�F����������w��ł���悤�ɂ����B
  �Emixed.dat �������Ă������B

  [Version 1.03] 2002/11/25(��)
  �Eref2fortune ���C�������B�� *.dat �����ׂč쐬���Ȃ������B
    �E���Ƃ� reference �� \n �L�q����Ă���ꍇ�ɁA���s����Ă��܂��Ă����Ƃ���B
    �E�u���ړI�ʍ����v�Ƃ����A�܂Ƃ܂��Ă��܂��Ă����Ƃ���B
  �E�w��s�� jump ���������B�i�ǂ��炩�Ƃ����Ǝ��̊m�F�p�j

  [Version 1.02] 2002/11/24(��)
  �Eref2fortune ���C�������B
    �E�s���̃z���C�g�X�y�[�X���폜����Ă����Ƃ���B
  �E������ reference.dat �� reference.xml 2002.11.23�� �����蒼�����B
  �E�ЂƂ̃f�B���N�g���ɂ܂Ƃ߂��B
  �E���̑��ׂ����C���B

  [Version 1.01.1] 2002/11/22(��)
  �E�����ƍ����ւ��B

  [Version 1.01] 2002/11/22(��)
  �Erandom �֐��ɁA��ڂ̈�����^�����B���싧�r����Ɋ��ӁB

  [Version 1.00] 2002/11/21(��)
  �E�Ƃ肠�������J�B


�����C�Z���X

  ese-fortune.l ��MIT���C�Z���X�Ɋ�Â��ė��p�\�ł��B
  <http://www.opensource.org/licenses/mit-license.php>

Copyright (c) 2002-2007 HIE Masahiro

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

(provide "ese-fortune")

(defconstant *ese-fortune-version* "1.09")

;;; ������������������������������������������������������������������������ ;;;
;;;  �� �ϐ��ݒ�
;;; ������������������������������������������������������������������������ ;;;

(defvar *ese-fortune-enable* t
  "ese-fortune: �N������ ese-fortune �����s")

(defvar *ese-fortune-dat* "reference.dat"
  "ese-fortune: �f�[�^�t�@�C��")

(defvar *ese-fortune-dat-list* nil
  "ese-fortune: �f�[�^�t�@�C���̃��X�g")

(defvar *ese-fortune-br* "\t"
  "ese-fortune: ���s�F��������")

(defvar *ese-fortune-buffer* "*ese-fortune*"
  "ese-fortune: �f�[�^�\���p�o�b�t�@��")

(defvar *ese-fortune-src-type* "dats"
  "ese-fortune: ���s���Ƀf�[�^�ϊ����s���t�@�C���̊g���q")

(defvar *ese-fortune-dat-separator* "^%\n"
  "ese-fortune: �f�[�^�����ϊ�����؂蕶����(���K�\��)
* ���̐��K�\���Ƀ}�b�`���镔�������s(\n)�ɕϊ������B
* ���̒P�ʂ��f�[�^ 1 ���Ƃ݂Ȃ����B")

(defvar *ese-fortune-absent* nil
  "ese-fortune: �N��������ڂ����ƌ���")

(defvar *ese-fortune-absent-interval* 10
  "ese-fortune: �X�V�Ԋu(�b)")

(defvar *ese-fortune-reference-update* t
  "ese-fortune: reference.txt �X�V���� reference.dat �������X�V����")

(defvar *ese-fortune-title*
  " ese-fortune ver.~A --- ~A [No.~5,'0D]  a: absent, i: interval, n: next, j: jump, q: quit~%~%"
  "ese-fortune: �^�C�g��������")

(defvar *ese-fortune-tmp-buffer* "*ese-fortune-tmp*"
  "ese-fortune: �ꎞ�o�b�t�@")

(defvar *ese-fortune-open-filer-func* #'open-filer
  "ese-fortune: �u�t�@�C�����J���v�R�}���h")

(defvar *ese-fortune-random-state* nil)


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �Θb�I�Ȋ֐�
;;; ������������������������������������������������������������������������ ;;;

(defun ese-fortune (&optional number file)
  "ese-fortune: ���s"
  (interactive)
  ;; *ese-fortune-dat* �� nil �Ȃ�I��
  (unless *ese-fortune-dat*
    (return-from ese-fortune nil))
  ;; �f�[�^�t�@�C���� reference.dat ���w�肳��Ă���ꍇ�̏���
  (when (string= *ese-fortune-dat* "reference.dat")
    (let ((dat (merge-pathnames "reference.dat" (etc-path)))
	  (txt (merge-pathnames "reference.txt" (etc-path))))
      ;; reference.dat ���Ȃ� or �Â��ꍇ�ɍ쐬/�X�V
      (if (file-exist-p txt)
	  (when (or (not (file-exist-p dat))
		    (and *ese-fortune-reference-update*
			 (> (file-write-time txt) (file-write-time dat))))
	    (ese-fortune-reftxt2dat))
	;; txt �� dat ���Ȃ���ΏI��
	(return-from ese-fortune nil)
	)))
  ;; �f�[�^�t�@�C���̑I��
  (let (dat fbuf tbuf blines num msg)
    (if file
	;; �f�[�^�t�@�C���������w�肳��Ă���ΗD��I�Ɏg�p����
	(setq dat file)
      (progn
	(let (files)
	  ;; �t�@�C�����X�g���擾
	  (setq files (if (file-directory-p *ese-fortune-dat*)
			  (directory *ese-fortune-dat*
				     :absolute t
				     :wild "*"
				     :file-only t)
			*ese-fortune-dat-list*))
	  ;; �t�@�C�����X�g�����݂���΁C�t�@�C���������_���ɑI��
	  (if files
	      (let ((len (list-length files)))
		(setq dat (nth (random len *ese-fortune-random-state*) files)))
	    ;; �t�@�C�����X�g���Ȃ���� *ese-fortune-dat* ���f�[�^�t�@�C���Ƃ���
	    (setq dat *ese-fortune-dat*)))
	;; �t�@�C�����̂ݎw��̏ꍇ��(etc-path)��t��
	(when (string= (file-namestring dat) dat)
	  (setq dat (merge-pathnames dat (etc-path))))))
    ;; ese-fortune �o�b�t�@�̌`��
    (if (setq fbuf (find-buffer *ese-fortune-buffer*))
	(progn
	  (set-buffer fbuf)
	  (setq buffer-read-only nil)
	  (delete-region (point-min) (point-max)))
      (progn
	(setq fbuf (create-new-buffer *ese-fortune-buffer*))
	(set-buffer fbuf)
	(ese-fortune-mode *ese-fortune-absent*)))
    ;; �f�[�^�t�@�C�����獡��\������f�[�^���擾
    (when (file-exist-p dat)
      ;; ��Ɨp�o�b�t�@�ƃf�[�^�̏���
      (setq tbuf (create-new-buffer *ese-fortune-tmp-buffer*))
      (set-buffer tbuf)
      (insert-file-contents dat)
      ;; �K�v�ɉ����g���q�̏ꍇ�̓f�[�^�ϊ��������s��
      (when (equal *ese-fortune-src-type*
		   (pathname-type dat))
	(ese-fortune-make-dat *ese-fortune-dat-separator*))
      (setq blines (1- (buffer-lines)))
      (goto-char (point-min))
      ;; �\������f�[�^�̍s���������_���ɑI��
      (if number
	  (if (or (< number 1)
		  (> number blines))
	      (setq num -1)
	    (setq num (1- number)))
	(setq num (random blines *ese-fortune-random-state*)))
      ;; �w��s�̃f�[�^���擾
      (if (= num -1)
	  (setq msg (format nil "1 �` ~D �܂ł����Ȃ���B" blines))
	(progn
	  (forward-line num)
	  (setq msg (buffer-substring
		     (progn (goto-bol)(point))
		     (progn (goto-eol)(point))))))
      (setq msg (substitute-string msg *ese-fortune-br* "\n" ))
      (delete-buffer tbuf))
    ;; �f�[�^��\������
    (set-buffer fbuf)
    (insert (format nil *ese-fortune-title*
		    *ese-fortune-version*
		    (file-namestring dat)
		    (1+ (or num -1))))
    (unless num (insert "�f�[�^������܂���B�O�_"))
    (when msg (insert msg))
    ;; ���݂̃f�[�^�t�@�C�������L�����Ă���
    (setq *ese-fortune-dat-current* dat))
  ;; �o�b�t�@�̏�Ԃ𐮂���
  (goto-char (point-min))
  (setq buffer-read-only t)
  (set-buffer-modified-p nil)
  )

(defun ese-fortune-jump (num)
  "ese-fortune: �\�����̃f�[�^�t�@�C���w��s�Ɉړ�"
  (interactive "nNo: ")
  (ese-fortune num *ese-fortune-dat-current*))

(defun ese-fortune-open-filer ()
  "ese-fortune: absent-mode ���I�������t�@�C�����J��"
  (interactive)
  (ese-fortune-absent-mode nil)
  (funcall *ese-fortune-open-filer-func*))

(defun ese-fortune-quit ()
  "ese-fortune: �����"
  (interactive)
  (ese-fortune-absent-mode nil)
  (delete-buffer (selected-buffer)))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� ese-fortune-mode
;;; ������������������������������������������������������������������������ ;;;

(defvar *ese-fortune-mode-hook* nil)

(defvar *ese-fortune-mode-map* nil)
(unless *ese-fortune-mode-map*
  (setq *ese-fortune-mode-map* (make-sparse-keymap))
  (define-key *ese-fortune-mode-map* '#\a 'ese-fortune-absent-mode)
  (define-key *ese-fortune-mode-map* '#\i 'ese-fortune-set-absent-interval)
  (define-key *ese-fortune-mode-map* '#\n 'ese-fortune)
  (define-key *ese-fortune-mode-map* '#\j 'ese-fortune-jump)
  (define-key *ese-fortune-mode-map* '#\q 'ese-fortune-quit)
  (define-key *ese-fortune-mode-map* '#\. 'ese-fortune-quit)
  (define-key *ese-fortune-mode-map* '#\F12 'ese-fortune-fortune2dat)
  (define-key *ese-fortune-mode-map* '(#\C-c #\C-f) 'ese-fortune-open-filer)
  )

(defvar *ese-fortune-mode-syntax-table* nil)
(unless *ese-fortune-mode-syntax-table*
  (setq *ese-fortune-mode-syntax-table* (make-syntax-table))
  (set-syntax-symbol *ese-fortune-mode-syntax-table*  #\-)
  (set-syntax-symbol *ese-fortune-mode-syntax-table*  #\*)
  )

(defun ese-fortune-mode(&optional absent)
  (interactive)
  (kill-all-local-variables)
  (setf buffer-mode 'ese-fortune-mode)
  (setq mode-name "ese-fortune")
  (use-keymap *ese-fortune-mode-map*)
  (use-syntax-table *ese-fortune-mode-syntax-table*)
  (setq need-not-save t)
  (setq kept-undo-information nil)
  (setq auto-save nil)
  (setq *ese-fortune-random-state* (make-random-state t))
  (let ((buf (selected-buffer)))
    (set-local-window-flags buf (+ *window-flag-newline*
				   *window-flag-tab*
				   *window-flag-full-width-space*
				   *window-flag-eof*
				   *window-flag-cursor-line*
				   *window-flag-line-number*
				   *window-flag-half-width-space*
				   *window-flag-scrolling*)
			    nil)
    (set-local-window-flags buf (+ (if (boundp '*window-flag-fold-mark*)
				       *window-flag-fold-mark*
				     *window-flag-fold-line*))
			    t))
  (when absent
    (ese-fortune-absent-mode t))
  (run-hooks '*ese-fortune-mode-hook*))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �N������
;;; ������������������������������������������������������������������������ ;;;

;;; xyzzy �N������ ese-fortune �����s
(add-hook '*post-startup-hook* #'(lambda ()
				   (when (and *ese-fortune-enable*
					      ;; �����Ƃ��ăt�@�C�����w�肳��Ă���ꍇ�͓��삳���Ȃ��悤��
					      ;; �Ǝv�������C����܂�Ӗ��Ȃ��H
					      (= 2 (length (buffer-list))))
				     (ese-fortune))))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �ڂ����ƌ��邽�߂̊֐�
;;; ������������������������������������������������������������������������ ;;;

(defun ese-fortune-set-absent-interval ()
  "ese-fortune: ��ʂ��؂�ւ��b����ύX"
  (interactive)
  (let ((absent *ese-fortune-absent-mode*))
    (ese-fortune-absent-mode nil)
    (message "���݂̐ݒ�l�F ~D �b" *ese-fortune-absent-interval*)
    (setq *ese-fortune-absent-interval* (read-integer "absent interval: "))
    (when absent
      (ese-fortune-absent-mode t))))

;;; �ڂ����ƌ���
(defun ese-fortune-absent ()
  (if (find-buffer *ese-fortune-buffer*)
      (when (equal *ese-fortune-buffer* (buffer-name (selected-buffer)))
	(ese-fortune)
	(when (fboundp 'shake-window)
	  (shake-window)))
    (ese-fortune-return-to-me))
  (refresh-screen))

;;; �ڂ����ƌ��n�߂�
(defun ese-fortune-absent-start ()
  (start-timer *ese-fortune-absent-interval* 'ese-fortune-absent))

;;; ���ɕԂ�
(defun ese-fortune-return-to-me ()
  (stop-timer 'ese-fortune-absent))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� ese-fortune-absent-mode
;;; ������������������������������������������������������������������������ ;;;

(defvar-local *ese-fortune-absent-mode* nil)

(defun ese-fortune-absent-mode (&optional (arg nil sv))
  (interactive "p")
  (ed::toggle-mode '*ese-fortune-absent-mode* arg sv)
  (update-mode-line t)
  (if *ese-fortune-absent-mode*
      (ese-fortune-absent-start)
    (ese-fortune-return-to-me))
  t)

(pushnew '(*ese-fortune-absent-mode* . "I am absentminded.") *minor-mode-alist* :key #'car)


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �f�[�^�t�@�C���쐬
;;; ������������������������������������������������������������������������ ;;;

(defun ese-fortune-reftxt2dat ()
  "ese-fortune: reference.txt ����f�[�^�t�@�C�����쐬"
  (interactive)
  (long-operation
    (let ((txt (merge-pathnames "reference.txt" (etc-path)))
	  (dat (merge-pathnames "reference.dat" (etc-path)))
	  ;; ���̐��K�\���Ƀ}�b�`���Ȃ��v�f�̓X�L�b�v
	  (reg ".*\\[    section\\]:.*")
	  ;(reg ".*\\(\\[    section\\]:\\|Copyright (c)\\).*")  ; �Ȃ�̃��C�Z���X���킩��Ȃ��Ȃ�B�Q�_
	  (bufname "*reference.dat*")
	  buf)
      (when (file-exist-p txt)
	;; ��Ɨp�o�b�t�@�ƃf�[�^�̏���
	(setq buf (create-new-buffer bufname))
	(set-buffer buf)
	(insert-file-contents txt t)
	;; �f�[�^�ϊ��J�n
	(while (scan-buffer "^��" :regexp t :no-dup t)
	  (save-excursion
	    (save-restriction
	      (narrow-to-region (point)
				(progn
				  (or (scan-buffer "^��" :regexp t :tail nil :no-dup t)
				      (goto-char (point-max)))
				  (forward-char -1)
				  (point)))
	      (goto-char (point-min))
	      ;; section �w��̂Ȃ��v�f�̓X�L�b�v
	      (if (string-match reg (buffer-substring (point-min) (point-max)))
		  (replace-buffer "\n" "\t" :regexp t)
		(delete-region (point-min) (point-max))))))
	;; �o�b�t�@�擪����ŏ��̃Z�N�V�����܂ł��폜
	(goto-char (point-min))
	(delete-region (point)
		       (progn
			 (scan-buffer "^��" :regexp t)
			 (point)))
	;; ���s�����̍s���폜
	(replace-buffer "^\n" "" :regexp t)
	;; dat �t�@�C��������Αޔ�����
	(when (or (not (file-exist-p dat))
		  (copy-file dat (concat dat ".bak")
			     :if-exists :overwrite
			     :if-access-denied :error)
		  ;(yes-or-no-p "~A ���㏑�����ėǂ��ł����H" dat)
		  )
	  (write-file dat))
	(delete-buffer buf)))))

(defun ese-fortune-fortune2dat ()
  "ese-fortune: fortune�p�f�[�^�t�@�C����ese-fortune�p�f�[�^�t�@�C���ɕϊ�"
  (interactive)
  (let ((bufname "*ese-fortune-fortune2dat*")
	buf src dat defdatname
	)
    (setq src (file-name-dialog
	       :title "�ϊ����t�@�C���̎w�� (fortune�p�f�[�^�t�@�C��)"
	       :multiple nil
	       :must-exist t
	       :filter '(("���ׂẴt�@�C��(*.*)" . "*.*"))))
    (when (and src (file-exist-p src))
      (setq defdatname (merge-pathnames (concat (pathname-name src) ".dat") (etc-path)))
      (setq dat (file-name-dialog
		 :title "�ϊ���t�@�C���̎w�� (ese-fortune�p�f�[�^�t�@�C��)"
		 :default defdatname
		 :multiple nil
		 :filter '(("dat�t�@�C��(*.dat)" . "*.dat")
			   ("���ׂẴt�@�C��(*.*)" . "*.*"))))
      (when dat
	;; ��Ɨp�o�b�t�@�ƃf�[�^�̏���
	(setq buf (create-new-buffer bufname))
	(set-buffer buf)
	(insert-file-contents src)
	;; �f�[�^�ϊ�
	(ese-fortune-make-dat "^%\n")
	;; dat �t�@�C��������Αޔ�����
	(when (file-exist-p dat)
	  (copy-file dat (concat dat ".bak")
		     :if-exists :overwrite
		     :if-access-denied :error))
	;; �t�@�C���ɏ�������
	(write-region (point-min) (point-max) dat)
	(delete-buffer buf)
	;; �m�F�p�ɍ쐬����dat�t�@�C�����J��
	(find-file dat)))))

;;; �\�[�X�f�[�^���� ese-fortune �p�f�[�^��K���ɍ쐬
;;;   �����Ƃ��āC�f�[�^��؂��\�����K�\�����w�肷��
(defun ese-fortune-make-dat (reg &optional br)
  (let ((brtag "<ese-fortune-br>"))                    ; �����s��\��������
    (untabify (point-min) (point-max))                 ; 1. TAB�����𔼊p�X�y�[�X�ɒu��
    (goto-char 0) (replace-buffer reg brtag :regexp t) ; 2. �w�肳�ꂽ���K�\�������������s�ɒu��
    (goto-char 0) (replace-buffer "\n" "\t")           ; 3. ���s���^�u�ɒu��
    (goto-char 0) (replace-buffer brtag (or br "\n"))  ; 4. �����s�����s�ɒu��
    (goto-char 0) (replace-buffer "^\n" "" :regexp t)  ; 5. ���s�����̍s���폜
    (goto-char (point-max)) (insert #\LFD)             ; 6. �����ɉ��s��������
    ))

;;; ese-fortune.l ends here.