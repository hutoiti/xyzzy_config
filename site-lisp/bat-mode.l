;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; bat-mode.l --- Simple mode for Windows BAT files

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Version: 0.0.0.4
;; Time-stamp: <2005/10/08 14:17:36 +0900>

;;; Commentary:

;; Description:
;;
;;  �o�b�`�t�@�C���ҏW���[�h
;;

;; Installation:
;;
;;      1. �A�[�J�C�u��W�J���� bat-mode.l �� $XYZZY/site-lisp ��
;;         �R�s�[���܂��B
;;
;;      2. �o�C�g�R���p�C�����܂��B
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/bat-mode.l
;;
;;      3. *.bat ��ǂ݂��񂾂Ƃ��Ɏ����I�� bat-mode ��
;;         ���邽�߂ɁA�ȉ��̃R�[�h��ǉ����܂��B
;;
;;        �� .xyzzy�ɒǉ�����ꍇ
;;              (export 'ed::bat-mode "ed")
;;              (autoload 'bat-mode "bat-mode" t)
;;              (pushnew '("\\.bat$" . bat-mode) *auto-mode-alist* :test 'equal)
;;
;;        �� siteinit.l�ɒǉ�����ꍇ
;;              (in-package "editor")
;;              (export 'bat-mode)
;;              (autoload 'bat-mode "bat-mode" t)
;;              (pushnew '("\\.bat$" . bat-mode) *auto-mode-alist* :test 'equal)
;;              (in-package "user")
;;
;;      4. ��L�̐ݒ�𔽉f�����邽�߂ɁAxyzzy ���ċN�����܂��B
;;         siteinit.l �ɋL�q�����ꍇ�� Ctrl �L�[�� Shift �L�[�������Ȃ���
;;         xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;

;; Uninstallation:
;;
;;      1. bat-mode.l �Ɋւ���L�q���폜���܂��B
;;
;;      2. siteinit.l �ɋL�q���Ă����ꍇ�� Ctrl �L�[�� Shift �L�[������
;;         �Ȃ��� xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;

;; Key bind:
;;
;;      RET     ���s�{�C���f���g�t��
;;      TAB     �C���f���g�t��
;;      C-;     ���ݍs�̃R�����g���g�O��
;;      M-;     indent-for-comment
;;

;; Changes:
;;
;;      [Version 0.0.0.4]
;;      Sat, 08 Oct 2005 14:15:37 +0900
;;        �EHIE ����� 2002/10/17 �ɋ����Ă��������Ă��� typo �̏C���R���
;;          �C���B
;;        �E���[���A�h���X��ύX�B
;;        �E���C�Z���X����(�C��BSD���C�Z���X)���L�ځB
;;
;;      [Version 0.0.0.3]
;;      Sun, 13 Jun 2004 00:11:30 +0900
;;        �EHIE ����� 2002/10/17 �ɋ����Ă��������Ă��� typo �C���B
;;        �ENetInstaller �Ή��B
;;
;;      [Version 0.0.0.2]
;;      Wed, 12 Dec 2001 15:53:35 +0900
;;        �E�قƂ�Ǖʕ��ɁB
;;
;;      [Version 0.0.0.1]
;;      Sat, 04 Aug 2001 02:11:45 +0900
;;        �E��@���킩��Ȃ��̂ŗ͂܂����łƂ肠�������ł������Ă݂��B
;;

;; Todo:
;;
;;  �E%....% �̊��ϐ���⊮�ł���悤��
;;      �E">", "<", "<<", "|" ��
;;      �EPRN, AUX, NUL, CON ��
;;      �EGOTO ���烉�x���ɔ�񂾂�߂�����
;;      �E����Ȋ��ϐ� COMSPEC, PATH, PROMPT, TEMP, DOSDIR, DIRCMD ��
;;      �E�߂����K���� BAT �t�@�C�����@�̊m�F
;;      �E�K���ɍ�����̂ŁuFOR �̕ϐ��v�uERRORLEVEL �̐����v�Ɋ��ϐ��Ƃ�
;;        �����ƕςɂȂ�͂�

;; Memo:
;;
;;      �\���}�~    ::= @
;;      ���x��A     ::= :���x��B
;;      ����        ::= %0 �` %9
;;      ���ϐ�    ::= %���ϐ���%
;;      �ϐ�        ::= %%���� �i�P�����j
;;      �R�����g    ::= REM
;;      �Z�p���[�^A ::= [ \t]
;;      �Z�p���[�^B ::= [ \t]+
;;      �C���f���g  ::= ^[ \t]*
;;
;;
;;      �J��Ԃ�    ::= FOR %%�ϐ� IN (�Z�b�g) DO �R�}���h [�p�����[�^]
;;      ��������    ::= IF [NOT] ���� �R�}���h [�p�����[�^]
;;
;;      ����        ::= ERRORLEVEL ���l | ������ == ������ | EXIST �t�@�C����
;;
;;      ���l        ::= [1-9][0-9]+
;;      ������      ::=
;;      ���b�Z�[�W  ::= �C�ӕ�����
;;      �R�����g    ::= �C�ӕ�����
;;      �C�ӕ�����  ::= .*
;;
;;                  ::= CALL �o�b�`�t�@�C����
;;                  ::= ECHO | ECHO OFF | ECHO ON | ECHO �C�ӕ����� | ECHO.
;;                  ::= GOTO ���x��B
;;                  ::= SHIFT ���b�Z�[�W
;;                  ::= PAUSE ���b�Z�[�W
;;

;; Licence:
;;
;;    bat-mode �͏C��BSD���C�Z���X�Ɋ�Â��ė��p�\�ł��B
;;    <http://www.opensource.org/licenses/bsd-license.php>
;;
;;
;;    Copyright (C) 2001-2005, OHKUBO Hiroshi.  All rights reserved.
;;
;;    Redistribution and use in source and binary forms, with or without
;;    modification, are permitted provided that the following conditions
;;    are met:
;;
;;    1. Redistributions of source code must retain the above copyright
;;       notice, this list of conditions and the following disclaimer.
;;
;;    2. Redistributions in binary form must reproduce the above copyright
;;       notice, this list of conditions and the following disclaimer in
;;       the documentation and/or other materials provided with the
;;       distribution.
;;
;;    3. Neither the name of the University nor the names of its
;;       contributors may be used to endorse or promote products derived
;;       from this software without specific prior written permission.
;;
;;    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;;    ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;;    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;;    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;;    OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;;    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;;    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;;    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;;    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;;    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;

;;; Code:

(provide "bat-mode")

(in-package "editor")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (export '(*bat-mode-hook*
            *bat-mode-map*
            *bat-version*
            *bat-keyword-file*
            *bat-keyword-file-use*
            *bat-regexp-keyword-list*
            *bat-mode-comment-start*
            *bat-comment-column*
            *bat-mode-abbrev-table*)))
(eval-when (:compile-toplevel :load-toplevel :execute)
  (export '(bat-mode
            bat-indent-line
            bat-newline-and-indent
            bat-comment-toggle-line)))

(defconstant *bat-version* "0.0.0.4"
  "bat-mode: Version")

(defvar *bat-keyword-file-use* nil
  "bat-mode: �L�[���[�h�t�@�C�����g�p")

;; �F�ݒ�
; �R�����g
(defvar *bat-comment-color* '(:keyword :comment))
; ���x��
(defvar *bat-lavel-color* '(:color 0 1 :underline))
; �R�}���h (GOTO IF FOR ECHO SET PATH PROMPT CALL PAUSE SHIFT)
(defvar *bat-command-color* '(:keyword 0))
; GOTO �̃��x��
(defvar *bat-goto-label-color* '(:color 1 0 :underline))
; �G�R�[�}�~
(defvar *bat-echo-stop-color* '(:keyword 1))
; ������
(defvar *bat-string-color* '(:keyword :string :underline))
; IF �\�� (NOT ERRORLEVEL EXIST)
(defvar *bat-if-syntax-color* '(:keyword 2))
; FOR �\�� (IN DO)
(defvar *bat-for-syntax-color* '(:keyword 2))
; ���[�v�ϐ�
(defvar *bat-loop-variable-color* '(:keyword 2))
; ����
(defvar *bat-argument-color* '(:keyword 2))
; �ϐ�
(defvar *bat-variable-color* '(:color 0 3))
; �ϐ��Q��
(defvar *bat-variable-reference-color* '(:keyword 2))


;;; ----------------------------------------
(defvar *bat-mode-hook* nil
  "bat-mode: Mode hook")

(defvar *bat-keyword-file* "BAT"
  "bat-mode: �L�[���[�h�t�@�C��")

(defvar *bat-mode-comment-start* "REM "
  "bat-mode: Commnet string")

(defvar *bat-comment-column* 0
  "bat-mode: Comment column")

; �L�[�}�b�v�̐ݒ�
(defvar *bat-mode-map* nil
  "bat-mode: Local keymap")
(unless *bat-mode-map*
  (setq *bat-mode-map* (make-sparse-keymap))
  (define-key *bat-mode-map* #\TAB      'bat-indent-line)
  (define-key *bat-mode-map* #\RET      'bat-newline-and-indent)
  (define-key *bat-mode-map* #\C-\;     'bat-comment-toggle-line)
  )

(defvar *bat-mode-abbrev-table* nil)
(unless *bat-mode-abbrev-table*
  (define-abbrev-table '*bat-mode-abbrev-table*))

;; Make underscores count as words
(defvar *bat-mode-syntax-table* nil
  "bat-mode: Syntax table")
(unless *bat-mode-syntax-table*
  (setq *bat-mode-syntax-table* (make-syntax-table))
;  (set-syntax-string *bat-mode-syntax-table* #\")
;  (set-syntax-string *bat-mode-syntax-table* #\')
;  (set-syntax-end-comment *bat-mode-syntax-table* #\LFD nil t)
  )
  
(defvar *bat-keyword-hash-table* nil
  "bat-mode: �L�[���[�h�n�b�V���e�[�u��")

(defvar *bat-regexp-keyword-list*
  nil
  "bat-mode: ���K�\���L�[���[�h���X�g")
  
(setq *bat-regexp-keyword-list*
  (compile-regexp-keyword-list
   `(
     ;; ���x���s
     ("^[ \t]*:.+" t ((0 . ,*bat-lavel-color*)))
     ;; �G�R�[�}�~
     ("^[ \t]*\\(@\\)" t ((1 . ,*bat-echo-stop-color*)))
     ; �R�����g
     (,(concat "\\<\\(REM\\)\\>"
           "\\(?:[ \t]\\(.*\\)\\)?") t ((0 . ,*bat-comment-color*)))
     ; IF
     ("\\<IF\\>" t ((0 . ,*bat-command-color*)))
     ("\\<\\(?:NOT\\|ERRORLEVEL\\|EXIST\\)\\>" t ((0 . ,*bat-if-syntax-color*)))
     ; FOR
     ("\\<FOR\\>" t ((0 . ,*bat-command-color*)))
     ("\\<\\(?:IN\\|DO\\)\\>" t ((0 . ,*bat-for-syntax-color*)))
     ; GOTO
     (,(concat "\\<\\(GOTO\\)\\>"
               "\\(?:[ \t]\\(.*\\)\\)?") t ((1 . ,*bat-command-color*)
                                            (2 . ,*bat-goto-label-color*)))
     ; ECHO
     ("\\<\\(ECHO\\)[ \t]+\\(ON\\|OFF\\)[ \t]*$" t ((0 . ,*bat-command-color*)))
     (,(concat "\\<\\(ECHO\\.?\\)\\>"
               "\\(?:[ \t]\\(.*\\)\\)?") t ((1 . ,*bat-command-color*)
                                            (2 . ,*bat-string-color*)))
     ; SET
     ("\\<\\(SET\\)\\(?:[ \t]+\\([^=\n]+\\)\\(?:=\\(.*\\)\\)?\\)?"
      t ((1 . ,*bat-command-color*)
         (2 . ,*bat-variable-color*)
         (3 . ,*bat-string-color*)))
     ;; �R�}���h = ������
     ; [PATH] [PROMPT]
     (,(concat "\\<"
               "\\(PATH"
               "\\|PROMPT"
               "\\)\\>"
               "\\(?:[ \t]*=[ \t]*\\(.*\\)\\)")
      t ((1 . ,*bat-command-color*)
         (2 . ,*bat-string-color*)))
     ;; �R�}���h ������
     (,(concat "\\<"
               "\\(PATH"
               "\\|PROMPT"
               "\\|CALL"
               "\\|PAUSE"
               "\\|SHIFT"
               "\\)\\>"
               "\\(?:[ \t]+\\(.*\\)\\)?")
      t ((1 . ,*bat-command-color*)
         (2 . ,*bat-string-color*)))

     ;; �R�}���h
     ("\\<\\(CHOICE\\)\\>" t ((0 . ,*bat-command-color*)))
     
     ; ����
     ("%[0-9]" nil ,*bat-argument-color*)
     ; ���[�v�ϐ�
     ("%%[a-zA-Z]" nil ,*bat-loop-variable-color*)
     ; �ϐ�
     ("%[a-zA-Z][a-zA-Z0-9_]*%" nil ,*bat-variable-reference-color*)

     )))

