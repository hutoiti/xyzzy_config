;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; clickable-uri.l --- �N���b�J�u�� URI

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 12:00:53 +0900>

;;; Commentary:

;; Description:
;;
;;  ���_�u���N���b�N�ɂ�� WEB �u���E�U�A���[���[���̋N�����\�ɂ��܂��B
;;  URI (Uniform Resource Identifier) �����\�����s���܂��B
;;

;; Installation:
;;
;;      1. �A�[�J�C�u��W�J���� clickable-uri.l �� $XYZZY/site-lisp ��
;;         �R�s�[���܂��B
;;
;;      2. �K�v�Ȃ�΃o�C�g�R���p�C�����܂��B
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/clickable-uri.l
;;
;;      3. ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ��̃R�[�h��
;;         �ǉ����܂��B
;;
;;              (require "clickable-uri")
;;
;;      4. �K�v�Ȃ�΃L�[�o�C���h�ݒ�̃R�[�h��ǉ����܂��B
;;         �i���N���b�N�ɂ��Ă͕W���ŃL�[�o�C���h��ύX���܂��B�j
;;
;;              ��F
;;              (global-set-key #\C-l 'clickable-uri-recenter)
;;              (global-set-key '(#\C-c #\C-o) 'clickable-uri-open)
;;
;;      5. ��L�̐ݒ�𔽉f�����邽�߂ɁAxyzzy ���ċN�����܂��B
;;         siteinit.l �ɋL�q�����ꍇ�� Ctrl �L�[�� Shift �L�[�������Ȃ���
;;         xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;

;; Uninstallation:
;;
;;      1. clickable-uri.l �Ɋւ���L�q���폜���܂��B
;;
;;      2. siteinit.l �ɋL�q���Ă����ꍇ�� Ctrl �L�[�� Shift �L�[������
;;         �Ȃ��� xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;

;; Specification:
;;
;;  URI �̋����\���́A�o�b�t�@�ɑ΂��Đ��K�\���L�[���[�h��ݒ�A�ǉ�
;;  ���邱�Ƃōs���Ă��܂��B
;;  ���̂��߁A���K�\���L�[���[�h��ǉ�����K���ȃ^�C�~���O���Ȃ��ꍇ��
;;  �����ŋ����\���ƂȂ�܂���B�܂��A�o�b�t�@�̐��K�\���L�[���[�h��
;;  ���������ꂽ�ꍇ�� URI �����\��������������܂��B
;;
;;  ��̓I�ɂ́Aregexp-keyword-list �� *clickable-uri-regexp* ���܂܂��
;;  ����΋����\������A�܂܂�Ă��Ȃ���΋����\������܂���B
;;
;;      URI �����\���L�����^�C�~���O:
;;          �E�V�K�o�b�t�@�쐬�� (�t�@�C���I�[�v����)
;;          �E�ȉ��̂����ꂩ�̎��s��
;;                M-x clickable-uri-emphasis
;;                M-x clickable-uri-emphasis-force
;;                M-x clickable-uri-recenter
;;
;;      URI �����\���������^�C�~���O:
;;          �E�蓮�ł̊e�탂�[�h���s�� (ex. M-x lisp-mode)
;;            (�e�탂�[�h�� regexp-keyword-list ���Đݒ肳��邪�A
;;             �V�K�o�b�t�@�쐬���ł͂Ȃ��̂ŁA*find-file-hooks* ��
;;             ���s���ꂸ�A���� clickable-uri-emphasis �����s����Ȃ����߁B)
;;
;;  �܂��Axyzzy �ł͓���|�C���g����u�L�[���[�h�v�Ɓu���K�\���L�[���[�h�v
;;  ���J�n�����ꍇ�u�L�[���[�h�v���D�悳��܂��B
;;  ���̏ꍇ�AURI �͋����\������܂���B
;;

;; Setting example:
;;
;;      (require "clickable-uri")
;;      ;; �����\���́u�\���F4 (��)�v�{�A���_�[���C��
;;      (setq *clickable-uri-keyword-color* '(:color 4 0 :underline))
;;      ;; �I�[�v�����̋����\���́u�����F4(��)�v�u�A���_�[���C���v�u�{�[���h�v
;;      (setq *clickable-uri-open-attribute* '(:foreground 4 :underline t :bold t))
;;      ;; �I�[�v�����̋����\�����Ԃ� 0.2 �b
;;      (setq *clickable-uri-open-attribute-timeout* 0.2)
;;      ;; uri �\�������ƌ��Ȃ��������g��
;;      (setq *clickable-uri-chars*
;;            "-a-zA-Z0-9_/~.@?&=;+(),'$!*:#%|�O-�X�`-�y��-����-��@-����-�")
;;      ;; http: https: scheme ���I�[�v������R�}���h���w��
;;      (push '("^https?:" . "D:/utils/sleipnir/Sleipnir.exe")
;;            *clickable-uri-open-command-alist*)
;;      ;; �ݒ�ύX�𔽉f
;;      (clickable-uri-set-regexp)
;;
;;      (global-set-key #\C-l 'clickable-uri-recenter)
;;      (global-set-key '(#\C-c #\C-l) 'clickable-uri-emphasis-force)
;;      (global-set-key '(#\C-c #\C-o) 'clickable-uri-open)
;;


;; Changes:
;;
;;      Sat, 08 Oct 2005 11:57:21 +0900
;;        �Efile: �̏ꍇ���̂܂� shell-execute �ɓn���悤�ɕύX�B
;;        �E���[���A�h���X��ύX�B
;;        �E���C�Z���X����(�C��BSD���C�Z���X)���L�ځB
;;
;;      Sat, 05 Feb 2005 23:09:48 +0900
;;        �E�����R�[�h�̕ύX�ɂ�� *clickable-url-emphasis-deny-mode-list*
;;          �w��̈Ӗ����قڂȂ��Ȃ��Ă������߁A�w�莩�̂��폜�B
;;
;;      Sat, 08 Jan 2005 07:19:24 +0900
;;        �Eclickable-uri-mouse-left-press �C���B
;;          (clickable-uri-open) �����ɐ��������ꍇ�� (mouse-left-press)
;;          �������s��Ȃ��悤�ɁB
;;        �E�R�����g�C���B
;;
;;      Tue, 26 Oct 2004 00:24:56 +0900
;;        �Eclickable-uri �Ƃ��ď��������Bfile:... ���� open �\�ɁB
;;        �E�X�L�[���� typo ���C���B
;;        �E����̍��N���b�N�� URI �� open ���邩���w�肷��
;;          *clickable-uri-click-count* �ǉ��B
;;        �Eclickable-uri-emphasis-any-mode ��
;;          clickable-uri-emphasis-force �ɖ��̕ύX�B
;;        �Eclickable-uri-emphasis-threshold ��
;;          clickable-uri-emphasis �ɓ������A�폜�B
;;        �E*clickable-uri-open-command* ��p�~���A
;;          *clickable-uri-open-command-alist* ��ǉ��B
;;        �E���Ғʂ�ɓ����Ă��Ȃ����Ƃ�����A*clickable-uri-keep-focus*
;;          �̏����l�� nil �ɕύX�B
;;        �Eclickable-uri-set-regexp �ǉ�
;;        �E*clickable-uri-modify-uri-alist* �ǉ�
;;
;;      Sun, 26 Sep 2004 21:37:03 +0900
;;        �E*clickable-url-attribute* �p�~�B
;;        �E*clickable-url-selection-attribute* ��
;;          *clickable-url-open-attribute* �ɖ��̕ύX�B
;;        �E*clickable-url-selection-timeout* ��
;;          *clickable-url-open-attribute-timeout* �ɖ��̕ύX�B
;;        �Eset-text-attribute ��p���Ȃ��Ȃ������߁A
;;          *-set-attribute-* �� *-emphasis-* �ɖ��̕ύX�B
;;        �EURI �������\�����郂�[�h���w�肷��̂ł͂Ȃ��A
;;          �����\�����Ȃ����[�h���w�肷��悤�ɕύX�B
;;          ��̓I�ɂ́A*clickable-url-set-attribute-mode-list* ��p�~���A
;;          *clickable-url-emphasis-deny-mode-list* ��ǉ��B
;;          �����\�����Ȃ����[�h�̃��X�g��ݒ肷��B
;;        �E*clickable-url-threshold* �� *clickable-url-emphasis-threshold*
;;          �ɖ��̕ύX�B
;;        �Eclickable-url-emphasis-threshold ��臒l�����
;;          �t�@�C���T�C�Y�ł͂Ȃ��o�b�t�@�T�C�Y (buffer-size) ��
;;          ���ɍs���悤�ɕύX�B
;;
;;      Sat, 25 Sep 2004 09:57:23 +0900
;;        �E���{�I�ɏ���������̂͂����Ă����A�����\���� set-text-attribute
;;          �łȂ� regexp-keyword �ōs���悤�ɕύX�B
;;          keyword �ɑ΂��� color �ݒ�� *clickable-url-keyword-color* �ŁB
;;
;;      Sat, 25 Sep 2004 00:04:11 +0900
;;        �E�uxyzzy�̎g������������ʂ₵ ��܂����� ����5�v�� 528 �ł�
;;          �s��ubackground=http://xyzzy.xyzzy/... �� "background" ��
;;          ���̃_�u���N���b�N�Ńu���E�U�������オ��v�ɑΏ��B
;;
;;      Fri, 18 Jun 2004 18:43:45 +0900
;;        �E����t�@�C�����ʃp�b�P�[�W(winapi)�� *define �����V���{��
;;          foo �� winapi:foo �Ƃ��Ďw�肵�Ă���� byte-compile �ł��Ȃ�
;;          ���ɑ΂��đΉ��B
;;
;;      Sat, 12 Jun 2004 17:29:06 +0900
;;        �ENetInstaller �Ή��B
;;
;;      Mon, 20 Oct 2003 01:03:18 +0900
;;        �E�t�@�C���T�C�Y��臒l���肷��R�}���h��ǉ��B
;;          *find-file-hooks* �ł͖{�R�}���h�����s�B
;;          clickable-url-set-attribute-threshold
;;          *clickable-url-threshold*
;;        �Elong-operation �ɁB
;;        �E���s�� message �\���ǉ��B
;;
;;      Mon, 27 Jan 2003 22:36:52 +0900
;;        �E*clickable-url-open-command* �ǉ��B
;;
;;      Sat, 15 Jun 2002 12:30:32 +0900
;;        �Exyzzy �̃t�H�[�J�X���ێ�����悤�ɁB���Ă݂����肪���܂������Ȃ��B
;;
;;      Sat, 23 Feb 2002 16:37:09 +0900
;;        �Eclickable-url-open �Ń��b�Z�[�W��\������悤�ɁB
;;
;;      Sat, 23 Feb 2002 01:32:15 +0900
;;        �E�I�𕶎���̋����\����A������ text-attribute �𕜌�����悤�ɁB
;;
;;      Tue, 19 Feb 2002 21:09:33 +0900
;;        �Eclickable-url-open �����������B
;;        �E�I�𕶎�����V�F���ɓn���O�ɋ����ł���悤�ɁB
;;
;;      Fri, 25 Jan 2002 23:45:13 +0900
;;        �Ettp:// �ł������悤�ɁB
;;
;;      Thu, 24 Jan 2002 08:49:58 +0900
;;        �E�L�[�{�[�h�ɂ���������蓖�Ă���悤��
;;          clickable-url-open �Ƃ��ď����𕪗��B
;;
;;      Thu, 24 Jan 2002 04:20:41 +0900
;;        �E�Ƃ肠���������Ă݂��B
;;          ����Ȃ̂� editor �p�b�P�[�W�ɂ���Ă����̂��^��B
;;

;; Todo:
;;      �ESetting example �̏C���B
;;      �Ekeep-focus �̏����������҂����Ƃ���ɓ����Ă��Ȃ��B
;;        winapi::SetWindowPos ��p���ď����Ȃ����B
;;

;; Memo:
;;      �EUniform Resource Identifer (URI) SCHEMES [IANA �Ǘ��A����]
;;        http://www.iana.org/assignments/uri-schemes
;;      �EAddressing Schemes [RFC �ɂ�����̂̈ꗗ]
;;        http://www.w3.org/Addressing/schemes
;;

;; Licence:
;;
;;    clickable-uri �͏C��BSD���C�Z���X�Ɋ�Â��ė��p�\�ł��B
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

(provide "clickable-uri")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "foreign")
  (require "wip/winapi"))
(in-package "winapi")

(unless (fboundp 'SetFocus)
  (*define-dll-entry HWND SetFocus (HWND) "user32"))
(unless (fboundp 'ShellExecute)
  (*define-dll-entry DWORD ShellExecute (HWND LPCSTR LPCSTR LPCSTR LPCSTR INT) "shell32" "ShellExecuteA"))

(*define SW_HIDE             0)
(*define SW_SHOWNORMAL       1)
(*define SW_NORMAL           1)
(*define SW_SHOWMINIMIZED    2)
(*define SW_SHOWMAXIMIZED    3)
(*define SW_MAXIMIZE         3)
(*define SW_SHOWNOACTIVATE   4)
(*define SW_SHOW             5)
(*define SW_MINIMIZE         6)
(*define SW_SHOWMINNOACTIVE  7)
(*define SW_SHOWNA           8)
(*define SW_RESTORE          9)
(*define SW_SHOWDEFAULT      10)
(*define SW_FORCEMINIMIZE    11)
(*define SW_MAX              11)

(in-package "editor")

(export '(*clickable-uri-emphasis-threshold*
          *clickable-uri-modify-uri-alist*
          *clickable-uri-open-command-alist*
          *clickable-uri-keyword-color*
          *clickable-uri-open-attribute*
          *clickable-uri-open-attribute-timeout*
          *clickable-uri-keep-focus*
          *clickable-uri-keep-focus-timeout*
          *clickable-uri-click-count*
          *clickable-uri-scheme-list*
          *clickable-uri-chars*
          *clickable-uri-mail-address-regexp*
          *clickable-uri-special-regexp-list*
          *clickable-uri-tag*))

(export '(clickable-uri-set-regexp
          clickable-uri-emphasis-force
          clickable-uri-emphasis
          clickable-uri-recenter
          clickable-uri-mouse-left-press
          clickable-uri-open))

(defvar *clickable-uri-emphasis-threshold* t
  "clickable-uri-emphasis �̃o�b�t�@�T�C�Y���s����臒l
               nil: ���s���Ȃ�
         <integer>: �o�b�t�@�T�C�Y���l�ȉ��̏ꍇ���s����
          ��L�ȊO: ���s����")
(defvar *clickable-uri-modify-uri-alist* nil
  "uri �␳�֐��p�̘A�z���X�g�B
\(key . datum\) �̑g�œo�^����B
uri �� key �ł̔���ŕ␳�ΏۂƔF�����ꂽ�ꍇ�Auri ��
\(funcall datum uri\) �̌��ʂŒu��������B
����́Akey ��������������́A�R���p�C���ςݐ��K�\���̏ꍇ
\(string-matchp key uri\) �ŁA�֐��̏ꍇ \(funcall key uri\) �ōs���B")
(defvar *clickable-uri-open-command-alist* nil
  "uri ���� open ���s�R�}���h�ݒ�p�̘A�z���X�g�B
\(key . datum\) �̑g�œo�^����B
uri �� key �ł̔���� non-nil �ƂȂ���s�ΏۂƔF�����ꂽ�ꍇ�A
datum ��������Ȃ�� URI �������Ƃ��� datum �v���O�����Ŏ��s�A
�����łȂ���� URL �������Ƃ��� datum �� funcall ����B")

(defvar *clickable-uri-keyword-color* '(:color 4 0 :underline)
  "URI �𐳋K�\���L�[���[�h���X�g�ŕ\������ۂ� color")
(defvar *clickable-uri-open-attribute* '(:foreground 4 :underline t :bold t)
  "�I������ URI �̋����\������ (set-text-attribute �p)")
(defvar *clickable-uri-open-attribute-timeout* 0.2
  "�I������ URI �̋����\���b��
nil �I������ URI �������\�����Ȃ�")
(defvar *clickable-uri-keep-focus* nil
  "xyzzy �̃t�H�[�J�X���ێ�����")
(defvar *clickable-uri-keep-focus-timeout* 1
  "�t�H�[�J�X���ێ����邽�߂̑ҋ@�b��")
(defvar *clickable-uri-click-count* 2
  "����A���̍��N���b�N�� clickable-uri-open �����s���邩")
(defvar *clickable-uri-tag* 'clickable-uri
  "�J���Ώۂ������\������ۂ� tag")

(defvar *clickable-uri-scheme-list*
  '("http" "https" "ftp" "file" "news" "nntp" "wais" "telnet" "mailto" "gopher" "ttp")
  "scheme ������̃��X�g")
(defvar *clickable-uri-chars* "-a-zA-Z0-9_/~.@?&=;+(),'$!*:#%|"
  "skip-chars-forward, skip-chars-backward �ŗp����ƂƂ��ɁA
���K�\���̕����N���X�Ƃ��Ă����p���邽�߁A�L�q�ɂ͒��ӂ��K�v�B")
(defvar *clickable-uri-mail-address-regexp*
  "[-a-zA-Z0-9_.]+@[-a-zA-Z0-9_]+\\(?:\\.[-a-zA-Z0-9_]+\\)+"
  "E-MAIL �A�h���X���K�\��")
(defvar *clickable-uri-special-regexp-list*
  (list *clickable-uri-mail-address-regexp*)
  "�����\���p�ʐ��K�\��")
(defvar *clickable-uri-regexp* nil
  "URI�����\���p���K�\��(clickable-uri-set-regexp �Őݒ�)")

(defun clickable-uri-set-regexp (&optional (scheme-list *clickable-uri-scheme-list*)
                                           (uri-chars *clickable-uri-chars*)
                                           (special-regexp-list *clickable-uri-special-regexp-list*))
  "*clickable-uri-regexp* ��ݒ肵�A�����o�b�t�@�̐ݒ���X�V����"
  (let ((old-regexp *clickable-uri-regexp*) scheme-regexp uri-regexp)
    ;; �V�K *clickable-uri-regexp* �̐���
    (setq scheme-regexp
          (concat "\\("
                  (substring (format nil "~{\\|~A~}" (mapcar #'regexp-quote scheme-list)) 2)
                  "\\):"))
    (setq uri-regexp (concat scheme-regexp "[" uri-chars "]+"))
    (setq *clickable-uri-regexp*
          (compile-regexp
           (concat "\\("
                   (substring
                    (format nil "~{\\|\\(?:~A\\)~}"
                            (append (list uri-regexp) special-regexp-list)) 2)
                   "\\)") t))
    ;; �f�t�H���g�ݒ�̍X�V
    (when (and (boundp 'regexp-keyword-list)
               (find old-regexp (default-value 'regexp-keyword-list)
                     :test #'clickable-uri-regexp-equal :key #'car))
      (setq-default regexp-keyword-list
                    (delete old-regexp (default-value 'regexp-keyword-list)
                            :test #'clickable-uri-regexp-equal :key #'car))
      (clickable-uri-emphasis-default))
    ;; �o�b�t�@�ʐݒ�̍X�V
    (save-excursion
      (dolist (buffer (buffer-list))
        (set-buffer buffer)
        (when (and (local-variable-p 'regexp-keyword-list)
                   (find old-regexp regexp-keyword-list
                         :test #'clickable-uri-regexp-equal :key #'car))
          (setq regexp-keyword-list
                (delete old-regexp regexp-keyword-list
                        :test #'clickable-uri-regexp-equal :key #'car))
          (clickable-uri-emphasis-force))))))

(defun clickable-uri-regexp-equal (regexp1 regexp2 &key regexp1-case-fold-p regexp2-case-fold-p)
  "���K�\����������������"
  (let (regexp1-source-regexp regexp2-source-regexp)
    (if (regexpp regexp1)
        (setq regexp1-source-regexp (compiled-regexp-source regexp1)
              regexp1-case-fold-p (compiled-regexp-case-fold-p regexp1))
      (setq regexp1-source-regexp regexp1))
    (if (regexpp regexp2)
        (setq regexp2-source-regexp (compiled-regexp-source regexp2)
              regexp2-case-fold-p (compiled-regexp-case-fold-p regexp2))
      (setq regexp2-source-regexp regexp2))
    (and (string= regexp1-source-regexp regexp2-source-regexp)
         (eq regexp1-case-fold-p regexp2-case-fold-p))))

(defun clickable-uri-emphasis-force (&optional buffer)
  "URI �����\����ݒ�(������)"
  (interactive)
  (save-excursion
    (when (and (bufferp buffer) (not (eq buffer (selected-buffer))))
      (set-buffer buffer))
    (when (and (boundp 'regexp-keyword-list)
               (find *clickable-uri-regexp* regexp-keyword-list
                     :test #'clickable-uri-regexp-equal :key #'car))
      (return-from clickable-uri-emphasis-force nil))
    (let ((clickable-uri-regexp-keyword-list
           (compile-regexp-keyword-list
            `((,*clickable-uri-regexp* t ,*clickable-uri-keyword-color* t)))))
      (make-local-variable 'regexp-keyword-list)
      (setq regexp-keyword-list
            (if (boundp 'regexp-keyword-list)
                (append regexp-keyword-list clickable-uri-regexp-keyword-list)
              clickable-uri-regexp-keyword-list)))))

(defun clickable-uri-emphasis (&optional buffer)
  "URI �����\����ݒ�"
  (interactive)
  (if (and *clickable-uri-emphasis-threshold*
           (or (not (integerp *clickable-uri-emphasis-threshold*))
               (<= (buffer-size buffer) *clickable-uri-emphasis-threshold*)))
      (progn
        (clickable-uri-emphasis-force buffer)
        t)
    (progn
      (when (interactive-p)
        (message "clickable-uri: skip"))
      nil)))

(defun clickable-uri-emphasis-default ()
  "URI �����\�����f�t�H���g�Ƃ��Đݒ�"
  (let ((clickable-uri-regexp-keyword-list
         (compile-regexp-keyword-list
          `((,*clickable-uri-regexp* t ,*clickable-uri-keyword-color* t)))))
    (setq-default regexp-keyword-list
                  (if (boundp 'regexp-keyword-list)
                      (append regexp-keyword-list clickable-uri-regexp-keyword-list)
                    clickable-uri-regexp-keyword-list))))

(defun clickable-uri-open ()
  "URI �ɑΉ����鏈�������s
�߂�l�F
  t    �Ώ�URI������A���������s
  nil  �Ώ�URI���Ȃ��A������s���s"
  (interactive)
  (let ((opoint (point)) epoint text-attribute-list
        uri from to modify-func command)
    (save-excursion
      (skip-chars-forward *clickable-uri-chars*)
      (setq epoint (point))
      (when (and (skip-chars-backward *clickable-uri-chars*)
                 (scan-buffer *clickable-uri-regexp* :regexp t :case-fold t :limit epoint)
                 (<= (point) opoint)
                 (< opoint epoint))
        (setq uri (match-string 0) from (match-beginning 0) to (match-end 0))))
    (unless uri
      (save-excursion
        (when (and (scan-buffer *clickable-uri-regexp* :regexp t :case-fold t :reverse t
                                :limit (save-excursion (goto-bol) (point)))
                   (<= (match-beginning 0) opoint)
                   (< opoint (match-end 0)))
          (setq uri (match-string 0) from (match-beginning 0) to (match-end 0)))))
    ;; URI ����ł��Ȃ����ߏI��
    (unless uri
      (when (interactive-p)
        (message "�J���ׂ� URI ��������܂���"))
      (return-from clickable-uri-open nil))
    ;; �J���Ώۂ� URI �������\��
    (when (and (numberp *clickable-uri-open-attribute-timeout*)
               (plusp *clickable-uri-open-attribute-timeout*))
      (setq text-attribute-list (list-text-attributes from to))
      (apply #'set-text-attribute (append (list from to *clickable-uri-tag*)
                                          *clickable-uri-open-attribute*))
      (goto-char opoint)
      (sit-for *clickable-uri-open-attribute-timeout*)
      (delete-text-attribute-point from)
      (dolist (text-attribute text-attribute-list)
        (apply #'set-text-attribute text-attribute)))
    ;; URI �␳
    (when (setq modify-func
                (cdr (find uri *clickable-uri-modify-uri-alist*
                           :key #'car
                           :test #'(lambda (uri checker)
                                     (or (and (or (regexpp checker) (stringp checker))
                                              (string-matchp checker uri))
                                         (and (functionp checker) (funcall checker uri)))))))
      (setq uri (funcall modify-func uri)))
    (message "~A" uri)
    ;; URI �Ή��������s
    (if (setq command
              (cdr (find uri *clickable-uri-open-command-alist*
                         :key #'car
                         :test #'(lambda (uri checker)
                                   (or (and (or (regexpp checker) (stringp checker))
                                            (string-matchp checker uri))
                                       (and (functionp checker) (funcall checker uri)))))))
        (if (stringp command)
            (shell-execute (map-slash-to-backslash command) t uri)
          (funcall command uri))
      (clickable-uri-shell-execute uri t nil winapi::SW_SHOWNOACTIVATE))
    ;; xyzzy ��Ƀt�H�[�J�X���c�����߂̋���̍�
    (when *clickable-uri-keep-focus*
      (sit-for *clickable-uri-keep-focus-timeout*)
      (clickable-uri-focus-editor)))
  t)

(defun clickable-uri-recenter (&optional arg)
  "recenter �ƂƂ��ɁAURI �����\����ݒ�"
  (interactive "p")
  (recenter arg)
  (clickable-uri-emphasis))

(defun clickable-uri-mouse-left-press ()
  "URI �N���b�N�Ή��ō��N���b�N"
  (interactive)
  (let ((click (mod *last-mouse-click-count* 6)))
    (unless (and (integerp *clickable-uri-click-count*)
                 (= click *clickable-uri-click-count*)
                 (clickable-uri-open))
      (mouse-left-press))))

(defun clickable-uri-focus-editor ()
  (interactive)
  (winapi::SetFocus (get-window-handle)))

(defun clickable-uri-shell-execute (uri &optional directory param (showcmd winapi::SW_SHOWNORMAL))
  (if (eq directory t)
      (progn
        (setq directory 0)
        (setq uri (si:make-string-chunk uri)))
    (progn
      (if (stringp directory)
          (setq directory (si:make-string-chunk (map-slash-to-backslash directory)))
        (setq directory (si:make-string-chunk (map-slash-to-backslash (directory-namestring uri)))))
      (setq uri (si:make-string-chunk (map-slash-to-backslash uri)))))
  (if (stringp param)
      (setq param (si:make-string-chunk param))
    (setq param 0))
  (winapi::ShellExecute (get-window-handle) (si:make-string-chunk "open")
                        uri param directory showcmd))

;; URI �␳�p
(defun clickable-uri-uri-mail-address-p (uri)
  (and (stringp *clickable-uri-mail-address-regexp*)
       (string-matchp (concat "^" *clickable-uri-mail-address-regexp* "$") uri)))

;; URI �I�[�v���p
(defun clickable-uri-filer-open-p ()
  (handler-case
      (progn (filer-reload) t)
    (error (c) nil)))
(defun clickable-uri-find-file (path)
  (if (file-exist-p path)
      (progn
        (if (file-directory-p path)
            (progn
              (unless (clickable-uri-filer-open-p)
                (filer nil t nil t (not *filer-modal*)))
              (filer-chdir path t)
              (filer-focus))
          (find-file path))
        t)
    (progn
      (message "~A �����݂��܂���B" path)
      nil)))

;; �����l�ݒ�
(clickable-uri-set-regexp)
(unless *clickable-uri-modify-uri-alist*
  (setq *clickable-uri-modify-uri-alist*
        (list (cons #'clickable-uri-uri-mail-address-p
                    #'(lambda (uri) (concat "mailto:" uri)))
              (cons "^ttp:"
                    #'(lambda (uri) (concat "h" uri))))))

;(push (cons "^file:"
;            #'(lambda (uri)
;                (string-matchp "^file:\\(///\\)?\\(.+\\)" uri)
;                (clickable-uri-find-file
;                 (si:www-url-decode (match-string 2)))))
;      *clickable-uri-open-command-alist*)

(push (cons "^file:" #'(lambda (uri) (shell-execute uri)))
      *clickable-uri-open-command-alist*)


;; �N��������
(clickable-uri-emphasis-default)
(add-hook '*find-file-hooks* 'clickable-uri-emphasis)

(global-set-key #\LBtnDown 'clickable-uri-mouse-left-press)

;;; clickable-uri.l ends here