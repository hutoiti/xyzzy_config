;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; keep-window-line.l --- �E�B���h�E�s���Œ肷��}�C�i�[���[�h

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 14:30:16 +0900>

;;; Commentary:

;; Description:
;;
;;  �E�B���h�E�s���Œ肷��}�C�i�[���[�h�ł��B
;;
;;  �E�B���h�E���X�N���[�����Ă��A�J�[�\���s�̕\���ʒu��ύX�������Ȃ�
;;  �ꍇ�Ɏg�p���܂��B
;;

;; Installation:
;;
;;      1. �A�[�J�C�u��W�J���� keep-window-line.l �� $XYZZY/site-lisp ��
;;         �R�s�[���܂��B
;;
;;      2. �o�C�g�R���p�C�����܂��B
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/keep-window-line.l
;;
;;      3. ~/.xyzzy �܂��� $XYZZY/site-lisp/siteinit.l �Ɉȉ��̃R�[�h��
;;         �ǉ����܂��B
;;
;;              (require "keep-window-line")
;;
;;      4. ��L�̐ݒ�𔽉f�����邽�߂ɁAxyzzy ���ċN�����܂��B
;;         siteinit.l �ɋL�q�����ꍇ�� Ctrl �L�[�� Shift �L�[�������Ȃ���
;;         xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;

;; Uninstallation:
;;
;;      1. keep-window-line.l �Ɋւ���L�q���폜���܂��B
;;
;;      2. siteinit.l �ɋL�q���Ă����ꍇ�� Ctrl �L�[�� Shift �L�[������
;;         �Ȃ��� xyzzy ���ċN�����A�_���v�t�@�C�����č\�z���܂��B
;;

;; Usage:
;;
;;      M-x keep-window-line-mode
;;

;; Setting example:
;;
;;      (require "keep-window-line")
;;

;; Changes:
;;
;;      Sat, 08 Oct 2005 14:28:49 +0900
;;        �E���[���A�h���X��ύX�B
;;        �E���C�Z���X����(�C��BSD���C�Z���X)���L�ځB
;;
;;      Mon, 14 Feb 2005 20:54:11 +0900
;;        �Edefvar-local �ϐ��̃V���{�����O�ォ�� * �����O�B
;;        �Eminor-mode ���B
;;
;;      Sun, 23 Feb 2003 18:56:24 +0900
;;        �E���ō쐬�B
;;

;; Licence:
;;
;;    keep-window-line �͏C��BSD���C�Z���X�Ɋ�Â��ė��p�\�ł��B
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

(provide "keep-window-line")

(in-package "editor")

(export '(keep-window-line-mode))

(defvar-local keep-window-line-mode nil)
(defvar-local keep-window-line nil)

(defun keep-window-line ()
  "Keep window line."
  (when (and keep-window-line-mode
             (integerp keep-window-line)
             (/= keep-window-line (get-window-line)))
    (let ((goal (goal-column)))
      (recenter keep-window-line)
      (set-goal-column goal))))

(defun keep-window-line-mode (&optional (arg nil sv))
  "�E�B���h�E�s���Œ肷��}�C�i�[���[�h"
  (interactive "p")
  (toggle-mode 'keep-window-line-mode arg sv)
  (update-mode-line t)
  (if keep-window-line-mode
      (progn
        (setq keep-window-line (get-window-line))
        (add-hook '*post-command-hook* 'keep-window-line))
    (progn
      (setq keep-window-line nil)
      (dolist (buffer (buffer-list) (delete-hook '*post-command-hook* 'keep-window-line))
        (when (buffer-local-value buffer 'keep-window-line-mode)
          (return)))))
  t)
(pushnew '(keep-window-line-mode . "KWLine") *minor-mode-alist* :key #'car)

;;; keep-window-line.l ends here