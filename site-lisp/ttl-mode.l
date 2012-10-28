;;; -*- Mode: Lisp; Package: EDITOR; Last modified: <2007/12/31 01:15:39> -*-
;;;
;;; This file is not part of xyzzy.
;;;
;;;   ttl-mode.l --- Simple mode for Tera Term Language
;;;
;;;     by HIE Masahiro <madoinu@ybb.ne.jp>
#|

���T�v

  Tera Term �}�N���p�̃��[�h�B

  ���̑��A�Q�l�ɂ����Ă������������́B�i�Ƃ��A�قڂ��̂܂܎g�킹��
  �������������́B�j

    htmlmode.l
    bat-mode.l
    php-mode.l
    csv-mode.l
    xyzzy ML
    ���̑���R...

  �����̗L�p�ȃR�[�h�����J���Ē����Ă��鏔��y���ɑ��ӁB


���g�p��̒���

  �ETera Term �̎��s�p�X�́A���W�X�g��(�̂��Ԃ�֘A�t���̕���)����
    �擾����悤�ɂ��Ă݂����A�N�����Ȃ��ꍇ�i����ъ֘A�t���̂���
    �Ȃ��ꍇ�j�́A*ttl-path* �𒼐ڎw�肵�Ȃ��Ƃ����Ȃ��Ǝv���B

  �ELisp �� TTL ���ǂ�������Ȃ��܂܍���Ă���̂ŁA�������B


�C���X�g�[��:

  1. ttl-mode.l �� ~/site-lisp �ɁATTL �� ~/etc �ɃR�s�[����B

  2. �K�v�Ȃ�΃o�C�g�R���p�C������B

  3. *.ttl ��ǂ݂��񂾂Ƃ��Ɏ����I�� ttl-mode �ɂ��邽�߂ɁA�ȉ�
     �̃R�[�h��ǉ�����i���Ԃ�j�B

     �� .xyzzy�ɒǉ�����ꍇ
           (export 'ed::ttl-mode "ed")
           (autoload 'ttl-mode "ttl-mode" t)
           (pushnew '("\\.ttl$" . ttl-mode) *auto-mode-alist* :test 'equal)

     �� siteinit.l�ɒǉ�����ꍇ
           (in-package "editor")
           (export 'ttl-mode)
           (autoload 'ttl-mode "ttl-mode" t)
           (pushnew '("\\.ttl$" . ttl-mode) *auto-mode-alist* :test 'equal)
           (in-package "user")

   4. �⊮���|�b�v�A�b�v�ꗗ�\��������ꍇ�́A�ȉ��̃R�[�h��������
      �t�@�C���ɒǉ�����B

           (setq *popup-completion-list-default* :always)

   5. ��L�̐ݒ�𔽉f�����邽�߂ɁAxyzzy���ċN������B


���g����

  M-x ttl-mode

  �X�N���v�g�����s����ꍇ�ɁA�p�����[�^���w�肷��ꍇ�́A
  Parameters: ���ɓ��͂���B�����w�肷��ꍇ�́A���p�X�y�[�X��؂�
  �ŁA���p�X�y�[�X����������������w�肷��ꍇ�́A"" �ł������Ďw��
  ����B�p�����[�^���s�v�ȏꍇ�́A�����͂̂܂� Enter �� OK�B


���L�[�o�C���h

  F1       �w���v������
  C-.      �L�[���[�h�⊮
  C-;      �Z���N�V����������΃Z���N�V�����ɃR�����g�������}���A
           �Ȃ���Ό��ݍs�̃R�����g���g�O��
  M-C-;    �Z���N�V�����̃R�����g��������폜
  C-c x    TTL �X�N���v�g���s


���ݒ��

  ;; �X�N���v�g���s���Ƀt�@�C����ۑ�
  (setq *ttl-auto-save* nil)


���X�V����

  [Version 1.08] 2007-12-31 (��)
  �E���C�Z���X����(MIT���C�Z���X)���L�ځB

  [Version 1.07.1] 2002/09/15 12:06:11 +0900
  �E�⊮�̃|�b�v�A�b�v�ꗗ�\���̐ݒ�́A�K�v�ȕ����݂̂Ƃ���(����)�B

  [Version 1.07] 2002/09/15 00:14:52 +0900
  �E�⊮�̈ꗗ�\���́A�R�{ �׎O����� Tips ���g���Ă����̂������v
    ���o���A��������ǉ������B

  [Version 1.06] 2002/09/14 08:46:48 +0900
  �E�X�N���v�g���s���A�������擾����̂� minibuffer-prompt ���g�p
    ����̂���߂��B�܂��A���s����t�@�C������ "" �ł�����悤�ɂ�
    ���B
  �E*ttl-auto-save* �̊���l�� t �ɂ����B

  [Version 1.05] 2002/09/14 00:32:56 +0900
  �E�X�N���v�g���s���ɁA�o�b�t�@�ҏW�󋵂��`�F�b�N���A�ꍇ�ɂ����
    �͕ۑ����Ă��炷��悤�ɂ����B

  [Version 1.04] 2002/09/03 11:13:47 +0900
  �E�R�����g������̑}���A�폜�̕��@��ύX�����B
  �E�L�[�o�C���h���W���I(?)�łȂ������̂�ύX�����B
  �E������������J�X�^�}�C�Y���邩������Ȃ�������� export �����B
  �E�ꉞ�A�f������� Tera Term �̃y�[�W�Ƀ����N����̂���߂��B

  [Version 1.03] 2002/09/02 11:16:40 +0900
  �E�x�[�J�[�X�̕��u(http://members.tripod.co.jp/mystery_trick_room/)
    ���Q�l�Ƀw���v�̌������@�𐳂���(?)���@�ɕύX�����B

  [Version 1.02] 2002/08/30(��)
  �E���W�X�g������ Tera Term �̃C���X�g�[���f�B���N�g�����擾����
    �悤�ɂ����B
  �E���j���[�������B

  [Version 1.01] 2002/08/28(��)
  �E�C���f���g����悤�ɂ����B
  �E���̑��ׂ����C���B

  [Version 1.00] 2002/08/12(��)
  �Ettl-run-script ��ǉ������B
  �Ettl-search-help-selection �ɁAwinbat32.exe �܂��� TTLHelp.btw 
    ���Ȃ��ꍇ�̏�����ǉ������B

  [Version 0.4] 2002/08/10(�y)
  �Ettl-encomment-selection, ttl-outcomment-selection
    ��ǉ������B

  [Version 0.3] 2002/08/08(��)
  �Eini-mode �x�[�X����Abatch-mode �x�[�X�ɕύX�����B
  �Ettl-search-help-selection ��ǉ������B�i�v WinBatchEh�j
  �Erito-ttl-outcomment-selection, rito-ttl-outcomment-selection
    ���폜�����B
    �� siteinit.l �Őݒ肷��悤�ɂ����B

  [Version 0.3] 2002/04/09
  �Erito-ttl-outcomment-selection, rito-ttl-outcomment-selection
    ��ǉ������B

  [Version 0.2] 2001/11/22
  �Elisp-mode �x�[�X����Aini-mode �x�[�X�ɕύX�����B

  [Version 0.1]
  �Elispmode.l �̃R�����g�F�t�����g�p���邽�߂����ɁA���������������Ă������B


�����C�Z���X

  ttl-mode.l ��MIT���C�Z���X�Ɋ�Â��ė��p�\�ł��B
  <http://www.opensource.org/licenses/mit-license.php>

Copyright (c) 2001-2007 HIE Masahiro

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

(provide "ttl-mode")

(in-package "editor")

(export '(ttl-mode
	  ttl-show-winhelp
	  ttl-run-script
	  ttl-completion
	  ttl-encomment-selection-or-comment-toggle-line
	  ttl-outcomment-selection
	  *ttl-mode-hook*
	  *ttl-mode-map*
	  *ttl-keyword-file*
	  *ttl-prog*
	  ))

(defconstant *ttl-mode-version* "1.07.1")

;; �X�N���v�g���s���Ƀt�@�C����ۑ�
(defvar *ttl-auto-save* t)

(defun ttl-path ()
  "���W�X�g������ Tera Term �̃p�X���擾"
  (let ((dat (read-registry "SOFTWARE\\Classes\\TTL_auto_file\\shell\\open\\command"
			    "" :local-machine)))
    (if dat (directory-namestring dat)
      "C:/Program Files/TTERMPRO/")))

;; Tera Term �̃C���X�g�[���f�B���N�g��
(defvar *ttl-path* (ttl-path))

;; ttpmacro.exe �̃t���p�X
(defvar *ttl-prog* (merge-pathnames "ttpmacro.exe" *ttl-path*))

;; �w���v�t�@�C���̃t���p�X
(defvar *ttl-winhelp-path* (merge-pathnames "macroj.hlp" *ttl-path*))

;; startup message
(defvar *ttl-startup-message* t)

(defvar *ttl-mode-hook* nil)

(defvar *ttl-keyword-hash-table* nil)
(defvar *ttl-keyword-file* "TTL")
(defvar *ttl-completion-list* nil)

(defvar *ttl-mode-map* nil)
(unless *ttl-mode-map*
  (setq *ttl-mode-map* (make-sparse-keymap))
  (define-key *ttl-mode-map*   #\F1       'ttl-show-winhelp)
  (define-key *ttl-mode-map*   #\TAB      'ttl-indent-line)
  (define-key *ttl-mode-map*   #\RET      'ttl-newline-and-indent)
  (define-key *ttl-mode-map*   #\C-.      'ttl-completion)
  (define-key *ttl-mode-map*   #\C-\;     'ttl-encomment-selection-or-comment-toggle-line)
  (define-key *ttl-mode-map*   #\M-\C-\;  'ttl-outcomment-selection)
  (define-key *ttl-mode-map* '(#\C-c #\x) 'ttl-run-script)
  (define-key *ttl-mode-map* '(#\C-c #\?) 'ttl-mode-version))

(defvar *ttl-mode-abbrev-table* nil)
(unless *ttl-mode-abbrev-table*
  (define-abbrev-table '*ttl-mode-abbrev-table*))

(defvar *ttl-mode-syntax-table* nil)
(unless *ttl-mode-syntax-table*
  (setq *ttl-mode-syntax-table* (make-syntax-table))
  (set-syntax-start-comment *ttl-mode-syntax-table* #\; t)
  (set-syntax-end-comment *ttl-mode-syntax-table* #\LFD t t)
  (set-syntax-string *ttl-mode-syntax-table* #\")
  (set-syntax-string *ttl-mode-syntax-table* #\'))

(defun ttl-mode ()
  (interactive)
  (kill-all-local-variables)
  (if *ttl-startup-message*
      (message "Tera Term Language mode ~A for xyzzy."
	       *ttl-mode-version*))
  (setq buffer-mode 'ttl-mode)
  (setq mode-name "TTL")
  (use-keymap *ttl-mode-map*)
  (use-syntax-table *ttl-mode-syntax-table*)
  (and *ttl-keyword-file*
       (null *ttl-keyword-hash-table*)
       (setq *ttl-keyword-hash-table*
	     (load-keyword-file *ttl-keyword-file* t)))
  (when *ttl-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *ttl-keyword-hash-table*))
  (setq *local-abbrev-table* *ttl-mode-abbrev-table*)
  (ttl-menu-update)
  (run-hooks '*ttl-mode-hook*))

(defun ttl-newline-and-indent (&optional (arg 1))
  "���s�{�C���f���g"
  (interactive "*p")
  (insert #\LFD arg)
  (ttl-indent-line))

(defun ttl-indent-line ()
  "���݂̍s�̃C���f���g�t��"
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

(defun ttl-completion ()
  "�L�[���[�h����⊮"
  (interactive)
  (or *ttl-completion-list*
      (setq *ttl-completion-list* (make-list-from-keyword-table *ttl-keyword-hash-table*))
      (return-from ttl-completion nil))
  (let ((opoint (point)))
    (when (skip-syntax-spec-backward "w_.")
      (let ((from (point)))
	(goto-char opoint)
	(do-completion from opoint :list *ttl-completion-list*)))))

(defun ttl-encomment-selection-or-comment-toggle-line ()
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
	  (insert ";")
	  (while (forward-line 1)
	    (insert ";")))))
    ;�Z���N�V�������Ȃ���΁A�R�����g���g�O��
    (save-excursion
      (let (bol eol)
	(goto-eol)
	(setq eol (point))
	(goto-bol)
	(setq bol (point))
	(if (string-match "^[ \t]*\\;+"
			  (buffer-substring bol eol))
	    (delete-region (+ bol (match-beginning 0)) (+ bol (match-end 0)))
	  (insert ";"))))))

(defun ttl-outcomment-selection ()
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
	(replace-buffer (concat "^" ";") "" :regexp t)))))

(defun ttl-run-script (&optional arg)
  "�X�N���v�g�摖��"
  (interactive "sParameters: ")
  (if (file-exist-p *ttl-prog*)
      (progn
	(if (and (buffer-modified-p) *ttl-auto-save*)
	    (save-buffer-dialog))
	(if (not (buffer-modified-p))
	      (call-process (concat *ttl-prog* " \""
				    (map-slash-to-backslash (get-buffer-file-name)) "\" " arg)
			    :wait nil)
	  (message "�ۑ�����ĂȂ��B")))
    (message (concat *ttl-prog* " ���݂���Ȃ��B"))))

(defun ttl-show-winhelp ()
  "�w���v�̌���"
  (interactive)
  (run-winhelp *ttl-winhelp-path*
	       (let ((topic (get-winhelp-topic)))
		 (and (not (equal topic "")) topic))))

(defun teraterm-home ()
  (interactive)
  (shell-execute "http://hp.vector.co.jp/authors/VA002416/teraterm.html" t))

(defun ttl-mode-version ()
  (interactive)
  (message-box (concat "ttl-mode.l version " *ttl-mode-version*)))


;; Menu

(defvar *ttl-menu-name*  "TTL(&T)")

(defun ttl-menu-update ()
  (interactive)
  (use-local-menu (ttl-add-menu)))

(defun ttl-add-menu ()
  (let ((menu (copy-menu-items *app-menu* (create-menu))))
    (insert-popup-menu menu (get-menu-position menu 'help)
                       *ttl-menu-default*
                       *ttl-menu-name*)
    menu))

(defvar *ttl-menu-default* nil)
(unless *ttl-menu-default*
  (setq *ttl-menu-default*
        (let ((menu (create-popup-menu nil)))
          (add-menu-item menu nil "�w���v������(&H)"     'ttl-show-winhelp)
          (add-menu-item menu nil "�X�N���v�g�����s(&X)" 'ttl-run-script)
	  	  (add-menu-separator menu)
	  (add-menu-item menu nil "�L�[���[�h�⊮(&K)"     'ttl-completion)
	  (add-menu-item menu nil "�R�����g������}���܂��̓g�O��(&R)"
			 'ttl-encomment-selection-or-comment-toggle-line)
	  (add-menu-item menu nil "�R�����g������폜(&D)" 'ttl-outcomment-selection)
	  (add-menu-separator menu)
	  ;(add-menu-item menu nil "Tera Term Home Page(&W)" 'teraterm-home)
          (add-menu-item menu nil "�o�[�W�������(&V)"      'ttl-mode-version)
          menu)))


;;; ttl-mode.l ends here.