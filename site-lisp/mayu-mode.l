;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; mayu-mode.l --- mayu setting editing commands for xyzzy

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Version: 0.0.0.6
;; Time-stamp: <2005/10/08 14:43:25 +0900>

;;; Commentary:

;; Description:
;;
;;  �u���g���̗J�T�v�ݒ�t�@�C���ҏW���[�h
;;

;; Installation:
;;
;;      1. �A�[�J�C�u��W�J���� mayu-mode.l �� $XYZZY/site-lisp ��
;;         �R�s�[���܂��B
;;
;;      2. �o�C�g�R���p�C�����܂��B
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/mayu-mode.l
;;
;;      3. *.mayu ��ǂ݂��񂾂Ƃ��Ɏ����I�� mayu-mode �ɂ��邽�߂ɁA
;;         ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ��̃R�[�h��
;;         �ǉ����܂��B
;;
;;        �� .xyzzy�ɒǉ�����ꍇ
;;              (export 'ed::mayu-mode "ed")
;;              (autoload 'mayu-mode "mayu-mode" t)
;;              (pushnew '("\\.mayu$" . mayu-mode) *auto-mode-alist* :test 'equal)
;;
;;        �� siteinit.l�ɒǉ�����ꍇ
;;              (in-package "editor")
;;              (export 'mayu-mode)
;;              (autoload 'mayu-mode "mayu-mode" t)
;;              (pushnew '("\\.mayu$" . mayu-mode) *auto-mode-alist* :test 'equal)
;;              (in-package "user")
;;
;;      4. ��L�̐ݒ�𔽉f�����邽�߂ɁAxyzzy ���ċN�����܂��B
;;         siteinit.l �ɋL�q�����ꍇ�� Ctrl �L�[�� Shift �L�[�������Ȃ���
;;         xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;

;; Uninstallation:
;;
;;      1. mayu-mode.l �Ɋւ���L�q���폜���܂��B
;;
;;      2. siteinit.l �ɋL�q���Ă����ꍇ�� Ctrl �L�[�� Shift �L�[������
;;         �Ȃ��� xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;

;; Key bind:
;;
;;      RET     ���s�{�C���f���g�t��
;;      TAB     �C���f���g�t��
;;      C-cC-c  ���[�W�������R�����g��
;;      C-;     ���ݍs�̃R�����g���g�O��
;;      M-;     indent-for-comment

;; Changes:
;;
;;      [Version 0.0.0.6]
;;      Sat, 08 Oct 2005 14:11:30 +0900
;;        �E���[���A�h���X��ύX�B
;;        �E���C�Z���X����(�C��BSD���C�Z���X)���L�ځB
;;
;;      Tue, 17 May 2005 23:45:07 +0900
;;        �E�u���g���̗J�T�vver. 3.30 �t���� mayu-mode.el �̃L�[���[�h
;;          �ɏ����B
;;
;;      [Version 0.0.0.5]
;;      Sat, 12 Jun 2004 23:58:32 +0900
;;        �ENetInstaller �Ή��B
;;
;;      [Version 0.0.0.4]
;;      Wed, 09 Jan 2002 17:53:02 +0900
;;        �Emayu- �� prefix �łȂ� function ���� mayu- ��t�������̂ɕύX�B
;;        �E�L�[���[�h�̑啶������������ʂ��Ȃ��悤�ɕύX�B
;;
;;      [Version 0.0.0.3]
;;      Wed, 29 Aug 2001 17:35:39 +0900
;;        �E�u���g���̗J�T�vver. 3.24, 3.26 �ł� mayu-mode.el ��
;;           �ύX�ɒǏ]���Ă݂�����B
;;            �E"R-" �ɑΉ�
;;            �Emayu-comment-indent �C��
;;
;;      [Version 0.0.0.2]
;;      Thu, 23 Aug 2001 15:22:45 +0900
;;        �Esyntax.txt ���� elif ���L�[���[�h��
;;        �E�Ȃ����܂���������Ȃ� indent �x����ǉ�
;;          mayu-newline-and-indent, mayu-indent-line
;;
;;      Tue, 07 Aug 2001 00:38:00 +0900
;;        �Emayu-comment-region �C��
;;
;;
;;      [Version 0.0.0.1]
;;      Sun, 05 Aug 2001 07:48:49 +0900
;;        �E�R�����g�� syntax ��ݒ肵�A���K�\���L�[���[�h�ł�
;;          �J���[������߂�
;;
;;      Sun, 05 Aug 2001 02:26:51 +0900
;;        �E�u���g���̗J�T�vver. 3.23 �� mayu-mode.el ������
;;           �Ƃ肠�������ł������Ă݂��B

;; Memo:
;;
;;      �E/ �` # �` / �ƂȂ��Ă��Ă� / �` / �̐F�t�������Ă��܂��Ă���B
;;        �󋵈ˑ��̃J���[���͏d���Ȃ� & �ʓ|�Ȃ̂ł�߁B
;;        �ނ��� "/[^/\n]*/" �̃L�[���[�h�𖳎������ق����悢�H

;; Licence:
;;
;;    mayu-mode �͏C��BSD���C�Z���X�Ɋ�Â��ė��p�\�ł��B
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

(provide "mayu-mode")

(in-package "editor")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (export '(*mayu-mode-hook*
            *mayu-mode-map*
            *mayu-version*
            *mayu-regexp-keyword-list*
            *mayu-keyword-file*
            *mayu-comment-column*
            *mayu-font-lock-keyword-face*
;           *mayu-font-lock-comment-face*
            *mayu-font-lock-string-face*
            *mayu-font-lock-warning-face*
            *mayu-font-lock-builtin-face*
            *mayu-cond-indent*
            *mayu-keymap-definition-indent*
            *mayu-continued-line-indent*)))
(eval-when (:compile-toplevel :load-toplevel :execute)
  (export '(mayu-mode
            mayu-comment-region
            mayu-comment-toggle-line
            mayu-newline-and-indent
            mayu-indent-line)))

(defconstant *mayu-version* "0.0.0.6")
; ----------------------------------------------------------------------
(defvar *mayu-cond-indent* 2)
(defvar *mayu-keymap-definition-indent* 1)
(defvar *mayu-continued-line-indent* 4)

(defvar *mayu-font-lock-keyword-face* '((:keyword 0)))
(defvar *mayu-font-lock-string-face*  '(:string))
(defvar *mayu-font-lock-warning-face* '((:keyword :comment :bold)))
(defvar *mayu-font-lock-builtin-face* '((:keyword 1)))
;(defvar *mayu-font-lock-comment-face* '(:comment))

(defvar
  mayu-font-lock-keywords
  `((,(concat
       "\\<\\("
       "[AMCWS]-"
       "\\|IC-"
       ;;"\\|I-"
       "\\|[INCSK]L-"
       "\\|M[0-9]-"
       "\\|L[0-9]-"
       "\\|U-"
       "\\|D-"
       "\\|R-"
       "\\|E[01]-"
       "\\|MAX-"
       "\\|MIN-"
       "\\|MMAX-"
       "\\|MMIN-"
       "\\)"
       ) t . ,*mayu-font-lock-keyword-face*)
;    ("#.*$" t . ,*mayu-font-lock-comment-face*)
    ("/[^/\n]*/" t . ,*mayu-font-lock-string-face*)
    ("\\\\$" t . ,*mayu-font-lock-warning-face*)
    (,(concat
       "^\\s *\\<\\("
       "key"
       "\\|event\\s +\\(prefixed\\|after-key-up\\|before-key-down\\)"
       "\\|keyseq"
       "\\|def\\s +\\(key\\|alias\\|mod\\|sync\\|subst\\|option\\)"
       "\\|mod"
       "\\|keymap"
       "\\|keymap2"
       "\\|window"
       "\\|include"
       "\\|if"
       "\\|define"
       "\\|else"
       "\\|elseif"
       "\\|elsif"
       "\\|elif"   ; syntax.txt
       "\\|endif"
       "\\)\\>"
       ) t . ,*mayu-font-lock-builtin-face*)
    (,(concat
       "&\\("
       "Default"
       "\\|KeymapParent"
       "\\|KeymapWindow"
       "\\|KeymapPrevPrefix"
       "\\|OtherWindowClass"
       "\\|Prefix"
       "\\|Keymap"
       "\\|Sync"
       "\\|Toggle"
       "\\|EditNextModifier"
       "\\|Variable"
       "\\|Repeat"
       "\\|Undefined"
       "\\|Ignore"
       "\\|PostMessage"
       "\\|ShellExecute"
       "\\|SetForegroundWindow"
       "\\|LoadSetting"
       "\\|VK"
       "\\|Wait"
       "\\|InvestigateCommand"
       "\\|MayuDialog"
       "\\|DescribeBindings"
       "\\|HelpMessage"
       "\\|HelpVariable"
       "\\|WindowRaise"
       "\\|WindowLower"
       "\\|WindowMinimize"
       "\\|WindowMaximize"
       "\\|WindowHMaximize"
       "\\|WindowVMaximize"
       "\\|WindowHVMaximize"
       "\\|WindowMove"
       "\\|WindowMoveTo"
       "\\|WindowMoveVisibly"
       "\\|WindowClingToLeft"
       "\\|WindowClingToRight"
       "\\|WindowClingToTop"
       "\\|WindowClingToBottom"
       "\\|WindowClose"
       "\\|WindowToggleTopMost"
       "\\|WindowIdentify"
       "\\|WindowSetAlpha"
       "\\|WindowRedraw"
       "\\|WindowResizeTo"
       "\\|WindowMonitor"
       "\\|WindowMonitorTo"
       "\\|MouseMove"
       "\\|MouseWheel"
       "\\|ClipboardChangeCase"
       "\\|ClipboardUpcaseWord"
       "\\|ClipboardDowncaseWord"
       "\\|ClipboardCopy"
       "\\|EmacsEditKillLinePred"
       "\\|EmacsEditKillLineFunc"
       "\\|LogClear"
       "\\|DirectSSTP"
       "\\|PlugIn"
       "\\|Recenter"
       "\\|SetImeStatus"
       "\\|SetImeString"
       "\\)\\>"
       ) t . ,*mayu-font-lock-builtin-face*)
    ) "Default font-lock-keywords for mayu mode.")
; ----------------------------------------------------------------------
(defvar *mayu-regexp-keyword-list*
  (compile-regexp-keyword-list mayu-font-lock-keywords)
  "mayu-mode: ���K�\���L�[���[�h���X�g")

; ----------------------------------------------------------------------
(defvar *mayu-mode-hook* nil
  "mayu-mode: ���[�h�t�b�N")

(defvar *mayu-keyword-file* "MAYU"
  "mayu-mode: �L�[���[�h�t�@�C��")

(defvar *mayu-keyword-hash-table* nil
  "mayu-mode: �L�[���[�h�n�b�V���e�[�u��")

; �L�[�}�b�v�̐ݒ�
(defvar *mayu-mode-map* nil
  "mayu-mode: Local keymap")
(unless *mayu-mode-map*
  (setq *mayu-mode-map* (make-sparse-keymap))
  (define-key *mayu-mode-map* '(#\C-c #\C-c)    'mayu-comment-region)
  (define-key *mayu-mode-map* #\C-\;            'mayu-comment-toggle-line)
  (define-key *mayu-mode-map* #\RET             'mayu-newline-and-indent)
  (define-key *mayu-mode-map* #\TAB             'mayu-indent-line))

(defvar *mayu-mode-syntax-table* nil
  "mayu-mode: Syntax table")
(unless *mayu-mode-syntax-table*
  (setq *mayu-mode-syntax-table* (make-syntax-table))
  (set-syntax-string *mayu-mode-syntax-table* #\")
  (set-syntax-string *mayu-mode-syntax-table* #\')
  (set-syntax-match *mayu-mode-syntax-table* #\( #\))
  (set-syntax-start-comment *mayu-mode-syntax-table* #\# nil)
  (set-syntax-end-comment *mayu-mode-syntax-table* #\LFD nil t))
  
(defvar *mayu-mode-comment-start* "# "
  "mayu-mode: Commnet string")

(defvar *mayu-comment-column* 0)

;; ���[�h�̐ݒ�
(defun mayu-mode ()
  "A major mode to edit mayu setting files."
  (interactive)
  (kill-all-local-variables)
  (setq buffer-mode 'mayu-mode)
  (setq mode-name "Mayu")
  (use-keymap *mayu-mode-map*)
  (use-syntax-table *mayu-mode-syntax-table*)

  (setq comment-start *mayu-mode-comment-start*)
  (setq comment-end "")
  (setq comment-start-skip "\\(^\\|\\s \\);?#+[ \t]*")
  (setq comment-indent-function 'mayu-comment-indent)
  (when *mayu-comment-column*
    (setq comment-column *mayu-comment-column*))
  
  (and *mayu-keyword-file*
       (null *mayu-keyword-hash-table*)
       (setq *mayu-keyword-hash-table*
             (load-keyword-file *mayu-keyword-file* t)))
  (when *mayu-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *mayu-keyword-hash-table*))

  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *mayu-regexp-keyword-list*)
  
  (run-hooks '*mayu-mode-hook*))

; ------------------------------
; ���[�W�������R�����g
(defun mayu-comment-region (&optional from to)
  "mayu-mode: ���[�W�������R�����g"
  (interactive "*r")
  (if (> from to) (rotatef from to))
  (save-excursion
    (narrow-to-region from to)
    (goto-char (point-min))
    (while (< (point) (point-max))
      (insert comment-start)
      (goto-eol)
      (insert comment-end)
      (forward-char))
    (widen)))

; ------------------------------
; �s�̃R�����g���g�O��(�蔲��)
(defun mayu-comment-toggle-line ()
  "mayu-mode: �s�̃R�����g���g�O��"
  (interactive)
  (save-excursion
    (let (bol eol)
      (goto-eol)
      (setq eol (point))
      (goto-bol)
      (setq bol (point))
      (if (string-match "^[ \t]*\#[ \t]?"
                        (buffer-substring bol eol))
          (delete-region (+ bol (match-beginning 0)) (+ bol (match-end 0)))
        (insert comment-start)))))

; ------------------------------
; �C���f���g�̌v�Z
; Tue, 07 Aug 2001 04:27:34 +0900
(defun mayu-calc-indent ()
  (save-excursion
    (if (mayu-in-continued-line-p)
        ; �p���s�Ȃ��
        (progn
          (mayu-continued-head-line)
          (+ (mayu-indent-of-a-line) *mayu-continued-line-indent*)) ; �Ƃ肠�����������Œ��
      ; �p���s�łȂ����
      (progn
        (goto-bol)
        (skip-chars-forward " \t")
        ;; �J�����g�s�`�F�b�N
        (cond
         ; KEYMAP_DEFINITION �� indent ��f���؂�s
         ((or (looking-at "\\(?:keymap2?\\|window\\)\\>" t)
              (looking-at "include\\>" t))
          (while t
            ; �O�̍s���Ȃ���� 0
            (unless (mayu-previous-line)
              (return-from mayu-calc-indent 0))
            (goto-bol)
            (skip-chars-forward " \t")
            (cond
             ; �P�� if �s���͂���
             ((looking-at "if\\>.+=>.+$" t) t)
             ; if �̒��Ȃ��
             ((looking-at "if\\>" t)
              (return-from mayu-calc-indent
                (max 0 (+ (mayu-indent-of-a-line) *mayu-cond-indent*))))
             ; endif �̏ꍇ�Ή����� if �܂ňړ�
             ((looking-at "endif\\>" t)
              (unless (mayu-goto-matched-if)
                (return-from mayu-calc-indent 0)))
             ; KEYMAP_DEFINITION �Ȃ��
             ((looking-at "\\(?:keymap2?\\|window\\)\\>" t)
              (return-from mayu-calc-indent (mayu-indent-of-a-line))))))
         ; COND
         ((looking-at "\\(?:else\\|elseif\\|elsif\\|elif\\|endif\\)\\>" t)
          (return-from mayu-calc-indent
            (if (mayu-goto-matched-if) (mayu-indent-of-a-line) 0)))
         ; ���ʂ̍s
         (t
          ;; �O�̍s�`�F�b�N
          (while t
            ; �O�̍s���Ȃ���� 0
            (unless (mayu-previous-line)
              (return-from mayu-calc-indent 0))
            (goto-bol)
            (skip-chars-forward " \t")
            (cond
             ; ��s or �R�����g�s�� skip
             ((or (eolp) (looking-at "#")) t)
             ; �P�� if �s
             ((looking-at "if\\>.+=>.+$" t)
              (return-from mayu-calc-indent (mayu-indent-of-a-line)))
             ; if or else �s
             ((looking-at "\\(?:if\\|else\\|elseif\\|elsif\\|elif\\)\\>" t)
              (return-from mayu-calc-indent
                (+ (mayu-indent-of-a-line) *mayu-cond-indent*)))
             ; keymap_definition �s
             ((looking-at "\\(?:keymap2?\\|window\\)\\>" t)
              (return-from mayu-calc-indent
                (+ (mayu-indent-of-a-line) *mayu-keymap-definition-indent*)))
             ; ���ʂ̍s
             (t (return-from mayu-calc-indent (mayu-indent-of-a-line))))))
         )))))


; ------------------------------
; �C���f���g�R�}���h�p
;; Tue, 07 Aug 2001 04:21:14 +0900
; (defun mayu-comment-indent ()
;   (save-excursion
;     (let ((opoint (point)))
;       (goto-bol)
;       (skip-chars-forward " \t")
;       (cond ((or (looking-for "#")
;                (eolp))
;            (mayu-calc-indent))
;           ((zerop comment-column)
;            0)
;           (t
;            (goto-char opoint)
;            (skip-chars-backward " \t")
;            (max (1+ (current-column)) comment-column))))))

; Wed, 29 Aug 2001 17:59:00 +0900
; derived from mayu-mode.el
(defun mayu-comment-indent ()
  (if (and (bolp) (not (eolp)))
      0                            ;Existing comment at bol stays there.
    (save-excursion
      (skip-chars-backward " \t")
      (max (if (bolp)              ;Else indent at comment column
               0                   ; except leave at least one space if
             (1+ (current-column))); not at beginning of line.
           comment-column))))

; ------------------------------
; ���s�{�C���f���g
(defun mayu-newline-and-indent (&optional (arg 1))
  "mayu-mode: ���s�{�C���f���g�t��"
  (interactive "*p")
  (delete-trailing-spaces)
  (insert #\LFD arg)
  (mayu-indent-line))

; ------------------------------
; ���݂̍s�̃C���f���g�t��
; Tue, 07 Aug 2001 07:47:57 +0900
(defun mayu-indent-line ()
  "mayu-mode: �C���f���g�t��"
  (interactive "*")
  (let (col ret1 ret2)
    ; �C���f���g�ʂ̌v�Z
    (setq col (mayu-calc-indent))
    ; �C���f���g
    (if (integerp col)
        (setq ret1 (mayu-indent-to-column col)))
    ; �擪���X�L�b�v
    (if (mayu-bol-white-p)
        (setq ret2 (skip-chars-forward " \t")))
    ; �C���f���g or �X�L�b�v�ŕύX����
    (or ret1 ret2)))

;;; -------------------------------------------------------
;;; Local Functions
;;; -------------------------------------------------------
; �ύX������ t ����� col
(defun mayu-indent-to-column (col)
  (save-excursion
    (let (bol)
      (goto-bol)
      (setq bol (point))
      (skip-chars-forward " \t")
      (if (eq col (current-column))
          t
        (progn
          (delete-region bol (point))
          (indent-to col)
          col)))))

(defun mayu-indent-of-a-line (&optional pnt)
  (save-excursion
    (if pnt (goto-char pnt))
    (goto-bol)
    (skip-chars-forward " \t")
    (current-column)))

(defun mayu-bol-white-p ()
  (save-excursion
    (skip-chars-backward " \t")
    (bolp)))

; ----------------------------------------
; �Ή����� if �Ɉړ�
; �Ή����� if ��������� nil ����� t
(defun mayu-goto-matched-if ()
  (let ((if-nest 1))
    (while (< 0 if-nest)
      (unless (mayu-previous-line)
        (return-from mayu-goto-matched-if nil))
      (goto-bol)
      (skip-chars-forward " \t")
      (cond
       ((looking-at "if\\>.+=>.+$" t) t)
       ((looking-at "if\\>" t) (decf if-nest 1))
       ((looking-at "endif\\>" t) (incf if-nest 1)))))
  t)

; ----------------------------------------
;; �R�����g�̒��ɂ��邩
;; �{���͐��K�\���̒��� # �̔��蓙�����Ȃ���΂Ȃ�Ȃ����Ƃ肠�����Ă��Ɓ[
; (defun mayu-in-comment-p (&optional pnt)
;   (save-excursion
;     (if pnt (goto-char pnt))
;     (let (bol org)
;       (setq org (point))
;       (goto-bol)
;       (setq bol (point))
;       (if (string-match "#" (buffer-substring bol org))
;         t
;       nil))))

; ----------------------------------------
; �p���s�����邩
; ���F �R�����g���l�����Ă��Ȃ�
;      �R�����g�̔��肪�߂�ǂ��̂ŁA�ւȂ��傱�ɁB
;      �R�����g�̍Ō�� \ ������Ƃւ�ɂȂ�B
(defun mayu-continued-line-exist-p ()
  (save-excursion
    (goto-eol)
    (if (bolp) nil
      (progn
        (backward-char)
        (if (looking-for "\\")
            t
          nil)))))

; ----------------------------------------
; �p���s�� 2 �s�ڈڍs�ɂ��邩
(defun mayu-in-continued-line-p (&optional pnt)
  (save-excursion
    (if pnt (goto-char pnt))
    (if (not (previous-line))
        nil
      (mayu-continued-line-exist-p))))

; �p���s�̍ŏ��̍s�Ɉړ�
(defun mayu-continued-head-line ()
  (if (mayu-in-continued-line-p)
      (loop
        (previous-line)
        (unless (mayu-in-continued-line-p)
          (return t)))
    nil))
  
; �p���s���l�������O�̍s(�p���s�Ȃ�ΐ擪�s)�ւ̈ړ�
(defun mayu-previous-line ()
  (mayu-continued-head-line)
  (if (previous-line)
      (progn
        (mayu-continued-head-line)
        t)
    nil))

; ���ݍs�ȍ~�̌p���s��A��
(defun mayu-get-concatenation-remaining-line ()
  (save-excursion
    (let ((str "") bol eol)
      (goto-bol)
      (setq bol (point))
      (goto-eol)
      (setq eol (point))
      (if (or (not (mayu-continued-line-exist-p)) ; �p���s�w�肪�Ȃ��ꍇ
              (eq eol (point-max)))               ; �ړ��\�Ȗ����Ȃ�
        (buffer-substring bol eol)
        (progn                  ; �p���s������ꍇ
          (next-line)
          (concat (buffer-substring bol (1- eol))
                  (mayu-get-concatenation-remaining-line)))))))
    
; �p���s��A������������𓾂�
; (�s���̃R�����g���l�����Ă��Ȃ�)
(defun mayu-get-concatenation-line ()
  (save-excursion
    (mayu-continued-head-line)
    (mayu-get-concatenation-remaining-line)))

;;; mayu-mode.l end here