;; ���[�h�̐ݒ�
(defun bat-mode ()
  (interactive)
  "Mode for DOS and Windows BAT files"
  (kill-all-local-variables)
  (setq buffer-mode 'bat-mode)
  (setq mode-name "Bat")
  (use-keymap *bat-mode-map*)
  (use-syntax-table *bat-mode-syntax-table*)

  (make-local-variable 'mode-specific-indent-command)
  (setq mode-specific-indent-command 'bat-indent-line)
  (setq comment-indent-function 'bat-comment-indent)

  (cond
   (*bat-keyword-file-use*
    (and *bat-keyword-file*
         (null *bat-keyword-hash-table*)
         (setq *bat-keyword-hash-table*
               (load-keyword-file *bat-keyword-file* t)))
    (when *bat-keyword-hash-table*
      (make-local-variable 'keyword-hash-table)
      (setq keyword-hash-table *bat-keyword-hash-table*)))
   (t
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table '())))

  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *bat-regexp-keyword-list*)
  
  (setq *local-abbrev-table* *bat-mode-abbrev-table*)
  (setq comment-start *bat-mode-comment-start*
        comment-end "")
  (setq comment-start-skip "[ \t]*[rR][eE][mM][ \t]*")
  (when *bat-comment-column*
    (setq comment-column *bat-comment-column*))
  (run-hooks '*bat-mode-hook*))


; ------------------------------
; �s�̃R�����g���g�O��
(defun bat-comment-toggle-line ()
  "bat-mode: �s�̃R�����g���g�O��"
  (interactive "*")
  (save-excursion
    (let (bol eol)
      (goto-eol)
      (setq eol (point))
      (goto-bol)
      (setq bol (point))
      (if (string-match "^[ \t]*[rR][eE][mM]\\(?:[ \t]*$\\|[ \t]\\)"
                        (buffer-substring bol eol))
          (delete-region (+ bol (match-beginning 0)) (+ bol (match-end 0)))
        (insert *bat-mode-comment-start*)))))

; ------------------------------
; ���s�{�C���f���g
(defun bat-newline-and-indent (&optional (arg 1))
  "bat-mode: ���s�{�C���f���g�t��"
  (interactive "*p")
  (insert #\LFD arg)
  (bat-indent-line))

; ------------------------------
; ���݂̍s�̃C���f���g�t��
(defun bat-indent-line ()
  "bat-mode: �C���f���g�t��"
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

; ------------------------------
; �R�����g�C���f���g
(defun bat-comment-indent ()
  (if (and (bolp) (not (eolp)))
      0
    (save-excursion
      (skip-chars-backward " \t")
      (max (if (bolp)
               0
             (1+ (current-column)))
           comment-column))))

;;; bat-mode.l ends here