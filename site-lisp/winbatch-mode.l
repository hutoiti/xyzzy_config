;;; -*- Mode: Lisp; Package: EDITOR; Last modified: <2007/12/31 01:16:01> -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   winbatch-mode.l --- Simple mode for Batch File Enhancer for Windows (WinBatchEh)
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>
#|

���T�v

  WinBatchEh �p�̃��[�h�B

  OHKUBO Hiroshi ����� bat-mode.l ���x�[�X�� WinBatchEh �p�̉����i
  �������Ă݂��B

  ���� �m������ɂ����낢��ƃA�h�o�C�X�𒸂��܂����B���ӂł��B

  ���̑��A�Q�l�ɂ����Ă������������́B�i�Ƃ��A�قڂ��̂܂܎g�킹��
  �������������́B�j
  
    htmlmode.l
    php-mode.l
    csv-mode.l
    xyzzy ML
    ���̑���R...

  �����̗L�p�ȃR�[�h�����J���Ē����Ă��鏔��y���ɑ��ӁB


���g�p��̒���

  �EWinBatchEh �̎��s�p�X�́A���W�X�g��(�̂��Ԃ�֘A�t���̕���)����
    �擾����悤�ɂ��Ă݂����A�N�����Ȃ��ꍇ����ъ֘A�t���̂��Ă�
    ���ꍇ�́A*winbatch-path* �𒼐ڎw�肵�Ȃ��Ƃ����Ȃ��Ǝv���B
  
      ��: (setq *winbatch-path* "c:/utility/winbatch/")
  
  �E�C�����C���R�����g�ɂ́A// �� # �̂ǂ��炩�����w��ł��Ȃ��B
  
  �E�t���b�O(MB_* �Ƃ�)�̕⊮���ꉞ�ł��邪�A
      MESSAGEBOX=MB_
    �܂ŋL�q���� C-. ���Ă� No match �ɂȂ��Ă��܂��B�������A
      MESSAGEBOX= MB_
    �ȂǂƂ��Ă���(= �̌�ɃX�y�[�X������Ă���)�Ƃł��Ȃ����Ȃ��B
    ���A��ŃX�y�[�X�������Ȃ��Ƃ����Ȃ��̂ŁA��͂�ʓ|�Ȃ̂ł�����
    �������B
  
  �E�R�}���h�̃L�[���[�h�⊮�́A�������ł̂ݗL���B�啶���ł�����
    �ꍇ�́A�L�[���[�h�t�@�C�� (WINBATCH) ���̃L�[���[�h��啶��
    �ɂ���Ηǂ��Ǝv���B�i�t���b�O�Ƃ��͑啶���j
  
  �E�t���b�O�̐F�t���́A�擪�� GCD,MB,OFN,SC,SPI,SPIF,STF,SW,VK,WM + _
    �Ŏn�܂�P��S�Ăɑ΂��čs���Ă���̂ŁA���ۂɂ͑��݂��Ȃ��t���O��
    ���ɂ��F�t�������B
  
  �E���x���ƃR�����g�̐F�����͂��������ł��Ă���B
  
  �EWinBatchEh �̌f���̃A�h���X�́A�T�[�o�̕��׏󋵂Ȃǂɂ��ύX
    ����邱�Ƃ����邻���Ȃ̂ŁA�����N�i���j���[�ɕ\���j�������ꍇ�́A
    ������ *winbatch-forum-url* ��ݒ肷��K�v����B�f�t�H���g�ł́A
    �\�����Ȃ��B
  
  �ELisp �� WinBatchEh ���ǂ�������Ȃ��܂܍���Ă���̂ŁA�������B


���C���X�g�[��

  1. winbatch-mode.l �� ~/site-lisp �ɁAWINBATCH �� ~/etc ��
     �R�s�[����B

  2. �K�v�Ȃ�΃o�C�g�R���p�C������B

  3. *.btw ��ǂ݂��񂾂Ƃ��Ɏ����I�� batch-mode �ɂ��邽�߂ɁA
     �ȉ��̃R�[�h���������t�@�C���ɒǉ�����(���Ԃ�)�B

     �� .xyzzy�ɒǉ�����ꍇ
           (export 'ed::winbatch-mode "ed")
           (autoload 'winbatch-mode "winbatch-mode" t)
           (pushnew '("\\.btw$" . winbatch-mode) *auto-mode-alist* :test 'equal)

     �� siteinit.l�ɒǉ�����ꍇ
           (in-package "editor")
           (export 'winbatch-mode)
           (autoload 'winbatch-mode "winbatch-mode" t)
           (pushnew '("\\.btw$" . winbatch-mode) *auto-mode-alist* :test 'equal)
           (in-package "user")

   4. �⊮���|�b�v�A�b�v�ꗗ�\��������ꍇ�́A�ȉ��̃R�[�h��������
      �t�@�C���ɒǉ�����B

           (setq *popup-completion-list-default* :always)

   5. ��L�̐ݒ�𔽉f�����邽�߂ɁAxyzzy���ċN������B


���g����

  M-x winbatch-mode

  �X�N���v�g�����s�܂��͊J���ꍇ�ɁA�p�����[�^���w�肷��ꍇ�́A
  Parameters: ���ɓ��͂���B�����w�肷��ꍇ�́A���p�X�y�[�X��؂�
  �ŁA���p�X�y�[�X����������������w�肷��ꍇ�́A"" �ł������Ďw��
  ����B�p�����[�^���s�v�ȏꍇ�́A�����͂̂܂� Enter �� OK�B


���L�[�o�C���h

  F1       �w���v������
  C-.      �L�[���[�h�⊮
  C-;      �Z���N�V����������΃Z���N�V�����ɃR�����g�������}���A
           �Ȃ���Ό��ݍs�̃R�����g���g�O��
  M-C-;    �Z���N�V�����̃R�����g��������폜
  C-c x    �X�N���v�g���s
  C-c o    �X�N���v�g�� winbat32.exe �ŊJ��
  C-c c    �t�@�C�������N���b�v�{�[�h�ɃR�s�[���āA�R���p�C�����N��


���ݒ��

  ;; �R�����g������ ("REM " or ":/ ")
  (setq *winbatch-mode-comment-start* ":/ ")
  
  ;; �C�����C���R�����g������ ("//", "#" or nil)
  (setq *winbatch-inlinecomment-string* "#")
  
  ;; �X�N���v�g���s���ȂǂɃt�@�C����ۑ�
  (setq *winbatch-auto-save* nil)
  
  ;; WinBatchEh �f���̃y�[�W�����j���[�ɕ\�� (nil or "url")
  (setq *winbatch-forum-url* "http://hpcgi3.nifty.com/b7/bbs/wforum.cgi")
  
  ;; ���s���O�̍s�ɍ��킹�ăC���f���g
  (setq *winbatch-use-newline-and-indent* t)

  ;; WinBatchEh �X�N���v�g�ۑ��t�H���_�iex: c:\winbatch\data\ �̏ꍇ�j
  (setq *winbatch-script-directory* "c:/winbatch/data/")


���X�V����

  [Version 1.16] 2007-12-31 (��)
  �E���C�Z���X����(MIT���C�Z���X)���L�ځB

  [Version 1.15] 2002/09/21 01:58:52 +0900
  �Ewinbatch-open-filer ��ǉ������B
      primary-directory:   �\�����̃t�@�C���̂���t�H���_
      secondary-directory: *winbatch-script-directory* �Ɏw�肵���t�H���_
    ���Ђ炭�B
  �EWinBatchEh �̃p�X�� local-machine �łȂ� classes-root ����擾
    ����悤�ɂ����B
  �E���̑��ׂ��ȕύX�B
  �E�i����ɁA�͂��߂� list ���g���Ă݂��B�j

  [Version 1.14.1] 2002/09/15 12:06:01 +0900
  �E�⊮�̃|�b�v�A�b�v�ꗗ�\���̐ݒ�́A�K�v�ȕ����݂̂Ƃ���(����)�B

  [Version 1.14] 2002/09/15 00:14:46 +0900
  �EWinBatchEh �������Ă��Ȃ��ƁA�N�����ɃG���[�ɂȂ�̂��C�������B
  �E�⊮�̈ꗗ�\���́A�R�{ �׎O����� Tips ���g���Ă����̂������v
    ���o���A��������ǉ������B

  [Version 1.12] 2002/09/14 09:53:55 +0900
  �E�X�N���v�g�̎��s�A�J�����̈����w��ɁAminibuffer-prompt ���g
    ��Ȃ��悤�ɂ����B
  �E*winbatch-auto-save* �̊���l�� t �ɂ����B
  
  [Version 1.11] 2002/09/12 22:21:07 +0900
  �E���ʂɑ������R�����g��ʃt�@�C���ɂ��č�������B
  �E���̑����ɗ����Ȃ��ύX�B
  
  [Version 1.10] 2002/09/11 23:18:52 +0900
  �E���܂�ɂ� bat-mode �ɐ��܂��Ă��܂����̂ŁAbat-mode ���x�[�X��
    ���ď����������B
  �E*winbatch-regexp-keyword-list* �����������B
  �E�t�@�C�����s���A�ۑ�����ĂȂ��ꍇ�́A�ۑ����邱�Ƃ��ł���悤��
    �����B �� *winbatch-auto-save*
  �Ebatch-mode �� winbatch-mode �ɕύX�����B�i�{���̖ړI�������t�c�[
    ��(?)�o�b�`�t�@�C���Ŏg�p����K�v�������̂Łj�B
  
  [Version 1.09] 2002/09/03 10:36:05 +0900
  �E����ς���f��������Ȃ��̂ŁA�f���̕\���͂������ꍇ�����A��
    ���ł���悤�ɂ����B�� *winbatch-forum-url*
  �E������������J�X�^�}�C�Y���邩������Ȃ�������� export �����B
  
  [Version 1.08] 2002/09/03 06:27:27 +0900
  �E�R�����g������̑}���A�폜�̕��@��ύX�����B�܂��A:/ ���g�p��
    ����悤�ɂ����B
  �E�L�[�o�C���h���W���I(?)�łȂ������̂�ύX�����B
  �E���̑��ׂ��ȕύX����ђ��ӏ����̒ǉ��B
  
  [Version 1.07] 2002/09/02 10:58:10 +0900
  �E�x�[�J�[�X�̕��u(http://members.tripod.co.jp/mystery_trick_room/)
    ���݂āA�ڂ���؁B�w���v�̌���������ȊȒP�ɂł����Ȃ��...�B
  
  [Version 1.06] 2002/09/02(��)
  �Ewinbat32.exe �֓n���t�@�C������"" �ł�����悤�ɂ����B
  �E�R�����g���ƃ��x���s�̐F�t�����@��ύX�����B
  
  [Version 1.05] 2002/09/01(��)
  �E���� �m������ɋ����Ă������������@���g���āAWinBatchHelp.btw
    ���g��Ȃ��Ă��w���v�������ł���悤�ɂȂ����B�iAPI�𒼐ڌĂ�
    �o�����@�ł���΁A������������ WinBatchEh ���g��Ȃ��Ă� xyzzy
    ���璼�ڎ��s�ł���̂��H�j
  
  [Version 1.04] 2002/08/30(��)
  �E���W�X�g������ WinBatchEh �̃C���X�g�[���f�B���N�g�����擾����
    �悤�ɂ����B
  �E�R���p�C�����N���Ƃ��A�f����\���Ƃ������B
  
  [Version 1.03] 2002/08/29(��)
  �Ecsv-mode ���Q�l�ɁA���[�J���ȃ��j���[�������B
  
  [Version 1.02] 2002/08/28(��)
  �Ebat-mode ���� indent ���������������B
    �قƂ�ǁAbat-mode �x�[�X�̉����i�ɂȂ����B
  �Ewinbatch-open-script ��ǉ������B
  �Ebatch-search-help-selection �ɁAwinbat32.exe �܂���
    WinBatchHelp.btw ���Ȃ��ꍇ�̏�����ǉ������B
  �E���̑��ׂ����C���B
  
  [Version 1.01] 2002/08/12(��)
  �Eversion �̓������������� mode-name ����߂��B
  �E�F�t���������炩�ύX����
  
  [Version 1.00] 2002/08/11(��)
  �Ewinbatch-run-script ��ǉ������B
  
  [Version 0.4] 2002/08/10(�y)
  �E:/ ���R�����g������Ƃ��ĔF������悤�ɂ����B
  �Einlinecomment �Ƃ��āA// �� # �̂ǂ��炩���g�p�ł���悤�ɂ����B
    ����l�́A// �B
  
  [Version 0.3] 2002/08/10(�y)
  �Ebatch-encomment-selection, batch-outcomment-selection
    ��ǉ������B
  
  [Version 0.2] 2002/08/08(��)
  �Emy-bat-mode ���� batch-mode �ɕύX�B
  �Esearch-winbatch-help-selection ��ǉ������B�i�v WinBatchEh�j
  �Ebat-mode ����A*bat-regexp-keyword-list* ������𒸂����B
  �Ephp-mode ����A"�L�[���[�h����⊮" �𒸂����B
  �Ehtmlmode.l ����̕s�v�Ǝv���邠������폜�����B
  
  [Version 0.1]
  �Ehtmlmode.l �̃L�[���[�h��`�݂̂�ύX���ĂƂ肠�����������B


�����C�Z���X

  winbatch-mode.l ��MIT���C�Z���X�Ɋ�Â��ė��p�\�ł��B
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

(provide "winbatch-mode")

(in-package "editor")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (export '(*winbatch-mode-hook*
            *winbatch-mode-map*
            *winbatch-mode-version*
            *winbatch-keyword-file*
            *winbatch-keyword-file-use*
            *winbatch-regexp-keyword-list*
            *winbatch-mode-comment-start*
            *winbatch-comment-column*
            *winbatch-mode-abbrev-table*
	    *winbatch-inlinecomment-string*
	    *winbatch-use-newline-and-indent*
	    *winbatch-path*
	    *winbatch-auto-save*
	    *winbatch-home-url*
	    *winbatch-forum-url*
	    )))
(eval-when (:compile-toplevel :load-toplevel :execute)
  (export '(winbatch-mode
            winbatch-indent-line
            winbatch-newline-and-indent
	    winbatch-comment-indent
	    winbatch-completion
	    winbatch-encomment-selection-or-comment-toggle-line
	    winbatch-outcomment-selection
	    winbatch-show-winhelp
	    winbatch-run-script
	    winbatch-open-script
	    winbatch-compile-script
	    )))

(defconstant *winbatch-mode-version* "1.15")

;; �L�[���[�h�t�@�C�����g�p
(defvar *winbatch-keyword-file-use* t)

;; �R�����g������ ("REM " or ":/ ")
(defvar *winbatch-mode-comment-start* "REM ")

;; �C�����C���R�����g������ ("//", "#" or nil)
;;   �g�p���Ȃ��ꍇ�́Anil ��ݒ�
(defvar *winbatch-inlinecomment-string* "//")

;; �X�N���v�g���s���ȂǂɃt�@�C����ۑ�
(defvar *winbatch-auto-save* t)

;; ���s���O�̍s�ɍ��킹�ăC���f���g
(defvar *winbatch-use-newline-and-indent* nil)

;; ���� �m������̂؁[��
(defvar *winbatch-home-url* "http://www.vector.co.jp/authors/VA000007/")

;; WinBatchEh �f���̃y�[�W (nil or "url")
(defvar *winbatch-forum-url* nil)

;; WinBatchEh �̃C���X�g�[���f�B���N�g��
(defvar *winbatch-path*
  (let (list)
    (setq list
	  (let ((result nil))
	    (dolist (item '(".BTW\\shell\\open\\command"
			    "BTW_auto_file\\shell\\open\\command")
			  (nreverse result))
	      (push
	       (let ((p (read-registry item "" :classes-root)))
		 (if p
		     (map-backslash-to-slash
		      (substring p 0 (string-match "[wW][iI][nN][bB][aA][tT]32.[eE][xX][eE]" p)))))
	       result))))
    ;list �����܂������Ȃ�...
    (let ((path1 (car list))
	  (path2 (cadr list)))
      (or path1 path2 ""))))

;; WinBatchEh �X�N���v�g�ۑ��f�B���N�g��
(defvar *winbatch-script-directory* (concat *winbatch-path* "sample/"))

;; winbat32.exe �̃t���p�X
(defvar *winbatch-prog* (merge-pathnames "winbat32.exe" *winbatch-path*))

;; wbatcp.exe �̃t���p�X
(defvar *winbatch-compiler-prog* (merge-pathnames "wbatcp.exe" *winbatch-path*))

;; �w���v�t�@�C���̃t���p�X
(defvar *winbatch-winhelp-file* (merge-pathnames "winbat32.hlp" *winbatch-path*))

;; �F�ݒ�
;�R�����g
(defvar *winbatch-comment-color* '(:keyword :comment))
;���x��
(defvar *winbatch-lavel-color* '(:color 1 0))
;GOTO �̃��x��
(defvar *winbatch-goto-label-color* '(:color 1 0))
;ECHO �{��
(defvar *winbatch-echo-color* '(:color 15 0))
;�G�R�[�}�~
(defvar *winbatch-echo-stop-color* '(:keyword 1))
;���[�v�ϐ�
(defvar *winbatch-loop-variable-color* '(:color 14 0))
;����
(defvar *winbatch-argument-color* '(:color 14 0))
;�ϐ�
(defvar *winbatch-variable-color* '(:color 14 0))
;�ϐ��Q��
(defvar *winbatch-variable-reference-color* '(:color 14 0))
;keyword 0
(defvar *winbatch-keyword0-color* '(:keyword 0))
;keyword 2
(defvar *winbatch-keyword2-color* '(:keyword 2))
;�t���O
(defvar *winbatch-flag-color* '(:color  9 0))

;; startup message
(defvar *winbatch-startup-message* t)

(defvar *winbatch-mode-hook* nil)
(defvar *winbatch-keyword-hash-table* nil)
(defvar *winbatch-keyword-file* "WINBATCH")
(defvar *winbatch-completion-list* nil)

(defvar *winbatch-mode-map* nil)
(unless *winbatch-mode-map*
  (setq *winbatch-mode-map* (make-sparse-keymap))
  (define-key *winbatch-mode-map*   #\F1       'winbatch-show-winhelp)
  (define-key *winbatch-mode-map*   #\TAB      'winbatch-indent-line)
  (if *winbatch-use-newline-and-indent*
      (define-key *winbatch-mode-map* #\RET    'winbatch-newline-and-indent))
  (define-key *winbatch-mode-map*   #\C-.      'winbatch-completion)
  (define-key *winbatch-mode-map*   #\C-\;     'winbatch-encomment-selection-or-comment-toggle-line)
  (define-key *winbatch-mode-map*   #\M-\C-\;  'winbatch-outcomment-selection)
  (define-key *winbatch-mode-map* '(#\C-c #\x) 'winbatch-run-script)
  (define-key *winbatch-mode-map* '(#\C-c #\o) 'winbatch-open-script)
  (define-key *winbatch-mode-map* '(#\C-c #\c) 'winbatch-compile-script)
  (define-key *winbatch-mode-map* '(#\C-c #\f) 'winbatch-open-filer)
  (define-key *winbatch-mode-map* '(#\C-c #\?) 'winbatch-mode-show-version))

(defvar *winbatch-mode-abbrev-table* nil)
(unless *winbatch-mode-abbrev-table*
  (define-abbrev-table '*winbatch-mode-abbrev-table*))

(defvar *winbatch-mode-syntax-table* nil)
(unless *winbatch-mode-syntax-table*
  (setq *winbatch-mode-syntax-table* (make-syntax-table))
  (cond ((string= *winbatch-inlinecomment-string* "//")
	 (progn
	   (set-syntax-start-c++-comment *winbatch-mode-syntax-table* #\/)
	   (set-syntax-end-c++-comment *winbatch-mode-syntax-table* #\LFD)))
	((string= *winbatch-inlinecomment-string* "#")
	 (progn
	   (set-syntax-start-comment *winbatch-mode-syntax-table* #\#)
	   (set-syntax-end-comment *winbatch-mode-syntax-table* #\LFD))))
  (set-syntax-string *winbatch-mode-syntax-table* #\")
  (set-syntax-string *winbatch-mode-syntax-table* #\'))

(defvar *winbatch-regexp-keyword-list* nil)

(setq *winbatch-regexp-keyword-list*
  (compile-regexp-keyword-list
   `(
     ;���x���s
     (,(concat "^[ \t]*\\(:[^/ \t\n]+\\)"
	       "\\(?:[ \t]\\(.*\\)\\)?") t ((1 . ,*winbatch-lavel-color*)
					    (2 . ,*winbatch-comment-color*)))
     ;�G�R�[�}�~
     ("^[ \t]*\\(@\\)" t ((1 . ,*winbatch-echo-stop-color*)))
     ;�R�����g
     ("\\<\\(REM\\)\\>\\(?:[ \t]\\(.*\\)\\)?" t ,*winbatch-comment-color*)
     ;���x���s�Ƀ}�b�`���Ȃ�����:�Ŏn�܂�s�̓R�����g��
     ("^[ \t]*:.*" t ,*winbatch-comment-color*)
     ;����
     ("%[0-9]" nil ,*winbatch-argument-color*)
     ;���[�v�ϐ�
     ("%%[a-zA-Z]" nil ,*winbatch-loop-variable-color*)
     ;�ϐ�
     ("%@*[a-zA-Z][a-zA-Z0-9_]*\\(\\[[0-9]+\\]\\)*%" nil ,*winbatch-variable-reference-color*)
     ;goto, gosub
     (,(concat "\\<\\(GOTO\\|GOSUB\\)\\>"
	       "\\(?:[ \t]+\\([^/ \t\n]+\\)\\)?"
	       "\\(?:[ \t]+\\(.*\\)\\)?") t ((1 . ,*winbatch-keyword0-color*)
					     (2 . ,*winbatch-goto-label-color*)
					     (3 . ,*winbatch-comment-color*)))
     ;echo
     ("\\<\\(ECHO\\)[ \t]+\\(ON\\|OFF\\)[ \t]*$" t ((0 . ,*winbatch-keyword2-color*)))
     (,(concat "\\<\\(ECHO\\.?\\)\\>"
               "\\(?:[ \t]\\(.*\\)\\)?") t ((1 . ,*winbatch-keyword2-color*)
                                            (2 . ,*winbatch-echo-color*)))
     ;set
     ("\\<\\(SET\\)\\(?:[ \t]+\\([^=\n]+\\)\\(?:=\\)?\\)?" t ((1 . ,*winbatch-keyword2-color*)
							      (2 . ,*winbatch-variable-color*)))
     ;�h���C�u�w��
     ("^[ \t]*\\([a-zA-Z]:$\\|[a-zA-Z]: \\)" t ,*winbatch-keyword2-color*)
     ;...
     ("\\(winbat\\(?:32\\|ch\\)\\) *==" t ((1 . ,*winbatch-keyword0-color*)))
     ;�t���O
     ("\\(GCD\\|MB\\|OFN\\|SC\\|SPI\\|SPIF\\|STF\\|SW\\|VK\\|WM\\)_[A-Z]+[0-9]*" t ,*winbatch-flag-color*)
     )))

;; ���[�h�̐ݒ�
(defun winbatch-mode ()
  (interactive)
  (kill-all-local-variables)
  (if *winbatch-startup-message*
      (message "WinBatchEh mode ~A for xyzzy."
	       *winbatch-mode-version*))
  (setq buffer-mode 'winbatch-mode)
  (setq mode-name "WinBatchEh")
  (use-keymap *winbatch-mode-map*)
  (use-syntax-table *winbatch-mode-syntax-table*)

  (make-local-variable 'mode-specific-indent-command)
  (setq mode-specific-indent-command 'winbatch-indent-line)

  (cond
   (*winbatch-keyword-file-use*
    (and *winbatch-keyword-file*
         (null *winbatch-keyword-hash-table*)
         (setq *winbatch-keyword-hash-table*
               (load-keyword-file *winbatch-keyword-file* t)))
    (when *winbatch-keyword-hash-table*
      (make-local-variable 'keyword-hash-table)
      (setq keyword-hash-table *winbatch-keyword-hash-table*)))
   (t
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table '())))

  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *winbatch-regexp-keyword-list*)
  
  (setq *local-abbrev-table* *winbatch-mode-abbrev-table*)
  (winbatch-menu-update)
  (run-hooks '*winbatch-mode-hook*))

(defun winbatch-newline-and-indent (&optional (arg 1))
  "���s�{�C���f���g�t��"
  (interactive "*p")
  (insert #\LFD arg)
  (winbatch-indent-line))

(defun winbatch-indent-line ()
  "���݂̃C���f���g�t��"
  (interactive "*")
  (if (save-excursion
        (skip-chars-backward " \t")
        (bolp))
      (let ((column 0))
        (save-excursion
          (while (forward-line -1)
            (unless (progn
                      (skip-chars-forward " \t")
                      (eolp))
              (skip-chars-forward " \t")
              (setq column (current-column))
              (return))))
        (smart-indentation column)
        (skip-chars-forward " \t"))
    (insert "\t")))

;php-mode ����B
(defun winbatch-completion ()
  "�L�[���[�h����⊮"
  (interactive)
  (or *winbatch-completion-list*
      (setq *winbatch-completion-list* (make-list-from-keyword-table *winbatch-keyword-hash-table*))
      (return-from winbatch-completion nil))
  (let ((opoint (point)))
    (when (skip-syntax-spec-backward "w_.")
      (let ((from (point)))
	(goto-char opoint)
	(do-completion from opoint :list *winbatch-completion-list*)))))

;[xyzzy:06776] ���B
(defun winbatch-encomment-selection-or-comment-toggle-line ()
  "�R�����g�������}���܂��̓g�O��"
  (interactive)
  (if (pre-selection-p)
      ;�Z���N�V����������΁A�I��͈͂̍s���ɃR�����g�������}��
    (let ((from (selection-mark))
	  (to (selection-point)))
      (if (> from to)
	  (rotatef from to))
      (save-excursion
	(save-restriction
	  (narrow-to-region from to)
	  (goto-char from)
	  (insert *winbatch-mode-comment-start*)
	  (while (forward-line 1)
	    (insert *winbatch-mode-comment-start*)))))
    ;�Z���N�V�������Ȃ���΁A�R�����g���g�O��
    (save-excursion
      (let (bol eol)
	(goto-eol)
	(setq eol (point))
	(goto-bol)
	(setq bol (point))
	(if (string-match "^[ \t]*\\(?:[rR][eE][mM]\\|:/\\)\\(?:[ \t]*$\\|[ \t]\\)"
			  (buffer-substring bol eol))
	    (delete-region (+ bol (match-beginning 0)) (+ bol (match-end 0)))
	  (insert *winbatch-mode-comment-start*))))))

;[xyzzy:06789] ���B
(defun winbatch-outcomment-selection ()
  "�I��͈͂̍s������R�����g��������폜"
  (interactive)
  (or (pre-selection-p)
      (error "selection���Ȃ��B"))
  (let ((from (selection-mark))
        (to (selection-point)))
    (if (> from to)
        (rotatef from to))
    (save-excursion
      (save-restriction
        (narrow-to-region from to)
        (goto-char from)
	(replace-buffer (concat "^" *winbatch-mode-comment-start*) "" :regexp t)))))

(defun winbatch-run-script (&optional arg)
  "�X�N���v�g�𑖂点��"
  (interactive "sParameters: ")
  (winbatch-exec "x" arg))

(defun winbatch-open-script (&optional arg)
  "�X�N���v�g���J��"
  (interactive "sParameters: ")
  (winbatch-exec "?" arg))

(defun winbatch-exec (option arg)
  "�X�N���v�g�� WinBatchEh �ɓn��"
  (let (opt)
    (if (equal option "?")
	(setq opt "?")
      (setq opt ""))
    (if (winbatch-prog-p)
	(progn
	  (if (and (buffer-modified-p) *winbatch-auto-save*)
	      (save-buffer-dialog))
	  (if (not (buffer-modified-p))
		(call-process (concat *winbatch-prog* " " opt "\""
				      (map-slash-to-backslash (get-buffer-file-name)) "\" " arg)
			      :wait nil)
	    (message "�ۑ�����ĂȂ��B")))
      (message (concat *winbatch-prog* " ���݂���Ȃ��B")))))

(defun winbatch-compile-script ()
  "�R���p�C���N��"
  (interactive)
  (if (winbatch-compiler-prog-p)
      (progn
	(if (and (buffer-modified-p) *winbatch-auto-save*)
	    (save-buffer-dialog))
	(if (not (buffer-modified-p))
	    (progn
	      (copy-to-clipboard (map-slash-to-backslash (get-buffer-file-name)))
	      (call-process *winbatch-compiler-prog* :wait nil))
	  (message "�ۑ�����ĂȂ��B")))
    (message (concat *winbatch-compiler-prog* " ���݂���Ȃ��B"))))

(defun winbatch-show-winhelp ()
  "�w���v�̌���"
  (interactive)
  (if (winbatch-help-file-p)
      (run-winhelp *winbatch-winhelp-file*
		   (let ((topic (get-winhelp-topic)))
		     (and (not (equal topic "")) topic)))
    (message (concat *winbatch-winhelp-file* " ���݂���Ȃ��B"))))

(defun winbatch-open-filer ()
  "WinBatchEh �p�t�@�C���̋N��"
  (interactive)
  (toggle-ime nil)
  (setq *filer-primary-directory* nil)
  (setq *filer-secondary-directory* *winbatch-script-directory*)
  (multiple-value-bind (files result)
      (filer nil t "WinBatch mode" t)
    (when result
      (dolist (f files t)
	(unless (file-directory-p f)
	  (find-file f)
	  (add-history f '*minibuffer-file-name-history*))))))

(defun winbatch-home ()
  (interactive)
  (shell-execute *winbatch-home-url* t))

(defun winbatch-forum ()
  (interactive)
  (shell-execute *winbatch-forum-url* t))

(defun winbatch-mode-show-version ()
  (interactive)
  (message-box (concat "winbatch-mode.l version " *winbatch-mode-version*) "winbatch-mode"))

(defun winbatch-prog-p ()
  "winbat32.exe �̑��݊m�F"
  (or (file-exist-p *winbatch-prog*) nil))

(defun winbatch-compiler-prog-p ()
  "wbatcp.exe �̑��݊m�F"
  (or (file-exist-p *winbatch-compiler-prog*) nil))

(defun winbatch-help-file-p ()
  "winbat32.hlp �̑��݊m�F"
  (or (file-exist-p *winbatch-winhelp-file*) nil))


;; Menu

;csv-mode ���Q�l�ɁB
(defvar *winbatch-menu-name*  "WinBatchEh(&B)")

(defun winbatch-menu-update ()
  (interactive)
  (use-local-menu (winbatch-add-menu)))

(defun winbatch-add-menu ()
  (let ((menu (copy-menu-items *app-menu* (create-menu))))
    (insert-popup-menu menu (get-menu-position menu 'help)
                       *winbatch-menu-default*
                       *winbatch-menu-name*)
    menu))

(defvar *winbatch-menu-default* nil)
(unless *winbatch-menu-default*
  (setq *winbatch-menu-default*
        (let ((menu (create-popup-menu nil)))
          (add-menu-item menu nil "�w���v������(&H)"     'winbatch-show-winhelp
			 #'(lambda () (unless (winbatch-help-file-p) :disable)))
	  (add-menu-separator menu)
	  (add-menu-item menu nil "�t�@�C��(&F)"         'winbatch-open-filer)
	  (add-menu-separator menu)
          (add-menu-item menu nil "�X�N���v�g�����s(&X)" 'winbatch-run-script
			 #'(lambda () (unless (winbatch-prog-p) :disable)))
	  (add-menu-item menu nil "�X�N���v�g���J��(&O)" 'winbatch-open-script
			 #'(lambda () (unless (winbatch-prog-p) :disable)))
	  (add-menu-item menu nil "�R���p�C���N��(&C)"   'winbatch-compile-script
			 #'(lambda () (unless (winbatch-compiler-prog-p) :disable)))
	  (add-menu-separator menu)
	  (add-menu-item menu nil "�L�[���[�h�⊮(&K)"     'winbatch-completion)
	  (add-menu-item menu nil "�R�����g������}���܂��̓g�O��(&R)"
			 'winbatch-encomment-selection-or-comment-toggle-line)
	  (add-menu-item menu nil "�R�����g������폜(&D)" 'winbatch-outcomment-selection)
	  (add-menu-separator menu)
	  (add-menu-item menu nil "���� �m������̃y�[�W(&W)" 'winbatch-home)
	  (if *winbatch-forum-url*
	    (add-menu-item menu nil "WinBatch�̌f����(&B)"    'winbatch-forum))
          (add-menu-item menu nil "�ɂ���(&A)..."           'winbatch-mode-show-version)
          menu)))


;;;  winbatch-mode.l ends here.