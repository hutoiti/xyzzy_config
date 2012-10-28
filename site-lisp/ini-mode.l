;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; ini-mode.l

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Version: 0.0.0.4
;; Time-stamp: <2005/10/08 14:22:05 +0900>

;;; Commentary:

;; Description:
;;
;;  INI�t�@�C���ҏW���[�h
;;

;; Installation:
;;
;;      1. �A�[�J�C�u��W�J���� ini-mode.l �� $XYZZY/site-lisp ��
;;         �R�s�[���܂��B
;;
;;      2. �o�C�g�R���p�C�����܂��B
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/ini-mode.l
;;
;;      3. *.ini ��ǂ݂��񂾂Ƃ��Ɏ����I�� ini-mode ��
;;         ���邽�߂ɁA�ȉ��̃R�[�h��ǉ����܂��B
;;
;;         �� .xyzzy�ɒǉ�����ꍇ
;;              (export 'ed::ini-mode "ed")
;;              (autoload 'ini-mode "ini-mode" t)
;;              (pushnew '("\\.ini$" . ini-mode) *auto-mode-alist* :test 'equal)
;;
;;         �� siteinit.l�ɒǉ�����ꍇ
;;              (in-package "editor")
;;              (export 'ini-mode)
;;              (autoload 'ini-mode "ini-mode" t)
;;              (pushnew '("\\.ini$" . ini-mode) *auto-mode-alist* :test 'equal)
;;              (in-package "user")
;;
;;      4. ��L�̐ݒ�𔽉f�����邽�߂ɁAxyzzy ���ċN�����܂��B
;;         siteinit.l �ɋL�q�����ꍇ�� Ctrl �L�[�� Shift �L�[�������Ȃ���
;;         xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;

;; Uninstallation:
;;
;;      1. ini-mode.l �Ɋւ���L�q���폜���܂��B
;;
;;      2. siteinit.l �ɋL�q���Ă����ꍇ�� Ctrl �L�[�� Shift �L�[������
;;         �Ȃ��� xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;

;; Key bind:
;;
;;      C-c C-c ���[�W�������R�����g��
;;      C-;     ���ݍs�̃R�����g���g�O��
;;      C-#     �R�����g�J�n�����̕ύX
;;      M-;     indent-for-comment
;;

;; Customize:
;;
;;      1. �F�̕ύX
;;
;;              (setq ed::*ini-section-parenthesis-face* '(:keyword 0))
;;              (setq ed::*ini-section-face* '(:keyword 1 :underline))
;;              (setq ed::*ini-variable-face* '(:keyword 2))
;;              (setq ed::*ini-equal-face* '(:keyword 0))
;;              (setq ed::*ini-value-face* '(:color 0 0))
;;              (setq ed::*ini-simple-value-face* ed::*ini-value-face*)
;;

;; Changes:
;;
;;      [Version 0.0.0.4]
;;      Sat, 08 Oct 2005 14:21:20 +0900
;;        �E���[���A�h���X��ύX�B
;;        �E���C�Z���X����(�C��BSD���C�Z���X)���L�ځB
;;
;;      [Version 0.0.0.3]
;;      Sat, 12 Jun 2004 15:49:59 +0900
;;        �ENetInstaller �Ή�
;;
;;      [Version 0.0.0.2]
;;      Thu, 10 Jan 2002 18:55:29 +0900
;;        �E# ���R�����g�J�n������ INI �t�@�C�����������̂�
;;          �R�����g�J�n������ύX�ł���悤�ɂ����B
;;        �E���̑��B
;;
;;      [Version 0.0.0.1]
;;      Wed, 05 Sep 2001 18:21:57 +0900
;;        �E�Ƃ肠�������ł������Ă݂��B
;;

;; Licence:
;;
;;    ini-mode �͏C��BSD���C�Z���X�Ɋ�Â��ė��p�\�ł��B
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

(provide "ini-mode")

(in-package "editor")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (export '(*ini-mode-hook*
            *ini-mode-map*
            *ini-version*
            *ini-regexp-keyword-list*
            *ini-keyword-file*
            *ini-comment-column*
            *ini-section-parenthesis-face*
            *ini-section-face*
            *ini-variable-face*
            *ini-equal-face*
            *ini-value-face*
            *ini-simple-value-face*)))
(eval-when (:compile-toplevel :load-toplevel :execute)
  (export '(ini-mode
            ini-comment-region
            ini-comment-toggle-line
            ini-change-comment-char)))

(defconstant *ini-version* "0.0.0.4"
  "ini-mode: Version")

(defvar *ini-section-parenthesis-face* '(:keyword 0))
(defvar *ini-section-face* '(:keyword 1))
(defvar *ini-variable-face* '(:keyword 2))
(defvar *ini-equal-face* '(:keyword 0))
(defvar *ini-value-face* '(:color 0 0))
(defvar *ini-simple-value-face* *ini-value-face*)

(defvar *ini-mode-hook* nil
  "ini-mode: ���[�h�t�b�N")
(defvar *ini-comment-column* 0
  "ini-mode: �R�����g�J�n��")
(defvar *ini-keyword-file* "INI"
  "ini-mode: �L�[���[�h�t�@�C��")
(defvar *ini-keyword-hash-table* nil
  "ini-mode: �L�[���[�h�n�b�V���e�[�u��")
(defvar-local *ini-comment-char* #\;
  "ini-mode: �R�����g�J�n����")

(defvar *ini-mode-map* nil
  "ini-mode: Local keymap")
(unless *ini-mode-map*
  (setq *ini-mode-map* (make-sparse-keymap))
  (define-key *ini-mode-map* '(#\C-c #\C-c) 'ini-comment-region)
  (define-key *ini-mode-map* #\C-\;         'ini-comment-toggle-line)
  (define-key *ini-mode-map* #\C-\#         'ini-change-comment-char))

(defvar *ini-regexp-keyword-list*
  (compile-regexp-keyword-list
   `(("^\\[\\(.*\\)\\]" nil
      ((0 . ,*ini-section-parenthesis-face*) (1 . ,*ini-section-face*)))
     ("^\\([^=\n]*\\)\\(=\\)\\(\\S<*?\\)\n" nil
      ((1 . ,*ini-variable-face*) (2 . ,*ini-equal-face*) (3 . ,*ini-value-face*)))
     ("^\\([^=\n]*\\)\\(=\\)\\(\\S<*\\)" nil
      ((1 . ,*ini-variable-face*) (2 . ,*ini-equal-face*) (3 . ,*ini-value-face*)))
     ("^\\(\\S<*?\\)\n" nil ((1 . ,*ini-simple-value-face*)))
     ("^\\(\\S<*\\)" nil ((1 . ,*ini-simple-value-face*)))))
  "ini-mode: ���K�\���L�[���[�h���X�g")

(defvar *ini-mode-syntax-table* nil
  "ini-mode: Syntax table")
(unless *ini-mode-syntax-table*
  (setq *ini-mode-syntax-table* (make-syntax-table))
  (set-syntax-start-comment *ini-mode-syntax-table* #\; nil)
  (set-syntax-end-comment *ini-mode-syntax-table* #\LFD nil t))

(defun ini-mode ()
  "A major mode to edit ini setting files."
  (interactive)
  (kill-all-local-variables)
  (setq buffer-mode 'ini-mode)
  (setq mode-name "Ini")
  (use-keymap *ini-mode-map*)
  (and *ini-keyword-file*
       (null *ini-keyword-hash-table*)
       (setq *ini-keyword-hash-table*
             (load-keyword-file *ini-keyword-file* t)))
  (when *ini-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *ini-keyword-hash-table*))
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *ini-regexp-keyword-list*)
  (ini-set-comment-char *ini-comment-char*)
  (setq comment-start-skip "\\s<+[ \t]*")
  (setq comment-end "")
  (setq comment-indent-function 'ini-comment-indent)
  (when *ini-comment-column*
    (setq comment-column *ini-comment-column*))
  (run-hooks '*ini-mode-hook*))

(defun ini-change-comment-char ()
  "ini-mode: �R�����g�J�n�����̕ύX"
  (interactive)
  (let (input)
    (setq input (read-string (format nil "Comment Character (~S): " *ini-comment-char*)))
    (if (plusp (length input))
        (ini-set-comment-char (char input 0)))))

(defun ini-set-comment-char (c)
  "ini-mode: �R�����g�J�n�����Ɋւ���ݒ�"
  (unless (and (characterp c) (syntax-punctuation-p c))
    (message "No punctuation syntax")
    (return-from ini-set-comment-char nil))
  (let ((str (make-vector 1 :element-type 'character :initial-element c)))
    (setq comment-start (concat str " "))
    (when *ini-mode-syntax-table*
      (set-syntax-punctuation *ini-mode-syntax-table* *ini-comment-char*)
      (set-syntax-start-comment *ini-mode-syntax-table* c)
      (use-syntax-table *ini-mode-syntax-table*))
    (setq *ini-comment-char* c)))

(defun ini-comment-region (&optional from to)
  "ini-mode: ���[�W�������R�����g"
  (interactive "*r")
  (if (> from to) (rotatef from to))
  (save-excursion
    (save-restriction
      (narrow-to-region from to)
      (goto-char (point-min))
      (while (< (point) (point-max))
        (insert comment-start)
        (goto-eol)
        (insert comment-end)
        (forward-char)))))

(defun ini-comment-toggle-line ()
  "ini-mode: �s�̃R�����g���g�O��"
  (interactive "*")
  (let ((obolp (bolp)))
    (save-excursion
      (goto-bol)
      (if (looking-at "^\\s *\\s<+ ?")
          (delete-region (match-beginning 0) (match-end 0))
        (insert comment-start)))
    (if obolp (forward-char (length comment-start)))))

(defun ini-comment-indent ()
  "ini-mode: indent-for-comment �p function"
  (if (and (bolp) (not (eolp)))
      0
    (save-excursion
      (skip-chars-backward " \t")
      (max (if (bolp)
               0
             (1+ (current-column)))
           comment-column))))

;;; ini-mode.l ends here