;;; -*- Mode: Lisp; Package: USER; Last modified: "2010/04/14 07:34:47" -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   OutlineX --- �ȈՃA�E�g���C��
;;;
;;;     by HIE Masahiro <madoinux@gmail.com>
#|

���T�v

  �o�b�t�@����w�肵���p�^�[���Ƀ}�b�`����s�𒊏o���܂��B


���C���X�g�[��

  1. outlinex.l �� site-lisp �ɃR�s�[����B

  2. �K�v�ɉ����C�o�C�g�R���p�C������B

       M-x byte-compile-file

  3. .xyzzy �� siteinit.l �Ɉȉ��̋L�q��ǉ�����B

      (require "outlinex")

  4. xyzzy ���ċN�����C�ݒ�𔽉f������B
     siteinit.l �ɋL�q�����ꍇ�͍ă_���v������B


���N�����@

    M-x olx           : ���K�\�����w�肵�Ď��s

    M-x olx-selection : �Z���N�V�����̕�������L�[�Ƃ��Ď��s
                        ���K�\��OFF�Ŏ��s���܂��B

    M-x olx-flex      : ���K�\������l���g���Ď��s
                        ���[�J���ϐ� olx-pattern �ɐݒ肳�ꂽ���K�\���Ŏ��s���܂��B
                        ���[�h���Ɋ���l��ݒ肷��Ȃǂ��Ďg���܂��B(�ݒ��Q��)

    M-x olx-reload    : �O��̌����p�^�[���ōēx���s
                        outlinex �o�b�t�@�����݂��Ă��違outlinex �o�b�t�@���A�N�e�B�u
                        �łȂ��ꍇ�Ɏ��s����ƁCoutlinex �o�b�t�@���X�V���܂��B

    M-x olx-dialog    : �_�C�A���O����p�^�[�����w�肵�Ď��s
                        �P��P�ʌ����C�啶����������ʁC�������@���w�肷��ꍇ�́C
                        ���̃R�}���h�ŁB


���L�[�o�C���h

  �A�E�g���C���o�b�t�@�ɂ�����L�[�o�C���h�́C�ȉ��̂Ƃ���B

    q   : �I��
    TAB : �J�[�\���ʒu�̃m�[�h���{��
    SPC : �J�[�\���ʒu�̃m�[�h�Ɉړ�
    RET : �J�[�\���ʒu�̃m�[�h�Ɉړ����I��

    M-Up       : ��������X�N���[��
    M-Down     : ���������X�N���[��

    d : �폜�}�[�N������i�\�[�X�o�b�t�@�͕ҏW���܂���j
    m : �}�[�N������i���F���邾���j
    p : ���ݍs���|�b�v�A�b�v�\��
    t : �|�b�v�A�b�v�\�����g�O��
    u : �}�[�N���O��
    U : �S�Ẵ}�[�N���O��
    x : �}�[�N�����s
    e : �s�ԍ����폜


���ݒ��

  ��F3 �n��L�ݒ��

    ;;; �Z���N�V�����̕�������L�[�Ƃ��Ď��s (�񐳋K�\��)
    (global-set-key #\F3 'olx-selection)
    (set-function-bar-label #\F3 "olx-select")

    ;;; ���K�\�����w�肵�Ď��s
    (global-set-key #\S-F3 'olx)
    (set-function-bar-label #\S-F3 "olx")

    ;;; ���[�J���Ȑ��K�\�����g���Ď��s
    (global-set-key #\S-C-F3 'olx-flex)
    (set-function-bar-label #\S-C-F3 "olx-flex")

    ;;; �O��̌����p�^�[���ōēx���s (or olx-rerun)
    (global-set-key #\M-F3 'olx-reload)
    (set-function-bar-label #\M-F3 "olx-reload")

    ;;; �_�C�A���O����p�^�[�����w�肵�Ď��s
    (global-set-key #\C-F3 'olx-dialog)
    (set-function-bar-label #\C-F3 "olx-dialog")

  ������l�̕ύX

    ;;; �����p�^�[���̊���l
    (setq-default olx-pattern "[��������������]")

    ;;; �c�ɕ�������
    (setq-default olx-vert-p t)

    ;;; �s�ԍ��̕\���F
    (setq *olx-color-line-number* '(:color 6 9))

  �����[�h���̌����p�^�[����ݒ��

    ;;; lisp-mode
    (add-hook '*lisp-mode-hook*
              #'(lambda ()
                  (setq olx-pattern "^\\(;;;\\|(def\\)")
                  (setq olx-vert-p t)))

    ;;; html-mode
    (add-hook 'ed::*html-mode-hook*
              #'(lambda ()
                  (setq olx-pattern "\\(<title\\|<h[0-4]\\)\\(>\\| +.*?>\\)")
                  (setq olx-coloring nil)))

  ��<strike>���D���ȕ�</strike>psearch���D�Ҍ���

    ;;; psearch �̂悤�ȐF�t��������
    (setq *olx-coloring-like-psearch* t)

    ;;; psearch �̂悤�ȐF�t���������ꍇ�̐F�ݒ�
    (setq *olx-attribute-like-psearch* '(:foreground 1 :background 2))

    ;;; psearch �̂悤�ȐF�t�����폜
    (global-set-key '(#\C-c #\F3) 'olx-delete-attributes)

    ;;; ���ȉ��́Cpsearch �����[�h������ɐݒ肷�邱�ƁB��

    ;;; psearch ���s���� olx �̐F������
    (add-hook '*psearch-hook* 'olx-delete-attributes)

    ;;; olx ���s���� psearch �̐F������
    (defun olx-delete-psearch-attributes ()
      "outlinex: psearch �̐F�t�����폜"
      (when (fboundp 'psearch-delete-attributes)
        (psearch-delete-attributes)))
    (add-hook '*olx-pre-hook* 'olx-delete-psearch-attributes)

    ;;; �F�������������� psearch �̐F�t���������ɍ폜
    (defun olx-delete-attributes-with-psearch ()
      "outlinex: olx �� psearch �̐F�t���𓯎��ɍ폜"
      (interactive)
      (olx-delete-attributes)
      (olx-delete-psearch-attributes))
    (global-set-key '(#\C-c #\]) 'olx-delete-attributes-with-psearch)

    ;;; olx-selection �Ń|�C���g�̕�������擾
    (setq *olx-use-psearch-get-string* t)

  �Ƃ��B


���X�V����

  [Version 3.06] 2010-04-14 (��)
  �Eolx-reload �̍ۂɁC�ꍇ�ɂ��\�[�X�o�b�t�@�̃f�[�^���󂵂Ă��܂�
    �s����C�������B(T-T)
  �E���o�Ώۂ��Ȃ������ꍇ�ɁC�A�E�g���C���o�b�t�@���폜���Ȃ��悤�ɂ����B
    (�����[�h���ɒ��o�Ώۂ��Ȃ��ƌ�����������)
  �E�m�[�h�Ɉړ����C�K���\�[�X�o�b�t�@�Ɉړ�����悤�ɁB
  �Eolx-rerun ��ǉ������B�̂� olx-reload �Ɠ����B���݂� olx-reload �Ƃ�
    �Ⴂ�́C���ɃA�E�g���C���o�b�t�@�����݂���ꍇ�ɁC�ǂ��炪�A�N�e�B�u
    �ɂȂ邩�����B
  �E���̑��ׂ��ȏC���B

  [Version 3.05.1] 2010-04-02 (��)
  �Epsearch.l ����Ƀ��[�h����ƁCpsearch-delete-attributes �� export ��
    ���s����s����C������(�͂�)�B 
    olx-delete-psearch-attributes, olx-delete-attributes-with-psearch �́C
    �K�v�ɉ��������ݒ�t�@�C���Őݒ肷��悤�ɁB

  [Version 3.05] 2010-04-01 (��)
  �E�q�b�g���������� point ���O�ɂ����Ȃ��ꍇ�Ƀ��X�g���쐬����
    �Ȃ��s����C�������B
  �E���K�\�����g��Ȃ��ꍇ�Cregexp t �̂܂܎w�蕶����� regexp-quote 
    ���Ď��s���Ă������Cregexp nil �Ŏ��s����悤�ɂ����B
  �E�����̃t���[���Ŏ��s����ƕ\��������Ă��܂��̂ŁC�\�[�X�o�b�t�@����
    �A�E�g���C���o�b�t�@�����悤�ɂ����B
  �Edialogs.l ���� search-dialog �� *search-dialog-template* ��q�؁B
      - �_�C�A���O���猟���I�v�V�������w��ł���悤�ɂ����B
      - �����I�v�V�����́C���ׂăo�b�t�@���[�J���Ȓl�Ƃ��ĕێ�����悤�ɂ����B
  �Epsearch �ɉ��߂Ċ������ꂽ�B
      - �|�C���g�̕�������擾�ł���悤�ɂ����B(�v psearch)
      - �F�t���ł���悤�ɂ����B
          *olx-coloring-like-psearch*, *olx-attribute-like-psearch* �ǉ��B
      - �F�t���폜���l�������B
          *olx-pre-hook*, olx-delete-attributes, olx-delete-psearch-attributes, 
          olx-delete-attributes-with-psearch �ǉ��B
  �E���[�h�s�ɁC�����I�v�V������\������悤�ɂ����B
      [SWRE]������ S or C : �啶�������������
              ���� W      : �P��P�ʂŌ���
              ���� R      : ���K�\��
              ���� E      : �G�X�P�[�v�V�[�P���X�𗝉�
  �Eolx-reload �̋����𑽏��ύX�����B(�A�E�g���C���̍X�V������炵��)
  �E�c�����𕜊�(--)�B���łɁC�|�b�v�A�b�v�\������悤�ɂ����B
      olx-vert-p �ǉ��B
  �E����������� *minibuffer-search-string-history* �ɒǉ�����悤�ɂ����B
  �E�㉺�m�[�h����(olx-transpose-node-up �� olx-transpose-node-down)��p�~�����B
    ����ŁC�\�[�X�o�b�t�@��ҏW���邱�Ƃ͂Ȃ��Ȃ����B
  �Eolx-left-press(�_�u���N���b�N�ŊJ��) �́C�f�t�H���g�ł̓L�[���蓖�Ă����Ȃ�
    �悤�ɂ����B(�}�E�X�I�����ł��Ȃ��Ȃ��Ă��܂��̂�)
  �E���̑��ׂ��ȏC�������B

  [Version 3.04] 2007-12-31 (��)
  �EMIT���C�Z���X�ɂ����B

  [Version 3.03] ���H
  �E�����p�^�[���̐ݒ���@��ύX�����B�ݒ���@�́C�ݒ����Q�l�ɁB�����p
    �^�[���ƒ��F�L���́C�ȉ��̃��[�J���ϐ��Őݒ肷��悤�ɁB
      olx-pattern
      olx-coloring
  �E�ȉ��̕ϐ����폜�����B
      *olx-pattern-default*
      *olx-coloring*
      *olx-coloring-exception-mode*
      *olx-flex-mode-list*
  �E�s�ԍ����폜�ł���悤�ɂ����B(Jump �͂ł��Ȃ��Ȃ�܂�)
  �E�֐� outlinex �� interactive �łȂ������B
  �E�֐� olx-toggle-coloring ���폜�����B

  [Version 3.02] 2005-02-03 (Thu)
  �Egrep ���g�p����ƁC�B���o�b�t�@�ɑ΂��Ď��s�ł��Ȃ��悤�Ȃ̂ŁC���
    �莩�O�ŃA�E�g���C�����쐬����悤�ɂ����B(-.-)
  �Eolx-scroll-up-both-window, olx-scroll-down-both-window �𕜊��B(-.-)

  [Version 3.01] 2004-12-09 (Thu)
  �E�}�[�N���폜�}�[�N�̒��F���@�������ύX�����B

  [Version 3.00] 2004-12-01 (Wed)
  �E�X�N���b�`���珑�������Cxyzzy �̕W���@�\�ł��� grep ���g�p���ăA�E�g
    ���C�����쐬����悤�ɂ����B
  �E���C�Z���X�� NYSL �Ƃ����B
  �E���[�h���̌����p�^�[����ϐ��Ŏw��ł���悤�ɂ����B
  �E�㉺�̃m�[�h�����ւ�����悤�ɂ����B
    �i����i:�\�[�X�o�b�t�@��ҏW���܂��B�j
  �E�}�[�N��t������C�s�폜�Ƃ��ł���悤�ɂ����B
    �i�\�[�X�o�b�t�@�͕ҏW���܂���B�j
  �E���F���Ȃ����[�h�����炩���ߎw�肵�Ă����悤�ɂ����B
  �E�s�ԍ��͏�ɕ\������悤�ɂ����B
  �E���E�ɕ\���ł��Ȃ������B
  �E���v�̂Ȃ������Ȍ����R�}���h���폜�����B
  �E���̑����낢��ȋ@�\�폜���܂ޕύX�B

  [Version 2.02] 2004/03/12 06:25:43 +0900
  �E�s�ԍ��� text-attribute �Ɏ��悤�ɂ����B
  �E�L�[���[�h�̐F�t��������悤�ɂ���(�K��)�B
  �E�m�[�h�ړ����Ƀ}�[�N������悤�ɂ����B���ʐݒ�́u�}�[�N�s�̍s�ԍ��𔽓]�v
    �Ƀ`�F�b�N�����Ă����ƁC�ړ������ꏊ���킩��₷�������B
  �E�s�ԍ���\���ł���悤�ɂ����B�i�A���C�s�ԍ���\������ƁC���[�h�ɂ���Ă�
    �L�[���[�h�̐F�t�����ł��Ȃ��Ȃ���̂�����܂��̂ł������炸�j�B
  �E�\���ʒu��؂�ւ�����悤�ɂ����B
  �Eolx-search �ł́C�L�[���[�h�� regexp-quote ����悤�ɂ����B
  �E�w�b�_�ƃt�b�^���폜�����B
  �E�����Ƀp�^�[����\��������C�R�s�[������ł���悤�ɂ����B
  �E*outlinex-mode-hook* ���쐬�����B
  �E*outlinex-default-size* �� *outlinex-default-height* �� *outlinex-default-width*
    �ɕ������B
  �E*outlinex-colors* �� *outlinex-buffer-colors* �ɕύX�����B
  �E�L�[�o�C���h��ύX�����B�i�����g���ĂȂ����̂��폜���Ă��܂����j�B
  �E�Ȃ�ׂ��]�v�ȏ��������Ȃ��悤�ɁB
  �E����炵���Ƃ��Ɉړ�����̂�������������炵���B
  �E�T���v���������ύX�B
  �E���̑����낢��B

  [Version 2.01] 2003/04/19 13:52:37 +0900
  �Euser �p�b�P�[�W�ɓ��ꂽ�B(__)
  �E�֐��� outlinex �� olx �ɕύX�����B
  �Epsearch.l ���܂˂āColx-search ��ǉ������B
  �E�쐬����Ώۂ��Ȃ��ꍇ�́C�A�E�g���C���E�B���h�E�����Ȃ��悤�ɂ����B
  �E�X�N���[���}�[�W���̊���l�� 2 �ɂ����B
  �E�T���v���� my-outlinex �ɂ�����ƒǉ��B

  [Version 2.00] 2003/01/25 22:02:28 +0900
  �Eoutlinex �p�b�P�[�W�ɓ���Ă݂��B
  �E���[�h���ɏ����𔻒f���邠������폜���C�u�ݒ��v�ɉ����Ă݂��B
  �E�X�N���[���}�[�W����ݒ肵���B
  �E�F�t����ύX�ł���悤�ɂ����B
  �E�p�^�[���Ƀ}�b�`���镶���񂪖��������ꍇ�ɁC�G���[�����������
    ���ɂȂ��Ă����̂��C�������B
  �E�������ɁC�}�b�`���镶���񂪖����ƁC�J�[�\������l�������Ă���
    ���̂��C�������B
  �Eoutlinex-auto, *outlinex-make-and-move* �폜�B
  �E���̑����낢��B

  (snip)

  [Version 1.00] 2002/08/18(��)
  �E���ō쐬�B(�����炭)


�����C�Z���X

  outlinex.l ��MIT���C�Z���X�Ɋ�Â��ė��p�\�ł��B
  <http://www.opensource.org/licenses/mit-license.php>

Copyright (c) 2007-2010 HIE Masahiro

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


���ӎ�

outlinex ���쐬����ɂ�����C�g�킹�Ă�����������C�Q�l�ɂ����Ă�������
���肵�����́B

�E�T�䂳��� xyzzy (dialogs.l)
    http://www.jsdlab.co.jp/~kei/xyzzy/

�E�ӂ�������� psearch
    http://www5e.biglobe.ne.jp/~fukafuka/xyzzy/script/

���ӂł��B

|#

(provide "outlinex")

(defconstant *olx-version* "3.06")


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �ϐ��ݒ� - �K���ɃJ�X�^�}�C�Y���邠����
;;; ������������������������������������������������������������������������ ;;;

(defvar-local olx-pattern
	      "^[ �@\t]*\\(\\[\\|[�y����������]\\|[0-9A-Za-z]+[.)] \\|[0-9]+-[0-9]+\\. \\)"
	      "outlinex: �����p�^�[���̊���l")

(defvar-local olx-coloring t
	      "outlinex: ���F����")

(defvar-local olx-case-fold-search ':smart
	      "outlinex: �啶������������ʂ���")

(defvar-local olx-word-search nil
	      "outlinex: �P��P�ʂŌ�������")

(defvar-local olx-vert-p t
	      "outlinex: �c�ɕ�������")

(defvar-local olx-num-of-rows 35
	      "outlinex: �c�ɕ��������ۂ̕\����
  - �u15 �` (xyzzy�̃E�B���h�E�S�̂̕�-15)�v�̊ԂŎw��")

(defvar *olx-color-buffer* nil
  "outlinex: �o�b�t�@�̐F
  - BGR��\�����l���x�N�^�Ŏw�� (set-buffer-colors �ɓn��)
  - #(0 #xe0ffff) �Ƃ�")

(defvar *olx-color-line-number* '(:color 15)
  "outlinex: �s�ԍ��̕\���F")

(defvar *olx-color-delete-line* '(:color 1 11)
  "outlinex: �폜�}�[�N�s�̕\���F")

(defvar *olx-color-mark-line* '(:color 4 11)
  "outlinex: �}�[�N�s�̕\���F")

(defvar *olx-color-point-line* '(:color 4 15)
  "outlinex: �|�C���g�s�̕\���F")

(defvar *olx-recenter-arg* 2
  "outlinex: �m�[�h�ړ����̕\���ʒu(�s��)")

(defvar *olx-use-psearch-get-string* nil
  "outlinex: psearch�Ń|�C���g�̕�������擾")

(defvar *olx-coloring-like-psearch* nil
  "outlinex: �\�[�X�o�b�t�@��psearch�̂悤�ȐF�t��������")

(defvar *olx-attribute-like-psearch* '(:foreground 6 :background 15)
  "outlinex: �\�[�X�o�b�t�@�ւ̐F�t�����̑���")

;;; ������������������������������������������������������������������������ ;;;
;;;  �� �ϐ��ݒ� - ���܂肳���Ȃ��ėǂ�����
;;; ������������������������������������������������������������������������ ;;;

(defvar-local olx-buffer-name nil)

(defvar-local olx-last-search-pattern ""
	      "outlinex: �Ō�̌����p�^�[��")

(defvar-local olx-last-search-pattern-pair nil
	      "outlinex: �G�X�P�[�v�V�[�P���X�𗝉�����ꍇ�̍Ō�̌����p�^�[��")

(defvar-local olx-last-search-regexp-p t
	      "outlinex: �Ō�̌��������K�\�����ǂ���")

(defvar-local olx-understand-escape-sequences nil
	      "outlinex: �G�X�P�[�v�V�[�P���X�𗝉�����")

(defvar-local olx-move-and-popup nil
	      "outlinex: �㉺�ړ����Ƀ|�b�v�A�b�v")

(defvar *olx-buffer-prefix* " *olx*-"
  "outlinex: �A�E�g���C���o�b�t�@���ړ���")

(defvar *olx-src-conf* nil
  "outlinex: ���s���̃E�B���h�E�̐����o�b�t�@")

(defvar *olx-mark-char-list*
  '((#\M #\P #\+)   (#\D #\P #\-)
    (#\+ #\: #\P)   (#\- #\: #\P)   (#\P #\: #\SPC)
    (#\P #\c #\:)   (#\+ #\c #\M)   (#\- #\c #\D)
    (#\: #\c #\SPC) (#\M #\c #\SPC) (#\D #\c #\SPC)
    )
  "outlinex: �}�[�N�����̑g����
  - ex. (#\M #\P #\+)
    ���ݍs�� M �̏ꍇ�� P ���w�肳���� + �ɕύX����B
  - #\SPC �͕ύX���Ȃ��ꍇ�B")

(defvar *outlinex-mode-map* nil
  "outlinex: �A�E�g���C���o�b�t�@�p�L�[�}�b�v")

(defvar *olx-pre-hook* nil
  "outlinex: �A�E�g���C�������O����")

(defvar *olx-hook* nil
  "outlinex: �A�E�g���C�������㏈��")


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �A�E�g���C���쐬
;;; ������������������������������������������������������������������������ ;;;

(defun olx (pattern)
  "outlinex: ���K�\�����w�肵�ăA�E�g���C�����쐬"
  (interactive "solx(regexp): " :default0 olx-pattern :history0 'ed::search)
  (olx-exec pattern t olx-coloring))

(defun olx-selection ()
  "outlinex: �Z���N�V�����̕�����ŃA�E�g���C�����쐬
  - �Z���N�V�������Ȃ��ꍇ�͖₢���킹�܂��B
  - psearch ���g���ƁC�|�C���g�̕�������擾���܂��B
  - ���K�\���͎g�p���܂���B"
  (interactive)
  (let ((pattern (cond ((eq (get-selection-type) 2)
			(buffer-substring (selection-mark)
					  (selection-point)))
		       ((and *olx-use-psearch-get-string*
			     (fboundp 'ed::psearch-get-string))
			(ed::psearch-get-string))
		       (t (read-string "olx(non-regexp): " :history 'ed::search)))))
    (unless (string= pattern "")
      (olx-exec pattern nil olx-coloring))))

(defun olx-flex ()
  "outlinex: ���[�h���ɓo�^���ꂽ���K�\���ŃA�E�g���C�����쐬"
  (interactive)
  (olx-exec olx-pattern t olx-coloring))

(defun olx-reload (&optional active-olx-buffer)
  "outlinex: �O��̌����p�^�[���ōēx�A�E�g���C�����쐬
  - ���ɃA�E�g���C�������݂��Ă��違�A�E�g���C���o�b�t�@���A�N�e�B�u�łȂ�
    (�Ƒz�������)�ꍇ�́C�A�E�g���C�����X�V����B(�蔲��)"
  (interactive)
  (unless olx-buffer-name
    (plain-error))
  (let* ((olx-buf (find-buffer olx-buffer-name))
	 (olx-buf-p (eq buffer-mode 'outlinex-mode))
	 (olx-p (and olx-buf
		     (not olx-buf-p)
		     (> (count-windows) 1)))
	 res)
    (when olx-buf-p
      (plain-error))
    (setq res (olx-exec olx-last-search-pattern olx-last-search-regexp-p olx-coloring))
    (when (and res olx-p)
      (recenter)
      (unless active-olx-buffer
	(olx-mark-point)
	(other-window -1)))))

(defun olx-rerun ()
  "outlinex: �O��̌����p�^�[���ōēx�A�E�g���C�����쐬
  - �����[�h���s��C�A�E�g���C���o�b�t�@���A�N�e�B�u�ɂ��Ă����B"
  (interactive)
  (olx-reload t))

(defun olx-exec (pattern regexp &optional coloring)
  "outlinex: �A�E�g���C�����쐬"
  (long-operation
    (run-hooks '*olx-pre-hook*)
    (when *olx-coloring-like-psearch*
      (delete-text-attributes 'olx))
    (let ((num-of-windows (count-windows))
	  (start-line (current-line-number))
	  (src-keyword-hash-table keyword-hash-table)
	  (src-syntax-table (syntax-table))
	  (src-regexp-keyword-list regexp-keyword-list)
	  (lines 0)
	  (match-p nil)
	  (olx-line nil)
	  (case-fold olx-case-fold-search)
	  (word-search olx-word-search)
	  (understand-escape olx-understand-escape-sequences)
	  (src-buffer (selected-buffer))
	  olx-buffer
	  )
      (setf olx-buffer-name (concat *olx-buffer-prefix* (buffer-name src-buffer)))
      ;; ���s���̏�Ԃ��L�� (count-window �� buffer)
      (unless (find-buffer olx-buffer-name)
	(setf *olx-src-conf* nil)
	(push num-of-windows *olx-src-conf*)
	(when (> num-of-windows 1)
	  (save-excursion
	    (other-window 1)
	    (setf *olx-src-conf*
		  (reverse (push src-buffer *olx-src-conf*)))
	    (other-window -1))))
      ;; �����p�^�[�����L��
      ;; �_�C�A���O�ȊO�̃R�}���h�ł��g�p����ϐ��͂����ŋL��
      (add-history pattern '*minibuffer-search-string-history*)
      (setf olx-last-search-regexp-p regexp)
      (setf olx-last-search-pattern pattern)
      ;; olx �o�b�t�@���쐬
      (save-excursion
	(setf olx-buffer (switch-to-buffer olx-buffer-name))
	(setf buffer-read-only nil)
	(erase-buffer olx-buffer))
      ;; �������s
      (save-excursion
	(goto-char (point-min))
	(with-output-to-buffer (olx-buffer)
	  (while (scan-buffer (if regexp (compile-regexp pattern) pattern)
			      :regexp regexp
			      :no-dup nil
			      :case-fold   case-fold
			      :left-bound  word-search
			      :right-bound word-search
			      )
	    (setf match-p t)
	    (let ((match-line (current-line-number)))
	      (format t "~6,' D:~A~%"
		      match-line (buffer-substring (progn (goto-eol)(point))
						   (progn (goto-bol)(point))))
	      (setf lines (1+ lines))
	      (message "scanning ... ~D" (current-line-number))
	      (unless olx-line
		(setf olx-line (cond ((= match-line start-line) lines)
				     ((> match-line start-line) (1- lines))))))
	    (when *olx-coloring-like-psearch*
	      (apply #'set-text-attribute
		     (match-beginning 0)
		     (match-end 0)
		     'olx *olx-attribute-like-psearch*))
	    (or (next-line)
		(return)))))
      ;; �������o�ł��Ȃ������ꍇ
      (unless match-p
	;(delete-buffer olx-buffer)
	(message (concat "\"" pattern "\" �͌�����Ȃ�"))
	(return-from olx-exec nil))
      ;; �E�B���h�E����
      (if olx-vert-p
	  (pop-to-buffer olx-buffer olx-num-of-rows t)
	(pop-to-buffer olx-buffer t))
      (outlinex-mode pattern regexp coloring
		     src-keyword-hash-table
		     src-regexp-keyword-list
		     src-syntax-table
		     case-fold
		     word-search
		     understand-escape
		     )
      ;; ����炵���ʒu�Ɉړ�
      (goto-line (or olx-line (point-max)))
      (refresh-screen)
      (recenter)
      (message "~D lines completed." lines)
      (run-hooks '*olx-hook*)))
  t)


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �F�t���폜
;;; ������������������������������������������������������������������������ ;;;

(defun olx-delete-attributes ()
  "outlinex: �F������"
  (interactive)
  (delete-text-attributes 'olx))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� outlinex-mode
;;; ������������������������������������������������������������������������ ;;;

(unless *outlinex-mode-map*
  (setf *outlinex-mode-map* (make-sparse-keymap))
  (define-key *outlinex-mode-map* #\TAB 'olx-view)
  (define-key *outlinex-mode-map* #\SPC 'olx-jump-and-mark)
  (define-key *outlinex-mode-map* #\RET 'olx-jump-and-quit)
  (define-key *outlinex-mode-map* #\M-Up 'olx-scroll-down-both-window)
  (define-key *outlinex-mode-map* #\M-Down 'olx-scroll-up-both-window)
  ;(define-key *outlinex-mode-map* #\LBtnUp 'olx-left-press)
  (define-key *outlinex-mode-map* #\d 'olx-mark-delete)
  (define-key *outlinex-mode-map* #\m 'olx-mark)
  (define-key *outlinex-mode-map* #\u 'olx-unmark)
  (define-key *outlinex-mode-map* #\U 'olx-unmark-all)
  (define-key *outlinex-mode-map* #\x 'olx-mark-execute)
  (define-key *outlinex-mode-map* #\e 'olx-erase-line-number)
  (define-key *outlinex-mode-map* #\p 'olx-popup-line)
  (define-key *outlinex-mode-map* #\t 'olx-toggle-move-and-popup)
  (define-key *outlinex-mode-map* #\Up 'olx-previous-line)
  (define-key *outlinex-mode-map* #\Down 'olx-next-line)
  (define-key *outlinex-mode-map* #\q 'olx-quit))

(defun outlinex-mode (pattern
		      regexp
		      coloring
		      src-keyword-hash-table
		      src-regexp-keyword-list
		      src-syntax-table
		      case-fold
		      word-search
		      understand-escape)
  "outlinex: �A�E�g���C���\���p���[�h"
  (kill-all-local-variables)
  (setf buffer-mode 'outlinex-mode)
  (setf mode-name "OutlineX")
  (use-keymap *outlinex-mode-map*)
  (setf buffer-read-only t)
  (setf ed::*paren-status* nil)
  ;; �\�[�X�o�b�t�@�̃��[�h�Œ��F
  (when coloring
    (when src-keyword-hash-table
      (make-local-variable 'keyword-hash-table)
      (setf keyword-hash-table src-keyword-hash-table))
    (when src-syntax-table
      (use-syntax-table src-syntax-table)))
  (make-local-variable 'regexp-keyword-list)
  (let ((olx-regexp-keyword-list
	 (compile-regexp-keyword-list
	  `(("^ *[0-9]+:" t ,*olx-color-line-number*)
	    ("^\\( *[0-9]+D\\)\\(.*\\)" t ((1 . ,*olx-color-delete-line*)
					   (2 . ,*olx-color-delete-line*)))
	    ("^\\( *[0-9]+M\\)\\(.*\\)" t ((1 . ,*olx-color-mark-line*)
					   (2 . ,*olx-color-mark-line*)))
	    ("^\\( *[0-9]+[P+-]\\)\\(.*\\)" t ((1 . ,*olx-color-point-line*)
					       (2 . ,*olx-color-point-line*)))
	    ))))
    (setf regexp-keyword-list (if (and coloring src-regexp-keyword-list)
				  (append src-regexp-keyword-list olx-regexp-keyword-list)
				olx-regexp-keyword-list)))
  (make-local-variable 'mode-line-format)
  (setf mode-line-format
	(format nil "--%*- %M version ~A [%k:%l] %P [~A~A~A~A] pattern:\"~A\""
		*olx-version*
		(cond ((equal case-fold ':smart) "S")
		      ((not case-fold) "C")
		      (t "-"))
		(if word-search "W" "-")
		(if regexp "R" "-")
		(if understand-escape "E" "-")
		pattern))
  ;; �o�b�t�@�̏�Ԃ𒲐�
  (let ((buf (selected-buffer)))
    (set-local-window-flags buf *window-flag-line-number* nil)
    (set-local-window-flags buf *window-flag-cursor-line* t)
    (set-buffer-fold-width nil buf)
    (set-buffer-modified-p nil buf)
    (set-buffer-colors *olx-color-buffer* buf)))

(defun olx-view ()
  "outlinex: �m�[�h��\��"
  (interactive)
  (olx-jump t))

(defun olx-jump (&optional view mark)
  "outlinex: �m�[�h�Ɉړ�"
  (interactive)
  (unless (eq buffer-mode 'outlinex-mode)
    (return-from olx-jump nil))
  (when mark
    (olx-mark-point))
  (let* ((num (if (eobp)
		  -1
		(olx-line-number)))
	 (src-buffer-name (substitute-string
			   (buffer-name (selected-buffer))
			   (regexp-quote *olx-buffer-prefix*)
			   ""))
	 (src-buffer (find-buffer src-buffer-name)))
    (unless src-buffer
      (msgbox "~A ���Ȃ����" src-buffer-name)
      (return-from olx-jump nil))
    (when (and num (other-window -1))
      (set-buffer src-buffer)
      (if (= num -1)
	  (progn
	    (goto-char (point-max))
	    (goto-bol))
	(goto-line num))
      (set-mark)
      (recenter *olx-recenter-arg*)
      (when view
	(other-window)))))

(defun olx-jump-and-mark ()
  "outlinex: �m�[�h�Ɉړ����}�[�N"
  (interactive)
  (olx-jump nil t))

(defun olx-quit ()
  "outlinex: �I��"
  (interactive)
  (when (eq buffer-mode 'outlinex-mode)
    (close-selected-buffer)
    (let ((c (first  *olx-src-conf*))
	  (b (second *olx-src-conf*)))
      (if (and (> c 1)
	       (= c (count-windows)))
	  (progn
	    (set-buffer b)
	    (other-window -1))
	(if (> (count-windows) 1)
	    (delete-window))))))

(defun olx-jump-and-quit ()
  "outlinex: �m�[�h�Ɉړ����I��"
  (interactive)
  (olx-view)
  (olx-quit))

(defun olx-left-press ()
  "outlinex: �_�u���N���b�N�ŊJ��"
  (interactive)
  (let ((click (mod *last-mouse-click-count* 6)))
    (if (= click 2)
	(olx-jump-and-quit)
      (mouse-left-press))))

(defun olx-scroll-up-both-window ()
  "outlinex: ��������X�N���[��"
  (interactive)
  (next-line)
  (olx-view))

(defun olx-scroll-down-both-window ()
  "outlinex: ���������X�N���[��"
  (interactive)
  (previous-line)
  (olx-view))

(defun olx-erase-line-number ()
  "outlinex: �s�ԍ����폜"
  (interactive)
  (when (and (eq buffer-mode 'outlinex-mode)
	     (yes-or-no-p "�s�ԍ����폜���܂��́H"))
    (save-excursion
      (setf buffer-read-only nil)
      (kill-rectangle (progn
			(goto-char (point-min))
			(point))
		      (progn
			(goto-char (point-max))
			(previous-line)
			(scan-buffer ":" :tail t)
			(point)))
      (setf buffer-read-only t))))

(defun olx-toggle-move-and-popup ()
  "outlinex: �㉺�ړ����Ƀ|�b�v�A�b�v���g�O��"
  (interactive)
  (unless olx-move-and-popup
    (olx-popup-line))
  (setf olx-move-and-popup (not olx-move-and-popup)))

(defun olx-popup-line ()
  "outlinex: ���ݍs�̕�������|�b�v�A�b�v�\��"
  (interactive)
  (save-excursion
    (let ((p (point))
	  (s (buffer-substring
	      (progn (goto-bol) (forward-char 7) (point))
	      (progn (goto-eol) (point)))))
      (popup-string (string-left-trim " \t" s) p))))

(defun olx-next-line (&optional previous)
  "outlinex: ���s�Ɉړ����s�̕�������|�b�v�A�b�v�\��"
  (interactive)
  (if previous
      (previous-line)
    (next-line))
  (when olx-move-and-popup
    (olx-popup-line)))

(defun olx-previous-line ()
  "outlinex: �O�s�Ɉړ����s�̕�������|�b�v�A�b�v�\��"
  (interactive)
  (olx-next-line t))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �܁[��
;;; ������������������������������������������������������������������������ ;;;

(defun olx-mark (&optional (c #\M) no-move)
  "outlinex: �}�[�N������
  - 1�s�ŕ\�����Ă��邽�ߐؑւ��ʓ|�ȁB
  - M: �}�[�N
  - D: �폜�}�[�N
  - P: olx-jump�����s
  - +: M + P
  - -: D + P"
  (interactive)
  (when (or (not (eq buffer-mode 'outlinex-mode))
	    (get-buffer-file-name))
    (plain-error))
  (goto-column 1)
  (when (eobp)
    ;(plain-error "����܂���")
    (return-from olx-mark nil))
  (scan-buffer "[:DMP+-]" :regexp t)
  (let ((buffer-read-only nil)
	(a (char-after (point)))
	cc)
    (declare (special buffer-read-only))
    (setf cc (dolist (x *olx-mark-char-list*)
	       (when (and (char= (first x) a)
			  (char= (second x) c))
		 (return (third x)))))
    (cond (;�}�[�N�̕ύX�����Ȃ�
	   (and cc (char= cc #\SPC))
	   (insert cc)
	   (backward-char))
	  (;�ϊ���̃}�[�N�ɕύX
	   cc (insert cc))
	  (;�w�肳�ꂽ�}�[�N�ɕύX
	   t  (insert c)))
    (delete-char 1)
    (set-buffer-modified-p nil))
  (unless no-move
    (forward-line 1)))

(defun olx-mark-point ()
  "outlinex: �|�C���g�s(�W�����v����s)�Ƀ}�[�N������"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (not (eobp))
      (olx-mark #\c)))
  (olx-mark #\P t))

(defun olx-mark-delete ()
  "outlinex: �폜����s�Ƀ}�[�N������"
  (interactive)
  (olx-mark #\D))

(defun olx-unmark ()
  "outlinex: �}�[�N���O��"
  (interactive)
  (olx-mark #\:))

(defun olx-unmark-all ()
  "outlinex: ����Ԃ̃}�[�N���O��"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (not (eobp))
      (olx-unmark))))

(defun olx-mark-execute ()
  "outlinex: �}�[�N�����s
  - �폜�}�[�N�̕t�����A�E�g���C���s���폜����B
    �����o�b�t�@�͍폜����܂���B"
  (interactive)
  (goto-char (point-min))
  (let ((buffer-read-only nil))
    (declare (special buffer-read-only))
    (while (scan-buffer "^ *[0-9]+D.*" :regexp t)
      (delete-region (point) (progn (next-line) (point))))
    (set-buffer-modified-p nil))
  (goto-char (point-min)))


;;; ������������������������������������������������������������������������ ;;;
;;;  �� �⏕�֐�
;;; ������������������������������������������������������������������������ ;;;

(defun olx-line-number ()
  "outlinex: �J�[�\���ʒu�̃m�[�h�̍s�ԍ����擾"
  (save-excursion
    (goto-bol)
    (if (looking-at "^ *\\([0-9]+\\)[:DMP+-]")
	(parse-integer
	 (string-left-trim
	  " "
	  (buffer-substring (match-beginning 1) (match-end 1))))
      0)))

;;; ������������������������������������������������������������������������ ;;;
;;;  �� �_�C�A���O
;;; ������������������������������������������������������������������������ ;;;

(defvar *olx-dialog-template*
  '(dialog 0 0 242 114
    (:caption "OutlineX")
    (:font 9 "MS UI Gothic")
    (:control
     (:static nil "����(&S):" #x50020000 7 10 28 8)
     (:combobox search nil #x50210842 39 8 140 96)
     (:button case-fold "�啶������������ʂ���(&C)" #x50010006 39 27 96 10)
     (:button word "�P��P�ʂŌ�������(&W)" #x50010003 39 40 83 10)
     (:button regexp "���K�\��(&E)" #x50010003 39 53 52 10)
     (:button escseq "�G�X�P�[�v�V�[�P���X�𗝉�����(&Y)" #x50010003 39 66 107 10)
     (:button vert-p "�c�ɕ���(&V)" #x50010003 39 79 107 10)
     (:static nil "��(&L):" #x50020000 7 96 40 8)
     (:edit rows nil #x50810086 39 92 20 14)
     (:button IDOK "���s(&E)" #x50010001 185 7 50 14)
     (:button IDCANCEL "�L�����Z��" #x50010000 185 24 50 14)
     )))

(defun olx-dialog ()
  "outlinex: �_�C�A���O����������w�肵�ăA�E�g���C�����쐬
  - �u�_�C�A���O�Őݒ肳�ꂽ�l�́C���ׂăo�b�t�@���[�J���Ȓl�Ƃ��ĕێ������B"
  (interactive)
  (multiple-value-bind (result data)
      (let ((string (or (selection-start-end (start end)
			  (buffer-substring start end))
			(unless (string= olx-last-search-pattern "")
			  olx-last-search-pattern)
			olx-pattern)))
	(dialog-box *olx-dialog-template*
		    (list (cons 'search *minibuffer-search-string-history*)
			  (cons 'case-fold (ed::cfs2dialog olx-case-fold-search))
			  (cons 'word olx-word-search)
			  (cons 'regexp olx-last-search-regexp-p)
			  (cons 'vert-p olx-vert-p)
			  (cons 'rows (format nil "~A" olx-num-of-rows))
			  (cons 'search (if (eq (cdr olx-last-search-pattern-pair)
						string)
					    (car olx-last-search-pattern-pair)
					  string))
			  )
		    '((word :disable (regexp))
		      (search :non-null "�������������͂���" :enable (IDOK))
		      (vert-p :enable (rows))
		      )))
    (when result
      (let ((string (cdr (assoc 'search data))))
	(when string
	  ;; �_�C�A���O�ł����g�p���Ȃ��ϐ��͂����ŋL��
	  (setf olx-case-fold-search (ed::dialog2cfs (cdr (assoc 'case-fold data))))
	  (setf olx-word-search (cdr (assoc 'word data)))
	  (setf olx-last-search-regexp-p (cdr (assoc 'regexp data)))
	  (setf olx-understand-escape-sequences (cdr (assoc 'escseq data)))
	  (if olx-understand-escape-sequences
	      (setf olx-last-search-pattern-pair
		    (cons string
			  (setf string (decode-escape-sequence
					string olx-last-search-regexp-p))))
	    (setq olx-last-search-pattern-pair nil))
	  (setf olx-vert-p (cdr (assoc 'vert-p data)))
	  (setf olx-num-of-rows (olx-dialog2nor (cdr (assoc 'rows data))))
	  (olx-exec string olx-last-search-regexp-p olx-coloring)
	  )))))

(defun olx-dialog2nor (x)
  "outlinex: �\���񐔎w�莞�̃G���[�`�F�b�N
  - �G���[�ƂȂ肻���Ȓl���w�肳�ꂽ�ꍇ�́C���݂̒l�̂܂܂Ƃ���B
  - 0 ���w�肷��ƁC�����ɕ��������B"
  (let ((rows (ignore-errors (parse-integer x))))
    (if (and rows
	     (or (zerop rows)
		 (and (> rows 14)
		      (< rows (- (screen-width) 15)))))
	rows
      olx-num-of-rows)))


;;; outlinex.l ends here.